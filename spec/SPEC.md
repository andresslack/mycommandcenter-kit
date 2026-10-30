# MyCommandCenter Board Specification

Version: 0.1.1
For: the Muse AI that builds and maintains this board, in the user's own Muse environment.

Build a private, fullstack web app (artifact) named MyCommandCenter (the user may choose a different display name during the interview; the internal name stays MyCommandCenter). The app stores its own data in the user's Muse environment. It is never published, shared, or exported. All data belongs to the user.

## 1. Layout

- Far-left vertical rail: the to-do list, headed "To-do's" (Section 2).
- Panel grid to the right of the rail (Section 3). On wide screens (1040px and up) the panels area has its own vertical scrollbar, capped to the viewport height, scrolling independently of the rail. Stacked phone layouts do not.
- The panels heading carries a Collapse all / Expand all toggle and an Add panel button styled to match it, plus the status-dot legend control (Section 3.6).
- Dark theme by default. All panel headers use a uniform slate charcoal fill #1c232e over a panel body fill #101216, including the recurring and links panels. The user may change the theme at any time; a theme change never touches data, and theme-dependent values in this spec are tokens, not fixed colors, where the spec says so.
- Fold controls everywhere are triangles: expanded ▼, collapsed ▶. This covers panel headers, the Done log fold, the weekly-audit fold, and the rail Expand/Collapse button (whose wording and size are unchanged). Add ("+") buttons, the Select-mode button, link icons, and × close buttons are not triangles.
- One editable coach note shown at the top of the board: a single short line of text with an updated-at timestamp.
- Weekly audit entries can be saved: date, wins, stalls, next week focus. Keep all entries, newest first. In the recurring panel, the weekly audit sits at the top of the panel as panel-level furniture: it is not an entry, and it is not draggable.
- Responsive bands: 1040px and up, rail 300px. 820 to 1039px, two-column layout with a 272px rail that is sticky, height-capped, and internally scrolling, and the expanded to-do drawer offset to left: 272px. Under 820px, stacked layout, rail capped at 50dvh with its own scroll.

## 2. To-do's (the Priority Rail)

The rail's heading is "To-do's". (Older drafts called the items "next actions"; that name is retired.)

### 2.1 Task record
Fields, with hard limits a build must enforce:
- title: string, required, 1 to 240 characters
- detail: string or null, max 600 characters (shown as Context in the drawer)
- due_date: string YYYY-MM-DD or null. Must be a real calendar date.
- estimate: one of 15m, 30m, 1h, 2h, 4hr, 6hr, 8hr, 10hr, 12hr, or null
- notes: string or null, max 5000 characters
- category: string or null, from the user's own category list where one exists
- sub_category: string or null. Category and SubCategory are distinct fields; never merge them.
- waiting_on: string or null, max 240 characters
- project_area: string or null, max 240 characters (free-form area label; the Bridge protocol writes this field)
- priority_tag: none, Important, or Critical. Labels only: no numeric priority exists anywhere in this design, deliberately. The manual order is the numbering.
- rank: positive integer, unique among open tasks. This is the saved manual order.
- status: open or done
- completed_at: timestamp or null
- created and updated timestamps (created drives the date-added sorts)

### 2.2 Rail presentation and the compact view
- Three columns: row number, Completed button, action name.
- A collapsed row shows the title, a priority-tag pill if tagged (Section 2.5), and, if set, the due date.
- Clicking a task name in the compact rail opens the expanded To-do's scrolled to that row, with a gold highlight on the row that clears when the drawer closes.
- Completing a task from the compact rail shows no confirmation modal (contrast Section 2.6).
- The add-task form on the rail has a functional Cancel button immediately left of "Add task": it discards the input, closes the form, and saves nothing.

### 2.3 The expanded drawer
- A toggle opens an overlay drawer listing every open task with editable fields. Everyday columns shown by default: Name, Due Date, Context, Notes, Category, SubCategory, Waiting On, Estimate, Priority Tag. All fields are inline editable and save in place.
- Action Name titles wrap to 2 lines at the unchanged column width; ellipsis only beyond 2 lines.
- While editing, the Action Name cell widens to 40ch + 16px with an opaque fill and shadow, the caret anchored at position 0; it returns to column width on save or cancel.
- Editor heights: the Notes editor opens at max(10 rows, which is 184px, the row's full current height). The Context editor opens at max(5 rows, which is 99px, the row's full current height). The taller-row rule wins in both, and any generic editor height cap is lifted for these two cells only. Other cells are unchanged.
- The drawer's Expand/Collapse symbol and the circular "+" are drawn and centered, level with their text label.
- To-do's have no link capability anywhere: no URL field exists on a task, in the drawer, or in the brief Add to To-do's modal. URLs inside notes or brief text are never auto-linked.

### 2.4 Ordering: My order, sort views, Batch

- The saved manual order (rank) is sovereign. It is displayed by the "My order" view, which is the only drag-enabled view: dragging in My order, and only there, rewrites rank.
- A "Sort view…" selector offers ten view-only sorts: Due soonest; Due latest; Title A–Z; Title Z–A; Category; Waiting On; Priority tag: Critical first; Estimate shortest; Estimate longest; Date added oldest; Date added newest. Items with no due date or no estimate sort last in those views. Manual rank breaks all ties. Date-added sorts use the creation timestamp.
- A sort view never rewrites the saved order. The only way to adopt a displayed order is the separate "Make this my order" button, which asks for confirmation and then writes the full displayed order to rank.
- "Batch" button: groups tasks into sections by Category/SubCategory, sections alphabetical A–Z, the blank batch (no category) last. Inside each batch the selected sort applies. The due-within-3-days float (Section 2.5) still applies ahead of grouping. Adopting an order from Batch writes the full flattened displayed order, with confirmation, like any "Make this my order".
- Compatibility note: the due-within-3-days float is a view behaviour of the board, not a change to saved order.

### 2.5 Due-soon float and priority tags
- In every view, tasks due within the next 3 days (today plus 2) are surfaced ahead, in chronological due date order, before the view's own ordering takes over for the rest.
- priority_tag renders as a filled pill beside the title: red #b23a26 with white text for Critical, gold #d4a72c with near-black text for Important. These are the same two tiers and colors as the recurring cue pills (ROUTINE-CATALOG.md); both meet WCAG AA against the panel fill.
- Tags never reorder the saved manual order on their own. They affect only the dedicated sort view and search.

### 2.6 Drawer search and the Done confirmation

- The drawer search searches every field of every open task: Name, Due Date, Context, Notes, Category/SubCategory, Waiting On, Estimate, Priority Tag. Case-insensitive. Multiple words are treated as one exact phrase.
- It shows a live match count, a Clear button, and clears on Escape. A "Name only" scope checkbox exists; searching everywhere is the default.
- While a search is active, every occurrence of the phrase is highlighted in gold in the displayed fields within scope (display-only; an open editor shows plain text), and "Make this my order" is disabled, so a filtered subset can never become the saved order.
- The search input is narrow: 30 percent of the bar's width. Its "SEARCH ALL FIELDS" label uses the same muted color as the "Name only" label.
- Done confirmation modal: completing a task in the expanded view only shows a post-save modal containing the task name with a green "Done", and the text "Item closed; you can undo in the Done Log of the Priority Rail." It auto-dismisses after exactly 5 seconds; the × at top right closes it; Escape and backdrop clicks close it (Escape dismisses the notice before it closes the drawer); retriggering restarts the timer; closing the drawer dismisses it.
- Completing a task sets status done and completed_at, and moves it to the Done log view, timestamped, with undo. Undo restores it as open with its prior rank.
- Delete per row, only after a confirmation that names the task.
- A task is never completed, deleted, or given a due date or estimate by Muse on its own. See OPERATING-RULES.md.

### 2.7 Drag model (applies to rail tasks, panel items, recurring entries, and panels)

One drag model everywhere; do not implement variants.
- During a drag, the dragged element and all others stay put. There is no live reordering on pointer move. Live reordering teleports the dragged element under the pointer and caps movement at one position per drag; that behaviour is a known bug, never reproduce it.
- Midpoint geometry decides the landing slot. A gold line shows in the gap where the element will land. Edge auto-scroll works while dragging.
- The new order is committed once, on drop, and must allow a move of any distance in a single drag.
- Keyboard reordering with arrow keys is supported wherever dragging is (Section 3.3 for panels).
- Hovering any drag handle (panel grip, entry grip, rail grip) shows the plain default arrow cursor, never a grab-hand cursor, in rest, hover, and pressed states. A subtle hover background tint on handles is fine.

## 3. Panels

### 3.1 Panel record
- title: string, required
- kind: routine, standard, or links
- position: integer ordering within its column
- column: integer column index, stored explicitly (Section 3.2)
- collapsed: boolean
- items: list of panel items
- links: list of panel links (standard panels may carry links; the links kind is links only)

### 3.2 Panel layout: stored columns
- Layout is stored, not auto-packed. Each panel carries an explicit column index and a position within that column. Columns may hold different numbers of panels and stay that way across reloads.
- Dropping a panel into a column shifts only the panels below the drop slot in that column. No panel changes columns unless it is dragged there.
- The recurring panel is anchored: it sits at the top of the first column, and anything placed above it is normalized back to below it. Every other panel, including Quick Open, is movable like a standard panel.

### 3.3 Panel dragging
- Panels can be dragged only when all panels are collapsed.
- Blocked-drag modal: grabbing a panel grip while any panel is expanded opens a centered modal containing only the text "To drag a panel all panels will be collapsed first", with Proceed and Cancel buttons. Proceed collapses all panels and closes the modal, on success only (if the collapse fails, the modal stays open and shows the error). Cancel and Escape close it without collapsing. Backdrop clicks do nothing. There is no auto-dismiss timer. (An earlier design used a red banner here; do not build the banner.)
- Trigger-grip highlight: after that modal closes, the grip of the panel that triggered it stays highlighted (persistent gold accent, full opacity, not washed out by any blocked-state dimming). The highlight moves if a different panel triggers the modal, and clears when a drag of that panel finishes or is cancelled, when a keyboard reorder of it completes, or if the panel is deleted.
- Keyboard: Up and Down move within a column, Left and Right move across columns, under the same all-collapsed rule.
- Panel drag uses the Section 2.7 drag model: nothing moves during the drag, a gold line marks the landing gap, one commit on drop.

### 3.4 New-panel flow
- Creating a panel first shows a warning that creating it will collapse all panels; Cancel, Escape, and clicking outside create nothing and collapse nothing.
- On confirm, the new panel lands directly below the recurring panel, blinks gold until the user clicks anywhere on it, and a banner explains it can be dragged wherever they want.

### 3.5 Panel record details, deletion, selection

- Panel item record: title (required, max 240), detail, notes, due_date, status (free text), url (single link field, Section 7 surface 1), sort_order, plus the recurring-only fields in Section 4.
- Panel link record (link drawers): label (max 120 chars), destination (max 2048 chars), sort_order. See Section 7 for clickability rules.
- Panel deletion requires an empty panel, enforced by the board's data layer, not just the UI: zero items AND zero saved drawer links. The trash control on a non-empty panel opens a "Delete all items first" dialog showing the exact item and link counts. Once a panel is empty, a normal delete confirmation still applies. Both safeguards, always.
- System panels (recurring panel, Recent File Saves, Quick Open) cannot be deleted at all.
- Multi-select bulk delete, all non-recurring panels: each panel header has a Select toggle, rendered as a "−" icon button in the same format as the "+" add button; while selecting, that header button reads "Cancel". Checkboxes appear on items; a bulk bar offers, in this order: [Esc] [Select all] [Delete selected (N)], plus a hint. Delete asks for confirmation showing the count, then deletes exactly the selected items in that panel; item IDs from another panel must be refused. The recurring panel is the sole exception: no Select toggle. For Recent File Saves, the confirmation also states that deleted entries stay hidden and the files and master log are untouched (FILE-SAVE-LOG.md).
- Standard panel items can be reordered by drag (Section 2.7 model) and by keyboard.

### 3.6 Status dots, headers, editors

- Status dots: an item's dot reflects its free-text Status. Gold #d4a72c for build, active, or link. Gray #a6adb7 for open, blank, or unrecognized (the default). Red #d66c55 for blocked, waiting, due, or decision. Green #55a879 for routine or personal. Matching is by keyword in the status text. Never rewrite a user's stored Status values to make the dots behave; unknown values simply show gray.
- Legend: a single legend control in the panels heading shows only the four dots, no words. Its modal entries read "Status: ..." (one per meaning), and the modal's backdrop is fully transparent.
- Two-line header rule: the board measures each panel's title against the single-line header space. If any panel's displayed title would be 9 visible characters or fewer, every header switches to two lines (name on line 1; count and controls on line 2), and all headers return to one line together when none qualifies. The switch is board-wide, never per-panel.
- White Edit window: the panel-item Edit window's fill is a theme token, --panel-complement (the complement of the panel fill; white #ffffff in the dark theme), with dark-on-light styling scoped to the editor only. The gold Save button is unchanged. Dialogs and item rows keep the board theme. Never hard-code white; always use the token, so user themes keep working.
- Collapsed-panel add: clicking the add-entry "+" on a collapsed panel expands the panel and leaves the add form open and focused.

### 3.7 Default panel set (15 panels, in order)
1. Recurring panel, kind routine. Display name from the interview: "Recurring Activities" by default, "Operating Rhythm" for the Small Business Operator pack. Internal identity is fixed; renaming never affects routines, the Email Brief, or session checkoffs.
2. Recent File Saves, kind standard, system panel. Items are created only by the File Save Log module.
3. Quick Open, kind links, system panel. Web links the user opens daily.
4. Administrative, kind standard.
5. Parking Lot, kind standard, special rules in Section 5.
6 to 15. Ten template panels, kind standard, blank at seed. Default names in TEMPLATE-PACKS.md; renamed during the interview.

## 4. Recurring panel behaviour

The full entry-type system is specified in ROUTINE-CATALOG.md. The data model here must support it:

- Each recurring entry carries a stored entry_type and a type config. Behaviour keys off the stored type and config, never the entry's title, so renaming an entry never strips its behaviour. (Title-matching behaviour is a known anti-pattern; never reproduce it.)
- Entry types: daily-check; weekday-check; sessions (multiple times a day); brief (carries long notes text and the brief reader, EMAIL-BRIEF.md); weekly-check (config: due weekday); monthly-check (config: due day 1 to 29, or the distinct stored value "last" meaning Last day of Month, resolved to each month's real final day; legacy stored 30 or 31 are read as "last"); interval-check (config: every N days).
- Sessions config: a list of sessions, each with a stable key, a label, and a time. Per-session completions are stored against the session key, not the label, so relabeling or retiming a session never erases that day's check. At least one session is required. Sessions display sorted by time, and are editable: add, remove, relabel, retime.
- Completions: daily and weekday entries carry a completed date; weekly entries a completed week; monthly entries a completed month; interval entries a last-completed date. An entry presents as due per its type's logic (ROUTINE-CATALOG.md).
- The recurring panel's "+" opens a type picker with the seven types. Other panels keep the simple title-only add.
- The recurring entry editor has no Status and no Due fields (standard-panel item editors keep both). An entry may still carry a stored status (shown by its dot); never strip stored values just because the editor no longer exposes the fields.
- Per-entry links: a recurring entry supports a list of links (label plus destination, up to 20 per entry), editable in the entry's Edit window and rendered clickable on the entry (Section 7 surface 3). A single pre-existing link on an entry migrates in as the first list item.
- Recurring entries are draggable within the panel (grip, plus Up and Down keys), persisting sort order only, under the Section 2.7 drag model.
- One entry is reserved for Email Brief notes, type brief (created by the Email Brief setup). Its notes hold the rolling stack specified in EMAIL-BRIEF.md.
- Board session times are board-only state. External reminder jobs created by a module setup are separate; changing board session times does not retime them (the setup prompts keep them in sync explicitly, or warn).

## 5. Parking Lot rules

- Purpose: temporary triage only. Every item here is expected to move to a permanent panel.
- Items Muse places here must carry, in notes: the source of the item and a suggested permanent panel.
- The UI must not treat Parking Lot as a system panel; it is a normal standard panel that happens to be seeded. Its special behaviour is in how Muse uses it (OPERATING-RULES.md rule 6).

## 6. Actions the app must publish (23)

Reads:
- getdashboard: returns coach note, open tasks, completed tasks (done log), panels with items and links, weekly audits.

Tasks:
- addtask (title required; detail, due_date, estimate, notes, category, sub_category, waiting_on, project_area, priority_tag optional)
- updatetask, deletetask, settaskdone (set or clear done), reordertasks

Panels:
- addpanel, updatepanel, deletepanel, setpanelcollapsed, reorderpanels

Panel items:
- addpanelitem, updatepanelitem, deletepanelitem, deletepanelitems (bulk, one panel only), reorderpanelitems. For recurring entries, add and update also carry entry_type and its config, and the per-entry links list.

Panel links:
- addworkstreamlink, updateworkstreamlink, deleteworkstreamlink

Routines and board:
- setroutineitemcompleted (id, completed_on date or null)
- setroutinesessioncompleted (item id, session key, completed_on date or null)
- updatecoachnote
- saveweeklyaudit

Validation the build must enforce: required titles non-empty; due dates are real YYYY-MM-DD dates; estimates from the enum in 2.1; priority_tag only none, Important, or Critical; bulk delete refuses IDs outside the named panel; panel deletion refuses a non-empty panel (items or links) at the data layer; deletes of tasks, panels, and panel items execute only after the caller's confirmation step (the confirmation itself is a UI and Muse behaviour rule, OPERATING-RULES.md).

## 7. Link rules: three surfaces, kept separate

Conflating these surfaces causes real bugs. Spec and build them apart.

Surface 1, the single Link field (standard-panel and links-panel items): the destination is stored verbatim and rendered as a raw link. https works; a pre-formed custom-protocol URL works. A bare local path typed here is not converted and will not open properly; that is expected, do not "fix" stored values.

Surfaces 2 and 3, panel link drawers (multiple links per standard panel) and recurring-entry link lists: both are gated by one renderer rule. Clickable: http:// and https:// on any domain; onenote: links; file:// links; and local Windows paths (drive-letter or UNC), which are converted to the local-opener protocol of the optional local-files module (the opener URL is the protocol name plus the fully percent-encoded path; the module keeps its own allowlist of folders and blocks scripts and executables). Everything else (mailto:, tel:, ftp:, custom app schemes, ready-made opener URLs, relative paths, bare names) is stored and shown as plain text with a Copy control.

Server-side validation, surfaces 2 and 3 only: destination non-empty, label at most 120 characters, destination at most 2048 characters. Clickability is purely a rendering decision.

Preservation rules: never clean up, normalize, or re-encode a stored destination. Moving a link between surfaces changes its clickability, and that is correct behaviour, not data loss. (Many note-app links are in fact https URLs with an embedded app suffix and open as web pages; that is fine.)

## 8. Seed

Build the board empty of content: panels and routine entries from SEED.json for the chosen pack (routine entries seeded with their types), no tasks, no panel items with invented content, no links except any the user provides in the interview, and the coach note the user gives in the interview (blank until then). Demo data exists separately (seed/DEMO.json) and loads only if the user explicitly asks for it.

## 9. What this spec deliberately omits

- No numeric priority (no P1/P2): the manual order is the numbering, and numbers would duplicate and contradict it.
- No Eisenhower quadrants, no energy levels: maintenance overhead, tested and rejected in the reference design.
- No hover grab cursors, no live-reorder dragging, no red blocked-drag banner: each was tried in the reference design and removed; Sections 2.7 and 3.3 carry the fixed behaviour.
- No email delete affordance anywhere, including in the Email Brief: held by explicit product decision. If it is ever revisited, it would be move-to-Trash only, per-message confirmation, and never bulk.
- No sharing, no public link, no multi-user editing: the board is private to its owner.
- No email sending, no external posting: the board records and reminds; acting outside is the user's.
