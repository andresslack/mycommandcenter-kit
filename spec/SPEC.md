# MyCommandCenter Board Specification

Version: current kit version (see the VERSION file at the kit root)
For: the Muse AI that builds and maintains this board, in the user's own Muse environment.

Build a private, fullstack web app (artifact) named MyCommandCenter (the user may choose a different display name during the interview; the internal name stays MyCommandCenter). The app stores its own data in the user's Muse environment. It is never published, shared, or exported. All data belongs to the user.

## 1. Layout

- Far-left vertical rail: the to-do list, headed "To-do's" (Section 2).
- Panel grid to the right of the rail (Section 3). On wide screens (1040px and up) the panels area has its own vertical scrollbar, capped to the viewport height, scrolling independently of the rail. Stacked phone layouts do not.
- The board's top header bar (the strip with the date, open count, and Coach note) carries, at its right end, the status-dot legend control, an Add panel button, a Collapse all / Expand all toggle (Section 3.6), and the Settings cog (Section 9), last in that order. The panels heading itself carries only its titles. There is no freshness or "Updated" text anywhere on the board. At narrow widths the header bar stacks and the Coach note truncates before any control is squeezed.
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
- category: string or null. Preset suggestions come from the user's own taxonomy table (Section 2.8); free text is always accepted, whether or not the value is in the table.
- sub_category: string or null. Preset suggestions are the subcategories listed under the task's category in the user's taxonomy table (Section 2.8); free text is always accepted. Category and SubCategory are distinct fields; never merge them.
- waiting_on: string or null, max 240 characters
- project_area: string or null, max 240 characters (free-form area label; the Bridge protocol writes this field)
- priority_tag: none, Important, or Critical. Labels only: no numeric priority exists anywhere in this design, deliberately. The manual order is the numbering.
- rank: positive integer, unique among open tasks. This is the saved manual order.
- status: open or done
- completed_at: timestamp or null
- created and updated timestamps (created drives the date-added sorts)

### 2.2 Rail presentation and the compact view
- Three columns: row number, the stacked Done/Delete button cell (Section 2.6), action name.
- A collapsed row shows the title, a priority-tag pill if tagged (Section 2.5), and, if set, the due date.
- Clicking a task name in the compact rail opens the expanded To-do's scrolled to that row, with a gold highlight on the row that clears when the drawer closes.
- Completing a task from the compact rail uses the same pre-completion confirmation as the expanded view (Section 2.6); nothing is saved before the user confirms.
- The add-task form on the rail has a functional Cancel button immediately left of "Add task": it discards the input, closes the form, and saves nothing.

### 2.3 The expanded drawer
- A toggle opens an overlay drawer listing every open task with editable fields. Everyday columns shown by default: Name, Due Date, Priority Tag, Context, Notes, Category, SubCategory, Waiting On, Estimate. The Priority Tag column sits between Due Date and Context and is narrow: sized to its header (with its filter funnel) and the widest tag pill, no wider. All fields are inline editable and save in place.
- Action Name titles wrap to 2 lines at the unchanged column width; ellipsis only beyond 2 lines.
- While editing, the Action Name cell widens to 40ch + 16px with an opaque fill and shadow, the caret anchored at position 0; it returns to column width on save or cancel.
- Editor heights: the Notes editor opens at max(10 rows, which is 184px, the row's full current height). The Context editor opens at max(5 rows, which is 99px, the row's full current height). The taller-row rule wins in both, and any generic editor height cap is lifted for these two cells only. Other cells are unchanged.
- Escape layering in the drawer: while an inline editor is open, Escape cancels the edit (restoring the value from when the edit opened) and closes only the editor; it never closes the drawer, and the drawer's scroll and filter state are untouched. With no editor open, Escape closes the drawer. An open modal takes precedence over both: its Escape aborts the modal only.
- Due Date editing: clicking a Due Date cell always opens the calendar picker; no calendar icon is shown anywhere in the cell, in view or edit mode (the column's filter funnel is a separate control and stays). With the calendar open, Enter captures the currently chosen date (a valid typed value if typed, otherwise the highlighted day) and closes the calendar, saving the date; a Select button centered at the bottom of the calendar, between Clear (left) and Today (right), does the same on click. Clear and Today keep their behavior. Escape cancels without saving, per the layering rule above. The cell still displays the date as mm/dd/yy. In the drawer, the Due Date text is not bold and is set a half point larger than the drawer's standard cell text, in the cell and in the editor input alike.
- The Category and SubCategory cells are combo boxes: a preset dropdown fed by the user's taxonomy table (Section 2.8), SubCategory presets following the category on that row, plus free-text entry in both. A control in the drawer opens the taxonomy editor (Section 2.8).
- The drawer's Expand/Collapse symbol and the circular "+" are drawn and centered, level with their text label.
- To-do's have no link capability anywhere: no URL field exists on a task, in the drawer, or in the brief Add to To-do's modal. URLs inside notes or brief text are never auto-linked.

- Whichever arrangement is selected (My order, Batch, or a Sort view), a short description of it shows in the compact rail's sort bar in the same place and style: what the arrangement is, that Batch and Sort views are view-only and leave My order unchanged, and for My order that it is the user's own ranking, reordered by drag or by double-clicking a task's handle and typing its new position number, with new tasks joining at the bottom and tasks due in the next 3 days floating to the top. The expanded To-do's shows no arrangement description; the rail's text is the only copy. The expanded To-do's header carries a "Close To-do's Drawer" button (the X close control also remains), and the taxonomy editor is opened from an "Edit categories" clickable text in the table header section at the Category column, not from a button in the drawer's top bar.
- Reordering in My order has exactly two methods: drag, and renumbering. Double-clicking a task's reorder handle (the grip and position number at the left of its row) turns it into an editable number field prefilled with the current position; typing an integer and committing moves the task to that position and shifts the others; a number past the end places it last and its displayed number becomes the true count; a number below 1 places it first; Escape or empty or non-numeric input cancels with no change. There is no arrow-key reordering. Both methods work only in My order and pause while the expanded To-do's column filters are active.
- Due Date sorting in the drawer: a paired-arrows sort icon button in the Due Date header's control cluster cycles a drawer-local sort: off, then ascending, then descending, then off. The DUE DATE header label itself is plain text and is never a sort control. The sort applies after the column filters and search, inside the visible set, using the same date comparators as the rail's Due views; undated tasks sort last in both directions, and ties keep the current rank order. Batch grouping is kept, with the sort applied within each group. While the sort is active, drag reordering and handle renumbering pause. The icon shows its state: both arrows muted when off, the up arrow lit in the accent color when ascending, the down arrow lit when descending, with state-aware accessible labels and tooltips. The sort resets to off when the drawer closes, together with the filters. No other drawer column is sortable.

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
- Due-date colors, one rule on the rail and in the drawer: OVERDUE (before today) renders in urgent red #d66c55 with no fill. IMMINENT (today through 3 days out) renders as a filled gold chip #d4a72c with near-black #0b0b0a text. SOON (4 through 7 days out) renders in gold #d4a72c text with no fill. LATER (8 or more days out) and undated tasks render in the normal text color. "Today" is reckoned in the local time zone of the device viewing the board; there is no stored setting and no install question for it. The 3-day float above, the 7-day header count, the drawer filter buckets, and these tier colors all use that same "today", so they can never disagree.

### 2.6 Drawer search and the Done confirmation

- The drawer search searches every field of every open task: Name, Due Date, Context, Notes, Category/SubCategory, Waiting On, Estimate, Priority Tag. Case-insensitive. Multiple words are treated as one exact phrase.
- It shows a live match count, a Clear button, and clears on Escape. A "Name only" scope checkbox exists; searching everywhere is the default.
- While a search is active, every occurrence of the phrase is highlighted in gold in the displayed fields within scope (display-only; an open editor shows plain text), and "Make this my order" is disabled, so a filtered subset can never become the saved order.
- The search input is narrow: 30 percent of the bar's width. Its "SEARCH ALL FIELDS" label uses the same muted color as the "Name only" label.
- Done confirmation: pressing the Done circle in the compact rail or the expanded view opens a confirmation BEFORE anything is saved. It names the task, asks to mark it done, notes it can be undone in the Done Log of the Priority Rail, and offers Cancel and a confirm button; Escape and backdrop clicks abort like Cancel. Only the confirm completes the task; aborting changes nothing, and there is no post-save notice after a completion. (This confirmation replaces an earlier post-save notice design; do not build the notice.)
- Done and Delete controls, both views: in the compact rail and the expanded drawer, each open task has one cell with two controls stacked vertically, Done on top and Delete below. Done is a circle with a light green perimeter, the same size and style family as the rail's circle button. Delete is a trashcan icon, gray at rest, that turns red on mouse hover, with no circle or ring around it. Both carry Done and Delete tooltips. There is no separate Delete column in the drawer. The Done log keeps its own per-entry Undo and Delete controls, unchanged.
- Completing a task sets status done and completed_at, and moves it to the Done log view, timestamped, with undo. Undo restores it as open with its prior rank.
- Delete is offered per task in the compact rail and the expanded view (the trashcan control in the stacked cell), and per entry in the Done log (completed tasks can be deleted too). Deleting a task is a hard delete: the task is removed permanently, there is no Trash and no restore, and a deleted task never counts as completed. One task at a time; there is no bulk or multi-select delete for tasks.
- The delete confirmation shows the task's title, its Category, its SubCategory, and its due date (if any), and states that the deletion is permanent. Nothing is deleted before the user confirms; the user's click plus that confirmation is the explicit OK, and Muse never deletes a task on its own (OPERATING-RULES.md).
- Every deletion is recorded in a deletion log in board-owned storage: the deletion timestamp plus a full snapshot of the deleted task's fields. getdashboard returns the log, and the Done log view shows it as a read-only Deleted list (title and deletion timestamp, no restore or undo control). The log is append-only; no control edits or removes its entries. Deleting a task never touches panel items, other tasks, or the taxonomy table.
- A task is never completed, deleted, or given a due date or estimate by Muse on its own. See OPERATING-RULES.md.

### 2.7 Drag model (applies to rail tasks, panel items, recurring entries, and panels)

One drag model everywhere; do not implement variants.
- During a drag, the dragged element and all others stay put. There is no live reordering on pointer move. Live reordering teleports the dragged element under the pointer and caps movement at one position per drag; that behaviour is a known bug, never reproduce it.
- Midpoint geometry decides the landing slot. A gold line shows in the gap where the element will land. Edge auto-scroll works while dragging.
- The new order is committed once, on drop, and must allow a move of any distance in a single drag.
- Keyboard reordering with arrow keys is supported wherever dragging is (Section 3.3 for panels).
- Hovering any drag handle (panel grip, entry grip, rail grip) shows the plain default arrow cursor, never a grab-hand cursor, in rest, hover, and pressed states. A subtle hover background tint on handles is fine.

### 2.8 The Category/SubCategory taxonomy table

The preset lists behind the Category and SubCategory dropdowns live in board-owned storage, not in board code, so the user can change them without a rebuild.

Storage and shape:
- One taxonomy table per board, stored durably with the board's own data: an ordered list of categories, each carrying an ordered list of subcategories. A category entry is a name plus its subcategory names. Names are trimmed, non-empty strings of at most 240 characters, matching the task fields they feed.
- Category names are unique in the table. Subcategory names are unique within their category; the same subcategory name may appear under different categories, and subcategory presets are always scoped to their category.
- The kit ships this table empty. No categories or subcategories are ever shipped, seeded from an example, or copied from any other user's board. The setup interview collects the user's own categories, and the subcategories for each, and a setup step writes those answers into the table at install (INTERVIEW.md; prompts/01-install-core.md; prompts/03-email-brief-setup.md).
- getdashboard returns the table as a top-level taxonomy field, so a backup taken from getdashboard (prompts/upgrade.md) includes the table verbatim. Dedicated actions also read and modify it (Section 6).

One source, two consumers:
- The table is the single source for Category and SubCategory presets: the expanded drawer's combo boxes read it, and the Email Brief's category and sub_category suggestions read the same list (EMAIL-BRIEF.md sections 2 and 4). There is no separate brief-only category list; brief suggestions are read from the table at run time. If brief instructions record a copy of the list, it is a mirror only, recorded from the table at setup and refreshed by Muse whenever it changes the table, and the table wins on any disagreement.
- Changing the table changes only future preset suggestions. It never rewrites a stored task value by itself (see the rename and remove rules below).

The editor:
- A small editor, opened from a control in the expanded To-do's area, lists the categories and, under each, its subcategories, and lets the user add, rename, and remove categories and subcategories. New entries are added at the end of their list.
- The editor is buffered: adds, renames, and removes are staged locally while the editor is open and nothing is written until the user presses Save, which applies the staged changes through the taxonomy actions in Section 6 and reads the table back afterward. Cancel discards the staged changes and is never disabled; any attempt to close the editor with unsaved changes, by the corner X, Cancel, Escape, or a backdrop click, asks first, with the warning headed "Changes will be lost" offering Keep editing and Discard changes (the unified dialog convention, Section 3.6).
- Save is partial, not atomic, and the spec says so plainly: the staged operations are applied one at a time, in order, and if one fails, the ones before it stay saved, the failing one and everything after it stay staged in the still-open editor, and the user is shown the error together with how many changes did save. There is no rollback.
- The rename count can drift, also plainly: the task count shown in a rename confirmation (Rename safety, below) is counted when the change is staged and is frozen at that number. If tasks are added, edited, or completed in the meantime, the number actually rewritten at Save can differ from the number the user confirmed, and nothing re-checks or warns at Save time.
- Add: adding a category or a subcategory touches no task. A name already present at the same level (in the same category, for a subcategory) is refused with a plain message.

Rename safety:
- On a rename, when the rename is staged (before Save is pressed), the editor counts the tasks carrying the old value and shows the old value, the new value, and that count, then offers two choices: update those tasks to the new value, or keep those tasks as they are. Nothing is rewritten without the user's explicit confirmation of one of those choices. The count is the staging-time count described above; it is not recounted at Save.
- Subcategory renames are scoped to their category: only tasks whose category is that category and whose sub_category is the old value are counted and, if the user chooses update, rewritten.
- If the user keeps the tasks as they are, those tasks keep the old value as free text (see the free-text rule below) and the table carries only the new value.
- The task rewrites, when chosen, go through the normal task update path, one task at a time, and change only the renamed field.

Remove safety:
- Removing a value never deletes, completes, or hides a task.
- If tasks carry the value being removed, the editor says how many, asks for confirmation, and offers two choices: reassign those tasks to another value at the same level (another category, or another subcategory in the same category), applied through the normal task update path, or leave the tasks carrying the removed value as free text.
- Removing a category also removes its subcategory list from the table. It does not touch the tasks' stored category or sub_category text beyond a reassignment the user explicitly chose, and a removed category's subcategory presets simply stop being offered.

Free-text rule (unchanged by the table):
- Category and SubCategory accept any typed value, in the drawer, in the add-task form, and in the brief's Add to To-do's modal, whether or not the value is in the table.
- A value that is not in the table displays and edits normally everywhere: the drawer, the column filters, Batch grouping, and search. It simply gets no presets: a task whose category is not in the table shows no SubCategory presets, and its SubCategory stays free text.
- An empty table is a valid state, for a new board or a user who never gave categories. In that state every Category and SubCategory is free text and nothing is blocked.

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
- System panels (recurring panel, File Saves History, Quick Open) cannot be deleted at all.
- Multi-select bulk delete, all non-recurring panels: each panel header has a Select toggle, rendered as a "−" icon button in the same format as the "+" add button; while selecting, that header button reads "Cancel". Checkboxes appear on items; a bulk bar offers, in this order: [Esc] [Select all] [Delete selected (N)], plus a hint. Delete asks for confirmation showing the count, then deletes exactly the selected items in that panel; item IDs from another panel must be refused. The recurring panel is the sole exception: no Select toggle. For File Saves History, the confirmation also states that deleted entries stay hidden and the files and master log are untouched (FILE-SAVE-LOG.md).
- Standard panel items can be reordered by drag (Section 2.7 model) and by keyboard.

### 3.6 Status dots, headers, editors

- Status dots: an item's dot reflects its free-text Status. Gold #d4a72c for build, active, or link. Gray #a6adb7 for open, blank, or unrecognized (the default). Red #d66c55 for blocked, waiting, due, or decision. Green #55a879 for routine or personal. Matching is by keyword in the status text. Never rewrite a user's stored Status values to make the dots behave; unknown values simply show gray. Hovering or focusing a dot shows a tooltip naming that item's own status: a recognized value reads "Status: link" (and likewise for the others); a blank status reads "Status: open (default)"; an unrecognized stored value reads "Status: <value> (unrecognized, shown as open)". Clicking a dot opens the same single status legend as the header-bar legend control; there is only ever one legend dialog.
- Legend: a single legend control in the board's top header bar shows only the four dots, no words. Its modal entries read "Status: ..." (one per meaning), and the modal's backdrop is fully transparent. The legend dismisses by its corner X under the dialog convention below, never by a footer button.
- Two-line header rule: the board measures each panel's title against the single-line header space. If any panel's displayed title would be 9 visible characters or fewer, every header switches to two lines (name on line 1; count and controls on line 2), and all headers return to one line together when none qualifies. The switch is board-wide, never per-panel.
- White Edit window: the panel-item Edit window's fill is a theme token, --panel-complement (the complement of the panel fill; white #ffffff in the dark theme), with dark-on-light styling scoped to the editor only. The gold Save button is unchanged. Dialogs and item rows keep the board theme. Never hard-code white; always use the token, so user themes keep working.
- Buffered saving in the panel-item editor: the editor (including the Email Brief entry's editor, EMAIL-BRIEF.md section 2b) stages its changes locally and writes nothing until Save, from every door that opens it. The per-entry control on an item row that opens this editor is labeled "Details". Cancel discards; closing with unsaved changes, by any path (the corner X, Cancel, Escape, or a backdrop click), asks first, with the same "Changes will be lost" warning (Keep editing / Discard changes) as the taxonomy editor (Sections 2.8 and 3.6, dialog convention). Dirtiness counts only the fields the editor actually shows for that entry. Where a Save applies more than one action, it is partial in the same way as the taxonomy editor's: earlier actions stay saved if a later one fails, and the rest stay staged in the open editor with the error shown.
- Collapsed-panel add: clicking the add-entry "+" on a collapsed panel expands the panel and leaves the add form open and focused.
- Card name editing: a single click on a workstream card's name never enters rename or edit mode. On hover over the name, a small pencil icon appears at its edge, and clicking the pencil opens the name editor (on touch, tapping the name selects it and shows the pencil). The pencil is the only mouse path into name editing. The same rule applies to any item title inside a card that would otherwise enter edit mode on a single click.
- Double-clicking a card's header (its background or name, never a link, button, or other control in the header) toggles that card's expand/collapse, the same end state as its fold triangle. Double-click never opens an editor.
- Links-panel item editor: for an item on a links-kind panel (Quick Open), the panel-item editor shows neither a STATUS field nor a DUE field. Stored values are preserved exactly: an untouched save writes the loaded status and due date back unchanged. Routine-panel and standard-panel item editors keep their fields.
- Links-panel creation default: an item created on a links-kind panel is born with status "link" unless a status is explicitly supplied at creation, in which case the supplied value is stored exactly. Items created on every other panel kind are born "open". The default applies at creation only and never rewrites existing items.
- STATUS field in the standard panel-item editor: a dropdown, never free text. The options, in order (the stored value is the bare word): open (gray), build (gold), active (gold), link (gold), blocked (red), waiting (red), due (red), decision (red), routine (green), personal (green). If the item's loaded status is outside that set, one extra option carries it as the initial selection, labeled "<value> (current, unrecognized)" for a nonblank value or "open (default)" for a blank one, and an untouched save writes the loaded status back byte-exact. Links-panel editors show no STATUS field at all (above); routine-panel entries show none in this editor either.
- Dialog convention (unified): every modal dialog carries a bare corner X at its top right, with no surrounding circle, no border, and a transparent background. A gold footer button still means a decision is present (Save, a confirmation, or an action with consequences). A dialog that only informs (the status legend, the File Save Log completion pop-up, the File Save Log rules dialog, the panel-not-empty notice) has no footer button and dismisses by its corner X, alongside whatever Escape and backdrop behavior it already has. On an editor dialog (the panel-item editor in all its forms, the Categories taxonomy editor, the routine entry editor), the corner X does exactly what the editor's Cancel button does, and the editor's footer Cancel is never disabled: with no unsaved changes, the X, Cancel, Escape, and a backdrop click each close the editor at once; with unsaved changes, every one of those paths shows the same warning, headed "Changes will be lost", offering "Keep editing" and "Discard changes", and nothing is discarded until the user chooses Discard changes. On a confirmation dialog, the corner X counts as that dialog's cancel choice. The File Save Log guidance modal follows the same split: its only footer button is the consequential "Cancel update", and dismissal is the corner X. The File Save Log FILTER modal has a corner X that does exactly what its header Close button does; the FILTER modal has no Escape or backdrop dismissal. Settings dismisses by its corner X and has no footer Close button.

### 3.7 Default panel set (14 panels always, plus File Saves History when its module is set up, in order)
1. Recurring panel, kind routine. Display name from the interview: "Recurring Activities" by default, "Operating Rhythm" for the Small Business Operator pack. Internal identity is fixed; renaming never affects routines, the Email Brief, or session checkoffs.
2. File Saves History, kind standard, system panel. Created only when the File Save Log module is set up: the seed marks it requires_module, the core install does not create it, and prompts/05 creates it at module setup if it is absent. An install that skips the module has 14 panels and never gets this one. Items are created only by the File Save Log module.
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
- The shared add-entry form (the form the recurring panel's type picker leads into, and the add form on routine-kind panels) treats the name as required. The name field's label reads "Name *" with a red asterisk and the field is marked required; its placeholder reads exactly "Enter a name here for the new item". The Add entry button is disabled while the name is empty or whitespace only. Hovering the disabled button shows a tooltip above it reading "Enter a name before Adding" (italic black text on white); clicking the disabled button flashes the same tooltip for about 2.4 seconds; typing a name removes the tooltip. The name field itself keeps a white fill, with a bold gray placeholder (#808080) and black typed text. Every other data-entry input in the form carries the board's green entry treatment (a tint of the done green as fill, with a deepened green border), the same treatment as the Email Brief entry's TIME inputs; the name field is the one deliberate exception and keeps its white fill.
- Type picker fade: once a type is selected in the picker, every unselected option's title and description render washed-out gray; the options remain fully clickable, and selecting a different one moves the fade. (The entry editor's own type control, a plain select, is a different control and does not fade.)
- The recurring entry editor has no Status and no Due fields (standard-panel item editors keep both). An entry may still carry a stored status (shown by its dot); never strip stored values just because the editor no longer exposes the fields.
- Per-entry links: a recurring entry supports a list of links (label plus destination, up to 20 per entry), editable in the entry's Edit window and rendered clickable on the entry (Section 7 surface 3). A single pre-existing link on an entry migrates in as the first list item.
- Recurring entries are draggable within the panel (grip, plus Up and Down keys), persisting sort order only, under the Section 2.7 drag model.
- One entry is reserved for Email Brief notes. It carries the dedicated routine type "Email briefs" (stored type email_briefs; created by the Email Brief setup); the generic "Brief / report" type is a different, ordinary type and never gets the Email Brief treatments. Its notes hold the rolling stack specified in EMAIL-BRIEF.md.
- Board session times are board-only state. External reminder jobs created by a module setup are separate; changing board session times does not retime them (the setup prompts keep them in sync explicitly, or warn).

## 5. Parking Lot rules

- Purpose: temporary triage only. Every item here is expected to move to a permanent panel.
- Items Muse places here must carry, in notes: the source of the item and a suggested permanent panel.
- The UI must not treat Parking Lot as a system panel; it is a normal standard panel that happens to be seeded. Its special behaviour is in how Muse uses it (OPERATING-RULES.md rule 6).

## 6. Actions the app must publish (25)

Module actions not listed here: the File Save Log module's board actions (refresh request, start, completion, and cancel, plus its panel stats and hide/dismiss actions) are specified in spec/FILE-SAVE-LOG.md sections 4 to 4d.

Reads:
- getdashboard: returns coach note, open tasks, completed tasks (done log), panels with items and links, weekly audits, the Category/SubCategory taxonomy table (Section 2.8), and the deletion log (Section 2.6).

Taxonomy:
- gettaxonomy: returns the full taxonomy table, categories in order, each with its subcategories in order.
- updatetaxonomy: replaces the taxonomy table with the ordered table provided. Validates the shape in Section 2.8 (trimmed, non-empty names, at most 240 characters, category names unique, subcategory names unique within their category). Saving the table never creates, rewrites, completes, or deletes a task; task rewrites after a rename or a removal happen only through updatetask, and only after the user's confirmation in the editor.

Tasks:
- addtask (title required; detail, due_date, estimate, notes, category, sub_category, waiting_on, project_area, priority_tag optional)
- updatetask, deletetask, settaskdone (set or clear done), reordertasks

Panels:
- addpanel, updatepanel, deletepanel, setpanelcollapsed, reorderpanels

Panel items:
- addpanelitem, updatepanelitem, deletepanelitem, deletepanelitems (bulk, one panel only), reorderpanelitems. For recurring entries, add and update also carry entry_type and its config, and the per-entry links list.
- addpanelitem field quirk (matters to every programmatic writer, the Bridge included): the create action silently ignores the detail and status arguments. The call returns success, but the item lands with its detail empty and the default status for its panel kind, whatever detail or status was passed. The url argument IS honored on create. The verified write pattern for creating an item with a detail or a chosen status is three steps: (1) create the item with addpanelitem; (2) set the detail and status with updatepanelitem (its arguments are the item's id, plus notes and url as required strings, passing empty strings when there are none, and due_date as null or a YYYY-MM-DD date); (3) read the item back and confirm every intended field landed. Bridge consequence (BRIDGE-PROTOCOL.md format 3): a bridge add-panel-item request that carries a detail must be followed by the update step in the same pass, or the item is created without its detail.

Panel links:
- addworkstreamlink, updateworkstreamlink, deleteworkstreamlink

Routines and board:
- setroutineitemcompleted (id, completed_on date or null)
- setroutinesessioncompleted (item id, session key, completed_on date or null)
- updatecoachnote
- saveweeklyaudit

Validation the build must enforce: required titles non-empty; due dates are real YYYY-MM-DD dates; estimates from the enum in 2.1; priority_tag only none, Important, or Critical; the taxonomy table follows the shape and uniqueness rules in Section 2.8, while task category and sub_category values themselves are never validated against the table (free text is always accepted); bulk delete refuses IDs outside the named panel; panel deletion refuses a non-empty panel (items or links) at the data layer; deletes of tasks, panels, and panel items execute only after the caller's confirmation step (the confirmation itself is a UI and Muse behaviour rule, OPERATING-RULES.md).

## 7. Link rules: three surfaces, kept separate

Conflating these surfaces causes real bugs. Spec and build them apart.

Surface 1, the single Link field (standard-panel and links-panel items): the destination is stored verbatim and rendered as a raw link. https works; a pre-formed custom-protocol URL works. A bare local path typed here is not converted and will not open properly; that is expected, do not "fix" stored values.

Surfaces 2 and 3, panel link drawers (multiple links per standard panel) and recurring-entry link lists: both are gated by one renderer rule. Clickable: http:// and https:// on any domain; onenote: links; file:// links; and local Windows paths (drive-letter or UNC), which are converted to the local-opener protocol of the optional local-files module (the opener URL is the protocol name plus the fully percent-encoded path; the module keeps its own allowlist of folders and blocks scripts and executables). Everything else (mailto:, tel:, ftp:, custom app schemes, ready-made opener URLs, relative paths, bare names) is stored and shown as plain text with a Copy control.

Server-side validation, surfaces 2 and 3 only: destination non-empty, label at most 120 characters, destination at most 2048 characters. Clickability is purely a rendering decision.

Preservation rules: never clean up, normalize, or re-encode a stored destination. Moving a link between surfaces changes its clickability, and that is correct behaviour, not data loss. (Many note-app links are in fact https URLs with an embedded app suffix and open as web pages; that is fine.)

File Saves History rows and Quick Open (Level 1): an expanded File Saves History row may offer an "Add to 'Quick Open'" action (FILE-SAVE-LOG.md section 4). The item it creates carries the file's path as copyable text in its Link field, not as a clickable local-opener link, because the kit ships no link handler; a user who later installs the optional local-files extra can replace the text with a working link by hand. It is born with status "link" under the links-panel creation default (Section 3.6).

## 8. Seed

Build the board empty of content: panels and routine entries from SEED.json for the chosen pack (routine entries seeded with their types), no tasks, no panel items with invented content, no links except any the user provides in the interview, and the coach note the user gives in the interview (blank until then). The taxonomy table (Section 2.8) is created empty at build, exactly as the empty taxonomy list in SEED.json, and is populated only from the user's own interview answers. Demo data exists separately (seed/DEMO.json), carries no categories, and loads only if the user explicitly asks for it. The top-level "version" field inside SEED.json and DEMO.json (currently "0.1.5") is the seed format version: it changes only when the seed data format changes, and it is independent of the kit version.

## 9. Settings (the cog)

A cog icon at the top right of the board's header bar opens one Settings dialog. Its purpose is post-install change: anything the setup interview asked that the user may later want to adjust has a discoverable home here, so the interview may defer non-essential questions with an honest "you can change this later from the cog".

The governing rule is ONE editor per setting. The cog is a front door, never a second copy: every control in the dialog either edits a board-owned value through the same stored field its other door uses, or opens the existing editor component for that setting. No setting may have two writable homes, and the in-context doors (the drawer's "Edit categories", the Email Brief entry's own Details, the filter modal's Show count) keep working and reach the same single editors and values.

The dialog has three short sections:

- Board: a row labeled "Default Show count for File Saves History" (only when the File Save Log module is installed; it is the same stored value the filter modal's Show count uses, so a change in either place is the same change), and a Categories and subcategories row that opens the taxonomy editor (Section 2.8), which remains the single taxonomy editor.
- Email Brief: a Brief times row that opens the same editor the Email Brief entry's own Details uses (the multi-session slot editor). No second slot editor exists.
- File Save Log (only when the module is installed): routing rows only, for settings that live on the user's own computer and that a hosted board cannot edit. Settings that live in local files (the scanner's watched folders and schedule in its config file, the hide and keep rules in the excludes user file) must never appear as live toggles. Each routing row follows one pattern, in the same gold-bordered callout style as the explainer's "Changing rules:" box: a one-line description of what it controls, a copyable plain-words request the user can send to Muse, and, for technical users, the generic config or file path.

When the File Save Log module is not installed, including every install where it was skipped (for example because the user's computer is a Mac; the module is Windows-only in this version), the dialog has only the Board and Email Brief sections, and the Board section omits the Default Show count row as well. That absence is correct, not missing structure.

Dialog behaviour: Escape closes the dialog and nothing else (the board's Escape layering rule applies); on close, focus returns to the cog; the cog and dialog are keyboard reachable; the dialog is usable at phone width (390px); styling follows the board theme. Opening an editor from Settings closes the Settings dialog first, so the dialog and an editor never stack.

Out of scope for the cog: anything that duplicates an existing editor in a second place, notification preferences, account or sharing settings, and any bridge or chat-side action that edits settings (read-only visibility at most).

## 10. What this spec deliberately omits

- No numeric priority (no P1/P2): the manual order is the numbering, and numbers would duplicate and contradict it.
- No Eisenhower quadrants, no energy levels: maintenance overhead, tested and rejected in the reference design.
- No hover grab cursors, no live-reorder dragging, no red blocked-drag banner: each was tried in the reference design and removed; Sections 2.7 and 3.3 carry the fixed behaviour.
- No email delete affordance anywhere, including in the Email Brief: held by explicit product decision. If it is ever revisited, it would be move-to-Trash only, per-message confirmation, and never bulk.
- No sharing, no public link, no multi-user editing: the board is private to its owner.
- No email sending, no external posting: the board records and reminds; acting outside is the user's.
