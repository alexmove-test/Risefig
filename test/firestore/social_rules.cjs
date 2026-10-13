const fs = require('node:fs');
const path = require('node:path');
const { before, after, beforeEach, test } = require('node:test');
const assert = require('node:assert/strict');
const { initializeTestEnvironment, assertSucceeds, assertFails } = require('@firebase/rules-unit-testing');
const { collection, doc, setDoc, getDoc, getDocs, updateDoc, deleteDoc, query, where,
  serverTimestamp, writeBatch } = require('firebase/firestore');

let env;
before(async () => {
  env = await initializeTestEnvironment({ projectId: 'demo-mahjong-social', firestore: {
    host: '127.0.0.1', port: 8186,
    rules: fs.readFileSync(process.env.SHOWCASE_RULES_FILE || path.resolve(__dirname, '../../firestore.rules'), 'utf8'),
  }});
});
beforeEach(async () => env.clearFirestore());
after(async () => env?.cleanup());
const db = (uid) => env.authenticatedContext(uid).firestore();
const link = (uid) => doc(db(uid), 'friendships/alice__bob');
const invite = (overrides = {}) => ({members:['alice','bob'], fromId:'alice', fromName:'Alice',
  toId:'bob', toName:'Bob', status:'pending', createdAt:serverTimestamp(), updatedAt:serverTimestamp(), ...overrides});
const message = (senderId='alice', text='Hello') => ({senderId, text, sentAt:serverTimestamp()});
async function accepted() {
  await setDoc(link('alice'), invite());
  await updateDoc(link('bob'), {status:'accepted', updatedAt:serverTimestamp()});
}

test('only recipient accepts; invitations are private and cannot be replaced while open', async () => {
  await assertSucceeds(setDoc(link('alice'), invite()));
  await assertFails(updateDoc(link('alice'), {status:'accepted', updatedAt:serverTimestamp()}));
  await assertFails(updateDoc(link('carol'), {status:'accepted', updatedAt:serverTimestamp()}));
  await assertFails(setDoc(link('bob'), invite({fromId:'bob',toId:'alice'})));
  await assertFails(getDoc(link('carol')));
  const list = await assertSucceeds(getDocs(query(collection(db('bob'),'friendships'), where('members','array-contains','bob'))));
  assert.equal(list.size,1);
  await assertSucceeds(updateDoc(link('bob'), {status:'accepted', updatedAt:serverTimestamp()}));
  await assertFails(setDoc(link('alice'), invite()));
  await assertSucceeds(updateDoc(link('alice'), {status:'removed', updatedAt:serverTimestamp()}));
  await assertSucceeds(setDoc(link('bob'), invite({fromId:'bob', fromName:'Bob', toId:'alice', toName:'Alice'})));
});

test('messages require accepted friendship and cannot be spoofed or edited', async () => {
  const ref = (uid,id='m') => doc(db(uid),'friendships/alice__bob/messages',id);
  await setDoc(link('alice'),invite());
  await assertFails(setDoc(ref('alice'),message()));
  await updateDoc(link('bob'),{status:'accepted',updatedAt:serverTimestamp()});
  await assertSucceeds(setDoc(ref('alice'),message()));
  await assertSucceeds(setDoc(ref('bob','reply'),message('bob','Hello Alice')));
  await assertFails(setDoc(ref('bob','fake'),message()));
  await assertFails(setDoc(ref('carol','fake'),message('carol')));
  await assertFails(updateDoc(ref('alice'),{text:'Changed'}));
  await assertFails(getDoc(ref('carol')));
  await assertSucceeds(getDoc(ref('bob')));
  await assertFails(setDoc(ref('alice','long'),message('alice','a'.repeat(1001))));
  await assertFails(setDoc(ref('alice','blank'),message('alice','   ')));
  await assertSucceeds(setDoc(ref('alice','multiline'),message('alice','First\nSecond')));
  await assertFails(deleteDoc(ref('carol')));
  await assertSucceeds(deleteDoc(ref('alice')));
  await assertFails(deleteDoc(link('carol')));
  await assertSucceeds(deleteDoc(link('bob')));
});

test('blocking stops chat and new game requests in both directions', async () => {
  await accepted();
  await assertSucceeds(setDoc(doc(db('bob'),'social_blocks/bob/players/alice'),{createdAt:serverTimestamp()}));
  await assertFails(setDoc(doc(db('alice'),'social_blocks/bob/players/carol'),{createdAt:serverTimestamp()}));
  for (const uid of ['alice','bob']) {
    await assertFails(setDoc(doc(db(uid),'friendships/alice__bob/messages',uid),message(uid)));
    const other = uid === 'alice' ? 'bob' : 'alice';
    await assertFails(setDoc(doc(db(uid),'neighbor_requests',`${uid}__${other}__message`),{
      fromId:uid,fromName:uid,toId:other,toName:other,kind:'message',phrase:'hello',status:'pending',createdAt:serverTimestamp(),
    }));
  }
  await updateDoc(link('alice'),{status:'removed',updatedAt:serverTimestamp()});
  await assertFails(setDoc(link('alice'),invite()));
});

test('profile bounds, ownership and opting out of invitations are enforced', async () => {
  const profile = {about:1,language:2,interests:1,goal:3,avatar:2,openToFriends:false};
  await assertSucceeds(setDoc(doc(db('bob'),'social_profiles/bob'),profile));
  await assertFails(setDoc(link('alice'),invite()));
  await assertFails(updateDoc(doc(db('alice'),'social_profiles/bob'),{about:2}));
  await assertFails(updateDoc(doc(db('bob'),'social_profiles/bob'),{about:'A gardener'}));
  await assertFails(updateDoc(doc(db('bob'),'social_profiles/bob'),{about:7}));
  await assertFails(updateDoc(doc(db('bob'),'social_profiles/bob'),{language:6}));
  await assertFails(updateDoc(doc(db('bob'),'social_profiles/bob'),{avatar:25}));
  await assertSucceeds(updateDoc(doc(db('bob'),'social_profiles/bob'),{about:0}));
  await assertSucceeds(updateDoc(doc(db('bob'),'social_profiles/bob'),{openToFriends:true}));
  await assertSucceeds(setDoc(link('alice'),invite()));
});

test('reports refer to an actual incoming message and remain possible after blocking', async () => {
  await accepted();
  await setDoc(doc(db('alice'),'friendships/alice__bob/messages/m'),message());
  await setDoc(doc(db('bob'),'social_blocks/bob/players/alice'),{createdAt:serverTimestamp()});
  const report = {reporterUid:'bob',targetUid:'alice',friendshipId:'alice__bob',messageId:'m',createdAt:serverTimestamp()};
  await assertSucceeds(setDoc(doc(db('bob'),'message_reports/report'),report));
  await assertFails(setDoc(doc(db('carol'),'message_reports/spoof'),{...report,reporterUid:'carol'}));
  await assertFails(setDoc(doc(db('bob'),'message_reports/missing'),{...report,messageId:'missing'}));
  await assertSucceeds(getDoc(doc(db('bob'),'message_reports/report')));
  await assertFails(getDoc(doc(db('carol'),'message_reports/report')));
  await assertFails(deleteDoc(doc(db('alice'),'message_reports/report')));
  await assertSucceeds(deleteDoc(doc(db('bob'),'message_reports/report')));
});

test('shared history accepts only real accepted requests and survives a new request', async () => {
  const alice=db('alice'), bob=db('bob');
  const id='alice__bob__message';
  await setDoc(doc(alice,'neighbor_requests',id),{fromId:'alice',fromName:'Alice',toId:'bob',toName:'Bob',
    kind:'message',phrase:'thanks',status:'pending',createdAt:serverTimestamp()});
  const original=(await getDoc(doc(bob,'neighbor_requests',id))).data();
  const snapshot={...original,status:'accepted',replyPhrase:'hello',respondedAt:serverTimestamp()};
  const history={members:['alice','bob'],pairId:'alice__bob',requestId:id,createdAt:original.createdAt,snapshot};
  await assertFails(setDoc(doc(bob,'neighbor_history/fake'),history));
  const batch=writeBatch(bob);
  batch.update(doc(bob,'neighbor_requests',id),{status:'accepted',replyPhrase:'hello',respondedAt:serverTimestamp()});
  batch.set(doc(bob,'neighbor_history/event'),history);
  await assertSucceeds(batch.commit());
  await assertSucceeds(getDocs(query(collection(alice,'neighbor_history'),where('members','array-contains','alice'),where('pairId','==','alice__bob'))));
  await assertFails(getDoc(doc(db('carol'),'neighbor_history/event')));
  await setDoc(doc(alice,'neighbor_requests',id),{...original,status:'pending',createdAt:serverTimestamp()});
  assert.equal((await getDoc(doc(bob,'neighbor_history/event'))).data().snapshot.status,'accepted');
  await assertFails(deleteDoc(doc(db('carol'),'neighbor_history/event')));
  await assertSucceeds(deleteDoc(doc(db('alice'),'neighbor_history/event')));
});
