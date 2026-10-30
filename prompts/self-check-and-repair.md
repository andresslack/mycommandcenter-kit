# Self-check and repair

Use this prompt any time the board looks wrong, incomplete, or different from the kit spec. Paste it into the same Muse that hosts the board.

---

Audit my MyCommandCenter board against the kit spec and repair drift. Read spec/SPEC.md, spec/TEMPLATE-PACKS.md, and spec/OPERATING-RULES.md first, then getdashboard.

Check, and report each as OK, repaired, or needs my decision:

1. Panels: 15 seeded panels exist (or more if I added some), in a sane order, with the right kinds: exactly one routine panel, Quick Open as kind links, Recent File Saves present. The recurring panel's display name may differ from the spec default; that is customization, not drift.
2. System panels (recurring, Recent File Saves, Quick Open) still exist and were not deleted.
3. Priority Rail: every open task has a unique rank; due dates are valid dates; estimates are from the allowed list; ordering follows SPEC.md 2.2.
4. Actions: the board answers all 23 actions in SPEC.md section 6. Test the read and one harmless write you can undo.
5. Recurring panel: routine items carry a cycle and completed dates; session-based items carry sessions; the Email Brief item holds at most the last 3 briefs with the divider format; the weekly Parking Lot item exists.
6. Parking Lot: every item Muse parked carries a source and a suggested panel in its notes. List any that do not, and fix their notes if the source is knowable, or ask me.
7. Jobs: Email Brief job (if set up) exists with my chosen times; Bridge jobs (if set up) exist (hourly snapshot, 15 minute inbox); File Save Log aggregator (if set up) exists at 15 minutes.
8. To-do's extras: priority tags are only none, Important, or Critical; the "My order" view is the only drag-enabled view and sort views never changed rank (spot-check that sorted views left the saved order untouched); "Make this my order" is disabled while a search is active.
9. Recurring entries: every entry carries a stored type and config (no behaviour depends on an entry's title); sessions have stable keys and today's session checks sit against keys; monthly entries store a day 1 to 29 or "last"; per-entry link lists hold at most 20 links.
10. Panels: each panel stores its column and position; the recurring panel sits at the top of the first column; panel deletion refuses any panel that still has items or saved links; the Edit window uses the --panel-complement theme token, not a hard-coded color.
11. Brief integration: recent brief entries in the recurring panel keep each run's TODOSUGGEST comment attached to its own run; Open buttons appear only for the three allowed webmail hosts.

Verification honesty: some behaviours cannot be proven from data alone (pointer drags, modal timing, drag highlight behaviour, cue pills for entry types not currently in a cue window). For checks like those, verify what the board's data and settings can prove and mark the item "verified in source, awaiting user confirmation" rather than claiming full verification. And if a record you expected is missing, do not assume data loss and do not restore it on sight: first rule out that I deleted it on purpose, and ask me if you cannot tell (Operating Rules, rule 14).

Rules while repairing: repairs that add missing structure (a missing panel, a missing routine item) you may do, then show me. Repairs that delete or rewrite my content need my confirmation first, item by item. Never "repair" my wording, names, or theme because they differ from the defaults; my customization is the point.

Finish with a plain summary: what was OK, what you repaired, what needs my decision.
