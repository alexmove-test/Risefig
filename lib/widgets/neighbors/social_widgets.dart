import 'dart:async';

import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../models/list_badges.dart';
import '../../models/neighbor_social.dart';
import '../../models/neighbor_request.dart';
import '../../models/social_connection.dart';
import '../../services/neighbor_request_repository.dart';
import '../../services/points_controller.dart';
import '../../services/points_store.dart';
import '../../services/social_repository.dart';
import 'neighbors_style.dart';
import 'neighbor_copy.dart';

class SocialPictureOption {
  const SocialPictureOption(this.picture, this.label);
  final String picture;
  final String label;
}

List<SocialPictureOption> _zip(List<String> pictures, List<String> labels) {
  assert(pictures.length == labels.length);
  return [
    for (var i = 0; i < pictures.length; i++)
      SocialPictureOption(pictures[i], labels[i]),
  ];
}

List<SocialPictureOption> socialAboutOptions(AppLocalizations l) =>
    _zip(SocialProfile.aboutPictures, [
      l.socialPicAboutFriendly,
      l.socialPicAboutCalm,
      l.socialPicAboutCheerful,
      l.socialPicAboutGentle,
      l.socialPicAboutNight,
      l.socialPicAboutCurious,
    ]);

List<SocialPictureOption> socialInterestOptions(AppLocalizations l) =>
    _zip(SocialProfile.interestPictures, [
      l.socialPicInterestGarden,
      l.socialPicInterestPets,
      l.socialPicInterestMahjong,
      l.socialPicInterestCourtyard,
      l.socialPicInterestSeeds,
      l.socialPicInterestStars,
    ]);

List<SocialPictureOption> socialGoalOptions(AppLocalizations l) =>
    _zip(SocialProfile.goalPictures, [
      l.socialPicGoalFlower,
      l.socialPicGoalHouse,
      l.socialPicGoalFriends,
      l.socialPicGoalLevels,
      l.socialPicGoalChat,
      l.socialPicGoalCross,
    ]);

ThemeData socialTheme(BuildContext context) => Theme.of(context).copyWith(
  colorScheme: ColorScheme.fromSeed(
    seedColor: NeighborsPalette.gold,
    brightness: Brightness.dark,
  ),
  scaffoldBackgroundColor: NeighborsPalette.wood,
);

/// Friends are a mutual server-confirmed relationship, separate from bookmarks.
class FriendsList extends StatelessWidget {
  const FriendsList({
    super.key,
    required this.me,
    required this.friends,
    required this.loading,
    required this.failed,
    required this.onOpen,
    required this.onBrowse,
    required this.onRetry,
  });
  final String? me;
  final List<Friendship> friends;
  final bool loading, failed;
  final ValueChanged<NeighborPerson> onOpen;
  final VoidCallback onBrowse, onRetry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final visible = friends.where((f) => f.accepted || f.pending).toList()
      ..sort((a, b) {
        final incomingA = a.pending && a.toId == me;
        final incomingB = b.pending && b.toId == me;
        if (incomingA != incomingB) return incomingA ? -1 : 1;
        return a.otherName(me ?? '').compareTo(b.otherName(me ?? ''));
      });
    return Theme(
      data: socialTheme(context),
      child: ListView(
        key: const ValueKey('friends-list'),
        padding: const EdgeInsets.all(16),
        children: [
          if (loading) const LinearProgressIndicator(),
          if (failed) ...[
            Text(l.socialUnavailable),
            TextButton(onPressed: onRetry, child: Text(l.retry)),
          ],
          if (!loading && !failed && visible.isEmpty) ...[
            Text(l.socialFriendsEmpty),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onBrowse,
              child: Text(l.neighborsBrowsePlayers),
            ),
          ],
          for (final friend in visible)
            Card(
              child: ListTile(
                key: ValueKey('friend-${friend.id}'),
                leading: Icon(
                  friend.accepted
                      ? Icons.people_alt_outlined
                      : Icons.mail_outline,
                ),
                title: Text(friend.otherName(me!)),
                subtitle: Text(
                  friend.accepted
                      ? l.socialFriend
                      : friend.toId == me
                      ? l.socialIncoming
                      : l.socialWaiting,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => onOpen(friend.person(me!)),
              ),
            ),
        ],
      ),
    );
  }
}

class SocialPersonSection extends StatefulWidget {
  const SocialPersonSection({
    super.key,
    required this.repository,
    required this.me,
    required this.person,
    required this.friendship,
    this.onBlocked,
  });
  final SocialRepository repository;
  final NeighborIdentity me;
  final NeighborPerson person;
  final Friendship? friendship;
  final VoidCallback? onBlocked;
  @override
  State<SocialPersonSection> createState() => _SocialPersonSectionState();
}

class _SocialPersonSectionState extends State<SocialPersonSection> {
  late Stream<SocialProfile> _profile;
  late Stream<List<NeighborRequest>> _history;
  bool _busy = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _listen();
  }

  void _listen() {
    _profile = widget.repository.watchProfile(widget.person.id);
    _history = widget.repository.watchHistory(widget.me.id, widget.person.id);
  }

  @override
  void didUpdateWidget(SocialPersonSection old) {
    super.didUpdateWidget(old);
    if (old.person.id != widget.person.id ||
        old.repository != widget.repository) {
      _listen();
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _failed = false;
    });
    try {
      await action();
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final friendship = widget.friendship;
    return Theme(
      data: socialTheme(context),
      child: StreamBuilder<SocialProfile>(
        stream: _profile,
        builder: (context, snapshot) {
          final profile = snapshot.data;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              if (profile != null)
                SocialProfileView(profile: profile)
              else if (!snapshot.hasError)
                const LinearProgressIndicator(),
              const SizedBox(height: 12),
              if (snapshot.hasError || _failed) ...[
                Text(l.socialUnavailable),
                TextButton(
                  onPressed: () => setState(_listen),
                  child: Text(l.retry),
                ),
              ],
              if (_busy) const LinearProgressIndicator(),
              if (friendship?.accepted == true) ...[
                Text(l.socialFriend),
                FilledButton.icon(
                  key: const ValueKey('friend-chat'),
                  onPressed: () async {
                    final blocked = await Navigator.of(context).push<bool>(
                      MaterialPageRoute<bool>(
                        builder: (_) => SocialChatScreen(
                          repository: widget.repository,
                          me: widget.me.id,
                          friendship: friendship!,
                        ),
                      ),
                    );
                    if (blocked == true && mounted) widget.onBlocked?.call();
                  },
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: Text(l.socialChat),
                ),
                TextButton(
                  onPressed: _busy
                      ? null
                      : () => _run(
                          () => widget.repository.respond(
                            widget.me.id,
                            friendship!,
                            FriendshipStatus.removed,
                          ),
                        ),
                  child: Text(l.socialRemoveFriend),
                ),
              ] else if (friendship?.pending == true) ...[
                Text(
                  friendship!.toId == widget.me.id
                      ? l.socialIncoming
                      : l.socialWaiting,
                ),
                if (friendship.toId == widget.me.id) ...[
                  Text(l.socialFriendConsent),
                  FilledButton(
                    key: const ValueKey('friend-accept'),
                    onPressed: _busy
                        ? null
                        : () => _run(
                            () => widget.repository.respond(
                              widget.me.id,
                              friendship,
                              FriendshipStatus.accepted,
                            ),
                          ),
                    child: Text(l.socialAccept),
                  ),
                  TextButton(
                    onPressed: _busy
                        ? null
                        : () => _run(
                            () => widget.repository.respond(
                              widget.me.id,
                              friendship,
                              FriendshipStatus.declined,
                            ),
                          ),
                    child: Text(l.neighborsCrossDecline),
                  ),
                ] else
                  TextButton(
                    onPressed: _busy
                        ? null
                        : () => _run(
                            () => widget.repository.respond(
                              widget.me.id,
                              friendship,
                              FriendshipStatus.cancelled,
                            ),
                          ),
                    child: Text(l.neighborsCancelRequest),
                  ),
              ] else if (profile?.openToFriends == true) ...[
                Text(l.socialFriendConsent),
                FilledButton.icon(
                  key: const ValueKey('friend-invite'),
                  onPressed: _busy
                      ? null
                      : () => _run(
                          () => widget.repository.invite(
                            widget.me,
                            widget.person,
                          ),
                        ),
                  icon: const Icon(Icons.person_add_alt_1),
                  label: Text(l.socialInvite),
                ),
              ],
              const SizedBox(height: 12),
              StreamBuilder<List<NeighborRequest>>(
                stream: _history,
                builder: (context, history) {
                  if (history.hasError) return Text(l.socialUnavailable);
                  if (!history.hasData || history.data!.isEmpty)
                    return const SizedBox.shrink();
                  return ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: Text(l.socialHistory),
                    children: [
                      for (final request in history.data!)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            neighborRequestHeadline(l, request, widget.me.id),
                          ),
                          subtitle: Text(
                            '${MaterialLocalizations.of(context).formatShortDate(request.createdAt.toLocal())} · '
                            '${neighborPhraseLabel(l, request.replyPhrase ?? request.phrase)}',
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class SocialProfileEditor extends StatefulWidget {
  const SocialProfileEditor({
    super.key,
    required this.repository,
    required this.me,
  });
  final SocialRepository repository;
  final String me;
  @override
  State<SocialProfileEditor> createState() => _SocialProfileEditorState();
}

class _SocialProfileEditorState extends State<SocialProfileEditor> {
  int _about = 0, _interests = 0, _goal = 0, _avatar = 0;
  bool _open = true, _loading = true, _failed = false, _saving = false;
  bool _loaded = false;

  /// Без известного срока покупка могла бы начать отсчёт заново и укоротить его.
  bool _badgesKnown = false, _buying = false;
  DateTime? _badgesUntil;

  SocialProfile get _profile => SocialProfile(
    about: _about,
    interests: _interests,
    goal: _goal,
    avatar: _avatar,
    openToFriends: _open,
  );

  bool get _badgesActive =>
      _badgesUntil != null && _badgesUntil!.isAfter(DateTime.now());
  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final p = await widget.repository
          .watchProfile(widget.me)
          .first
          .timeout(const Duration(seconds: 15));
      if (!mounted) return;
      _about = p.about;
      _interests = p.interests;
      _goal = p.goal;
      _avatar = p.avatar;
      _open = p.openToFriends;
      _loaded = true;
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
    if (_loaded) {
      try {
        _badgesUntil = await widget.repository
            .loadBadgesUntil(widget.me)
            .timeout(const Duration(seconds: 15));
        _badgesKnown = true;
      } catch (_) {
        _badgesKnown = false;
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _failed = false;
    });
    try {
      final until = _badgesUntil;
      if (_badgesActive) {
        await widget.repository.showBadges(widget.me, _profile, until!);
      } else {
        await widget.repository.saveProfile(widget.me, _profile);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        setState(() {
          _failed = true;
          _saving = false;
        });
      }
    }
  }

  /// Списание до записи на сервер: без подтверждения поинты возвращаются.
  Future<void> _buy(ListBadgeOffer offer) async {
    final points = PointsScope.read(context);
    if (points == null || _buying || _saving || !_badgesKnown) return;
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final now = DateTime.now().toUtc();
    final until = ListBadges.extend(_badgesUntil, offer, now);
    if (until == null) {
      messenger.showSnackBar(SnackBar(content: Text(l.socialBadgesTooLong)));
      return;
    }
    setState(() => _buying = true);
    var listed = false;
    try {
      listed = await widget.repository.ensureListed(widget.me);
    } catch (_) {
      listed = false;
    }
    if (!listed) {
      if (!mounted) return;
      setState(() => _buying = false);
      messenger.showSnackBar(SnackBar(content: Text(l.socialBadgesNotListed)));
      return;
    }
    final paid = await points.spend(offer.price);
    String? message;
    if (paid.status == PointsSpendStatus.insufficient) {
      message = l.pointsShortfall(paid.shortfall);
    } else if (!paid.spent) {
      message = l.socialUnavailable;
    } else {
      try {
        await widget.repository.showBadges(widget.me, _profile, until);
        _badgesUntil = until;
      } catch (_) {
        await points.refund(offer.price);
        message = l.socialBadgesFailed;
      }
    }
    if (!mounted) return;
    setState(() => _buying = false);
    message ??= l.socialBadgesActive(_badgeTime(context, until));
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _badgeShop(AppLocalizations l, PointsController points) {
    final busy = _buying || _saving;
    final preview = ListBadges.of(_profile, DateTime.now());
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.socialBadgesTitle,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(l.socialBadgesExplain),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(preview.avatarPicture, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 8),
              ProfileBadgeStrip(pictures: preview.pictures),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _badgesActive
                ? l.socialBadgesActive(_badgeTime(context, _badgesUntil!))
                : l.socialBadgesOff,
            key: const ValueKey('profile-badges-status'),
          ),
          Text(
            l.pointsBalance(points.balance),
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final offer in ListBadges.offers)
                OutlinedButton(
                  key: ValueKey('profile-badges-${offer.days}'),
                  onPressed: busy ? null : () => _buy(offer),
                  child: Text(l.socialBadgesOfferFor(offer.days, offer.price)),
                ),
            ],
          ),
          if (_buying)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: LinearProgressIndicator(),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final points = PointsScope.maybeOf(context);
    return Theme(
      data: socialTheme(context),
      child: PopScope(
        canPop: !_saving && !_buying,
        child: Scaffold(
          appBar: AppBar(title: Text(l.socialMyProfile)),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(l.socialProfilePublic),
                if (_loading || _saving) const LinearProgressIndicator(),
                if (_failed) ...[
                  Text(l.socialUnavailable),
                  TextButton(onPressed: _load, child: Text(l.retry)),
                ],
                if (!_loading && _loaded) ...[
                  Wrap(
                    spacing: 8,
                    children: [
                      for (var i = 0; i < SocialProfile.avatars.length; i++)
                        ChoiceChip(
                          label: Text(
                            SocialProfile.avatars[i],
                            style: const TextStyle(fontSize: 28),
                          ),
                          selected: i == _avatar,
                          onSelected: _saving
                              ? null
                              : (_) => setState(() => _avatar = i),
                        ),
                    ],
                  ),
                  _PicturePicker(
                    field: 'about',
                    heading: l.socialAbout,
                    value: _about,
                    options: socialAboutOptions(l),
                    enabled: !_saving,
                    onChanged: (value) => setState(() => _about = value),
                  ),
                  _PicturePicker(
                    field: 'interests',
                    heading: l.socialInterests,
                    value: _interests,
                    options: socialInterestOptions(l),
                    enabled: !_saving,
                    onChanged: (value) => setState(() => _interests = value),
                  ),
                  _PicturePicker(
                    field: 'goal',
                    heading: l.socialGoal,
                    value: _goal,
                    options: socialGoalOptions(l),
                    enabled: !_saving,
                    onChanged: (value) => setState(() => _goal = value),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l.socialOpenInvites),
                    value: _open,
                    onChanged: _saving
                        ? null
                        : (v) => setState(() => _open = v),
                  ),
                  FilledButton(
                    onPressed: _saving || _buying ? null : _save,
                    child: Text(l.socialSave),
                  ),
                  if (points != null && _badgesKnown) _badgeShop(l, points),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _badgeTime(BuildContext context, DateTime at) {
  final local = at.toLocal();
  return '${MaterialLocalizations.of(context).formatShortDate(local)} '
      '${TimeOfDay.fromDateTime(local).format(context)}';
}

/// Значки профиля в одну строку, как их видят соседи в списке.
class ProfileBadgeStrip extends StatelessWidget {
  const ProfileBadgeStrip({super.key, required this.pictures, this.size = 16});

  final List<String> pictures;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (pictures.isEmpty) return const SizedBox.shrink();
    return ExcludeSemantics(
      child: Text(
        pictures.join(' '),
        maxLines: 1,
        style: TextStyle(fontSize: size, height: 1.1),
      ),
    );
  }
}

class _ChosenPicture extends StatelessWidget {
  const _ChosenPicture({
    required this.heading,
    required this.value,
    required this.options,
  });

  final String heading;
  final int value;
  final List<SocialPictureOption> options;

  @override
  Widget build(BuildContext context) {
    final chosen = value >= 1 && value <= options.length;
    final option = chosen ? options[value - 1] : null;
    final muted = NeighborsPalette.ivory.withValues(alpha: 0.55);
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              option?.picture ?? '—',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                color: option == null ? muted : null,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  heading,
                  style: const TextStyle(
                    color: NeighborsPalette.goldSoft,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  option?.label ?? AppLocalizations.of(context).socialNotChosen,
                  style: TextStyle(
                    color: option == null ? muted : NeighborsPalette.ivory,
                    fontWeight: option == null
                        ? FontWeight.w400
                        : FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Что игрок выбрал в профиле, только для просмотра. Пустые строки тоже видны.
class SocialProfileView extends StatelessWidget {
  const SocialProfileView({super.key, required this.profile});

  final SocialProfile profile;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return DecoratedBox(
      key: const ValueKey('social-profile-view'),
      decoration: BoxDecoration(
        color: NeighborsPalette.woodTop,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: NeighborsPalette.gold.withValues(alpha: 0.45),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  SocialProfile.avatars[profile.avatar],
                  style: const TextStyle(fontSize: 36),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.socialProfileHeading,
                        style: const TextStyle(
                          color: NeighborsPalette.goldSoft,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        profile.openToFriends
                            ? l.socialInvitesOpen
                            : l.socialInvitesClosed,
                        style: TextStyle(
                          color: NeighborsPalette.ivory.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            _ChosenPicture(
              heading: l.socialAbout,
              value: profile.about,
              options: socialAboutOptions(l),
            ),
            _ChosenPicture(
              heading: l.socialInterests,
              value: profile.interests,
              options: socialInterestOptions(l),
            ),
            _ChosenPicture(
              heading: l.socialGoal,
              value: profile.goal,
              options: socialGoalOptions(l),
            ),
          ],
        ),
      ),
    );
  }
}

class _PicturePicker extends StatelessWidget {
  const _PicturePicker({
    required this.field,
    required this.heading,
    required this.value,
    required this.options,
    required this.enabled,
    required this.onChanged,
  });

  final String field;
  final String heading;
  final int value;
  final List<SocialPictureOption> options;
  final bool enabled;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(heading, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < options.length; i++)
                Tooltip(
                  message: options[i].label,
                  child: ChoiceChip(
                    key: ValueKey('profile-$field-${i + 1}'),
                    label: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          options[i].picture,
                          style: const TextStyle(fontSize: 28),
                        ),
                        Text(
                          options[i].label,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                    selected: value == i + 1,
                    onSelected: enabled
                        ? (chosen) => onChanged(chosen ? i + 1 : 0)
                        : null,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class SocialChatScreen extends StatefulWidget {
  const SocialChatScreen({
    super.key,
    required this.repository,
    required this.me,
    required this.friendship,
  });
  final SocialRepository repository;
  final String me;
  final Friendship friendship;
  @override
  State<SocialChatScreen> createState() => _SocialChatScreenState();
}

class _SocialChatScreenState extends State<SocialChatScreen> {
  final _text = TextEditingController();
  late Stream<List<SocialMessage>> _messages;
  int _limit = 50;
  bool _sending = false, _failed = false;
  String? _pendingId, _pendingText;
  @override
  void initState() {
    super.initState();
    _listen();
  }

  void _listen() {
    _messages = widget.repository.watchMessages(
      widget.friendship.id,
      limit: _limit,
    );
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _text.text.trim();
    if (text.isEmpty || text.length > 1000 || _sending) return;
    if (_pendingText != text) {
      _pendingId = widget.repository.newMessageId(widget.friendship.id);
      _pendingText = text;
    }
    setState(() {
      _sending = true;
      _failed = false;
    });
    try {
      await widget.repository.sendMessage(
        widget.me,
        widget.friendship.id,
        _pendingId!,
        text,
      );
      if (!mounted) return;
      _text.clear();
      _pendingId = null;
      _pendingText = null;
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
    if (mounted) setState(() => _sending = false);
  }

  Future<void> _report(SocialMessage message) async {
    final l = AppLocalizations.of(context);
    try {
      await widget.repository.reportMessage(
        widget.me,
        widget.friendship,
        message,
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.reportThanks)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.socialUnavailable)));
      }
    }
  }

  Future<void> _block() async {
    try {
      await widget.repository.block(
        widget.me,
        widget.friendship.otherId(widget.me),
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Theme(
      data: socialTheme(context),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.friendship.otherName(widget.me)),
          actions: [
            IconButton(
              tooltip: l.neighborsBlock,
              onPressed: _block,
              icon: const Icon(Icons.block),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder<List<SocialMessage>>(
                  stream: _messages,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(l.socialUnavailable),
                            TextButton(
                              onPressed: () => setState(_listen),
                              child: Text(l.retry),
                            ),
                          ],
                        ),
                      );
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final messages = snapshot.data!;
                    if (messages.isEmpty) {
                      return Center(child: Text(l.socialChatEmpty));
                    }
                    return ListView(
                      reverse: true,
                      padding: const EdgeInsets.all(16),
                      children: [
                        for (final message in messages)
                          Align(
                            alignment: message.senderId == widget.me
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SelectableText(message.text),
                                    if (message.sentAt != null)
                                      Text(
                                        '${MaterialLocalizations.of(context).formatShortDate(message.sentAt!.toLocal())} '
                                        '${TimeOfDay.fromDateTime(message.sentAt!.toLocal()).format(context)}',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.labelSmall,
                                      ),
                                    if (message.senderId != widget.me)
                                      TextButton.icon(
                                        onPressed: () => _report(message),
                                        icon: const Icon(
                                          Icons.flag_outlined,
                                          size: 16,
                                        ),
                                        label: Text(l.socialReportMessage),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        if (messages.length == _limit)
                          TextButton(
                            onPressed: () => setState(() {
                              _limit += 50;
                              _listen();
                            }),
                            child: Text(l.socialOlderMessages),
                          ),
                      ],
                    );
                  },
                ),
              ),
              if (_failed)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(l.socialSendFailed),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        key: const ValueKey('social-message-input'),
                        controller: _text,
                        enabled: !_sending,
                        maxLength: 1000,
                        minLines: 1,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: l.socialMessageHint,
                        ),
                      ),
                    ),
                    IconButton(
                      key: const ValueKey('social-message-send'),
                      tooltip: l.neighborsSend,
                      onPressed: _sending ? null : _send,
                      icon: _sending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
