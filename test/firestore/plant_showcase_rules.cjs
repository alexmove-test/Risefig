const fs = require('node:fs');
const path = require('node:path');
const { before, after, beforeEach, test } = require('node:test');
const assert = require('node:assert/strict');
const { initializeTestEnvironment, assertSucceeds, assertFails } = require('@firebase/rules-unit-testing');
const { collection, doc, setDoc, getDoc, getDocs, deleteDoc, query, where,
  orderBy, limit, startAfter, documentId, serverTimestamp, Timestamp } = require('firebase/firestore');

let env;
before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-mahjong-showcase',
    firestore: {
      host: '127.0.0.1', port: 8186,
      rules: fs.readFileSync(process.env.SHOWCASE_RULES_FILE || path.resolve(__dirname, '../../firestore.rules'), 'utf8'),
    },
  });
});
beforeEach(async () => env.clearFirestore());
after(async () => env?.cleanup());

const database = (uid) => env.authenticatedContext(uid).firestore();
const ref = (db, owner = 'alice', plant = 'plant-1') => doc(db, 'plant_showcase', `${owner}__${plant}`);
const payload = (overrides = {}) => ({
  ownerId: 'alice', ownerName: 'Alice', plantId: 'plant-1',
  species: 'amberbell', power: 10, publishedAt: serverTimestamp(), ...overrides,
});

test('owner publishes; another authenticated player reads the common list', async () => {
  await assertSucceeds(setDoc(ref(database('alice')), payload()));
  const result = await assertSucceeds(getDocs(query(
    collection(database('bob'), 'plant_showcase'), orderBy('publishedAt', 'desc'), limit(30))));
  assert.equal(result.size, 1);
  assert.equal(result.docs[0].data().ownerName, 'Alice');
});

test('owner can retry idempotently, change name, and remove the publication', async () => {
  const item = ref(database('alice'));
  await assertSucceeds(setDoc(item, payload()));
  const original = (await getDoc(item)).data();
  await assertSucceeds(setDoc(item, original));
  await assertSucceeds(setDoc(item, { ...original, ownerName: 'Alice II' }));
  await assertSucceeds(deleteDoc(item));
  assert.equal((await getDoc(item)).exists(), false);
});

test('another player cannot impersonate an owner, alter, or remove their card', async () => {
  await assertSucceeds(setDoc(ref(database('alice')), payload()));
  const bob = database('bob');
  await assertFails(setDoc(ref(bob, 'alice', 'plant-2'), payload({ plantId: 'plant-2' })));
  await assertFails(setDoc(ref(bob), payload({ ownerName: 'Changed' })));
  await assertFails(deleteDoc(ref(bob)));
  await assertFails(setDoc(ref(bob, 'bob'), payload()));
});

test('rejects inflated power, invalid species, arbitrary fields and client timestamps', async () => {
  const item = ref(database('alice'));
  await assertFails(setDoc(item, payload({ power: 9999 })));
  await assertFails(setDoc(item, payload({ species: 'invented' })));
  await assertFails(setDoc(item, payload({ email: 'private@example.invalid' })));
  await assertFails(setDoc(item, payload({ ownerName: '' })));
  await assertFails(setDoc(item, payload({ publishedAt: Timestamp.fromMillis(0) })));
  await assertFails(setDoc(item, payload({ plantId: 'plant-2' })));
  await assertSucceeds(setDoc(item, payload()));
  const original = (await getDoc(item)).data();
  await assertFails(setDoc(item, { ...original, species: 'starbamboo', power: 60 }));
  await assertFails(setDoc(item, { ...original, publishedAt: serverTimestamp() }));
});

test('anonymous-to-Firebase means signed in; unauthenticated reads and writes fail', async () => {
  const db = env.unauthenticatedContext().firestore();
  await assertFails(getDoc(ref(db)));
  await assertFails(getDocs(collection(db, 'plant_showcase')));
  await assertFails(setDoc(ref(db), payload()));
});

test('owner and common lists support the exact paginated client queries', async () => {
  const db = database('alice');
  for (let i = 1; i <= 3; i++) {
    await setDoc(ref(db, 'alice', `plant-${i}`), payload({ plantId: `plant-${i}` }));
  }
  const ownQuery = query(collection(db, 'plant_showcase'),
    where('ownerId', '==', 'alice'), orderBy(documentId()), limit(2));
  const ownFirst = await assertSucceeds(getDocs(ownQuery));
  const ownNext = await assertSucceeds(getDocs(query(ownQuery, startAfter(ownFirst.docs.at(-1)))));
  assert.equal(ownFirst.size + ownNext.size, 3);
  const publicQuery = query(collection(database('bob'), 'plant_showcase'), orderBy('publishedAt', 'desc'), limit(2));
  const first = await assertSucceeds(getDocs(publicQuery));
  const next = await assertSucceeds(getDocs(query(publicQuery, startAfter(first.docs.at(-1)))));
  assert.equal(new Set([...first.docs, ...next.docs].map((item) => item.id)).size, 3);
});
