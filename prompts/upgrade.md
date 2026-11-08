# Upgrade

Use this prompt to apply a newer version of the MyCommandCenter kit to an existing board, without losing any data. The user provides the new kit files (or points Muse at the kit repository release).

This prompt is written for boards installed from kit v0.1.5 or v0.2.0. It detects which one it is dealing with before changing anything, and it fails safe: an install it does not recognize is reported, not improvised on.

Status: this detect-and-branch flow is UNRUN on a real v0.1.5 board. What could not be verified without one is listed at the end.

---

Upgrade my MyCommandCenter board to the kit version in the new files I just gave you. Work through the steps in order. Diagnose first and change nothing until I have seen the diagnosis and said yes.

## 1. Diagnosis (read-only; report before any change)

Read the new kit's VERSION and CHANGELOG.md. Then examine my current install and report each of these to me, in plain language, before touching anything:

- Installed kit version: the version marker recorded for my install (on the board or in my files), and how you determined it. If no version is recorded anywhere, say so; that is itself a finding.
- File Save Log: whether a scanner exists on my computer, the script's name and folder, whether it carries the kit's $ScriptVersion marker, which scheduled tasks exist for it and what they are named, and whether its config files (config.json, the excludes files) and state file exist.
- The File Saves panel's current title on my board (it may be the older title, the current "File Saves History", a name I chose, or absent).
- Email Brief structure: whether my board has the old two-entry structure of the two-entry era, the combined single entry, or no brief entry.
- Category table: whether a Category/SubCategory taxonomy table exists on my board, and if it does, how many categories and subcategories it holds.
- Board actions and data: which of the newer board features my board already has (the taxonomy table returned by getdashboard, a deletion log, the file-save refresh stamps), reading getdashboard to find out.

Then state which branch I am on: v0.1.5, v0.2.0, or unrecognized. This prompt's branches are written for v0.1.5 and v0.2.0. If my install is older, newer, between versions, or cannot be identified, STOP and report what you found instead of improvising an upgrade path.

## 2. Backup and rollback plan (before any change)

- Call getdashboard and save the complete result as a file named with today's date (for example mycommandcenter-backup-YYYY-MM-DD.json) in my Muse workspace. Confirm the file exists before going further. If the backup fails, stop. The backup includes my taxonomy table if I have one; say so when you confirm it.
- If a File Save Log scanner exists, back up its script, both config files, its state file, and the master log next to the originals with the date in the names.
- State the rollback plan in plain words: what would be restored, from which files, and in what order. Restoring is something you walk me through if I ask, never something you do automatically.
- Summarize the upgrade plan the diagnosis produced (which of steps 3 to 7 apply to me and which are skipped, and why) and wait for my explicit yes. Every later step that changes my data also waits for my yes at that step.

Two standing constraints on everything below. First, a version change upgrades code, layout, and rules only: my board data (tasks, items, notes, order, settings) is never rolled back, reset, or re-seeded by an upgrade. Second, where a scheduled job owns updates to a store (for example the File Save Log aggregator owns the File Saves History panel), make upgrade changes through that job's inputs, never by writing the store directly, so the upgrade cannot race a cycle.

## 3. Category table: preserve it, or seed it once from my own presets

- If my board already has a taxonomy table: it is my data, on the same footing as my tasks. Preserve it verbatim: every category name, every subcategory name, and their order and grouping exactly as stored. Never reseed it, never overwrite it with the shipped empty table, and never replace it with defaults or examples. After the upgrade, read the table back (getdashboard or gettaxonomy) and compare it with the backup: report the counts of categories and subcategories before and after, and show me the full table if either count differs or if anything changed.
- If my board has no taxonomy table (the v0.1.5 branch): create the table and seed it ONCE from my own existing presets: the Category and SubCategory values already carried by my tasks, organized as they are used there, plus anything from my own setup answers you can still find. Show me the proposed table and get my yes before saving it. Never seed it from the kit (the kit's table ships empty), from examples, or from another user's values. If I would rather start empty, create it empty and say that is what happened. Once seeded or created, it is my table from then on: no later upgrade reseeds or overwrites it, and edits I make to it later are never undone by an upgrade.

## 4. Board code, actions, and additive changes

- Apply the new migrations and actions for my version gap only where the diagnosis found them missing: taxonomy storage (with the gettaxonomy and updatetaxonomy actions), the append-only deletion log, and the file-save refresh stamps (requested, started, completed) with the cancel action. Where a feature already exists, leave it exactly as it is.
- Everything else applies additively only:
  - New panels, routine items, actions, or fields in the new spec: add them, seeded empty, then tell me about them and let me place or rename them.
  - Changed defaults (names, catalog items): apply only to things I never customized. If I renamed it, mine wins.
  - Changed rules in OPERATING-RULES.md: show me the differences in plain language and ask before adopting any rule change that would make you more proactive. Rule changes that make you more careful apply automatically, but still tell me.
  - Never delete or rewrite my tasks, items, links, notes, or settings as part of an upgrade. If the new spec removes a feature I use, leave my version of it alone and flag it for my decision.
  - Lossless migration promise (recurring entries): converting my existing recurring entries to the typed entry system must lose nothing. Checkoffs recorded under the older model, including a reviews entry's same-day session checks, carry into the typed model intact, stored against the session keys you create for them. A pre-existing single link on an entry becomes the first item of its link list. Stored Status values survive even where the new editor no longer shows the field. After migrating, show me the before and after checkoff state for any entry that had a check recorded today.

## 5. Email Brief: merge only if the diagnosis found the old structure

- If the diagnosis found the old two-entry structure: merge the two entries into the one combined Email briefs entry specified in spec/EMAIL-BRIEF.md, carrying over the brief times I already use (if the two entries disagree about times or anything else, show me both and ask; never pick silently). My existing brief stack and per-brief files are my records: they carry over and stay readable. Show me the merged entry and read it back before calling this step done.
- If my board already has the combined entry, or no brief entry at all: skip this step and say which case it was.

## 6. File Saves panel rename

If my File Saves panel still carries the old title "Recent File Saves", rename it to "File Saves History" as part of this upgrade, with my yes. Any lookup that finds the panel (yours, the bridge snapshot's, the aggregator's) must accept the old title as a fallback, so nothing that looks the panel up by title breaks before, during, or after the rename. If the panel already has the current title, or a name I chose myself, leave it alone and say so. If I have no File Saves panel, skip.

## 7. File Save Log scanner, through the one installer

What happens here depends on the diagnosis in step 1. In every branch, the only tool that installs or replaces a scanner is the new kit's ONE installer, filesave-log/Install-FileSaveLog.ps1 (spec/FILE-SAVE-LOG.md section 2d). Never copy a packaged script over an installed one by hand: the installer's comparison is the upgrade path. Backups for this step were taken in step 2.

Mac exception: File Save Log is Windows-only in this version, so no kit scanner was ever installed on a Mac. If my computer is a Mac, take Branch C below as a skip, not as a missing component to install: do not offer the installer or the pre-install diagnostic, and record the module as skipped by platform. The rest of the upgrade is unaffected. Mac support for File Save Log is planned for a later version.

- **Branch A, the kit's scanner is installed** (a Scan-FileSaves.ps1 carrying the $ScriptVersion marker, with its config): run the installer on my computer with the existing install folder as its -InstallDir. It refreshes FileSaveLog-Excludes.json, upgrades the scanner only when the packaged copy's marker is higher, and never overwrites FileSaveLog-Excludes.user.json, which holds my personal rules and survives every update, so rules I added carry over as they are. If the existing install predates the config files, create the user file from FileSaveLog-Excludes.user.template.json, fill its selfPaths with the scanner's install folder, and move my personal rules into it. Keep the scanner's state file, the master log, the ingested batches, and the board's panel data untouched, so no save history is lost. Read the installer's per-component summary back and report it; a component reported FAILED stops the upgrade here, with the rollback in step 9.
- **Branch B, a scanner exists but is not the kit's** (the v0.1.5 case: that version shipped no scanner, so any scanner on my machine was generated during my install; expect another name, no $ScriptVersion marker, or both): that scanner is legacy. Tell me plainly, before running anything: it will be backed up and replaced by the kit's scanner through the installer; the old script stays in its backup if I ever want it back; and the first scan under the new scanner re-baselines, meaning the new scanner starts its own state fresh (saves from before the swap remain in the master log backup and in the panel's existing rows, which are board data and are not touched). With my yes, run the installer against the folder I approve as the install folder.
- **Branch C, no scanner exists**: offer the installer as an optional step, and say plainly that it is optional and that it needs PowerShell 7 on my computer plus the pre-install diagnostic in INSTALL.md step 5 (the full setup is prompts/05 part B). If I decline, skip it: the File Save Log module simply stays uninstalled, and the rest of the upgrade is unaffected.

One expected effect to tell me about before the run, in branches A and B: the new default exclusion rules may remove matching old rows from the log and the CSV on the first aggregator run after the upgrade. That is expected, and the log backup from step 2 covers those rows.

After the installer: parse-check the new scanner script and confirm both config files load as valid JSON in the loader before running anything. Then verify with one manual scanner run and one aggregator cycle, and report how many events the verification run produced. If the parse check, the run, or the cycle fails, roll back: restore the backed-up scanner and config files, leave the state file and log as they were, and report the failure instead of calling the upgrade done.

## 8. Self-check

Run the self-check (prompts/self-check-and-repair.md) against the NEW spec and report the result.

## 9. Read back, compare, and finish

- Read the board back and compare the counts with the step 1 diagnosis: open tasks, completed tasks, panels, panel items, and (if a table exists) categories and subcategories. Every count must match the diagnosis, apart from changes this upgrade deliberately made and already reported (a merged brief entry, a renamed panel, a newly added empty structure). On ANY other mismatch: stop, report exactly what differs, and offer the rollback from the step 2 backups. Do not paper over a mismatch and do not restore anything without my direction.
- Finish with: versions before and after; which branches were taken and which steps were skipped, and why; what was added; where the backup files are; and how to go back (restore means rebuilding from the backup files, which you will walk me through if I ask, never automatically).
- Feedback to the kit author is voluntary: if I want to share how the upgrade went, you can help me write it up (see FEEDBACK.md). The kit has no telemetry and reports nothing on its own.

## What could not be verified without a real older install

This flow is UNRUN on a real v0.1.5 board (and on a real v0.2.0 board outside the reference install). Specifically unverified: whether a v0.1.5 install records its kit version anywhere the step 1 diagnosis looks; the exact script name, folder, and scheduled task names a v0.1.5-era generated scanner used, so branch B's detection may need the user's help to recognize it; whether a two-entry-era board stores its brief times in the form the step 5 merge expects; and whether getdashboard on those versions returns every field step 1 reads. The diagnosis reports what it actually finds and stops on anything unrecognized, which is the designed behavior when these assumptions miss.
