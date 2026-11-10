# Email Brief Specification

Version: current kit version (see the VERSION file at the kit root)
Module: Email Brief (core module). It is called Email Brief, never "morning brief", because each user chooses their own run times.

## 1. Purpose

On a schedule the user sets, read the user's connected inboxes and produce a short brief: what needs action, what has a deadline, what is worth noticing, and what is FYI. Briefs are stored on the board only; scheduled runs deliver nothing to chat. On the board, every action and FYI bullet carries an "Add to To-do's" button that opens a prefilled task-entry modal (section 5), and, where a deep link is available, an "Open" button that opens the source email (section 6).

## 2. Setup contract

- Inboxes: Gmail and Outlook are the supported first providers. Connect accounts one at a time with the user's involvement, confirming each works before the next. If a provider cannot connect, start with what works and say so.
- Starting with one inbox is valid. Adding inboxes later changes nothing else.
- Schedule: the board entry carries five brief slots (section 2b). The user enters a time for each slot in the entry's Edit window; a slot left blank is off, so one to five briefs a day are possible. Briefs run Monday to Friday only. A single checker job runs every 15 minutes on weekdays, reads the slot times from the board entry, and produces a brief whenever a slot's time has arrived and that slot has not run today (a brief may land up to about 15 minutes after its slot time). If several slots are due at once, one brief covers them all, attributed to the latest due slot, and every due slot is marked complete. A slot whose time is edited mid-day counts as a fresh slot and runs once at its new time.
- The setup interview also collects, and writes into the user's own brief instructions:
  - The user's categories and subcategories for to-do's (their own words for the areas of their work and life), collected in the interview (INTERVIEW.md) and stored in the board's Category/SubCategory taxonomy table (SPEC.md section 2.8). That table is the one source for the brief's category suggestions and for the board's dropdowns. Categories are never shipped with the kit; every install collects its own. The brief reads its suggestions from the table at run time. If the brief instructions also record the list, that recording is a mirror only, taken from the table at setup and refreshed by Muse whenever it changes the table, and the table wins on any disagreement.
  - Which webmail each inbox is read in (Gmail, Microsoft 365 Outlook, or personal Outlook), which decides the Open link pattern in section 6.
  - VIP senders and screening preferences.
- All of these can be changed at any time by asking.

## 2b. The board entry

- One routine entry in the recurring panel, named "Email Brief", holds everything: the five slots, the day's checkoffs, and the combined brief stack in its notes. There are never separate entries per run time.
- The entry is a multi-session routine entry (SPEC.md, routine entries): its config stores five sessions (keys s1 to s5), each with a label ("Brief 1" to "Brief 5") and a time in 24-hour "HH:MM" form, or blank. Editing the entry exposes one time field per slot. The entry carries the dedicated routine type "Email briefs", which is what keys all of this section's editor treatments (the original entry is also recognized). The New Entry form offers "Email briefs" as a type, creating the entry with the five blank slots and the standard detail line, and it is singleton-guarded: if an Email briefs entry already exists, the form names it and creates nothing, and the server rejects a second one as well. The generic "Brief / report" type is a different, ordinary type and never gets these treatments.
- The entry's detail line reads exactly: "Up to 5 briefs a day, Mon-Fri. 'Edit' to change times." The same slot editor is also reachable from the Settings dialog's Brief times row (SPEC.md section 9); there is only one editor. In this entry's session editor, the per-session TIME inputs carry a green fill (a tint of the board's done green) so the times read as the editable values; other entries' session editors keep the plain fill. The five sessions are fixed in this entry's editor: no label inputs and no LABEL header (the stored labels are not presented or editable), no Add session, and no Remove buttons; an italic blue helper line immediately below the first TIME header states that leaving a time empty turns that slot off. The editor for this entry also has no Delete button (the entry is machine-owned; deleting it would break the brief system), while other entries keep theirs. The saved configuration always carries the five keyed sessions. Other entries' session editors keep editable labels, Add session, and Remove.
- Slot display: a slot with a time entered shows just its time, in the compact form used by the brief headings (no leading zero, lowercase am/pm, minutes only when nonzero: "5am", "1pm", "6:30am"), and not its "Brief x" label. A blank slot still shows its label, so it stays findable for editing. Clicking a slot marks that slot complete for today, whichever text it shows.
- A "View" button sits immediately to the right of the entry's title. It opens the brief reader modal with the entry's full combined stack (section 7).
- A watermark, kept with the scheduled job's state (not on the board), records the end of the last completed brief's window. Each run covers mail received after the watermark, and the watermark advances only after a brief has been written to the board successfully. A missed or failed run therefore never loses mail: the next brief covers the longer window. Monday's first brief covers everything since Friday's last brief, weekend mail included.

## 3. What a run does

1. Read new mail in every connected inbox since the watermark (the end of the last completed brief's window; first run ever: the last 24 hours), including junk and spam folders, since real mail lands there. Read-only: the brief never sends, replies, forwards, or drafts mail. There is no delete affordance in the brief, in this version or by add-on; do not build one.
2. Sort what it finds into four sections, in this order:
- Needs action: a person is waiting on the user, or a decision is required.
- Deadlines: anything with a date attached, with the date.
- Signals: opportunities, changes, or problems worth noticing even if no action is due.
- FYI: everything else worth one line.

### 3.1 Bullet format rule (binding on every brief writer)

- Every item in the Needs action and FYI sections is exactly one bullet per source message. Never merge two messages into one bullet; never split one message across two bullets.
- Each bullet's bold lead is a complete, self-contained one-clause summary that works on its own as a to-do title. Detail goes after the bold lead, never inside it.
- Bullets without a bold lead are allowed, but they render plain, with no Add to To-do's button.
- Before labelling anything an opportunity or a follow-up, check the board: if it is already tracked, already decided, or already on the rail, say that instead of presenting it as new.

### 3.2 Screening

Applied before the sections: newsletters, routine automated alerts, and generic template recruiter messages (first contact, no named employer, role, or project, formulaic praise) are screened out; a generic LinkedIn InMail recruiter message is the standing example of the recruiter class. Screened messages are never surfaced individually. If at least one generic LinkedIn InMail recruiter message is screened in a window, the brief carries exactly one tally line, at the end of FYI: "Screened: N generic LinkedIn InMail recruiter message(s)." When nothing is screened in a window, the brief says nothing about screening anywhere, including in its coverage line: the coverage line (section 7) states which inboxes were swept and the window covered, and nothing about screening. Never screen mail from a named person in an existing conversation thread; if unsure, include it in FYI.

### 3.3 No carry-overs (binding on every brief writer)

- Each run reports only messages received in its own window that have not already been reported in an earlier brief.
- Never repeat an item because it is still open or because its deadline is near, and never label anything "(carried over)".
- A new message about a known item is new mail: report it on its own, in the run where it arrived.

## 4. Suggestion metadata (the TODOSUGGEST channel)

At the end of the board and file versions of each brief, the brief writer appends one invisible HTML comment:

<!--TODOSUGGEST {"<exact bold lead>": {"due_date": "...", "category": "...", "sub_category": "...", "waiting_on": "...", "estimate": "...", "notes": "...", "priority_tag": "...", "open_url": "..."}}-->

Rules for the writer:
- Keys are the bullets' exact bold lead texts.
- Include a field only when the source email actually supports it. Never invent values.
- due_date: only for a deadline the email itself states, resolved to an absolute YYYY-MM-DD date.
- category and sub_category: only from the user's own taxonomy table (SPEC.md section 2.8), collected at setup (section 2). A sub_category suggestion must be one listed under the suggested category in that table. Waiting On and SubCategory are distinct fields; never merge them.
- estimate: only when the email makes the effort obvious; use the rail's estimate values (15m, 30m, 1h, 2h, and so on; a half day is 4hr).
- priority_tag: only "Important" or "Critical", and only when the email supports it (SPEC.md, priority tags).
- notes: only facts from the email that help do the task.
- open_url: per section 6.
- In the combined stack (section 7), each run's metadata comment stays attached to its own run. Never merge two runs' metadata. The stack fit steps in section 7 may remove the oldest days' comments, in their stated order, only when the notes limit requires it.

## 5. The Add to To-do's modal (board behaviour; see also SPEC.md)

- Every Needs action and FYI bullet with a bold lead renders a gold "Add to To-do's" button in the brief reader. Clicking it opens a modal with the full expanded to-do field set, prefilled:
  - Name = the bold lead. Context = the full bullet text, including its mailbox tag and the brief name.
  - Due Date, Category, SubCategory, Waiting On, Estimate, Notes, and Priority Tag prefilled from the TODOSUGGEST metadata for that bullet (primary source), falling back to explicit signals in the bullet text.
- Nothing is added until the user confirms in the modal. Cancel, clicking the backdrop, and Escape add nothing.
- A successful add flips that bullet's button to "Added ✓", even if the user edited the name in the modal. Matching is by open task (title match after the add, using the same dedupe as the rail): while a matching open task exists, the button shows "Added ✓"; when that task is completed or deleted, the button frees up. This is what stops bullets anywhere in the stack from ever duplicating.
- Adding from the modal places the task at the bottom of the rail (the end of the user's manual order). Due dates in the metadata do not change that; the board's own due-soon view ordering still surfaces it.
- Date-parsing caution when inferring anything from bullet text: skip year-less dates that are followed by a time of day (those are message timestamps, not deadlines), and never roll a recently-past year-less date forward a year.
- Proactivity tiers (OPERATING-RULES.md) still govern what Muse itself adds from a brief without the user clicking: Tier 1 and 2, Muse adds nothing from the brief on its own; the modal is the path. Tier 3, Muse may also add directly and reports what it added in the brief. The modal exists at every tier, because it is the user's action, not Muse's.

## 6. The Open button

- Beside "Add to To-do's", a quiet "Open" pill appears when the bullet's metadata carries open_url. It opens the source email at its mailbox web interface in a new tab (target=_blank, rel="noopener noreferrer"), and it stays available after the item has been added. Opening is read-only.
- Button row: in the reader, each bullet's Open pill and its Add to To-do's button (or its Added state, when the bullet has been added) always sit together on one dedicated row of their own, directly under the bullet's text, never inline within the text and never split across rows. The row is aligned to the right end of the bullet's block (far right), and the controls are slim: reduced vertical padding with a line-height of 1.2. Within the row, the Open pill comes first, then the Add control. A bullet with no Open pill shows the row carrying just the Add control.
- Writer side: add open_url for every bullet that corresponds to a specific message, built from the message's own identifiers:
  - Gmail: https://mail.google.com/mail/?authuser=<mailbox address>#inbox/<message id> (use #spam/<id> when the message was found in Spam)
  - Microsoft 365: use the message's webLink value verbatim when the mail API provides one. Otherwise: https://outlook.office365.com/owa/?ItemID=<converted message id>&exvsurl=1&viewmodel=ReadMessageItem (works from any folder, including Junk)
  - Personal Outlook: https://outlook.live.com/mail/deeplink/read/<converted message id>?ItemID=<same converted id>&exvsurl=1 (works from any folder, including Junk)
  - Outlook message id conversion (applies to both Outlook patterns above): in the raw message id, replace every _ with + and every - with /, then URL-encode the result (+ becomes %2B, / becomes %2F, = becomes %3D). Skipping the conversion produces links that do not open the message.
  - If an exact deep link cannot be formed from the identifiers actually available, omit open_url rather than guessing. The button simply does not appear.
- Board side validation: render the Open button only for https URLs on these hosts: mail.google.com, outlook.office365.com, outlook.office.com, outlook.live.com. Any other value renders no button, and the value is never rendered as a link anywhere else.

## 7. Where the brief goes

- On the board only. Scheduled runs deliver nothing to chat.
- Into the notes of the single "Email Brief" routine entry (section 2b), as one combined stack: days newest first, and within a day, that day's briefs newest first, in reverse slot-time order (the day's latest brief first, its earliest last), so the whole stack reads newest on top throughout; each brief is separated by a line containing only ---. Keep at most today and the previous four calendar days.
- Each brief is headed "# {compact} Brief - {Weekday Mon D, YYYY}", with {compact} the slot's time in compact form (section 2b), followed by its coverage line (which inboxes, since when; the coverage line says nothing about screening, per section 3.2). Each brief's TODOSUGGEST comment stays at the end of that brief's text.
- The board notes field is capped at 100,000 characters, so apply these fit steps in order until the stack fits: (a) shorten every prior day (all except today) to its Needs action items only, keeping each brief's heading, its Needs action section, a note that the full text is in the brief files, and its TODOSUGGEST comment filtered to the bullets that remain; (b) remove the TODOSUGGEST comment entirely from the oldest day, then the next oldest, until it fits; (c) drop the oldest day entirely, then the next, until it fits; (d) drop every remaining prior day before touching today; (e) only then trim summary prose from today's briefs, oldest brief of today first, and never trim the newest brief of today. Hard rules: a brief's TODOSUGGEST comment is kept whole or removed whole, never filtered to a subset outside step (a)'s matched trim; today is never sacrificed for a prior day; if the stack is still over the cap after step (e), the run fails loudly instead of cutting further (section 8). Warning rule: whenever a fit step removes content from a brief (steps (a) or (e)) or removes a brief's metadata (step (b)), place this line on its own line directly under that brief's title line in the stack: "⚠ Warning: part of this brief was cut to fit the board's length limit. The full brief is saved in the briefs folder. [Full brief](<link>)", where <link> is the web link of that brief's file, uploaded for this purpose to a folder named "Email Briefs - Full Text" in the user's Google Drive (create the folder if it is absent; upload the brief's saved file, updating it in place if a file of that name is already there; upload only for briefs that receive a warning). When a whole day is dropped (steps (c) or (d)), leave a stub block where the day would have stood: that day's earliest brief heading line, then this line: "⚠ Warning: this day's briefs were cut entirely to fit the board's length limit. The full briefs are saved in the briefs folder. [Full briefs](<folder link>)". If the Drive upload fails, or the install has no Google Drive connection, place the warning without the bracketed link and say so in the run's log line. In the brief reader, a line starting with "⚠ " renders as its own block line in urgent red and semibold, and a trailing bracketed link on such a line renders as a real link in the same red. A brief published whole carries no warning; never add one speculatively.
- As a file: save each run as email-brief-YYYY-MM-DD-HHMM.md (the slot's time) in the user's Muse workspace, with the same TODOSUGGEST comment, so the panel limit loses nothing.

## 8. Failure behaviour

- If an inbox cannot be read on a run, brief the rest and name the inbox that failed at the top of the brief. Do not present a partial brief as complete.
- If a run fails before the brief is written to the board, the watermark does not advance and the slot is not marked complete, so the next checker run retries the same window. Never silently skip a day: surface repeated failures at the next conversation.
- If the stack cannot be made to fit even after every fit step in section 7, that is a failure of this same kind: nothing is pushed, the watermark does not advance, and the run says so loudly in its log line. A brief is never silently cut beyond the fit steps to force it in.
