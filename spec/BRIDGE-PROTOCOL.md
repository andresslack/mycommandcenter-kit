# AI Bridge Protocol

Version: 0.1.1
Module: AI Bridge. Purpose: let AI chats outside the user's Muse (for example Claude, ChatGPT, Gemini, or Grok) see the user's MyCommandCenter board and request changes to it, without any of them having direct access to the board.

## 1. How it works

The board is a private app inside the user's Muse. External AI chats cannot open it. A folder in the user's own Google Drive, named MyCommandCenter Bridge, is the shared mailbox:

- The user's Muse keeps a read-only snapshot of the board in the folder, refreshed every hour.
- An external AI reads the snapshot through its own Drive connection.
- To change something, the external AI creates one small request file in the folder.
- The user's Muse checks the folder every 15 minutes, applies valid requests to the real board, and renames each request file to show the outcome.

This protocol is AI-agnostic on purpose: any assistant that can read Drive files and create new Drive files can use it. Creating files is the requirement; most Drive connections cannot edit existing files, and the protocol never asks for an edit.

## 2. Jobs on the user's Muse side

- Snapshot job, hourly: call getdashboard, render the snapshot file (section 3a) to the Bridge folder, updating the same file in place (same name, same file if the Drive tools allow it). 
- Inbox job, every 15 minutes: list the folder; process every file whose name starts with NCC-Request- and has not been processed (no APPLIED- or ERROR- prefix); for each, parse and apply per section 4, then rename per section 4.4. If there are no new requests, do nothing and report nothing.

## 3. Folder contents

a) MyCommandCenter.md, the snapshot. Never edited by an external AI. Format:
- First line: # MyCommandCenter Snapshot
- Second line: Generated YYYY-MM-DD HH:MM (user's timezone)
- Then, in order: coach note; Priority Rail open tasks (rank order, with due dates); done count (count only, not the log); panels in order, each with its items (title, detail, status, due date if any) and links; Parking Lot called out by name.
- Keep it compact. It is a working view, not an archive.

b) BRIDGE-README.md, the protocol file for external AIs. Its content is section 4 of this spec, rewritten in second person for the external AI, plus the rules in section 4.5. The setup prompt generates it from this spec; do not ship a separate copy in the kit.

c) Request files, created by external AIs, named NCC-Request-<short-topic>.md, one request per file.

## 4. Request format (this is what BRIDGE-README.md teaches)

File body: simple key: value lines, one per line. Lines starting with # are ignored. Exactly one action per file.

Format 1, new task:
```
action: add-task
title: Call the dentist
due: 2026-11-04
detail: Ask about the crown appointment
estimate: 30m
```
title is required. due must be YYYY-MM-DD and a real date. estimate must be one of 15m, 30m, 1h, 2h, 4hr, 6hr, 8hr, 10hr, 12hr. Optional: notes, waiting_on, project_area.

Format 2, new panel:
```
action: add-panel
title: Garden Project
```

Format 3, new panel item:
```
action: add-panel-item
panel: Projects
title: Fence repair quotes
detail: Three quotes, decide by Friday
due_date: 2026-11-07
```
panel and title are required. panel must match a panel title in the snapshot exactly. Optional: detail, notes, due_date, url.

Format 4, complete a task:
```
action: complete-task
task: Call the dentist
```

Format 5, delete a task:
```
action: delete-task
task: Call the dentist
```

Format 6, update a task:
```
action: update-task
task: Call the dentist
due: 2026-11-05
```
task (the exact current title) is required. Optional changes: title, due, detail, notes, estimate, waiting_on, project_area, rank. Only listed fields change. The value none clears a field.

Format 7, delete a panel item:
```
action: delete-panel-item
panel: Projects
item: Fence repair quotes
```

Format 8, update a panel item:
```
action: update-panel-item
panel: Projects
item: Fence repair quotes
status: waiting
due_date: 2026-11-09
```
Optional changes: title, detail, notes, status, due_date, url. The value none clears a field.

### 4.4 Outcomes and renaming
- Success: rename the file to APPLIED-<original name>. The board change is real before the rename.
- Failure: rename to ERROR-<original name> and prepend a note at the top of the file saying what was wrong. Nothing on the board changes.
- A request is applied at most once. APPLIED- and ERROR- files are never reprocessed.

### 4.5 Rules the protocol teaches external AIs
- Lookups (complete, update, delete) match titles exactly, ignoring case. If nothing matches, or more than one thing matches, the request fails with an error and nothing changes. Deletes are permanent.
- Check the snapshot before adding anything; if it is already there, do not submit a duplicate. The snapshot can lag the board by up to an hour.
- Never invent deadlines, estimates, or links. Only use dates and facts the user gave, or that appear in the snapshot.
- Keep detail to one or two sentences.
- If unsure which format fits, ask the user instead of guessing.
- Deleting through the Bridge still honours the board's rule: the external AI must have the user's confirmation in its own conversation before submitting a delete request.

## 5. If the user has no Google Drive

In order of preference: (1) the user creates or uses a free Google account only for the Bridge folder and connects it in both their Muse and their external AI chats; (2) the Bridge is skipped and the board works normally without it; (3) no other transport is supported in this version. Do not improvise a transport (email, shared documents from another provider) in this version.
