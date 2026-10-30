# Prompt 03: Email Brief setup

Step 3 of 6 in INSTALL.md. Sets up the Email Brief, a core module.

---

You are setting up my Email Brief per spec/EMAIL-BRIEF.md. Read that file and spec/INTERVIEW.md (Email Brief module interview) first.

1. Run the Email Brief module interview: which inboxes, walk me through connecting each email account in my Muse one at a time and confirm each connection works before the next, brief times and days, VIP senders, and screening preferences. Also collect the two things the brief writer needs from me:
- My category list for to-do's, in my own words (the areas of my work and life). Write this list into my brief instructions. Never substitute a list from anywhere else.
- Which webmail each inbox is read in (Gmail, Microsoft 365 Outlook, or personal Outlook), so Open links can be built correctly.

2. Create the Email Brief routine item in my recurring panel (check getdashboard first; create it only if it does not exist).

3. Set up the scheduled brief job for the times I chose, following spec/EMAIL-BRIEF.md exactly. The job's instructions must include, word for word in effect:
- The bullet format rule: exactly one bullet per source message in the action and FYI sections, and every bullet's bold lead must stand alone as a to-do title.
- The TODOSUGGEST metadata rule (EMAIL-BRIEF.md section 4): append the invisible metadata comment at the end of the board and file versions of each brief, never in the chat version; fields only when the source email supports them, due_date only for a deadline the email itself states, categories only from my list; and when briefs stack in the panel, each run keeps its own metadata comment attached to its own run.
- The open_url rule (EMAIL-BRIEF.md section 6): build a deep link for every bullet tied to a specific message, using the pattern for that inbox's webmail; omit it rather than guessing.
- The sections, the screening defaults, the rolling 3-run stack in the routine item's notes, and saving each brief as a file.
- Never send, reply to, or draft mail as part of the brief, and never add any delete affordance to a brief.

4. Run one live test brief now, over the inboxes that are connected, label it clearly as the test run, show it to me in chat (without the metadata comment), and write the board version, with its metadata, into the routine item. Then open the brief with me in the board reader so I can see the Add to To-do's buttons, and, where a deep link exists, an Open button on the bullets.

5. Checkpoint: show me the scheduled job exists with the right times, the test brief is in the panel (read the board back), my category list and webmail choices are recorded in the brief instructions, and tell me how to change the times or categories later (by asking you) and that the brief will run on schedule from now on.
