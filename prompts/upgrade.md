# Upgrade

Use this prompt to apply a newer version of the MyCommandCenter kit to an existing board, without losing any data. The user provides the new kit files (or points Muse at the kit repository release).

---

Upgrade my MyCommandCenter board to the kit version in the new files I just gave you.

1. Read the new kit's VERSION and CHANGELOG.md, and the currently installed version if it is recorded on the board or in my files. State both versions and summarize what the changelog says changed.

2. Back up first: call getdashboard and save the complete result as a file named with today's date (for example mycommandcenter-backup-YYYY-MM-DD.json) in my Muse workspace. Confirm the file exists before going further. If the backup fails, stop.

2c. File Save Log upgrades specifically: before changing anything, back up the current Scan-FileSaves.ps1, both config files, the scanner's state file, and the master log, next to the originals with the date in the name. Then replace Scan-FileSaves.ps1 and FileSaveLog-Excludes.json with the new versions, and never overwrite FileSaveLog-Excludes.user.json, which holds the user's personal rules and survives every update, so rules the user added carry over as they are. If the existing install predates the config files, create the user file from FileSaveLog-Excludes.user.template.json, fill its selfPaths with the scanner's install folder, and move the user's personal rules into it. Keep the scanner's state file, the master log, the ingested batches, and the board's panel data untouched, so no save history is lost. One expected effect to tell me about before the run: the new default exclusion rules may remove matching old rows from the log and the CSV on the first run after the upgrade. That is expected, and the log backup taken at the start of this step covers those rows. Parse-check the new scanner script and confirm both config files load as valid JSON in the loader before running anything. Then verify with one manual scanner run and one aggregator cycle, and report how many events the verification run produced. If the parse check, the run, or the cycle fails, roll back: restore the backed-up scanner and config files, leave the state file and log as they were, and report the failure instead of calling the upgrade done.
2b. Two standing constraints on everything below. First, a version change upgrades code, layout, and rules only: my board data (tasks, items, notes, order, settings) is never rolled back, reset, or re-seeded by an upgrade. Second, where a scheduled job owns updates to a store (for example the File Save Log aggregator owns the Recent File Saves panel), make upgrade changes through that job's inputs, never by writing the store directly, so the upgrade cannot race a cycle.

3. Apply changes additively only:
- New panels, routine items, actions, or fields in the new spec: add them, seeded empty, then tell me about them and let me place or rename them.
- Changed defaults (names, catalog items): apply only to things I never customized. If I renamed it, mine wins.
- Changed rules in OPERATING-RULES.md: show me the differences in plain language and ask before adopting any rule change that would make you more proactive. Rule changes that make you more careful apply automatically, but still tell me.
- Never delete or rewrite my tasks, items, links, notes, or settings as part of an upgrade. If the new spec removes a feature I use, leave my version of it alone and flag it for my decision.
- Lossless migration promise (recurring entries): converting my existing recurring entries to the typed entry system must lose nothing. Checkoffs recorded under the older model, including a reviews entry's same-day session checks, carry into the typed model intact, stored against the session keys you create for them. A pre-existing single link on an entry becomes the first item of its link list. Stored Status values survive even where the new editor no longer shows the field. After migrating, show me the before and after checkoff state for any entry that had a check recorded today.

4. Run the self-check (prompts/self-check-and-repair.md) against the NEW spec and report the result.

5. Finish: versions before and after, what was added, what was skipped and why, where the backup file is, and how to go back (restore means rebuilding from the backup file, which you will walk me through if I ask, never automatically).
