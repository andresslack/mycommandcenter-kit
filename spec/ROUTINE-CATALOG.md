# Routine Catalog and Entry Types

Version: current kit version (see the VERSION file at the kit root)
The recurring panel runs on a typed entry system. This file defines the seven entry types, their behaviour, and the standard catalog. seed/SEED.json is the machine-readable seed; if the two ever disagree, SEED.json wins for what gets built, and this file explains the behaviour.

## 1. The type system

- The recurring panel's "+" opens a type picker (other panels keep the simple title-only add). Seven types:
  1. Daily check: due every day; checked with a date.
  2. Weekday-only check: due Monday to Friday only; checked with a date.
  3. Multiple times a day: the sessions model (section 2).
  4. Brief / report: carries long notes text and opens in the reader view; the Email Brief entry is this type (EMAIL-BRIEF.md). Not a checkoff entry.
  5. Weekly check: the user picks the due weekday; checked per week (weeks run Monday to Sunday, the same rule the cue pills use).
  6. Monthly check: due day 1 to 29 picked by the user, or "Last day of Month", stored distinctly as the value "last" and resolved to each month's real final day. Legacy stored values 30 and 31 are read as "last".
  7. Every N days: an interval in days; due when N days have passed since the last check (or since creation, if never checked).
- Behaviour keys off the stored type and its config, never the entry's title. Renaming an entry never strips its behaviour, its checkoffs, or its cue pills. Never implement behaviour by matching titles.
- Entries are draggable within the panel (grip, plus Up and Down keys), persisting sort order only, under the drag model in SPEC.md section 2.7.
- The entry editor has no Status and no Due fields (standard-panel editors keep both). An entry can still carry a stored status, shown by its dot; never strip stored values.
- Per-entry links: an entry supports a list of links (label plus destination, up to 20), editable in the entry's Edit window and rendered clickable on the entry, under SPEC.md section 7 surface 3. A pre-existing single link on an entry migrates in as the first list item.
- The weekly audit at the top of the panel is panel-level furniture, not an entry, and is not draggable.

## 2. Sessions (Multiple times a day)

- Each session has a stable key, a label, and a time. Per-session completions are stored against the session key, not the label.
- Relabeling or retiming a session never erases that day's check for it. Removing a session removes its future checkoffs; its past record is simply no longer shown. Adding a session adds an unchecked session for today.
- At least one session is required. Sessions display sorted by time. Sessions are fully editable: add, remove, relabel, retime.
- Board session times are board-only state. If the setup created external reminder jobs for a reviews entry, changing the board's session times does not retime those jobs. Muse must either update both when the user changes times, or tell the user plainly that they are separate and offer to update the reminders too.

## 3. Due-soon cue pills (weekly and monthly entries only)

Filled badges. Warning tier: solid gold #d4a72c with near-black text. Urgent tier: deepened red #b23a26 with white text. (A lighter red does not reach readable contrast with white text; both of these tiers meet WCAG AA against the panel fill.) The same colors are used for the to-do priority-tag pills (SPEC.md section 2.5).

Weekly entries:
- Gold "Due tomorrow" on the day before the due weekday.
- Red "Due today" on the due weekday.
- Red "Past due · due <Ddd Mon D>" from the day after the due weekday until the entry is checked for that week or the week rolls over.
- Nothing is shown when the entry is checked for the current week, when no weekday is set, or when the due day is more than a day away.

Monthly entries:
- Gold "Due in N days" when the due day is within 3 days.
- Red "Due today" on the due day.
- Red "Overdue · due <Mon D>" once past due, persisting until the entry is checked or the month turns.
- The due day resolves through the "Last day of Month" value, so a "last" entry is due on the 28th, 29th, 30th, or 31st as the month dictates.

Daily, weekday, sessions, brief, and interval entries show no cue pills in this version.

## 4. Catalog: seeded at core install (all packs)

Seeded with their types (types in brackets):
- Daily board review [Daily check]. Detail: Open the board, look at the To-do's list, pick the day's top items.
- Empty the Parking Lot [Weekly check; weekday picked in the interview, or left unset until the user picks one]. Detail: Move every Parking Lot item to a permanent panel, convert it to a to-do, or delete it. This entry protects the Parking Lot from becoming storage (OPERATING-RULES.md, routine behaviours).
- Weekly audit [Weekly check; same weekday note]. Detail: Wins, stalls, next week focus. Done with Muse, the result is saved to the board's weekly audit via saveweeklyaudit.

## 5. Pack additions

Small Business Operator adds:
- Weekly money check [Weekly check]. Cash position, bills due this week, invoices waiting.
- Customer follow-up review [Weekly check]. Which customers are waiting on something from us.

Consultant / Client Work adds:
- Client follow-up review [Weekly check]. Which clients are waiting on something from me.

## 6. Created by module setups (not seeded)

- Email Brief [Brief / report]. Created by prompts/03-email-brief-setup.md. Its notes carry the rolling combined stack, today and the previous four calendar days (EMAIL-BRIEF.md section 7). Never create a second Email Brief entry. (The entry the Email Brief setup actually creates carries the dedicated "Email briefs" type, EMAIL-BRIEF.md section 2b; the generic Brief / report type described here is a different, ordinary type.)
- Daily reviews entry [Multiple times a day]. Created by prompts/05-reviews-and-file-log-setup.md part A. Title from the user's habit (for example "LinkedIn Daily Reviews"). Sessions are the times the user named. If the user has more than one review habit, create one entry per habit, each with its own sessions; never merge two habits into one entry.

## 7. Rules for all recurring entries

- A recurring entry is a checklist entry, not a to-do: it never goes on the To-do's rail, and checking it never creates a to-do.
- Entries can be added, renamed, re-typed or re-configured (cycle, weekday, due day, interval, sessions), or removed by the user at any time, except the Email Brief entry, whose notes format is load-bearing: renaming it is fine, deleting it pauses the board copy of the brief (the setup prompt can recreate it, and Muse should say that if the user deletes it).
- Muse never checks an entry or a session off on the user's behalf (OPERATING-RULES.md rule 2).
- Migration: converting an existing untyped entry to this system must be lossless. Checkoffs recorded under the older model (for example a reviews entry's same-day session checks) carry into the typed model intact, against the session keys created for them. The upgrade prompt promises this; keep the promise testable.
