/**
 * Backfill Firestore `users` documents with string field CreatedAt (dd-MM-yyyy).
 *
 * SETUP (once):
 * 1. Firebase Console → Project settings → Service accounts → Generate new private key
 *    → save JSON as `serviceAccountKey.json` in THIS folder (never commit it).
 * 2. In this folder run: npm install
 * 3. Run: npm run migrate
 *
 * ENV ALTERNATIVE: set GOOGLE_APPLICATION_CREDENTIALS to the full path of that JSON
 * and run `node migrate.js` (then you can delete the local copy after pointing env to it).
 *
 * BEHAVIOR: Only updates documents where CreatedAt is missing or empty string.
 * DEFAULT VALUE: 22-01-2026 (22 Jan 2026).
 *
 * Firestore batches are limited to 500 writes; this script commits in chunks.
 */

import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import admin from 'firebase-admin';

const __dirname = dirname(fileURLToPath(import.meta.url));

const COLLECTION = 'users';
const FIELD = 'CreatedAt';
const DEFAULT_CREATED_AT = '22-01-2026';
const BATCH_SIZE = 500;

function initAdmin() {
  const keyPath = join(__dirname, 'serviceAcountKey.json');
  try {
    const serviceAccount = JSON.parse(readFileSync(keyPath, 'utf8'));
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
    });
  } catch (e) {
    if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
      admin.initializeApp();
      return;
    }
    console.error(
      'Missing credentials: place serviceAccountKey.json in this folder, or set GOOGLE_APPLICATION_CREDENTIALS.',
    );
    process.exit(1);
  }
}

function needsBackfill(data) {
  const v = data?.[FIELD];
  if (v === undefined || v === null) return true;
  if (typeof v === 'string' && v.trim() === '') return true;
  return false;
}

async function main() {
  initAdmin();
  const db = admin.firestore();
  const snap = await db.collection(COLLECTION).get();
  let batch = db.batch();
  let count = 0;
  let updated = 0;

  for (const doc of snap.docs) {
    const data = doc.data();
    if (!needsBackfill(data)) continue;

    batch.update(doc.ref, { [FIELD]: DEFAULT_CREATED_AT });
    count++;
    updated++;

    if (count >= BATCH_SIZE) {
      await batch.commit();
      batch = db.batch();
      count = 0;
      console.log(`Committed batch… (${updated} docs updated so far)`);
    }
  }

  if (count > 0) {
    await batch.commit();
  }

  console.log(
    `Done. Scanned ${snap.size} documents; updated ${updated} with ${FIELD}=${DEFAULT_CREATED_AT}.`,
  );
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
