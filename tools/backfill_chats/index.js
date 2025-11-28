/*
Node.js backfill script for Firestore chats collection.
- Adds ownerId/merchantId from chalet doc when missing
- Converts string timestamps in chat doc fields (createdAt, lastMessageTime) to Firestore Timestamps

Usage:
1) Install dependencies: npm i firebase-admin
2) Set GOOGLE_APPLICATION_CREDENTIALS to your service account JSON
3) Run: node index.js

This script is destructive only in that it updates documents; it writes only when it finds missing/incorrect fields.
*/

const admin = require('firebase-admin');
const fs = require('fs');

// CLI args
const args = process.argv.slice(2);
if (args.includes('--help') || args.includes('-h')) {
  console.log('Usage: node index.js [--dry-run] [--service-account <path>]')
  console.log('\nOptions:')
  console.log('  --dry-run               Preview changes without writing to Firestore')
  console.log('  --service-account <path>  Path to Firebase service account JSON (optional if GOOGLE_APPLICATION_CREDENTIALS set)')
  process.exit(0)
}
const dryRun = args.includes('--dry-run');
const saIndex = args.indexOf('--service-account');
let saPath = null;
if (saIndex !== -1 && args.length > saIndex + 1) {
  saPath = args[saIndex + 1];
}

// Initialize Admin SDK using either provided service-account path or
// GOOGLE_APPLICATION_CREDENTIALS environment variable.
if (saPath) {
  if (!fs.existsSync(saPath)) {
    console.error(`Service account file not found at ${saPath}`);
    process.exit(1);
  }
  const serviceAccount = require(saPath);
  admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
} else if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
  admin.initializeApp();
} else {
  console.error('Please provide a service account JSON with --service-account <path> or set GOOGLE_APPLICATION_CREDENTIALS env var.');
  process.exit(1);
}

const db = admin.firestore();

async function parseMaybeTimestamp(val) {
  if (val === undefined || val === null) return null;
  if (val._seconds !== undefined && val._nanoseconds !== undefined) return val; // already a Timestamp-like
  if (typeof val === 'string') {
    const d = new Date(val);
    if (!isNaN(d.getTime())) return admin.firestore.Timestamp.fromDate(d);
  }
  return null;
}

async function backfill() {
  const chatsRef = db.collection('chats');
  const snapshot = await chatsRef.get();
  console.log(`Found ${snapshot.size} chats`);

  let count = 0;
  for (const doc of snapshot.docs) {
    const data = doc.data();
    const updates = {};

    // ownerId/merchantId
    const ownerId = data.ownerId || data.merchantId || '';
    if (!data.ownerId && ownerId) updates.ownerId = ownerId;
    if (!data.merchantId && ownerId) updates.merchantId = ownerId;

    // createdAt
    const createdAtTs = await parseMaybeTimestamp(data.createdAt);
    if (createdAtTs) updates.createdAt = createdAtTs;

    // lastMessageTime
    const lastMsgTs = await parseMaybeTimestamp(data.lastMessageTime);
    if (lastMsgTs) updates.lastMessageTime = lastMsgTs;

    if (Object.keys(updates).length > 0) {
      if (dryRun) {
        console.log(`[dry-run] Would update chat ${doc.id} with ${Object.keys(updates).join(', ')}`);
      } else {
        await chatsRef.doc(doc.id).update(updates);
        count++;
        console.log(`Updated chat ${doc.id} with ${Object.keys(updates).join(', ')}`);
      }
    }
  }

  console.log(dryRun ? `Dry-run complete. ${count} documents would have been updated.` : `Done. Updated ${count} documents.`);
}

backfill().catch(err => {
  console.error('Backfill failed', err);
  process.exit(1);
});
