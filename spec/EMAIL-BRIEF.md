# Email Brief Specification

Version: 0.1.1
Module: Email Brief (core module). It is called Email Brief, never "morning brief", because each user chooses their own run times.

## 1. Purpose

On a schedule the user sets, read the user's connected inboxes and produce a short brief: what needs action, what has a deadline, what is worth noticing, and what is FYI. Deliver it in chat and store it on the board, where every action and FYI bullet carries an "Add to To-do's" button that opens a prefilled task-entry modal (section 5), and, where a deep link is available, an "Open" button that opens the source email (section 6).

## 2. Setup contract

- Inboxes: Gmail and Outlook are the supported first providers. Connect accounts one at a time with the user's involvement, confirming each works before the next. If a provider cannot connect, start with what works and say so.
- Starting with one inbox is valid. Adding inboxes later changes nothing else.
- Schedule: the user picks days and times. Default offer: weekdays at the start of the user's workday, plus an optional second run around midday that covers only mail arrived since the previous run and skips items already briefed unless they changed.
- The setup interview also collects, and writes into the user's own brief instructions:
  - The user's category list for to-do's (their own words for the areas of their work and life). Categories are never shipped with the kit; every install collects its own.
  - Which webmail each inbox is read in (Gmail, Microsoft 365 Outlook, or personal Outlook), which decides the Open link pattern in section 6.
  - VIP senders and screening preferences.
- All of these can be changed at any time by asking.

## 3. What a run does

1. Read new mail in every connected inbox since the previous run (first run: the last 24 hours), including junk and spam folders, since real mail lands there. Read-only: the brief never sends, replies, forwards, or drafts mail. There is no delete affordance in the brief, in this version or by add-on; do not build one.
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

Applied before the sections: newsletters, routine automated alerts, and generic template recruiter messages (first contact, no named employer, role, or project, formulaic praise) are screened out. If the screened count is greater than zero, add one tally line at the end: "Screened: N routine message(s)." Never screen mail from a named person in an existing conversation thread; if unsure, include it in FYI.

## 4. Suggestion metadata (the TODOSUGGEST channel)

At the end of the board and file versions of each brief, never in the chat-delivered brief, the brief writer appends one invisible HTML comment:

<!--TODOSUGGEST {"<exact bold lead>": {"due_date": "...", "category": "...", "sub_category": "...", "waiting_on": "...", "estimate": "...", "notes": "...", "priority_tag": "...", "open_url": "..."}}-->

Rules for the writer:
- Keys are the bullets' exact bold lead texts.
- Include a field only when the source email actually supports it. Never invent values.
- due_date: only for a deadline the email itself states, resolved to an absolute YYYY-MM-DD date.
- category and sub_category: only from the user's own category list, collected at setup (section 2). Waiting On and SubCategory are distinct fields; never merge them.
- estimate: only when the email makes the effort obvious; use the rail's estimate values (15m, 30m, 1h, 2h, and so on; a half day is 4hr).
- priority_tag: only "Important" or "Critical", and only when the email supports it (SPEC.md, priority tags).
- notes: only facts from the email that help do the task.
- open_url: per section 6.
- In a stacked brief (the recurring panel keeps the last 3 runs), each run's metadata comment stays attached to its own run. Never strip a run's comment when stacking, and never merge two runs' metadata.

## 5. The Add to To-do's modal (board behaviour; see also SPEC.md)

- Every Needs action and FYI bullet with a bold lead renders a gold "Add to To-do's" button in the brief reader. Clicking it opens a modal with the full expanded to-do field set, prefilled:
  - Name = the bold lead. Context = the full bullet text, including its mailbox tag and the brief name.
  - Due Date, Category, SubCategory, Waiting On, Estimate, Notes, and Priority Tag prefilled from the TODOSUGGEST metadata for that bullet (primary source), falling back to explicit signals in the bullet text.
- Nothing is added until the user confirms in the modal. Cancel, clicking the backdrop, and Escape add nothing.
- A successful add flips that bullet's button to "Added ✓", even if the user edited the name in the modal. Matching is by open task (title match after the add, using the same dedupe as the rail): while a matching open task exists, the button shows "Added ✓"; when that task is completed or deleted, the button frees up. This is what stops carried-over bullets in a 3-run stack from ever duplicating.
- Adding from the modal places the task at the bottom of the rail (the end of the user's manual order). Due dates in the metadata do not change that; the board's own due-soon view ordering still surfaces it.
- Date-parsing caution when inferring anything from bullet text: skip year-less dates that are followed by a time of day (those are message timestamps, not deadlines), and never roll a recently-past year-less date forward a year.
- Proactivity tiers (OPERATING-RULES.md) still govern what Muse itself adds from a brief without the user clicking: Tier 1 and 2, Muse adds nothing from the brief on its own; the modal is the path. Tier 3, Muse may also add directly and reports what it added in the brief. The modal exists at every tier, because it is the user's action, not Muse's.

## 6. The Open button

- Beside "Add to To-do's", a quiet "Open" pill appears when the bullet's metadata carries open_url. It opens the source email at its mailbox web interface in a new tab (target=_blank, rel="noopener noreferrer"), and it stays available after the item has been added. Opening is read-only.
- Writer side: add open_url for every bullet that corresponds to a specific message, built from the message's own identifiers:
  - Gmail: https://mail.google.com/mail/?authuser=<mailbox address>#inbox/<message id> (use #spam/<id> when the message was found in Spam)
  - Microsoft 365: https://outlook.office.com/mail/inbox/id/<URL-encoded message id> (use /mail/junkemail/id/ for Junk)
  - Personal Outlook: https://outlook.live.com/mail/0/inbox/id/<URL-encoded message id> (use /mail/0/junkemail/id/ for Junk)
  - If an exact deep link cannot be formed from the identifiers actually available, omit open_url rather than guessing. The button simply does not appear.
- Board side validation: render the Open button only for https URLs on these three hosts: mail.google.com, outlook.office.com, outlook.live.com. Any other value renders no button, and the value is never rendered as a link anywhere else.

## 7. Where the brief goes

- In chat, as the run's delivery. The chat version carries no TODOSUGGEST comment.
- On the board: into the notes of the "Email Brief" routine item in the recurring panel, as a rolling stack of the last 3 runs, newest on top, each run headed with its date, time, and coverage line (which inboxes, since when), runs separated by a line containing only ---, and each run's TODOSUGGEST comment kept with its run at the end of that run's text. The 4th oldest run drops off the panel.
- As a file: save each run as email-brief-YYYY-MM-DD-HHMM.md in the user's Muse workspace, with the same TODOSUGGEST comment, so the panel limit loses nothing.

## 8. Failure behaviour

- If an inbox cannot be read on a run, brief the rest and name the inbox that failed at the top of the brief. Do not present a partial brief as complete.
- If the scheduled job itself fails, tell the user at the next conversation and offer to re-run. Never silently skip a day.
