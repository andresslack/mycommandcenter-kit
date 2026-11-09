# Install Guide

## Start here: the guided install (recommended)

You do not need to read this guide. Give the file 00-START-HERE.md, at the front of this kit, to your Muse, and type one sentence: "Follow the file I gave you and start my install." Your Muse then leads the entire install in conversation: it gets the kit files into place with you, builds the board, runs the interviews, and handles the module setups one step at a time, checking each step with you as it goes. You can pause at any checkpoint and resume later by giving your Muse the same file in a new conversation and saying "continue my install."

This guide remains as the reference, and as the manual route: if you prefer to run the install yourself, the six steps below are the same install, one prompt at a time.

## The six steps (manual route and reference)

Six steps. Steps 1 and 2 give you a working board. Steps 3 to 5 add the modules, in the order most people want them. Step 6 closes the install. You can stop after any step and continue later; every prompt works on its own.

Before step 1, get the kit files where your Muse can read them: the unzipped kit folder in your Muse workspace is easiest. In each step, open the prompt file named, copy its whole text, and paste it into a conversation with your Muse. When a step's checkpoint summary matches what the prompt promised, the step is done.

## Step 0: Before you start (2 minutes, no prompt)

- Be in your own Muse AI, signed in as you.
- Decide which email accounts you want in the Email Brief (step 3). You can start with one.
- Have 15 minutes for step 1 alone, or 30 to 45 minutes for everything.

## Step 1: Core board (prompt: prompts/01-install-core.md)

Your Muse builds the board and interviews you: board name and theme, starter pack, what the board must track, a one-line coach note, how proactive Muse may be, and your first real tasks.

Done looks like: a Priority Rail with your first 3 to 7 real tasks ranked, 14 panels in order (a 15th, File Saves History, is added in step 5 if you set up the optional File Save Log module), your routines panel under the name you chose (Recurring Activities by default, Operating Rhythm for the small business pack), and a summary from Claude confirming all of it. The board is fully usable after this step.

## Step 2: Import and personalize (prompt: prompts/02-import-and-personalize.md)

Bring in tasks from wherever they live now: paste a list, or let Muse walk you through your current tool. Anything Muse cannot place goes to the Parking Lot, with a note saying where it should probably go, and you sort it together. You also add your daily websites to Quick Open.

Done looks like: counts that match (tasks added, items per panel, items parked), and a rail order you agreed with.

## Step 3: Email Brief (prompt: prompts/03-email-brief-setup.md)

Walk through connecting each email account, choose your brief times, name anyone whose mail always matters, and run a live test brief.

Done looks like: a scheduled job at your times, a test brief in chat, and the same brief written into your routines panel.

## Step 4: AI Bridge (prompt: prompts/04-bridge-setup.md)

Optional. Skip it if you use no other AI chat, or have no Google Drive and do not want a free Google account for it. Skipping changes nothing else.

Done looks like: a Drive folder named MyCommandCenter Bridge with a board snapshot in it, and one test request made from your other AI chat that landed on the board.

## Step 5: Reviews and File Save Log (prompt: prompts/05-reviews-and-file-log-setup.md)

Part A sets up daily review sessions (LinkedIn, or any habit) at your real times. Part B sets up File Saves History from folders you pick on your main computer.

Part B starts with a short preflight on that computer, before anything is installed: it checks that the computer is Windows, that a recent PowerShell is present, that the windowless launch this module needs can actually run on your machine, and whether the machine is managed by an employer or school, which can block parts of the setup. If the preflight fails, part B ends there, cleanly, with nothing half installed.

Mac note: File Save Log is Windows-only in this version. If your main computer is a Mac, skip part B of prompt 05 and the pre-install check below entirely. Part A (daily reviews) still applies to you, and everything else in this kit works on macOS. Mac support for File Save Log is planned for a later version.

Before you paste prompt 05, run the pre-install check on your main computer. It takes about a minute, installs nothing, and tells us both whether the File Save Log module can work on your machine before we set anything up.

1. Open the kit's preinstall folder in File Explorer.
2. Click in the folder's address bar, type powershell, and press Enter. A PowerShell window opens in that folder.
3. Paste this line and press Enter:

powershell -NoProfile -ExecutionPolicy Bypass -File .\Check-FileSaveLogRequirements.ps1

4. Read the verdict at the end. The script also saves the full report as a text file in the same folder, with the date and time in its name.
5. Paste the whole report into your Muse conversation and say: "Here is my pre-install diagnostic report." Then paste prompt 05. Your Muse will use the report's results and paths for setup, or park the File Save Log module cleanly if anything failed, and finish the rest of your install either way.

Optional, if you already know your folders: add -Folders with your folders as one quoted string separated by semicolons, and -LogDestination with your intended log folder, as shown in the script's own examples, and those exact locations are checked instead of the defaults. The semicolon form matters: a comma separated list passed to a second PowerShell process can be split at the spaces in folder names.

Done looks like: your review sessions on the board and checkable, and either "File Save Log live" with real recent saves in the panel, or, if that module would not cooperate after troubleshooting, "parked to a later version" with the rest of the board complete. Both are valid endings; the File Save Log is the one module that touches your real computer, and it is designed to fail politely rather than leave a mess.

## Step 6: Close (the end of prompt 05, plus prompt 06 scheduled)

Muse schedules a one-time Day 7 tuning session, seven days out, so the board gets one adjustment pass once you have lived with it. It also explains upgrades (prompts/upgrade.md, for when a new kit version appears) and feedback (FEEDBACK.md).

## After install: three phrases that always work

- "Add this to my board."
- "What should I do next?"
- "Clean out the Parking Lot with me."

And the standing rule: let your Muse know at any time if you want to modify anything about your panel. Names, panels, routines, times, and Muse's own behaviour are all yours to change by asking.

## Optional extra: local file links

Quick Open holds web links. If you want board entries to open files on your own computer: level 1, no install, is to keep local file paths as copyable text (your Muse can set this up in one request). Level 2, an advanced extra that lets links open local files directly, is Windows-only in this version, involves a small system registration on your computer, and should only be done with your Muse walking you through it and your explicit approval at the step. It is never part of a first install.
