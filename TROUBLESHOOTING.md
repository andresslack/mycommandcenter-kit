# Troubleshooting

Most fixes in this kit follow one pattern: paste prompts/self-check-and-repair.md into the Muse that hosts your board, and let it audit and repair against the spec. Start there unless your problem is one of these specific ones.

## The board came out different from the pictures or the guide

Different is often customization, not breakage: names, panel titles, and themes are yours. If an action, a panel kind, or the rail ordering behaves wrong, run the self-check prompt. If the self-check cannot fix it, note exactly which check failed; that line is the most useful thing you can send when asking for help.

## A panel or routine item is missing

Run the self-check prompt. Adding missing structure is a repair it may do on its own; it will show you what it added.

## The Email Brief did not run

Ask your Muse: "Did the Email Brief job run today, and if not, why?" Muse should check the job, say what happened, and offer to re-run it now. A brief that read only some inboxes will say so at its top; that means an inbox connection needs attention, and your Muse can walk you through reconnecting it.

## The Email Brief is noisy or misses things

Tell your Muse in plain words what it got wrong, ideally right after a brief: senders to screen out, people whose mail always matters, topics that are noise. Ask it to apply the changes to the brief setup and say back what changed. The Day 7 tuning session also asks about brief accuracy on purpose.

## The Bridge is not applying requests

Check, in order:
1. Is the request file in the MyCommandCenter Bridge folder, named NCC-Request-something.md, with one action in the format the protocol file describes?
2. Has 15 minutes passed (the inbox job's interval)? For a faster answer, ask your Muse to run the Bridge inbox job now and report.
3. Was the file renamed with an ERROR- prefix? Open it; the top line says what was wrong, usually a panel or task title that does not match the snapshot exactly. Fix the cause and have the external AI create a new request file (requests are never edited, always recreated).
4. Remember the snapshot lags the board by up to an hour. A duplicate refusal often means the item was added in the last hour and the snapshot the external AI read was older.

## File Saves History shows junk files, or a deleted entry came back

Junk: tell your Muse the file name or type you do not want to see; adding an exclusion is a normal request. An entry that came back after deletion: ask your Muse to confirm the entry was added to the hide list, and to verify across the next scheduled cycle, not by pushing the panel by hand (a manual push can race the cycle and re-add things). If problems persist after one pass at these fixes, the File Save Log parking rule applies (spec/FILE-SAVE-LOG.md section 6): Muse disables the module cleanly and the rest of the board carries on. If the problem is on the computer side instead (the scanner has stopped running, a window has started appearing, folders or the log destination have become unreachable), run the pre-install check again (preinstall/Check-FileSaveLogRequirements.ps1, the same script from INSTALL.md step 5) and give your Muse the new report; it re-tests the machine requirements as they are now, and a change since install, a Windows update, new security software, a moved folder, is the usual story.

## I hit a usage or session limit mid-install (common on free tiers)

Nothing is lost. Each install prompt stands alone, and the board saves state as it goes. Start a new conversation, paste the prompt for the step you were on, and tell Muse which steps you already finished and that it should check the board before redoing anything. Muse is required to check before adding, so re-running a finished step should end in verification, not duplicates.

## Muse added a task with a date I never gave it

That breaks a core rule (Operating Rules, rule 3). Point at the task and say so. Ask Muse to clear the field and to re-read its operating rules. If it repeats, note it in feedback; it is exactly the kind of behaviour the kit needs to hear about.

## I want to start over

Tell your Muse. It should: export the current board with getdashboard and save it as a file for you, then, only with your confirmation naming the board, delete the board and re-run prompt 01. Starting over is a valid choice, and your export means it is not a destructive one.
