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
3. Applies exclusions (section 3) and hides, in that order, before taking the top 40.
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

## 3. Exclusions (panel only; excluded entries still go to the master log)

Never show in the panel (the Tier 1 list):
- Files with a .log extension, entirely
- Any path containing a segment named .next or .metadata
- Any path containing a segment named Temp, or a segment whose name contains filesforclaudecode (a staging folder some AI tools use; match is on the segment name, case-insensitive)
- Partial or temporary files: suffixes .tmp, .part, .partial, .crdownload
- Application lock and housekeeping files: names starting with ~$, and next-env.d.ts, files ending in .tsbuildinfo, Thumbs.db, desktop.ini, .DS_Store, and shortcut files (.lnk)
- Handover notes created by tools for other tools: file names starting with HANDOFF- or handoff_
- The user's own automation working folders, listed explicitly in their config at setup (for example the working folders of a scheduled search tool they run). This is a per-user config list, never a shipped default.

Deliberately NOT excluded. These were considered for the panel filter and rejected; do not add them, and do not let a setup conversation talk the user into them without flagging that they hide real work:
- Screenshot and screen-capture files from capture tools (for example .snagx)
- Same-day duplicates of the same file in two locations (no dedupe by name or day)
- Project instruction files such as CLAUDE.md
- Folders named Templates, and files with "Temporary" in their name (substring lookalikes are not matches)
- Photos, anything in Downloads, and Save-As versions of a document

The user may add exclusions of their own beyond this list by asking; Muse should restate the effect before applying. Matching discipline: exclusions are file-name, suffix, and path-segment matches as written above, never a substring search over the whole path.

## 4. Permanent hide

- Deleting a panel entry means "never show this save again". The file itself and the master log entry are untouched. The panel confirmation for deletion (including bulk delete) must say exactly that.
- Detection: a managed key that was present in the previous cycle's panel payload (the aggregator keeps a baseline of each cycle's payload), was still expected, and is now missing from the panel counts as user-deleted and becomes a hide. An entry that simply rolled off the top 40, or vanished from a computer's scan, is not a hide and may return if it qualifies again. Deleting the underlying file does not remove its panel entry either; the entry stays until it rolls out of the top 40.
- Post-edit caution: after any automated edit to a store the user also edits (this hide list, the panel, the master log), a missing record is not automatically data loss. Confirm it was not an intentional deletion by the user before restoring anything. This is the same check OPERATING-RULES.md rule 14 states generally.
- Hides are stored as a list of hide keys ("<date>|<full path>") in the aggregator's data. Adding a hide is idempotent. The user can also name an entry in chat and ask for it to be hidden without opening the board.
- An unhide operation exists (same key), for mistakes.
- The pinned entry, titled "File Save Log, full log", linking to the full-log file, always sits at the top of the panel above the 40 saves and never counts toward them. It carries no Date or Full path notes, so deletion detection never hides it, and the aggregator re-adds it if it is removed.

## 4b. Rolling 12-month archive

- The master log keeps a rolling 12 months of entries. Entries older than 12 months are archived before they are removed: grouped by year, one JSON file and one CSV file per year, written into an archive folder beside the master log (or in the cloud location the user chose for the full log).
- Archiving is part of the aggregator cycle, and it is fail-safe: if writing an archive file fails, the whole cycle aborts before anything is published to the panel, so an archiving problem can never silently drop history.
- Archived entries are gone from the working log and the panel, and retrievable from the archive files at any time by asking.

## 5. Verification (from the cycle, not by hand)

A change to this module counts as working only when a normal scheduled cycle's own output shows it: saves appearing, exclusions holding (zero excluded names in the panel), hides sticking across two cycles. Never verify by pushing the panel manually; a manual push can race the cycle and create duplicates. Setup's test save (prompts/05) is verified the same way: wait for, or run, one aggregator cycle and read the panel back.

## 6. Honest limits and the parking rule

- This module watches a real computer. Paths, tools, and habits differ per person, and any part (scanner install, restart behaviour, path formats) can fail for local reasons the kit cannot foresee.
- Setup therefore has exactly one troubleshooting pass (TROUBLESHOOTING.md). If the checks still fail, park the module: disable the scanner schedule and the aggregator job, remove nothing from the board (the empty Recent File Saves panel stays, or the user may delete it), and tell the user plainly it is parked to a later kit version with the rest of the board unaffected.
- Local file links: panel entries carry the full path as text. Opening a file from the board is not part of this version (see INSTALL.md on the optional local-files extra); the path is there to copy.

