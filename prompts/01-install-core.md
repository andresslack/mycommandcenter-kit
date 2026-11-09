# Prompt 01: Install the core board

Paste this whole prompt into your Muse to begin. It is step 1 of 6 in INSTALL.md. You need the kit files available to your Muse (the kit folder in your Muse workspace, or the files attached to the chat).

---

You are installing MyCommandCenter for me. Follow the kit exactly. The kit files named below are your instructions and outrank any guess you might make about how this board should look.

1. Read these kit files first: spec/SPEC.md, spec/OPERATING-RULES.md, spec/INTERVIEW.md, spec/TEMPLATE-PACKS.md, spec/ROUTINE-CATALOG.md, and seed/SEED.json. Tell me in two or three sentences what you are about to build, then wait for me to say go.

2. Build the board exactly as spec/SPEC.md describes: a private fullstack app named MyCommandCenter, the Priority Rail (SPEC section 2), 14 panels (SPEC section 3.7) seeded from seed/SEED.json, the recurring panel behaviour (SPEC section 4), and all 25 actions (SPEC section 6). Do NOT create the File Saves History panel in this step: the seed marks it requires_module, and it is created in step 05 if and when I set up the File Save Log module. Dark theme by default. Do not publish or share the app. Do not add any content of your own: no invented tasks, panels beyond the spec, items, links, or sample data.

2b. Category taxonomy, empty at build: as part of the build, create the board's Category/SubCategory taxonomy table in board-owned storage (SPEC section 2.8), with its read and update actions, the getdashboard taxonomy field, and the taxonomy editor in the expanded To-do's. Create it EMPTY, exactly as the empty taxonomy list in seed/SEED.json. Do not seed it with any example, default, or borrowed categories or subcategories, from the kit or from anywhere else. It is populated later, only from the user's own interview answers (the categories question in spec/INTERVIEW.md, saved during step 03, Email Brief setup). Category and SubCategory entry on tasks is free text from the start, so the empty table blocks nothing.

3. As soon as the board exists, start the interview in spec/INTERVIEW.md, Core interview section, in order. Ask one topic at a time. Apply each answer as we go (board name and theme, starter pack, recurring panel name, template panel renames, coach note, proactivity tier, my first real tasks, Quick Open links). After each topic, read the board back with getdashboard and confirm the change landed before moving on. Follow spec/OPERATING-RULES.md throughout, including: never invent a due date, estimate, name, or link I did not give you.

4. Finish with the checkpoint. Read the full board back and report in plain language: the rail with my first real tasks ranked, the 14 panels in order with the recurring panel under the name I chose (File Saves History is not among them; it arrives with the File Save Log module in step 05 if I set that module up), my coach note, and my proactivity tier. Also read the taxonomy table back (getdashboard or gettaxonomy) and confirm to me that it exists and is empty, and tell me it will be filled only with my own categories and subcategories when I give them in the Email Brief setup (step 03), and that I can change it later in the taxonomy editor or by asking you. Then say the three closing items from the interview script, including that I can ask at any time to modify anything about my panel, and tell me the next install steps (02 import, 03 Email Brief, 04 Bridge, 05 reviews and file log) and that I can do them now or later.

If anything in the spec fails to build, stop, tell me plainly which part failed and what you did instead, and do not improvise a different design silently.
