# Changelog

## 0.1.5 (pilot)

The kit now carries its real license, which was the last piece missing before a public release.

- The pilot license placeholder is replaced by the MIT License, copyright xlSigma LLC, in a LICENSE file at the front of the kit. In plain terms: you may use the kit, change it, and share it onward, including for client work, as long as the copyright and license notice stay with copies. That was always the project's intent; this version makes it the legal text instead of a statement of intent.
- The README gains a single credit line, "Created by xlSigma LLC," and a note that the license covers the kit's content, not the names MyCommandCenter or xlSigma, which belong to xlSigma LLC.
- Nothing else changed in this version: no board behaviour, no prompts, no specs. Installs already running are unaffected and do not need to do anything.

## 0.1.4 (pilot)

The install is now guided. You no longer read instructions or paste a series of prompts yourself.

- New front door: 00-START-HERE.md, at the front of the kit (and sendable on its own, ahead of the kit). You hand that one file to your Muse and type one sentence, "Follow the file I gave you and start my install." Your Muse then conducts the entire install in conversation: it introduces what will happen, gets the kit files into place with you (if your Muse can work with files, you just upload the kit zip and it unpacks and verifies the set; if not, it walks you through unzipping and asks for each file when it needs it), then runs the six install steps in order, one question or action at a time, explaining anything you have to do on your own computer before you do it and interpreting what comes back.
- Checkpoints and pauses are built in: each step ends with a verified summary you confirm, you can pause at any point and resume in a fresh conversation (your Muse keeps a small install-state file and re-reads your board, which is the ground truth), and if something goes wrong your Muse stops, troubleshoots once, and either fixes it or parks that one module and carries on with the rest. Nothing is silently skipped, and nothing is marked done that was not verified.
- INSTALL.md and README.md now present the guided route first. The six-step manual route is unchanged and remains as the reference and the fallback; the step prompts, specs, and board behaviour did not change in this version.

## 0.1.3 (pilot)

File Save Log setup is now checked before it is installed, instead of being discovered by failure.

- New pre-install diagnostic: a script in the kit's preinstall folder that you run once on your main computer before the File Save Log setup, which checks the module's machine requirements live: Windows version, that you are in a logged-on session, PowerShell 7 and its real path on your machine, the windowless scanner launch (tested for real, not read from settings), Task Scheduler including a create-and-delete test task, access to the folders you want watched and to your log destination, and whether your cloud folders are visible from your session. It writes a short dated report that you paste to your Muse; setup uses its results and paths, and anything it marks FAIL is fixed and rechecked, or the module is parked, before anything is installed. It installs nothing itself, runs on the PowerShell built into Windows (so it works on machines that do not have PowerShell 7 yet), and its few test files clean up after themselves.
- The File Save Log install steps are rewritten around that report: a preflight before setup, a fuller setup interview (folders your own tools work in are excluded for you, the shipped exclusions are read out loud in case one would hide real work of yours, a plain privacy note that the log records file names and paths, and honest expectations about scans pausing while you are logged out, scan time, and the occasional save showing up one cycle late), explicit setup rules with no substitutes, and a verification step that now asks you directly whether any window appeared and measures how long your scanner actually takes.
- The spec now states the scanner's core safety rule in its own words: it records metadata only and must never open, read, or copy a watched file, because reading a cloud file that has not downloaded yet would force it to download.
- The Privacy file now says plainly that the log's content is file names and full paths, which can themselves be sensitive, so choosing folders and the log location is a privacy choice.
- A correction to the 0.1.2 notes below: the windowless wrapper on the reference install, described there as prepared but not yet applied, was in fact applied and verified later that same day, with the scanner running a full cycle and no window appearing. The pre-install diagnostic has also run live on the reference machine since then, with every check passing. Neither result proves anything about your machine, which is the point of running the diagnostic there; they do mean the designs in this release are not untested.

## 0.1.2 (pilot)

One setup fix for the File Save Log on Windows, learned from real use: a scanner window flashing (or worse, lingering) every 15 minutes is disruptive enough to make people drop the module.

- The File Save Log spec now requires a completely windowless scanner launch on Windows: run the scanner through a small wscript.exe VBScript wrapper that starts it hidden from the moment the process is created and passes its exit code back to Task Scheduler. Launching PowerShell directly with a hidden-window flag is explicitly not sufficient (Windows creates the window before the flag applies, and the flag can be ignored after updates). Fallback: conhost.exe --headless where VBScript is blocked.
- The spec also forbids the tempting wrong fix, running the scheduled task outside the user's logged-on session, because mapped cloud drives may not exist there and scan output can silently stop arriving.
- Windowless counts as verified only when the user confirms a cycle ran with no window seen, never from task settings alone.
- The reference install this was learned from has the wrapper prepared but not yet applied as of this kit version; the kit carries the design, and pilot installs will be its first live test.

## 0.1.1 (pilot)

A behaviour update folded in from two weeks of daily use of the reference board. No data model breaks; upgrades from 0.1.0 are additive and lossless (see prompts/upgrade.md).

- The rail is headed "To-do's" everywhere (it was described as "next actions" in places).
- Email Brief: bullets are now one per source email with a bold lead that works as a to-do title; a hidden suggestion channel (TODOSUGGEST) lets the brief writer prefill due date, category, subcategory, waiting on, estimate, notes, and priority tag, only from what the email itself supports; the "Add to To-do's" button opens a prefilled confirmation modal instead of adding instantly; a new "Open" button deep-links to the source email in Gmail or Outlook (the button appears only when a trustworthy link exists).
- To-do's: optional priority tags (Important, Critical) as filled pills; ten view-only sorts plus a "Make this my order" adoption step; Batch view grouped by Category/SubCategory; drawer search across all fields with phrase highlighting (adoption is disabled while a search is active); a Done confirmation modal in the expanded view; click a task in the compact rail to open the drawer scrolled to it; Cancel button on the add-task form.
- Recurring panel: a real entry-type system (daily, weekday-only, multiple times a day with editable sessions keyed so relabeling never loses a check, brief/report, weekly, monthly including "Last day of Month", every N days); due-soon cue pills on weekly and monthly entries; per-entry link lists; the entry editor drops the Status and Due fields it never needed.
- Panels: layout is stored in explicit columns instead of auto-packing; dragging uses a fixed model (nothing moves mid-drag, gold landing line, one commit on drop, moves of any distance); a blocked-drag modal replaces the old banner, with the grip staying highlighted afterwards; no grab-hand cursors anywhere; panels can only be deleted when empty; the item Edit window uses a theme-complement fill; status-dot legend added; headers switch to two lines together when any title is very short.
- File Save Log: deleted panel entries now stay deleted for good (a hide list, verified against each cycle's own baseline); the panel filter list is explicit about what is excluded and, just as important, what is deliberately not excluded; a pinned link to the full log sits above the list; master log entries older than 12 months are archived by year before removal.
- Operating Rules: two new rules: queue changes through the scheduled job that owns a store instead of writing around it, and check for an intentional user deletion before restoring a missing record.
- Honest note: there is still no delete-email button in the brief. That idea is on hold by decision; if it ever ships it will be Trash-only, one message at a time, with confirmation.

## 0.1.0 (pilot)

First version. Built for a single pilot install before public release.

- Core board: Priority Rail with due-soon ordering, drawer editing, done log with undo; 15 panels (recurring panel, Recent File Saves, Quick Open, Administrative, Parking Lot, ten template panels); three starter packs (Solo / Very Busy Individual, Small Business Operator, Consultant / Client Work); 23 board actions.
- Recurring panel with daily, weekly, and monthly cycles, plus generic multi-session routine items.
- Parking Lot triage with source and suggested-panel notes, and a weekly cleanout routine.
- Email Brief module: user-chosen schedule and inboxes, four-section brief, screening defaults, rolling 3-run stack on the board, per-run files.
- AI Bridge module: hourly Drive snapshot, 15 minute request inbox, 8 request formats, AI-agnostic protocol.
- Daily reviews module: session checkoffs at the user's real times.
- File Save Log module (scoped): one computer, chosen folders, preset exclusions, permanent hide, pinned full-log entry, 15 minute aggregation, with a defined parking rule if it fails.
- Operating Rules: 12 rules plus three proactivity tiers (Tier 2 default).
- Install in 6 staged steps with checkpoints; self-check and repair prompt; data-safe upgrade prompt; Day 7 tuning prompt.
