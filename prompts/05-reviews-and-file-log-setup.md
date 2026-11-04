# Prompt 05: LinkedIn reviews and File Save Log setup

Step 5 of 6 in INSTALL.md. Two independent parts. Do part A, checkpoint it, then part B. If part B fails, part A still counts and the install can still complete (see part B step 5).

---

## Part A: Daily reviews (LinkedIn or another habit)

Read spec/INTERVIEW.md (LinkedIn reviews module interview) and spec/ROUTINE-CATALOG.md (reviews item).

1. Run the module interview: how many sessions a day, at what times, what a review means for me. If I am not on LinkedIn, offer the same pattern for another daily review habit, or drop the item entirely. My choice wins.

2. Create the reviews routine item in my recurring panel with one session per time I named (SPEC.md section 4, sessions). Set reminders at the session times only if I asked for reminders.

3. Checkpoint: read the board back, show me the item and its sessions, and check off today's first session with me if I have already done it (only I say whether it is done).

## Part B: File Save Log

Read spec/FILE-SAVE-LOG.md in full and spec/INTERVIEW.md (File Save Log module interview).

1. Preflight, before installing anything. Start with my pre-install diagnostic report:
   a. Ask me for the report from the pre-install check in INSTALL.md step 5. If I have not run it, walk me through running preinstall/Check-FileSaveLogRequirements.ps1 now, using the steps in INSTALL.md, and wait for the report before going any further.
   b. Read the report and act on it exactly: any FAIL line means we fix that item and I rerun the diagnostic, or we park this module per step 6, before any part of it is installed. A WARN line means we proceed, but we build the setup around it (for example, using the fallback windowless launch the report names). Use the report's exact paths and versions (the PowerShell 7 path, my folder paths, my log destination) in setup. Do not re-ask what the report already answers, and never copy a path from an example or another machine.
   c. If I cannot run the diagnostic script at all, treat that as a warning sign in itself, and fall back to checking these by hand with me, reporting each in plain language: this computer is Windows and I can create a scheduled task under my own account (ask me whether the machine is managed by an employer or school; their policies may block parts of this, and we may need IT approval or we park); PowerShell 7 or later is installed, with its real path resolved on this machine; the windowless launch works here, proven by a small live test using the wrapper pattern in spec/FILE-SAVE-LOG.md section 2c, with the conhost.exe --headless fallback on Windows 11 if script host is blocked, and parking on Windows 10 if it is blocked there; my security software is not blocking that launch pattern (if it prompts, I decide whether to allow it). Also tell me, while you check: the wrapper uses VBScript, which Microsoft has deprecated and which is an optional feature in newer Windows versions, so a future machine may need the fallback.
   d. Do not proceed to step 2 unless the diagnostic verdict is ready or ready with warnings we have a plan for, or every fallback check in (c) passes.

2. Run the module interview from spec/INTERVIEW.md: folders that matter on my main computer, folders my own tools work in that should be excluded for me, the shipped exclusions read out loud, whether the full log lives in Drive or as a local file, the privacy notice, and the expectations list. Also offer me the shipped optional exclusion groups (extra backup files, build output folders, Snagit working files, screenshot folders) and the two settings: how many saves the panel shows (default 40) and how many months of log to keep (default 12). Record every answer; my choices on the optional groups and the settings are written into my user file in step 3, never into the defaults file. Where the diagnostic report already answered a question, confirm it with me instead of asking from scratch.

3. Set up the scanner and the aggregator per spec/FILE-SAVE-LOG.md, with these rules stated so there is no ambiguity:
   a. Scanner on my computer for the folders I chose, and no others, on this one computer only. Aggregator job every 15 minutes in my Muse. Preset exclusions on, plus my own folders from the interview. Dismiss and Hide always available on the panel. The pinned full-log entry in the Recent File Saves panel pointing at my log location. The panel shows the most recent saves up to my panel-size setting (default 40), and the master log rolls into an archive after my retention setting (default 12 months).
   a2. The exclusion rules are config-driven, in two JSON files placed in the scanner's folder. Install FileSaveLog-Excludes.json (the shipped defaults) exactly as it ships, and create my personal file, FileSaveLog-Excludes.user.json, by copying FileSaveLog-Excludes.user.template.json and filling its selfPaths with the scanner's install folder, so the scanner never logs its own files. My own rules from the interview (folders to keep out of the log entirely, folders to hide from the panel only) go in my user file, never in the defaults file, because updates replace the defaults file and never touch my user file. Python is not needed on my computer for this module, except for the optional explain.py check, which I can run myself only if I have Python 3 (or I can ask you, and you run it against my config).
   b. The scanner records metadata only: file name, full path, folder, save time, size, new or updated. It must never open, read, or copy a watched file, because reading a cloud placeholder file can force that file to download.
   c. Windowless launch, per spec section 2c, with no substitutes: the scheduled task action is the wscript.exe VBScript wrapper, never a direct PowerShell launch, because -WindowStyle Hidden still flashes and can be ignored; the task's own "Hidden" checkbox does not count, it hides the task in a list, not its window; and never set the task to "run whether the user is logged on or not", because outside my logged on session my cloud drives may not be mounted and scanner output can silently stop arriving.
   d. The task runs as me, interactive logon, limited level. It does not need admin rights and it cannot see other users' files; do not widen that.
   e. Resolve the real paths on this machine and put them in the config: the pwsh.exe path from the diagnostic report or step 1, each watched folder, the state file location, and the log destination, including the actual drive letter or OneDrive or Drive folder my sync app uses, confirmed running and mounted in this session. Before the first real cycle, check that every watched folder can be read and that the state location and the log destination can be written. The diagnostic's folder checks count for the folders it tested; check any additional folder the same way.

4. Run one cycle and verify from the cycle's own output (spec/FILE-SAVE-LOG.md section 5), plus these two checks:
   a. Ask me directly, while a scheduled cycle runs: "Did any window appear, even briefly?" My answer is part of the verification. Do not claim windowless from the task settings alone, and do not mark this live without my answer.
   b. Report how long the scanner run actually took on my machine.
   The panel must show real recent saves from my folders, no filler files, newest first, no excluded names.

5. Test Hide always with me: I pick one panel entry, you hide it always through the board's own control, and we confirm it stays hidden, that it appears in the board's Hidden items list where I can restore it, and that the file itself is untouched.

6. If any check fails after one troubleshooting pass with TROUBLESHOOTING.md, including a diagnostic FAIL we could not fix, a security software block I do not want to allow, a blocked script host with no working fallback, a managed machine policy, or a folder or destination that cannot be read or written: stop, park this module, tell me plainly that the File Save Log is parked to a later version and that the rest of my board is complete and unaffected. Do not keep retrying and do not leave half-installed pieces running; disable what you created for this module and say what you disabled.

7. Checkpoint: either "File Save Log live" with the verified counts, the measured run time, and my no window confirmation, or "parked" with what was disabled and which check parked it. Then close the install: name what is live overall, schedule the Day 7 tuning (prompt 06) as a one-time job 7 days from today, and repeat the standing reminder that I can ask at any time to modify anything about my panel.
