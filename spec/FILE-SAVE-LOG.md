# File Save Log Specification (scoped v1)

Version: 0.1.3
Module: File Save Log. It fills the Recent File Saves panel with the files the user actually saved, so they can find recent work from the board.

Read section 6 first. This is the kit's most fragile module, by design honestly labelled, and it is the last thing installed.

## 1. Scope

- One main computer (the user's). Multi-computer merging is not in this version.
- Folders: the ones the user chose in the module interview (typical: Documents, Downloads, Desktop, and the user's Muse workspace). Nothing outside the chosen folders is watched.
- Panel output: the 40 most recent saves after exclusions (section 3) and hides (section 4), newest first.

## 2. Components

a) Scanner, on the user's computer: a small script, set up with the user's explicit approval, that records file saves in the watched folders (file name, full path, folder, save time, whether the file is new or updated) into a local log file. It must be set up so it restarts with the computer, and the setup must verify that it is actually running after setup, not merely installed. On Windows it must also run completely windowless (section 2c); a scanner window appearing every 15 minutes is a setup failure, not a cosmetic issue. It records metadata only and must never open, read, hash, or copy a watched file: reading a cloud placeholder file (a OneDrive or Drive file that is not downloaded yet) would force that file to download, so content access is forbidden by design, not merely unnecessary.

b) Aggregator, a scheduled job in the user's Muse every 15 minutes, which:
1. Reads new scanner log entries since the last run (keep a watermark; never re-read the whole history).
2. Detects panel deletions since the last run and records them as hides (section 4), before building the new panel list.
3. Applies exclusions (section 3) and hides, in that order, before taking the top panelSize entries (the panel-size setting, default 40).
4. Syncs the Recent File Saves panel to the result: add new entries, remove entries that rolled off or were hidden, change nothing else on the board.
5. Appends everything (including excluded entries) to the master log, and refreshes the full-log file in the location the user chose (their Drive, or a local file).
6. Records the panel state seen at the end of the cycle, for the next cycle's deletion detection.

c) Panel entry format: title is the file name. Detail line: location label (the watched folder's short name), status (New or Updated), last saved time. Notes carry three lines: Date (YYYY-MM-DD), Folder (full path of the containing folder), Full path. The hide key is "<date>|<full path>". The pinned full-log entry (section 4, last paragraph) is separate.

## 2b. Pre-install diagnostic

Setup for this module begins before anything is installed, with the diagnostic the kit ships at preinstall/Check-FileSaveLogRequirements.ps1 (see INSTALL.md step 5 for how the user runs it). Design points that matter:

- It runs on the Windows PowerShell that ships with Windows (5.1) on purpose, because PowerShell 7 is one of the requirements it checks; a diagnostic that needed PowerShell 7 could not run on the machines that most need it.
- It checks the machine-side minimum requirements live, not from settings: Windows version and build (including whether the Windows 11 headless fallback exists), an interactive logged-on session, PowerShell 7 presence, version, and its real resolved path on that machine, script host present and not policy disabled plus the live windowless test in section 2c's pattern, the Task Scheduler service plus a real create, read back, and delete task test under the user's own account, read and write access on the watched folders and the log destination, and which cloud folders and sync apps are visible from that session.
- It is check-only and self-cleaning: its only writes are small test files it deletes in the same run, the temporary test task, and its report file. It installs nothing and changes no setting.
- Its output is a dated plain text report the user pastes to their Muse. Setup consumes the report: its verdict gates installation (any FAIL is fixed and the diagnostic rerun, or the module is parked, before anything is installed), and its measured paths and versions are the ones setup uses.
- A passing report is evidence about that machine, on that day, in that session. Like every verification in this kit, it does not transfer to another machine or another user.

## 2c. Windowless launch on Windows (scanner)

The scanner runs every 15 minutes on a machine the user is actively working at. Any window it shows, even a brief one, is disruptive; a window that lingers for the length of a scan is unacceptable. Set the launch up windowless from the start:

- Do NOT create the scheduled task action as a direct PowerShell launch. A flag such as -WindowStyle Hidden is not sufficient: Windows creates the console window first and PowerShell applies the flag afterward, so there is always at least a flash, and the flag can be ignored entirely (observed after a PowerShell update, when the scan window stayed fully open for the whole run).
- Instead, the task action runs a tiny VBScript wrapper through wscript.exe. wscript.exe has no console window of its own, and the wrapper starts the scanner process with window style 0 (hidden from the moment the process is created), waits for it to finish, and returns its exit code, so Task Scheduler still tracks start, end, result, and the run time limit exactly as it would for a direct launch. The wrapper changes only how the scanner is launched: not the scanner script, not the triggers, not the task settings. Reverting is restoring the direct action.
- Fallback, if VBScript is blocked on the machine: launch through conhost.exe --headless (Windows 11).
- The task's own "Hidden" checkbox in Task Scheduler is not a substitute; it hides the task in the Task Scheduler list, not its window.
- Never fix window visibility by switching the task to "run whether the user is logged on or not". That runs outside the user's desktop session, where mapped cloud drives (for example a Drive letter for cloud storage, or a synced OneDrive) may not be mounted, so scanner output can silently stop landing where the aggregator reads it. An invisible failure is worse than a visible window.
- Verification: windowless counts as working only when the user confirms a scheduled cycle ran with no window seen at all. Do not claim it from the task settings alone (same honesty rule as section 5: verify from the cycle, not from configuration).

## 3. Exclusions and panel-only rules (the layers)

What a save hits, in order (the full layer table is Section 3c):

- **Complete exclusions** (never in the panel, the master log, or the CSV): the config-driven rules of Section 3b. The shipped defaults cover machine output only: temporary and partial downloads (.tmp, .temp, .crdownload, .partial, .part), application sidecars and locks (.log, .swp, .swo, .pyc, .etl, .asd, .wbk, .lock, -wal, -shm, -journal), housekeeping names (desktop.ini, Thumbs.db, .DS_Store, ~$*, ~WRL*.tmp, LibreOffice locks), generated build files (next-env.d.ts, *.tsbuildinfo), and tool and system folders (.git, node_modules, __pycache__, virtualenvs, .cache, editor folders, recycle and trash folders, Drive transfer temp folders). Optional groups ship disabled (.bak files, build folders, Snagit .snagx captures, screenshot folders, and an example generated-output pair); a user enables them in their own file.
- **Panel-only rules** (kept in the master log and CSV, never on the panel): the patterns live in the `panelOnly` block of the same two config files (Section 3b), never in code. The shipped defaults carry only Temp and tmp folder segments. Everything user-specific belongs in the user's own file: their staging folders, handover-file name patterns, shortcut files (.lnk) if they choose, and path prefixes for whole trees they work in but do not want on the panel (for example their development folder).
- **Behaviors, in code only**: Dismiss, Hide this file always, and the link test (Section 4) are behaviors, not patterns; they live in the board and aggregator code and have no config entries.
- The user's own automation working folders are a per-user config entry at setup (for example the output, logs, and attachments folders of a scheduled search tool they run, as segment pairs, plus its state file names). Per-user, never a shipped default.
- Matching discipline: file-name, suffix, folder-segment, adjacent segment-pair, and path-prefix matches, all case-insensitive, never a substring search over the whole path.

Deliberately NOT excluded by the shipped defaults. These were considered and rejected; do not add them as defaults, and flag it if a setup conversation drifts toward them, because they hide real work:

- Screenshot and screen-capture files as a class (a user may still enable the optional screenshot or .snagx groups for their own setup)
- Same-day duplicates of the same file in two locations (no dedupe by name or day)
- Project instruction files (for example CLAUDE.md)
- Folders named Templates, and files with "Temporary" in their name (substring lookalikes are not matches)
- Photos, anything in Downloads, and Save-As versions of a document

The user may add exclusions of their own beyond the defaults by asking; whoever applies the change restates its effect first (complete versus panel-only) before applying it.

## 3b. Exclusions are config-driven (one design, two files)

- The scanner and the aggregator read the SAME two JSON files, so they can never drift apart. `FileSaveLog-Excludes.json` ships with the kit and is replaced on every kit update; it holds the shipped defaults and a block of optional rule groups that ship disabled. `FileSaveLog-Excludes.user.json` holds the user's own rules and is never overwritten; the installer creates it from `FileSaveLog-Excludes.user.template.json` and fills its `selfPaths` with the user's own scanner, batch, state, and ingest folders (the feedback-loop guard).
- Schema: `extensions` (a name ending in the entry; dot entries match the extension, suffix entries like `-wal` match the name ending), `fileNames` (wildcards allowed), `folderSegments` (one path segment anywhere), `segmentPairs` ([parent, child], the child folder directly under the parent, so unrelated folders named cache or Output are untouched), `selfPaths`, and `enableOptional` in the user file to switch on shipped optional groups (for example Snagit .snagx captures, screenshot folders, build folders, .bak files).
- The kit ships the shared loader (`filesave-log/excludes.py`, used by the aggregator and the scanners) and the explain command (`filesave-log/explain.py`, see Section 4) with the module.
- A `panelOnly` block in the same two files carries the record-only rules, with the same rule types plus `pathPrefixes` (absolute path prefixes). The shipped defaults carry only generic entries (Temp and tmp folder segments); a user's private entries (their staging folders, their dev-tree prefixes) belong only in their user file. The scanner ignores the panelOnly block; only the aggregator and the panel apply it.
- All matching is case-insensitive. The Section 3 lists above describe rule CONTENT; this section is the mechanism, and the shipped defaults file is where the current content lives.
- Fail-safe: if a config file is missing or invalid, the scanner and the aggregator fall back to a small built-in minimal set (transient downloads and lock artifacts only), write a visible warning to the scanner's log, and keep running. A bad config never crashes the scan and never excludes everything.
- Personal rules (a user's own tool-output folders, private segment pairs) belong only in the user file, never in the shipped defaults.
- Two numbers are settings, not constants: `panelSize` (saves shown in the panel, default 40, valid 10 to 200) and `retentionMonths` (months kept in the master log, default 12, valid 1 to 60). They ship in the defaults file's `settings` object; the user file may override either key. An invalid value (out of range, not a whole number, wrong type) falls back with a logged warning: an invalid user value to the defaults value, an invalid defaults value to the built-in 40 and 12. With no override anywhere, behavior is exactly the shipped defaults.
- Lowering retentionMonths takes effect on the aggregator's next run: entries older than the new window are archived and removed from the working log at that point. Raising it again later does not pull archived entries back.

## 3c. The layers at a glance

| Layer | Where defined | Panel | Master log and CSV | Who can change it |
|---|---|---|---|---|---|
| Complete exclusions | Config files (defaults + user), applied by the aggregator and the scanners | Never shown | Never kept | Kit update (defaults) or the user (their user file) |
| Panel-only rules (panelOnly) | Config files' `panelOnly` block, applied by the aggregator | Never shown | Kept | Kit update (generic defaults) or the user (their entries) |
| Link test | Aggregator code | Shown only if the path makes a working link (Windows drive, UNC, macOS user paths) | Kept | Kit code |
| Dismiss (one save) | Board state, set from the panel | That save hidden; a newer save of the file returns | Kept | The user, in the panel (restorable) |
| Hide this file always | Board state, set from the panel | File never shown until restored | Kept | The user, in the panel (restorable) |
| Extension filter and Show x | Board state, set from the panel | Narrows what is displayed; rows are still on the board | Kept | The user, in the panel (Reset filters clears) |
| Retention window | Config setting `retentionMonths` | Rows older than the window are gone | Archived by year, then removed | The user (config), with the archiving safeguard |

## 4. Panel delete: Dismiss and Hide always

- Deleting a panel row offers two actions. **Dismiss** (the default) hides only that save event: the row's day entry is suppressed, and a newer save of the same file shows again. **Hide this file always** mutes the path: no save of that file ever shows until it is restored.
- Both lists live in the board's own durable state. A **Hidden items** view lists dismissals and always-hidden files together, each with a **Restore** action; restoring a dismissal brings that save back, restoring an always-hide lets the file's rows show again.
- Pre-split permanent hides (from the earlier delete model, keyed "<date>|<full path>") migrate to Hide-always entries for their paths, so nothing already hidden reappears when the split model ships.
- Detection by absence is retired: a row missing from the displayed list is never, by itself, treated as a deletion. The aggregator no longer guesses hides from panel snapshots.
- Post-edit caution: after any automated edit to a store the user also edits (these hide lists, the panel, the master log), a missing record is not automatically data loss. Confirm it was not an intentional deletion by the user before restoring anything. This is the same check OPERATING-RULES.md rule 14 states generally.
- The pinned entry, titled "File Save Log, full log", linking to the full-log file, always sits at the top of the panel above the saves and never counts toward them. It carries no Date or Full path notes, and the aggregator re-adds it if it is removed.
- A "Why isn't this file shown?" control on the panel answers from the board's own state (Dismiss, Hide always, filtered out, beyond the shown count). For the exact config rule behind a complete exclusion or a panel-only rule, the user can ask Muse "why isn't <path> shown?" and Muse runs the kit's checker against the config, or the user can run it themselves if they have Python 3: `python3 explain.py "<full path>"` in the filesave-log folder (it uses the same loader as the aggregator and reads the two config files beside it). The panel dialog gives both options.

## 4c. Panel filters

- The panel receives **all** panel-eligible rows in the retention window (not just the top panelSize), so filtering is honest. Rows arrive newest first.
- **Only show** filter: one checkbox per extension present among the panel-eligible rows (after exclusions, panel-only rules, the link test, dismissals, and always-hides), with a count per extension, grouped case-insensitively, plus a "(no extension)" entry, Select all, and Clear. The board stores the UNCHECKED set, so an extension that appears later is shown by default.
- **Show x files**: how many rows are displayed after filtering, from 1 up to the panelSize setting (default 40). The status line reads "Showing N of M matching"; an empty match shows a clear empty message.
- Both selections persist in the board's durable state across reloads and sessions. **Reset filters** clears the saved selection (all extensions checked, show count back to panelSize).
- A small footer on the panel reads "N hidden (no link)": rows kept in the log that failed the link test in the current window.

## 4b. Rolling retention archive

- The master log keeps a rolling retention window (the retentionMonths setting, default 12 months). Entries older than the window are archived before they are removed: grouped by year, one JSON file and one CSV file per year, written into an archive folder beside the master log (or in the cloud location the user chose for the full log).
- Archiving is part of the aggregator cycle, and it is fail-safe: if writing an archive file fails, the whole cycle aborts before anything is published to the panel, so an archiving problem can never silently drop history.
- Archived entries are gone from the working log and the panel, and retrievable from the archive files at any time by asking.

## 5. Verification (from the cycle, not by hand)

A change to this module counts as working only when a normal scheduled cycle's own output shows it: saves appearing, exclusions holding (zero excluded names in the panel), hides sticking across two cycles. Never verify by pushing the panel manually; a manual push can race the cycle and create duplicates. Setup's test save (prompts/05) is verified the same way: wait for, or run, one aggregator cycle and read the panel back.

## 6. Honest limits and the parking rule

- This module watches a real computer. Paths, tools, and habits differ per person, and any part (scanner install, restart behaviour, path formats) can fail for local reasons the kit cannot foresee.
- Setup therefore has exactly one troubleshooting pass (TROUBLESHOOTING.md). If the checks still fail, park the module: disable the scanner schedule and the aggregator job, remove nothing from the board (the empty Recent File Saves panel stays, or the user may delete it), and tell the user plainly it is parked to a later kit version with the rest of the board unaffected.
- The link test is defined once: a path is linkable if it is a Windows drive path, a UNC path, or starts with /Users/ or /Volumes/. The board, the aggregator and explain.py all apply that same definition.
- Local file paths: Copy path works for every row and needs no setup. Click-to-open needs a link handler on the user's computer (the optional local-files extra); without one, use Copy path. A row is eligible when its path is a Windows drive path, a UNC path, or a macOS path under /Users/ or /Volumes/, or a web link; other paths, including workspace and sandbox paths, stay in the log only. The rules dialog says exactly this, in the same words.

