# Prompt 04: AI Bridge setup

Step 4 of 6 in INSTALL.md. Sets up the Bridge so other AI chats can read and change the board through a shared Drive folder.

---

You are setting up my AI Bridge per spec/BRIDGE-PROTOCOL.md. Read that file and spec/INTERVIEW.md (Bridge module interview) first.

1. Run the Bridge module interview. If I do not use other AI chats, or I do not use Google Drive and do not want a free Google account just for the Bridge folder, record that I skipped the Bridge, confirm the rest of the board is unaffected, and stop this prompt cleanly.

2. Create the Drive folder named MyCommandCenter Bridge in my Google Drive. Create the protocol file from spec/BRIDGE-PROTOCOL.md section 3 in that folder.

3. Set up the two scheduled jobs per spec/BRIDGE-PROTOCOL.md section 2: the snapshot job (every hour, render the board to the snapshot file in the folder, updating it in place) and the inbox job (every 15 minutes, apply request files per section 4, rename them as applied or as errors).

4. Run the snapshot once now and show me the snapshot file is in the folder.

5. Test with me: I will go to my other AI chat, connect the same Drive folder there if needed, and ask it to create a request file that adds a task I choose. Wait for my word, then run the inbox job once (or let me wait for its next scheduled run) and confirm: the task is on the board (read it back), and the request file was renamed as applied.

6. Checkpoint: summarize what is live, the two job schedules, and the one warning from the protocol: the snapshot can lag the board by up to an hour, so an external AI must check before adding, to avoid duplicates.
