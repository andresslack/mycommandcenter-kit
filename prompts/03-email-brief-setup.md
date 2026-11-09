# Prompt 03: Email Brief setup

Step 3 of 6 in INSTALL.md. Sets up the Email Brief, a core module.

---

You are setting up my Email Brief per spec/EMAIL-BRIEF.md. Read that file and spec/INTERVIEW.md (Email Brief module interview) first.

1. Run the Email Brief module interview: which inboxes, walk me through connecting each email account in my Muse one at a time and confirm each connection works before the next, brief times and days, VIP senders, and screening preferences. Also collect the two things the brief writer needs from me:
- My categories for to-do's, in my own words (the areas of my work and life), and for each category, my subcategories for it, in my own words. Save them into my board's Category/SubCategory taxonomy table (spec/SPEC.md section 2.8) with the taxonomy update action, in the order I gave them. That table is the one source for both the board's Category and SubCategory dropdowns and the brief's category suggestions, so the brief writer reads its category list from my table. If my brief instructions also record the list, record this same list, from the table, and keep the two in sync when the table changes (I change it in the taxonomy editor, or by asking you, and you update the recorded copy the same way). Never substitute a list from anywhere else.
- Which webmail each inbox is read in (Gmail, Microsoft 365 Outlook, or personal Outlook), so Open links can be built correctly.

2. Create the Email Brief routine item in my recurring panel (check getdashboard first; create it only if it does not exist).

3. Create the single "Email Brief" board entry with its five slots set to the times I chose (blank for the rest), and set up the weekday checker job (every 15 minutes, Monday to Friday) that reads those slot times from the entry, following spec/EMAIL-BRIEF.md exactly. The job's instructions must include, word for word in effect:
- The bullet format rule: exactly one bullet per source message in the action and FYI sections, and every bullet's bold lead must stand alone as a to-do title.
- The TODOSUGGEST metadata rule (EMAIL-BRIEF.md section 4): append the invisible metadata comment at the end of the board and file versions of each brief; fields only when the source email supports them, due_date only for a deadline the email itself states, categories and subcategories only from my board's taxonomy table; and in the combined stack, each run keeps its own metadata comment attached to its own run, subject only to the section 7 fit steps.
- No chat delivery: scheduled runs write to the board and the brief files only, and the watermark window rule (EMAIL-BRIEF.md sections 2b and 3): each run covers mail since the last completed brief, and the watermark advances only after a successful board write.
- The open_url rule (EMAIL-BRIEF.md section 6): build a deep link for every bullet tied to a specific message, using the pattern for that inbox's webmail; omit it rather than guessing.
- The sections, the screening defaults, the combined stack in the single entry's notes (days newest first, briefs in slot-time order, the "# {compact} Brief - {date}" headings, and the section 7 fit steps for the 100,000-character notes cap, with their hard rules and the fail-loudly rule), and saving each brief as a file.
- The warning rule (EMAIL-BRIEF.md section 7): when a fit step cuts content or a whole day, the stack says so in the affected brief's own text block: the warning line under the cut brief's title ending with a "[Full brief]" link to that brief's file in the "Email Briefs - Full Text" folder in my Google Drive (create the folder if it is absent; upload only for briefs that receive a warning, updating a same-named file in place), the stub block for a dropped day, and the no-link fallback with a log note when the upload cannot be made or I have no Drive connection.
- Never send, reply to, or draft mail as part of the brief, and never add any delete affordance to a brief.

4. Run one live test brief now, over the inboxes that are connected, label it clearly as the test run, show it to me in chat (without the metadata comment), and write the board version, with its metadata, into the routine item. Then open the brief with me in the board reader so I can see the Add to To-do's buttons, and, where a deep link exists, an Open button on the bullets.

5. Checkpoint: show me the scheduled job exists with the right times, the test brief is in the panel (read the board back), and read my taxonomy table back from the board and show me my categories and their subcategories exactly as stored, so I can confirm they are mine and correct. Show me that the brief instructions take the category list from that table (or record the same list, from the table), and my webmail choices are recorded in the brief instructions, and tell me how to change the times later (in the entry's Edit window, one time field per slot, or by asking you), how to change categories and subcategories later (in the taxonomy editor in the expanded To-do's, or by asking you, which updates the same table), and that the brief will run on schedule from now on.
