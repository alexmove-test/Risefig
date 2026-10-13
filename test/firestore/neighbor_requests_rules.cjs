const fs = require('node:fs');
const path = require('node:path');
const { before, after, beforeEach, test } = require('node:test');
const assert = require('node:assert/strict');
const { initializeTestEnvironment, assertSucceeds, assertFails } = require('@firebase/rules-unit-testing');
const { collection, doc, setDoc, getDoc, getDocs, updateDoc, deleteDoc, query, where,
  serverTimestamp, Timestamp } = require('firebase/firestore');

let env;
before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-mahjong-neighbors',
    firestore: {
      host: '127.0.0.1', port: 8186,
      rules: fs.readFileSync(process.env.SHOWCASE_RULES_FILE || path.resolve(__dirname, '../../firestore.rules'), 'utf8'),
    },
  });
});
beforeEach(async () => env.clearFirestore());
after(async () => env?.cleanup());

const database = (uid) => env.authenticatedContext(uid).firestore();
const ref = (db, from = 'alice', to = 'bob', kind = 'message') =>
  doc(db, 'neighbor_requests', `${from}__${to}__${kind}`);
const payload = (overrides = {}) => ({
  fromId: 'alice', fromName: 'Alice', toId: 'bob', toName: 'Bob',
  kind: 'message', phrase: 'hello', status: 'pending', createdAt: serverTimestamp(),
  ...overrides,
});
const raid = (overrides = {}) => payload({ kind: 'raid', phrase: 'readyForRaid', power: 25, ...overrides });
const cross = (overrides = {}) => payload({ kind: 'cross', phrase: 'letsCross', species: 'amberbell', ...overrides });

async function seed(id, data) {
  await env.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), 'neighbor_requests', id), data);
  });
}

test('a player sends a request that only the two sides can read', async () => {
  await assertSucceeds(setDoc(ref(database('alice')), payload()));
  await assertSucceeds(getDoc(ref(database('bob'))));
  await assertFails(getDoc(ref(database('carol'))));
  const inbox = await assertSucceeds(getDocs(query(
    collection(database('bob'), 'neighbor_requests'), where('toId', '==', 'bob'))));
  assert.equal(inbox.size, 1);
  await assertSucceeds(getDocs(query(
    collection(database('alice'), 'neighbor_requests'), where('fromId', '==', 'alice'))));
  await assertFails(getDocs(collection(database('carol'), 'neighbor_requests')));
  await assertSucceeds(getDoc(ref(database('alice'), 'alice', 'bob', 'raid')));
});

test('requests cannot be forged, inflated, free-text, or aimed at oneself', async () => {
  const alice = database('alice');
  await assertFails(setDoc(ref(database('carol')), payload()));
  await assertFails(setDoc(ref(alice), payload({ phrase: 'buy gold at example.invalid' })));
  await assertFails(setDoc(ref(alice), payload({ text: 'free text' })));
  await assertFails(setDoc(ref(alice, 'alice', 'alice'), payload({ toId: 'alice' })));
  await assertFails(setDoc(ref(alice), payload({ status: 'accepted' })));
  await assertFails(setDoc(ref(alice), payload({ createdAt: Timestamp.fromMillis(1) })));
  await assertFails(setDoc(ref(alice, 'alice', 'bob', 'raid'), raid({ power: 5000 })));
  const { power, ...powerless } = raid();
  assert.equal(power, 25);
  await assertFails(setDoc(ref(alice, 'alice', 'bob', 'raid'), powerless));
  await assertFails(setDoc(ref(alice, 'alice', 'bob', 'cross'), cross({ species: 'invented' })));
  await assertFails(setDoc(ref(alice, 'alice', 'bob', 'raid'), payload()));
  await assertSucceeds(setDoc(ref(alice, 'alice', 'bob', 'raid'), raid()));
  await assertSucceeds(setDoc(ref(alice, 'alice', 'bob', 'cross'), cross()));
});

test('an open request blocks a second one; a closed one can be replaced', async () => {
  const alice = database('alice');
  await assertSucceeds(setDoc(ref(alice), payload()));
  await assertFails(setDoc(ref(alice), payload({ phrase: 'goodLuck' })));
  await assertSucceeds(updateDoc(ref(alice), { status: 'cancelled', respondedAt: serverTimestamp() }));
  await assertSucceeds(setDoc(ref(alice), payload({ phrase: 'goodLuck' })));
  await assertFails(deleteDoc(ref(database('carol'))));
  await assertSucceeds(deleteDoc(ref(alice)));
});

test('only the recipient answers; a raid cannot be declined', async () => {
  await assertSucceeds(setDoc(ref(database('alice'), 'alice', 'bob', 'raid'), raid()));
  const bobRaid = ref(database('bob'), 'alice', 'bob', 'raid');
  await assertFails(updateDoc(ref(database('alice'), 'alice', 'bob', 'raid'),
    { status: 'accepted', replyPower: 0, respondedAt: serverTimestamp() }));
  await assertFails(updateDoc(bobRaid, { status: 'declined', respondedAt: serverTimestamp() }));
  await assertFails(updateDoc(bobRaid, { status: 'accepted', respondedAt: serverTimestamp() }));
  await assertFails(updateDoc(bobRaid,
    { status: 'accepted', replyPower: 10, power: 1, respondedAt: serverTimestamp() }));
  await assertSucceeds(updateDoc(bobRaid,
    { status: 'accepted', replyPower: 10, replyPhrase: 'wellPlayed', respondedAt: serverTimestamp() }));
  await assertFails(updateDoc(bobRaid, { replyPower: 999 }));

  await assertSucceeds(setDoc(ref(database('alice')), payload()));
  await assertSucceeds(updateDoc(ref(database('bob')),
    { status: 'declined', replyPhrase: 'thanks', respondedAt: serverTimestamp() }));
});

test('each side marks its cross seed once; a fresh cross waits for both', async () => {
  const alice = database('alice');
  const bob = database('bob');
  await assertSucceeds(setDoc(ref(alice, 'alice', 'bob', 'cross'), cross()));
  await assertFails(updateDoc(ref(bob, 'alice', 'bob', 'cross'),
    { status: 'accepted', respondedAt: serverTimestamp() }));
  await assertSucceeds(updateDoc(ref(bob, 'alice', 'bob', 'cross'), {
    status: 'accepted', replySpecies: 'glassreed', resultSpecies: 'mistfern',
    respondedAt: serverTimestamp(),
  }));
  await assertFails(updateDoc(ref(database('carol'), 'alice', 'bob', 'cross'), { toClaimed: true }));
  await assertFails(updateDoc(ref(alice, 'alice', 'bob', 'cross'), { toClaimed: true }));
  await assertSucceeds(updateDoc(ref(alice, 'alice', 'bob', 'cross'), { fromClaimed: true }));
  await assertFails(setDoc(ref(alice, 'alice', 'bob', 'cross'), cross()));
  await assertSucceeds(updateDoc(ref(bob, 'alice', 'bob', 'cross'), { toClaimed: true }));
  await assertSucceeds(setDoc(ref(alice, 'alice', 'bob', 'cross'), cross()));
});

test('an unclaimed cross can be replaced after a week', async () => {
  await seed('alice__bob__cross', {
    fromId: 'alice', fromName: 'Alice', toId: 'bob', toName: 'Bob', kind: 'cross',
    phrase: 'letsCross', status: 'accepted', species: 'amberbell',
    createdAt: Timestamp.fromMillis(Date.now() - 9 * 86400000),
    respondedAt: Timestamp.fromMillis(Date.now() - 8 * 86400000),
    replySpecies: 'mistfern', resultSpecies: 'mistfern',
  });
  await assertSucceeds(setDoc(ref(database('alice'), 'alice', 'bob', 'cross'), cross()));
});
