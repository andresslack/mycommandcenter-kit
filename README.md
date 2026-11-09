# MyCommandCenter Kit

Run your day from one board.

MyCommandCenter is a personal command center that lives inside your own Muse AI: a ranked To-do's rail on the left, and panels for everything you track, including your routines, on the right. Your Muse builds it from this kit, interviews you to personalize it, and then helps you run it day to day.

This kit is the installer. There is no app to download and no account to create. You hand one file, 00-START-HERE.md at the front of the kit, to your Muse and type one sentence, and your Muse guides you through the whole install in conversation, one step at a time: no instructions to read, just questions to answer and small actions to take when it asks. The board is built inside your Muse, with your data, which never leaves your Muse and your own accounts. See PRIVACY.md.

## What you get

- To-do's (the Priority Rail): your to-do list, in your own order, with due dates, estimates, categories, and optional Important and Critical tags shown as pills. Anything due in the next 3 days rises to the top. Ten view-only sorts, a Batch view grouped by category, and a search across every field help you look at the list sideways without ever disturbing your saved order.
- Panels: projects, clients, money, personal, and more, starting from a starter pack you pick, plus a Parking Lot for anything that does not have a home yet. Panels live in columns you arrange by dragging, and stay where you put them.
- Recurring panel: routines with real types: daily and weekday checks, multiple-times-a-day habits with per-session checkoffs, weekly and monthly checks with "Due tomorrow" and "Overdue" cue pills, every-N-days items, and brief entries. Renaming an entry never breaks its behaviour.
- Email Brief: a scheduled summary of your inboxes, at times you choose, written onto the board. Needs action, deadlines, signals, FYI. Every bullet has an "Add to To-do's" button that opens a form prefilled from the email (due date, category, estimate, when the email supports them; nothing is ever guessed), and an "Open" button that takes you straight to the source email. It never sends mail.
- AI Bridge (optional): your other AI chats can see the board and request changes, through a folder in your own Google Drive.
- Daily reviews (optional): session checkoffs for LinkedIn, or any habit you check several times a day.
- File Saves History (optional): the files you saved recently, on the board, with the filler filtered out.

## Who it is for

People in small companies and very busy individuals who want one board instead of five apps and a pile of sticky notes, and who are happy to tell their AI what to change in plain words.

## What you need

The essentials:

- Your own Muse AI account, where the board will live. There is no separate app to download and no other account to create.
- A Muse plan that supports the connected features. Connecting email and running scheduled jobs (the briefs use both) depend on plan features, so check your plan if you are on a free tier.
- A device, a browser, and an internet connection: whatever you run Muse on day to day.
- 30 to 45 minutes for the full install, or about 15 minutes to get the board working and the rest later. The install is staged on purpose.
- The ability to hand Muse a file and answer questions in plain language. You do not need to be technical, and you do not need to read the kit's instructions.

Decisions only you can supply (Muse asks; you answer in your own words):

- A starter pack: solo, small-business, or consultant.
- Your categories and subcategories for to-do's. A partial list is fine; categories can be added and edited later from the Settings cog, and the Email Brief reads the same table.
- Your routines, panels, and projects: the areas of your work and life the board should track.
- For the Email Brief: which email accounts it covers (one is enough to start), up to five brief times a day, and the names of anyone whose mail always matters to you.

For the Email Brief (a core module):

- A Gmail or Outlook account you can connect in Muse. The connection is the only way the brief can read your mail. The brief never sends mail.

For the Bridge (optional):

- A Google Drive account (a free one is enough), plus another AI chat that can work with it. Skipping the Bridge changes nothing else.

For the daily reviews (optional):

- A LinkedIn account, if the reviews are for LinkedIn. The same mechanism serves any habit checked several times a day, with nothing extra required.

For File Saves History (optional; Windows-only in this version):

- A Windows computer as your main machine. If your main computer is a Mac, skip that one module; everything else in this kit works on macOS. Mac support for File Save Log is planned for a later version.
- Windows PowerShell 5.1 (built into Windows), to run the one-minute pre-install check, which installs nothing and verifies the machine before anything is set up.
- PowerShell 7 (free from Microsoft). The scanner runs on it; if the pre-install check finds it missing, the check itself gives the exact remedy.
- Task Scheduler, and you normally signed in: the scanner's task runs at sign-in and every 15 minutes while you are signed in on that computer.
- Permission to run the kit's scripts on your own machine, started by the documented one-line launch.
- Folders to watch, chosen by you during setup. The scanner records file names, paths, and times only; it never reads file contents.
- Optional: Google Drive syncing to that computer, which carries the scanner's batches. Without Drive sync, the installer uses a local folder instead and says so.
- Ongoing: pasting "Update File Saves History" into Muse Chat whenever you want the panel updated. Updates are manual only; nothing runs on a schedule.

One optional extra:

- The local-files handler (Windows only) lets board links open local files directly. Without it, rows show the path as text with a Copy path button, which works on every platform.

Two standing rules of use:

- Only you send email. Your Muse prepares drafts; it never sends.
- Your data stays in your own accounts. Board data lives in your Muse and your own connected accounts. The kit has no telemetry and sends nothing back; feedback is voluntary.

## Install

Open INSTALL.md and follow the 6 steps. Each step is one prompt from the prompts folder, pasted into your Muse, with a checkpoint at the end so you know it worked.

## The one rule to know

The board is yours. At any time, in any conversation with your Muse, you can say you want to modify anything about your panel: rename it, move things, add or remove panels, change how Muse behaves. Nothing is locked.

## Files in this kit

- INSTALL.md, TROUBLESHOOTING.md, FEEDBACK.md, PRIVACY.md: for you.
- prompts/: the install prompts your Muse runs for you, plus self-check, upgrade, and Day 7 tuning.
- spec/: the precise specifications your Muse builds from. You never need to read these, they are there so every install builds the same board, and so you can see exactly what your Muse was told to do.
- seed/: the starting structure, empty of content. DEMO.json is optional sample data, loaded only if you ask.

## Version, license, support

Version: see VERSION. Changes: see CHANGELOG.md.
License: MIT License, see LICENSE. Created by xlSigma LLC. The license covers the kit's content; the names MyCommandCenter and xlSigma belong to xlSigma LLC and are not licensed under it.
Support: best efforts. Start with TROUBLESHOOTING.md, most problems are fixed by pasting the self-check prompt into your Muse. Feedback is voluntary and welcome: FEEDBACK.md.
