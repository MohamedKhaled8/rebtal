Backfill chats script

What it does:
- For every document in `chats` collection it:
  - Sets `ownerId` and `merchantId` from whichever exists (if missing)
  - Converts `createdAt` and `lastMessageTime` strings to Firestore Timestamps when possible

How to run:
1) Install Node and npm.
2) In this folder run: npm install firebase-admin
3) Provide service account credentials. Two options:

- Environment variable (PowerShell):
  $env:GOOGLE_APPLICATION_CREDENTIALS = 'C:\path\to\serviceAccount.json'

- Or pass path directly to the script:
  node index.js --service-account C:\path\to\serviceAccount.json --dry-run

4) Run:
  - Dry-run (preview only):
    node index.js --service-account C:\path\to\serviceAccount.json --dry-run

  - Apply changes:
    node index.js --service-account C:\path\to\serviceAccount.json

This will log or apply the updates depending on mode.

Notes:
- Run in a safe environment. This script updates documents; keep a backup if needed.
- It uses the Admin SDK and requires project-level credentials.
