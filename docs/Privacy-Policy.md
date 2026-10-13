# Privacy Policy

**Last updated:** October 13, 2026

This Privacy Policy describes how **Rise Fig** (“the App”, “we”, “us”, or “our”) collects, uses, and shares information when you use our mobile game on Android (and other platforms where the App may be made available).

By installing or using the App, you agree to the collection and use of information in accordance with this Privacy Policy. If you do not agree, please do not use the App.

---

## 1. Who we are

**App name:** Rise Fig  
**Package name:** `com.rise.mahjong`  
**Developer / Data controller:** Oleksii Hnylytskyi  
**Contact email:** myevidentsuccess@gmail.com

For privacy-related questions, requests, or complaints, please contact us at the email address above. Inappropriate leaderboard names can be reported **in the App** (see Section 8) or by email.

---

## 2. Overview

Rise Fig is an offline-capable tile-matching puzzle game with optional online features:

- **Online leaderboard** (powered by Google Firebase)
- **Optional public plant showcase** (powered by Google Firebase)
- **Optional public profiles, friend invitations, private conversations and shared game-action history** (powered by Google Firebase)
- **Rewarded advertisements** (powered by Google AdMob)
- **Product analytics** (powered by Google Firebase Analytics)
- **Optional local reminders** (scheduled on your device; not sent through our servers)

We do **not** require you to create an account with an email address or password. Online features use **anonymous authentication** provided by Firebase.

We do **not** sell your personal information.

The App is for a **general audience** and is **not** directed at children. It is **not** enrolled in Google Play’s Families program.

---

<h2>3. Information we collect</h2>

### 3.1 Information you provide

| Data | Description | Required? |
|------|-------------|-----------|
| **Display name** | A nickname you choose for the leaderboard (up to 20 characters) | Optional (default: a generated guest label) |

You are encouraged not to use your real name or other personally identifying information as your display name. Nicknames are **public user-generated content**: other players can see them on the leaderboard. On the leaderboard screen you can **report** a name or **hide** that player. A report is sent to us through the App when you are online; if that fails, the App can open an email draft to myevidentsuccess@gmail.com. Hidden-player IDs are stored on your device and synchronized with Firebase when you use the social features, so server rules can stop contact in both directions. Blocking does not send a notification to the other player.

### Optional profiles and conversations

What a profile, a friendship, a private message, a block, and a message report contain, and who can read them, is described in Section 3.8. The service operator can access those stored records for support and moderation. Messages are not end-to-end encrypted. **Delete account and data** in Settings removes the signed-in account’s copies (Section 8). Clearing App storage or uninstalling does not. An anonymous account is not restored after you reinstall the App.

### 3.2 Information stored on your device (local)

The App stores progress and settings on your device using local storage (SharedPreferences), including:

- Campaign progress (levels unlocked, stars, best scores, in-progress table)
- Courtyard progress (house stage, decorations such as pond / swing / flower bed, table look)
- Pet companionship, stories, and related local state
- Player display name (if set) and local leaderboard sync metadata
- IDs of leaderboard players you have hidden
- IDs of plants reserved for your public showcase and the Firebase account that published them
- Settings (language, sound, music, haptics, covered-tile dimming, reminder opt-in)

This data stays **on your device** unless a feature below sends a subset of it online. Clearing App storage or uninstalling the App deletes it.

The App also reads your device **timezone** locally so reminder times match the clock on your phone. We do not send your timezone to our servers.

### 3.3 Information collected automatically — online leaderboard (Firebase)

If you use the online leaderboard and have an internet connection, the App may send the following to **Google Firebase** (Cloud Firestore):

| Data | Purpose |
|------|---------|
| **Anonymous user ID** | Identifies your leaderboard entry without email/password |
| **Display name** | Shown on the public leaderboard |
| **Rating score** | Calculated from stars, best scores, and campaign progress |
| **Total stars** | Campaign progress |
| **Levels unlocked** | Campaign progress |
| **Sum of best scores** | Rating calculation |
| **Last updated timestamp** | Leaderboard ordering and sync |

The leaderboard is **publicly readable** by anyone using the App. Other players can see your display name and scores. Only you (via your anonymous account on this device) can update your own leaderboard entry. You can delete that document from **Settings → Delete account and data** (see Section 8). Clearing App storage alone does not delete it.

If you **report** a nickname from the leaderboard, the App may also write a moderation record to Firestore (`ugc_reports`), including your anonymous user ID, the reported player’s anonymous ID and nickname, a reason code, and a timestamp. You cannot read other players’ reports. We use these records to review names and may remove or change an entry.

**Firebase services used:**

- Firebase Authentication (Anonymous sign-in)
- Cloud Firestore (database)
- Firebase Analytics (product funnel events)

**Firebase project:** `mahjong-rise`

### Optional plant showcase

When you choose to put a harvested plant on display, the App sends your anonymous
Firebase user ID, public display name, the plant's ID, species, feeding value,
and publication timestamp to Cloud Firestore (`plant_showcase`). Other players
using Firebase authentication in the App can read these cards. Publishing does
not upload your full inventory. You can remove your own cards from inside the
App while connected. Removing a card does not remove the plant from your local
inventory. Local protection prevents feeding a displayed plant to a pet until
the server confirms that the card has been removed.

Player hiding applies to the showcase as well. A name can be reported using the
same moderation mechanism described above. If you lose access to the anonymous
account that published a card, contact us to request removal.

### 3.4 Information collected automatically — product analytics (Firebase Analytics)

If you have an internet connection, the App may send anonymous gameplay events to **Firebase Analytics** so we can see where players get stuck and which levels or boosters need tuning. These events are not tied to your name or email. They may include:

- Level started, won, lost, or left (including level id, layout, and an anonymous session id)
- Daily-table or campaign mode
- Booster used (hint, shuffle, magnet, undo)
- Rewarded ad offered, completed, or skipped
- Score, remaining tiles, and booster charges at those moments
- Leaderboard opened, pet visit or adopt, reminder notification opened, streak broken
- A leaderboard name was reported or a player was hidden (no nickname is sent with those events)

In the EEA, the UK, and other regions where Google shows the UMP form, the App does not send these events until you accept that form. **Privacy settings** applies a later change: if you withdraw consent, new analytics events stop. Outside those regions, events are sent when you are online on the basis of legitimate interest (Section 4). You can also limit analytics by playing offline or by restricting the App’s network access in your device settings.

This data is processed by **Google** in accordance with Google’s policies.

### 3.5 Information collected automatically — advertising (Google AdMob)

The App displays **optional rewarded video advertisements** through **Google AdMob** when you choose to watch a short video for an in-game boost (shuffle, magnet, hint, or undo), or once a day to harvest one growing garden plant immediately.

In the European Economic Area (EEA), United Kingdom, and other regions where Google requires it, the App shows Google’s **User Messaging Platform (UMP)** consent form **on first launch**, before AdMob is initialized — not only when you tap to watch a video. Where Google requires an ongoing privacy-options entry point, a **Privacy settings** item appears in the App’s settings (and in the table menu) so you can change or withdraw that consent.

When ads are served, Google may collect information such as:

- Advertising ID (AAID on Android)
- Device information (device model, OS version)
- IP address (approximate location may be inferred)
- Ad interaction data (impressions, clicks, rewards)
- Diagnostic and performance data related to ad delivery
- Consent choices collected through UMP

This data is collected and processed by **Google** in accordance with Google’s policies, not directly by us.

**AdMob App ID:** `ca-app-pub-1561854396404271~8263443836`

For more information:

- [Google Privacy Policy](https://policies.google.com/privacy)
- [Google AdMob & Advertising](https://support.google.com/admob/answer/6128543)
- [How Google uses data from sites and apps that use its services](https://policies.google.com/technologies/partner-sites)

You can also reset or limit your advertising ID in **Android device settings** (Settings → Google → Ads → Reset advertising ID / Opt out of Ads Personalization).

### 3.6 Optional local reminders

If you turn reminders **on** in Settings, the App asks Android for notification permission and schedules **local** notifications on your device (for example, courtyard play reminders and pet-care reminders). Scheduling uses the clock and timezone on your phone.

- Reminders are **not** sent through our servers or Firebase Cloud Messaging.
- No precise GPS location is used.
- You can turn reminders off in Settings at any time; the App then cancels scheduled notifications.
- If you open the App from a reminder, we may log an anonymous `notification_open` analytics event (see Section 3.4).

### 3.7 Information we do NOT collect

We do **not** intentionally collect:

- Email address or phone number
- Precise GPS location
- Contacts, photos, microphone, or camera data
- Payment or financial information (the App has no in-app purchases; any future purchases would be handled by Google Play)

### 3.8 Neighbors, courtyard actions, and what other players can see

Online neighbor features use the same **anonymous Firebase account** as the leaderboard (Firebase project `mahjong-rise`, Cloud Firestore). They do **not** upload your courtyard. House stage, decorations, garden beds, pet care, points balance, and your plant inventory stay on the device (Section 3.2), except the specific fields listed in this section.

**Neighbor list (“players on the hills”).** This list is the public leaderboard. Anyone who can read that collection can see the fields in Section 3.3 (anonymous ID, display name, rating, stars, levels unlocked, sum of best scores, last updated time). If you spend on-device points to show profile pictures next to your name, the same public document also stores `badges` (avatar and picture indexes for description, interests, and goal) and `badgesUntil` (a timestamp, at most 31 days ahead). Those pictures stay visible on the public leaderboard until that time. Your points balance is not sent.

**Profile.** Any signed-in player can read your profile document: picture indexes for a short description, interests, an in-game goal, and an avatar, plus whether you accept new invitations (`openToFriends`). The editor does not ask for a language; the stored language number stays zero. There is no free-form profile text.

**Friendship.** An invitation stores both anonymous IDs, both display names (the App sends at most 20 characters), status (`pending`, `accepted`, `declined`, `cancelled`, or `removed`), and created/updated timestamps. Only the two participants can read it. Ending a friendship in the neighbor card sets the status to `removed` and leaves the document and messages in place. Either participant can delete the document when they delete their account (Section 8).

**Private messages.** After both people have accepted, you can send free text of up to 1000 characters. Each message stores the sender’s anonymous ID, the text, and a server timestamp. Only the two participants can read the conversation. The App loads messages in pages of 50. The conversation screen cannot edit or delete a message. Deleting your account deletes the conversation for both participants. There is no calendar expiry. Messages stay until you delete the account, we remove them after an email request, or we remove them during maintenance. Messages are not end-to-end encrypted.

A message report stores the reporting player’s anonymous ID, the sender’s anonymous ID, the friendship ID, the message ID, and a timestamp. Players cannot read reports.

**Preset notes** (`neighbor_requests`). These are separate from free-text chat. You send one of eight fixed phrases. There is no custom text. The request stores both anonymous IDs, both display names, the kind (`message`, `defense`, `cross`, or `raid`), the phrase, the status, and timestamps. Only the two players can read it. The request screen does not offer a separate delete. Either participant can delete the request when they delete their account. When a newer request of the same kind is allowed to replace it, the previous accepted snapshot is copied into shared history (`neighbor_history`).

**Defending another yard.** A defense request stores your anonymous ID, display name, the fixed phrase, and your defending pet’s combat power (a number from 1 to 1000). If the owner accepts, it also stores the reply phrase and the response time. The App treats protection as lasting 24 hours from acceptance. That duration is calculated on the device; it is not stored as its own field. Only you and the yard owner can read this request. The defense request does not include the pet’s hunger, stories, or the layout of either courtyard.

**Raids.** A raid request stores both players’ anonymous IDs and display names, the fixed phrase, and the attacker’s pet power. When the yard answers, it also stores the defense power, how the yard was defended (`own`, `guard`, `help`, or `auto`), and — when another player defended — that defender’s anonymous ID, display name, and pet kind. The security rules accept the pet kinds `dog` and `hamster` in this field. If the raid succeeds, the request stores at most one burned plant species and one taken plant species, an optional trait (`attack`, `defense`, or `bloom`), and whether each side has applied the result on their device. The owner has 24 hours to answer. Another raid on the same yard cannot start until 24 hours after the answer, and unsettled loot can block a new raid for 7 days. Those timers do not delete the stored request. Only the two players in the request can read it.

**Call for help** (`raid_help`). The raided player may publish a call with their anonymous ID and display name, the attacker’s anonymous ID, the attack power, the audience (`friends` or `everyone`), up to 50 friend anonymous IDs (`viewers`), the raid time, and an expiry 24 hours after the raid was created. A signed-in player can read the call if they are not the attacker and they own it, are listed in `viewers`, or the audience is `everyone`. The attacker cannot read the call. A helper’s offer stores their anonymous ID, display name, power, pet kind (`dog` or `hamster`), raid time, and a timestamp. The yard owner and that helper can read the offer. The attacker cannot read the offer. Deleting your account deletes calls you created and offers you sent, and it deletes offers other players placed on your call. The App does not otherwise delete calls or offers. The call does not include the courtyard layout or the plant inventory.

**Crossing plants.** A cross request stores both anonymous IDs and display names, the fixed phrase, and the plant species each player offers. On acceptance it stores the resulting species and whether each side has taken their seed. Only the two players can read it. The seed kept on your device also stores the partner’s anonymous ID and display name, the parent species, and the ID of your own plant used in the cross, so the warehouse can show who you grew it with. That lineage is not uploaded with a public showcase card. Showcase cards remain as described under “Optional plant showcase” above.

**Shared history.** An accepted request can be copied to `neighbor_history` with both member IDs, a pair ID, the request ID, and a snapshot of the request fields above. Only those two players can read it. The App shows the latest 50 events. Older copies stay until either participant deletes their account or we remove them after an email request or during maintenance.

**Stored only on your device.** The App also keeps, in local storage: players you marked as acquaintances (anonymous ID, display name, and the public leaderboard numbers you last saw); IDs of neighbor events you have seen or thanked (up to 1000); a local memory of joint actions (up to 50 entries: person ID, display name, an action code, and a time); and a cache of neighbor-list cards for offline display. The code does not set a maximum size for that cache. Other players do not receive these local copies. Clearing App data deletes them.

**Who else receives this data.** These records are stored with **Google Firebase** (Cloud Firestore and anonymous Authentication), the same provider as the leaderboard. We do not sell them, and this social data is not sent to AdMob. Other players see only the fields described above. The service operator can access stored records for support and moderation. The App itself has no separate operator console.

**How long we keep it.** The code sets no fixed number of days. Profiles, friendships, messages, neighbor requests, raid-help calls, offers, and shared history remain until you delete the account in Settings, we remove them after an email request (Section 8), or we remove them during maintenance. The 24-hour and 7-day periods above only control when a new action may replace the current request.

---

## 4. How we use your information

We use collected information to:

| Purpose | Legal basis (where applicable) |
|---------|-------------------------------|
| Save and restore your game progress and settings | Performance of the App’s core functionality |
| Display and sync the online leaderboard | Your use of optional online features |
| Show your profile, friendships, private messages, and neighbor actions (defense, raids, plant crossing, calls for help) | Your use of optional online features |
| Calculate and rank player ratings | App functionality |
| Show the advertising consent form and deliver rewarded ads | Consent (UMP where required; you also choose whether to watch a video) |
| Schedule optional local reminders | Consent (in-app toggle and the OS notification permission) |
| Review reported leaderboard names | Legitimate interest / legal obligation to moderate public UGC |
| Review message reports | Legitimate interest / legal obligation to moderate private messages |
| Understand level difficulty and booster use | Consent in the EEA, UK, and other regions where UMP is required; legitimate interest elsewhere |
| Improve stability and fix bugs | Legitimate interest |
| Comply with legal obligations | Legal requirement |

We do **not** use your data for automated decision-making that produces legal or similarly significant effects.

---

## 5. Data sharing and third parties

We share data only with the following categories of recipients:

| Recipient | Data shared | Purpose |
|-----------|-------------|---------|
| **Google LLC (Firebase)** | Anonymous ID, display name, game stats, profile picture choices, friendships, private messages, neighbor-action records, raid-help calls, plant showcase cards, name-report and message-report records, anonymous gameplay events | Online leaderboard, anonymous auth, social features, UGC reports, product analytics |
| **Google LLC (AdMob / UMP)** | Ad ID, device/ad interaction data, consent choices | Display rewarded ads and collect advertising consent |
| **Google LLC (Google Play)** | Standard Play distribution data | App distribution (when published on Play Store) |

Local reminders are not shared with these recipients.

We do **not** sell, rent, or trade your personal information to third parties for their marketing purposes.

Firebase and AdMob may process data on servers located outside your country, including the United States and the European Union, subject to Google’s data protection terms and standard contractual clauses where applicable.

---

## 6. Data retention

| Data type | Retention |
|-----------|-----------|
| **Local game progress and settings** | Until you uninstall the App or clear App data |
| **Hidden leaderboard players (local)** | Until you uninstall the App or clear App data |
| **Local reminder schedules** | Until you turn reminders off, deny notification permission, uninstall, or clear App data |
| **Leaderboard entry (Firestore)** | Until you delete the account in Settings, you request deletion by email and we remove the entry, or we remove inactive entries as part of maintenance |
| **Profile, friendships, messages, neighbor requests, raid help, shared history, and showcase cards (Firestore)** | Until you delete the account in Settings, we remove them after an email request, or we remove them during maintenance. No fixed number of days is set in the App |
| **Reports you submitted (Firestore)** | Until you delete the account in Settings, or we finish reviewing them and delete or anonymize them during maintenance |
| **Name-report records filed by other players (Firestore)** | Until we finish reviewing the report and any related enforcement, then delete or anonymize as part of maintenance. **Delete account and data** does not remove reports other players submitted about you |
| **Anonymous Firebase account** | Deleted when you use **Delete account and data** while this device is signed in. If Authentication refuses that delete, the App signs out so this device does not write the records again under the same ID. Uninstalling without that step typically creates a new anonymous ID on next install and does not delete the old server records |
| **Firebase Analytics events** | Retained by Google per [Google’s retention policies](https://policies.google.com/privacy) |
| **AdMob / UMP data** | Retained by Google per [Google’s retention policies](https://policies.google.com/privacy) |

We may retain anonymized or aggregated data that cannot identify you for analytics and service improvement.

---

## 7. Data security

We take reasonable measures to protect your information:

- Data in transit to Firebase is encrypted via HTTPS/TLS
- Firestore security rules restrict writes so users can only update their own leaderboard document
- Leaderboard writes require authenticated (anonymous) access
- A signed-in player can delete their own leaderboard document, profile, block list, and showcase cards, and the shared records they belong to (friendships, messages, neighbor requests, shared history, raid-help calls they created, and help offers they sent or that were placed on their call)
- A signed-in player can read and delete only reports they submitted. They cannot read or delete reports filed by other players
- If in-app deletion cannot reach an old anonymous account, we delete the remaining entries manually after a verified email request

No method of transmission or storage is 100% secure. We cannot guarantee absolute security.

---

## 8. Your rights and choices

Depending on your location, you may have the right to:

- **Access** the personal data we hold about you
- **Correct** inaccurate data (e.g., change your display name in the App)
- **Delete** your data
- **Object** to or **restrict** certain processing
- **Withdraw consent** for optional features
- **Lodge a complaint** with your local data protection authority

### How to exercise your rights

1. **Display name:** Change it in the App on the leaderboard screen.
2. **Report or hide a public nickname:** On the leaderboard, open that player and choose **Report this name** or **Hide this player**. Report sends a record to us in the App (email is only a fallback if the App cannot send it). Hide removes them from **your** list only. You can also email myevidentsuccess@gmail.com with the name and, if possible, the rank or score.
3. **Local data:** Uninstall the App or clear App storage in Android Settings → Apps → Rise Fig → Storage → Clear data.
4. **Account and data:** In Settings, choose **Delete account and data**. This clears the device and, when this device is signed in, deletes that anonymous account and the server records described under “Account and data deletion.” If the App cannot find the account, email myevidentsuccess@gmail.com.
5. **Advertising consent (EEA/UK and similar regions):** Use **Privacy settings** in the App when that item is shown. You can also skip rewarded videos entirely.
6. **Advertising ID:** Manage via Android device settings (see Section 3.5).
7. **Reminders:** Turn the reminder switch off in App settings, or revoke notification permission in Android Settings.
8. **Analytics / online features:** Play without a network connection, or restrict the App’s network access in Android Settings.

### Account and data deletion

**In the App.** Settings includes **Delete account and data**. After you confirm, and while this device is signed in to its anonymous account, the App deletes:

- the leaderboard entry (name, scores, and badge pictures);
- the social profile and the block list;
- friendships and the messages under them;
- neighbor requests (preset notes, defense, raids, and crosses) and shared history snapshots;
- raid-help calls you created, help offers you sent, and offers other players placed on your call;
- plant showcase cards you published;
- message reports and leaderboard name reports **you** submitted;
- the Firebase Authentication user for that sign-in.

It then clears data stored on the device: the courtyard (house, decorations, garden, pets, seeds, and points), campaign progress, settings, local neighbor lists, and the partner ID and name stored on a crossbred seed. It also cancels local reminders. The game starts again empty.

If Firebase refuses to delete the sign-in, the App signs this device out after the records above are gone, so the same ID is not used to write them again.

A conversation, a neighbor request, and a history snapshot are one document shared by two players. Deleting that document removes it for the other player as well. The App cannot erase a display name that another player’s device already stored locally (for example, on a seed they grew with you).

Reports that **other players** submitted about you are not deleted by this button. They stay until we finish moderation, then we delete or anonymize them during maintenance.

The conversation screen does not delete individual messages. Messages are deleted through **Delete account and data**.

You can still, without deleting the account:

- remove your own plant showcase cards while online;
- remove a player from your on-device acquaintance list;
- change or clear profile pictures and turn off new friend invitations;
- end a friendship (the status becomes `removed`; the document and messages stay until an account deletion);
- block or hide a player.

If this device has no signed-in anonymous account, the button clears only the device. Server records from an earlier install are not on the new anonymous ID.

Uninstalling the App or clearing App storage (Android Settings → Apps → Rise Fig → Storage → Clear data) removes only what is on the device. It does not delete Cloud Firestore records.

**By email.** If deletion in the App fails, or you no longer have the device that was signed in, email **myevidentsuccess@gmail.com**. Ask us to delete the anonymous account and all related records, not only the leaderboard. Include your display name and, if you can, your approximate rating or scores. Because the account is anonymous, we may not be able to verify identity beyond the information you provide. We delete the same server records listed above, including reports you submitted. We complete a verified request within **30 days**.

We will respond to requests within a reasonable timeframe and as required by applicable law (typically within 30 days).

---

## 9. Children’s privacy

Rise Fig is intended for a **general audience age 13 and over**. It is **not** directed at children under 13 (or the applicable digital-consent age in your jurisdiction). It is **not** designed for Google Play’s Families program, and we do **not** knowingly collect personal information from children.

Advertising is configured with **not under the age of consent**. We do not serve ads as a children’s app.

If you are a parent or guardian and believe your child has provided us with personal information, please contact us at myevidentsuccess@gmail.com and we will take steps to delete such information.

---

## 10. International users

If you access the App from the European Economic Area (EEA), United Kingdom, or other regions with data protection laws, you have additional rights under GDPR/UK GDPR as described in Section 8. Advertising consent in those regions is collected through Google UMP as described in Section 3.5.

Google acts as a processor/sub-processor for Firebase and AdMob services. Google’s compliance documentation is available at [Google Cloud & GDPR](https://cloud.google.com/privacy/gdpr).

---

## 11. Changes to this Privacy Policy

We may update this Privacy Policy from time to time. We will post the updated version on this page and change the **“Last updated”** date at the top.

For material changes, we may also notify you through the App or Google Play listing. Continued use of the App after changes constitutes acceptance of the updated Privacy Policy.

---

## 12. Contact us

If you have questions about this Privacy Policy or our data practices, please contact:

**Oleksii Hnylytskyi**  
Email: myevidentsuccess@gmail.com

---

## 13. Summary (plain language)

| Question | Answer |
|----------|--------|
| Do I need an account? | No email account. Optional anonymous online ID for the leaderboard. |
| Is my name public? | Your chosen nickname appears on the public leaderboard. Other players can report or hide it in the App. |
| Are there ads? | Yes — optional rewarded videos via Google AdMob. In the EEA/UK a consent form appears at launch; Privacy settings reopen it when required. |
| Are there notifications? | Optional local reminders only, if you turn them on. Nothing is pushed from our servers. |
| Is analytics collected? | Yes, when you are online. In the EEA/UK, only after you accept the UMP form. Elsewhere, on the basis of legitimate interest. |
| Is data sold? | No. |
| Can I delete my data? | Yes. Settings → Delete account and data clears the device and deletes the signed-in anonymous account and its server records. Email myevidentsuccess@gmail.com if that account is no longer on the device. We respond within 30 days. |
| Who processes my data? | Primarily Google (Firebase, AdMob, UMP) under their policies. |

---

*This Privacy Policy applies to Rise Fig (`com.rise.mahjong`) published by Oleksii Hnylytskyi.*
