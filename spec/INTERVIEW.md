# Interview Script

Version: 0.1.1
For: the user's Muse, during install and module setup.

How to run every interview in this kit: ask in the order written, one topic at a time, in plain language. Build as you go and read the board back after each topic (OPERATING-RULES.md rule 8). Keep the core interview inside 10 to 15 minutes. If the user wants to stop, stop cleanly: the board is usable at any point after Step 1 of INSTALL.md. Never invent answers. A skipped question stays blank.

## Core interview (during prompts/01-install-core.md)

Opening, say this first, in your own words but with this content: this board is yours, it lives in your Muse, nothing leaves it, and you can change anything about it at any time, including its name, its look, and how I behave. I will ask a few questions and build as we go.

1. Board name and theme
- "What would you like the board to be called?" Default: MyCommandCenter.
- "Dark theme is the default. Keep it, or would you like to see a light theme?" Apply the choice. Remind them it can change any time.

2. Starter pack (see TEMPLATE-PACKS.md)
- Describe the three packs in one line each and ask which is closest: Solo / Very Busy Individual, Small Business Operator, Consultant / Client Work.
- Apply the pack. This sets the recurring panel name: Recurring Activities, or Operating Rhythm for Small Business Operator. Confirm the name with the user; they can choose the other one, or their own.

3. What the board must track
- "Is this board for work, personal life, or both?"
- "What are the 3 to 5 areas of your work or life this board has to keep track of?" Use the answers to rename the ten template panels. Any template panel no answer covers keeps its default name from TEMPLATE-PACKS.md; tell the user those are blank spares they can rename or delete later.

4. Coach note
- "What is one short line you would like to see at the top of your board, to keep you on track?" Save it with updatecoachnote. It can be blank.

5. Proactivity tier (OPERATING-RULES.md)
- Explain the three tiers in one sentence each. Recommend Tier 2. Record the choice and restate it once.

6. First real tasks
- "What are the most important things on your plate right now?" Add each as a Priority Rail task, verb-first, no due date or estimate unless they give one. Rank them together, most important first. Aim for 3 to 7. Stop when they run dry; a short real list beats a long invented one.

7. Import offer (details in prompts/02-import-and-personalize.md)
- "Do you keep tasks anywhere else, a task app, notes, a spreadsheet? You can paste a list here, or name the tool and I will walk you through bringing it over. Anything I cannot place goes to your Parking Lot and we sort it together." If they have nothing to import, move on without pressing.

8. Quick Open
- "Which websites do you open every day?" Add each as a Quick Open link, label plus URL. If they give a site name without a URL, confirm the URL with them before adding. Never guess a URL for a private or internal site.

Closing, always say these three things before ending the core interview:
- "Let me know at any time if you want to modify anything about your panel: rename it, move things, add or remove panels. It is yours, nothing is locked."
- "Three phrases that always work: add this to my board, what should I do next, and clean out the Parking Lot with me."
- What happens next: the remaining install steps (import, Email Brief, Bridge, reviews and file log), and that they can do them now or later, in any order, because the board already works.

## Module interviews (short; run inside their setup prompts)

### Email Brief (prompts/03-email-brief-setup.md)
1. "Which email accounts should the brief cover?" Gmail and Outlook are supported first. If an account cannot connect, start with the ones that can and say so plainly.
2. Walk the user through connecting each account in their Muse, one at a time, confirming each connection works before the next.
3. "When should the brief run?" Offer the default: once at the start of their workday on weekdays, with an optional second run around midday covering only what arrived since the first. Let them set times and days.
4. "Whose mail always matters, and what should I screen out?" Record VIP senders if any, and screening preferences. Default screening: newsletters, routine alerts, and generic template recruiter messages are screened out and counted in a tally line.
5. "What are your categories for to-do's, in your own words, the areas of your work and life you sort tasks into?" Record the list exactly as given and write it into the brief instructions, where it feeds the Add to To-do's suggestions (EMAIL-BRIEF.md section 4). Categories always come from the user, never from a shipped list. Subcategories are theirs to add later, item by item.
6. "For each inbox, where do you read it on the web: Gmail, Microsoft 365 Outlook, or personal Outlook?" Record per inbox; this decides the Open button's link pattern (EMAIL-BRIEF.md section 6). If they do not read mail on the web at all, record that too; the Open button simply will not appear for that inbox.

### Bridge (prompts/04-bridge-setup.md)
1. "Do you use other AI chats besides me, and do you use Google Drive?" If no Drive, offer the choices in BRIDGE-PROTOCOL.md section 5, in order. Skipping is a valid outcome; record it and move on.
2. Confirm the folder name: MyCommandCenter Bridge.

### LinkedIn reviews (prompts/05-reviews-and-file-log-setup.md, part A)
1. "Are you on LinkedIn regularly? How many times a day do you realistically check it, and at about what times?" Build the sessions from their real habit, 1 to 4 sessions. Times are labels for checkoffs and optional reminders.
2. "What does a good review mean for you: feed, messages, posting, all of it?" Put the answer in the routine entry's detail.
2b. If you set up reminder jobs for the sessions, say this plainly: the board's session times and the reminder jobs are separate clocks. Changing one does not change the other unless they ask you to update both, and offer to keep them in sync whenever times change.
3. If they are not on LinkedIn: offer the same pattern for another daily review habit, or drop the item. Never force it.

### File Save Log (prompts/05-reviews-and-file-log-setup.md, part B)

Before the questions, run the preflight in prompt 05 part B step 1 and report its result. Do not start this interview if the preflight has already parked the module.

1. "Which folders on your main computer matter most, the places you actually save work?" Default suggestions: their Documents folder, Downloads, Desktop, and their Muse workspace. Let them add or remove. Only the folders they name here are ever watched, and this module covers this one computer only in this version.
2. "Do you run any tools that save a lot of working files of their own, for example scheduled searches, build tools, or other AI tools?" List the folders those tools work in; they go into this user's exclusion config explicitly. Then name the shipped panel exclusions out loud, including .log files, temporary and partial files, and files under folders named .next, .metadata, or Temp, and ask whether any of those would hide real work for this user. Record any exception they name before setup, not after.
3. "Should the full log file live in your Google Drive, or as a local file?" Record the choice for the pinned panel entry. Resolve the actual location on this machine during setup: the real drive or folder the sync app uses, which may not match any example.
4. Read this privacy notice before the choices are finalised: "The log records the name and full path of every file saved in the folders you picked, and nothing else about the files; the scanner never opens them. If the full log lives in Drive, those names and paths are copied there. If a file name itself is sensitive, a client name or a case name, treat that as information this module records, and pick folders and the log location with that in mind."
5. Set expectations plainly, in this order: (a) This module watches their real computer, paths and tools differ per person, and if it does not pass its checks after one troubleshooting pass, it is parked and revisited in a later version, with the rest of the board unaffected (FILE-SAVE-LOG.md section 6). (b) Scans run every 15 minutes only while they are logged in; nothing is captured in real time while the machine is asleep, off, or logged out, and the next scan after logon picks changes up. (c) A scan takes longer the more files are in the chosen folders; their first verified run time will be measured and told to them. (d) Occasionally a file cannot be read on one pass, for example a cloud placeholder or a very long path; it is skipped and picked up on a later cycle, so a save can show up one cycle late. (e) Board entries carry the file path as text they can copy; opening a file from the board is a separate optional extra, not part of this install.
