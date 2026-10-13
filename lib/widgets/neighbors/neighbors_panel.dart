import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_links.dart';
import '../../l10n/l10n.dart';
import '../../models/list_badges.dart';
import '../../models/neighbor_request.dart';
import '../../models/neighbor_social.dart';
import '../../models/pet.dart';
import '../../models/pet_combat.dart';
import '../../models/plant_cross.dart';
import '../../models/seed_catalog.dart';
import '../../models/seed_batch.dart';
import '../../models/social_connection.dart';
import '../../models/plant_listing.dart';
import '../../screens/plant_showcase_screen.dart';
import '../../services/points_controller.dart';
import '../../services/analytics_service.dart';
import '../../services/neighbor_actions.dart';
import '../../services/neighbor_directory.dart';
import '../../services/neighbor_records.dart';
import '../../services/neighbor_request_repository.dart';
import '../../services/pet_store.dart';
import '../../services/ugc_block_store.dart';
import '../../services/ugc_report_repository.dart';
import '../../services/social_repository.dart';
import '../../models/raid_help.dart';
import '../../services/raid_help_repository.dart';
import '../../services/points_store.dart';
import 'neighbor_card.dart';
import 'neighbor_compose_sheet.dart';
import 'neighbor_copy.dart';
import 'neighbor_requests_section.dart';
import 'neighbors_style.dart';
import 'raid_widgets.dart';
import 'social_widgets.dart';

/// Шторка на краю двора. Индикатор считает только непросмотренные входящие события.
class NeighborsEntryButton extends StatefulWidget {
  const NeighborsEntryButton({
    super.key,
    required this.onPressed,
    required this.unseen,
  });

  final VoidCallback onPressed;
  final int unseen;

  @override
  State<NeighborsEntryButton> createState() => _NeighborsEntryButtonState();
}

class _NeighborsEntryButtonState extends State<NeighborsEntryButton>
    with SingleTickerProviderStateMixin {
  static const _swayDistance = 4.0;

  AnimationController? _sway;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncSway();
  }

  @override
  void didUpdateWidget(NeighborsEntryButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.unseen == widget.unseen) return;
    _syncSway();
  }

  @override
  void dispose() {
    _sway?.dispose();
    super.dispose();
  }

  void _syncSway() {
    final play = widget.unseen > 0 && !MediaQuery.disableAnimationsOf(context);
    final sway = _sway;
    if (!play) {
      if (sway == null) return;
      if (sway.isAnimating) sway.stop();
      if (sway.value != 0) sway.value = 0;
      return;
    }
    final motion = _sway ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    if (!motion.isAnimating) motion.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = l10n.neighborsTitle;
    final label = widget.unseen > 0
        ? '$title. ${l10n.neighborsUnseen(widget.unseen)}'
        : title;
    final sway = _sway;
    final curtain = _NorenTab(
      title: title,
      unseen: widget.unseen,
      onPressed: widget.onPressed,
    );
    return Semantics(
      button: true,
      label: label,
      child: Tooltip(
        message: title,
        excludeFromSemantics: true,
        child: sway == null
            ? curtain
            : AnimatedBuilder(
                animation: sway,
                builder: (context, child) {
                  final t = Curves.easeInOut.transform(sway.value);
                  return Transform.translate(
                    offset: Offset(-_swayDistance * t, 0),
                    child: child,
                  );
                },
                child: curtain,
              ),
      ),
    );
  }
}

class _NorenTab extends StatelessWidget {
  const _NorenTab({
    required this.title,
    required this.unseen,
    required this.onPressed,
  });

  final String title;
  final int unseen;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        key: const ValueKey('neighbors-entry'),
        onTap: onPressed,
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
        overlayColor: const WidgetStatePropertyAll(Color(0x22F8F1DE)),
        child: SizedBox(
          width: _NorenPainter.width,
          height: _NorenPainter.height,
          child: ExcludeSemantics(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const CustomPaint(
                  painter: _NorenPainter(),
                  child: SizedBox.expand(),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    _NorenPainter.fabricLeft + (unseen > 0 ? 6 : 2),
                    unseen > 0 ? 42 : 16,
                    3,
                    10,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: RotatedBox(
                      quarterTurns: 1,
                      child: Text(
                        title,
                        softWrap: false,
                        style: const TextStyle(
                          color: NeighborsPalette.ivory,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          letterSpacing: 1.4,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ),
                if (unseen > 0)
                  Positioned(
                    left: _NorenPainter.fabricLeft - 11,
                    top: 18,
                    child: _WaxSeal(count: unseen),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WaxSeal extends StatelessWidget {
  const _WaxSeal({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          center: Alignment(-0.35, -0.4),
          colors: [Color(0xFFF3D98A), NeighborsPalette.gold, Color(0xFF8C6818)],
        ),
        border: Border.all(color: const Color(0xFF6B4E12), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: SizedBox(
        width: 22,
        height: 22,
        child: Center(
          child: Text(
            count > 9 ? '9+' : '$count',
            style: const TextStyle(
              color: NeighborsPalette.wood,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _NorenPainter extends CustomPainter {
  const _NorenPainter();

  static const height = 132.0;
  static const fabricWidth = 40.0;
  static const fabricLeft = 12.0;
  static const width = fabricLeft + fabricWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final right = size.width;
    final top = 5.0;
    final bottom = size.height - 1;
    final cloth = _clothPath(right, top, bottom);

    canvas.drawPath(
      cloth.shift(const Offset(-3, 2)),
      Paint()
        ..color = const Color(0x59000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    final bounds = Rect.fromLTWH(fabricLeft, top, fabricWidth, bottom - top);
    canvas.drawPath(
      cloth,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF8C3A32), Color(0xFF4A1E18)],
        ).createShader(bounds),
    );

    canvas.save();
    canvas.clipPath(cloth);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(fabricLeft + 14, top + 8, 2.2, bottom - top - 16),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0x40000000),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(fabricLeft + 18, top + 10, 3.2, bottom - top - 20),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0x33F8E7C8),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(fabricLeft + 28, top + 16, 2.4, bottom - top - 30),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0x24F8E7C8),
    );
    canvas.restore();

    final hem = _hemPath(right, top, bottom);
    canvas.drawPath(
      hem,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round
        ..color = NeighborsPalette.gold.withValues(alpha: 0.9),
    );

    final rod = RRect.fromRectAndCorners(
      Rect.fromLTWH(fabricLeft - 2, 0, fabricWidth + 8, 5),
      topLeft: const Radius.circular(2.5),
      bottomLeft: const Radius.circular(2.5),
    );
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.drawRRect(
      rod,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF3D98A), Color(0xFFD4AF37), Color(0xFF8C6818)],
        ).createShader(rod.outerRect),
    );
    canvas.restore();
  }

  Path _clothPath(double right, double top, double bottom) {
    final path = Path()..moveTo(right, top);
    path.lineTo(right, bottom);
    _traceWave(path, top, bottom);
    path.close();
    return path;
  }

  Path _hemPath(double right, double top, double bottom) {
    final path = Path()..moveTo(right, bottom);
    _traceWave(path, top, bottom);
    return path;
  }

  void _traceWave(Path path, double top, double bottom) {
    const waves = 2.0;
    const amplitude = 2.2;
    const steps = 28;
    for (var i = 0; i <= steps; i++) {
      final t = i / steps;
      final y = bottom - (bottom - top) * t;
      final wave = math.sin(t * waves * 2 * math.pi) * amplitude;
      path.lineTo(fabricLeft + wave, y);
    }
  }

  @override
  bool shouldRepaint(covariant _NorenPainter oldDelegate) => false;
}

/// Полноэкранная панель. Состояние списка живёт здесь и переживает закрытие.
class NeighborsOverlay extends StatefulWidget {
  const NeighborsOverlay({
    super.key,
    required this.visible,
    required this.directory,
    required this.acquaintances,
    required this.notices,
    required this.history,
    required this.blocks,
    required this.gateway,
    required this.onClose,
    required this.onObscuring,
    this.events = const [],
    this.showPractice = false,
    this.onNoticesChanged,
    this.requests,
    this.onRequestsChanged,
    this.social,
    this.raidHelp,
    this.initialPerson,
    this.initialCross = false,
  });

  final bool visible;
  final NeighborDirectory directory;
  final AcquaintanceStore acquaintances;
  final NeighborNoticeStore notices;
  final NeighborHistoryStore history;
  final UgcBlockStore blocks;
  final NeighborActionGateway gateway;
  final VoidCallback onClose;
  final ValueChanged<bool> onObscuring;
  final List<NeighborEvent> events;
  final bool showPractice;
  final VoidCallback? onNoticesChanged;

  /// Сообщения и действия с игроками. null — раздел действий не показывается.
  final NeighborRequestRepository? requests;
  final SocialRepository? social;

  /// Зов о помощи против набега. null — зов недоступен.
  final RaidHelpRepository? raidHelp;
  final NeighborPerson? initialPerson;
  final bool initialCross;
  final void Function(String me, List<NeighborRequest> requests)?
  onRequestsChanged;

  @override
  NeighborsOverlayState createState() => NeighborsOverlayState();
}

class NeighborsOverlayState extends State<NeighborsOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion;
  late final CurvedAnimation _curve;
  late final Animation<Offset> _slide;
  final _search = TextEditingController();
  final _allScroll = ScrollController();
  final _savedScroll = ScrollController();
  final _focus = FocusNode();
  Timer? _debounce;

  var _tab = 0;
  var _appliedQuery = '';
  var _generation = 0;
  var _loading = true;
  var _loadingMore = false;
  var _moreFailed = false;
  var _failed = false;
  var _fromCache = false;
  var _hasMore = false;
  var _fillHops = 0;
  String? _nextToken;
  List<NeighborPerson> _people = [];
  String? _selectedId;
  var _forYouExpanded = false;
  final _overrides = <String, NeighborEvent>{};
  final _busyEvents = <String>{};
  final _busyPeople = <String>{};
  var _interactive = false;
  NeighborIdentity? _me;
  var _requestsOnline = false;
  List<NeighborRequest> _requests = const [];
  final _busyRequests = <String>{};
  List<PetKind> _ownedPets = const [];
  StreamSubscription<List<Friendship>>? _friendsSubscription;
  List<Friendship> _friends = [];
  bool _friendsLoading = false, _friendsFailed = false;
  NeighborPerson? _externalPerson;
  bool _initialCrossHandled = false;
  final _raidHelpStatus = <String, RaidHelpStatus>{};
  List<RaidHelpCall> _helpCalls = const [];
  Set<String> _helpAnswered = const {};
  final _busyHelp = <String>{};
  var _settlingRaids = false;

  @override
  void initState() {
    super.initState();
    _externalPerson = widget.initialPerson;
    _selectedId = widget.initialPerson?.id;
    _motion = AnimationController(vsync: this, value: 0);
    _curve = CurvedAnimation(parent: _motion, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(_curve);
    _motion.addStatusListener(_onMotionStatus);
    _motion.addListener(_onMotionTick);
    _search.addListener(_onSearchChanged);
    _allScroll.addListener(_onAllScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.visible) {
        _play(true);
        unawaited(AnalyticsService.log('neighbors_open'));
      }
      unawaited(_reload());
      unawaited(_loadRequests());
    });
  }

  @override
  void didUpdateWidget(NeighborsOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.visible == widget.visible) return;
    _play(widget.visible);
    if (widget.visible) {
      _focus.requestFocus();
      unawaited(AnalyticsService.log('neighbors_open'));
      unawaited(_loadRequests());
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _friendsSubscription?.cancel();
    _curve.dispose();
    _motion.dispose();
    _search.dispose();
    _allScroll.dispose();
    _savedScroll.dispose();
    _focus.dispose();
    super.dispose();
  }

  /// Системная «Назад»: сначала карточка, затем панель.
  void handleBack() {
    if (_selectedId != null) {
      setState(() => _selectedId = null);
      return;
    }
    widget.onClose();
  }

  void _play(bool open) {
    final reduced = MediaQuery.disableAnimationsOf(context);
    final duration = reduced
        ? Duration.zero
        : const Duration(milliseconds: 280);
    _motion.duration = duration;
    _motion.reverseDuration = duration;
    if (open) {
      _motion.forward();
    } else {
      _motion.reverse();
    }
  }

  void _onMotionTick() {
    final interactive = widget.visible || _motion.value > 0;
    if (interactive == _interactive || !mounted) return;
    setState(() => _interactive = interactive);
  }

  void _onMotionStatus(AnimationStatus status) {
    if (status != AnimationStatus.dismissed || widget.visible) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !widget.visible) widget.onObscuring(false);
    });
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      final next = _search.text;
      if (next == _appliedQuery) return;
      _appliedQuery = next;
      unawaited(_reload());
    });
  }

  void _onAllScroll() {
    if (!_hasMore || _loading || _loadingMore || !_allScroll.hasClients) return;
    final position = _allScroll.position;
    if (position.pixels < position.maxScrollExtent - 280) return;
    unawaited(_loadMore());
  }

  Future<NeighborPage> _fetch({String? token}) async {
    try {
      return await widget.directory.load(
        pageToken: token,
        query: _appliedQuery,
      );
    } catch (error) {
      debugPrint('Neighbor page failed: $error');
      return NeighborPage.emptyOffline;
    }
  }

  Future<NeighborPage> _pull({String? token}) async {
    var page = await _fetch(token: token);
    var hops = 0;
    while (page.people.isEmpty &&
        page.hasMore &&
        page.pageToken != null &&
        hops < 4) {
      hops += 1;
      page = await _fetch(token: page.pageToken);
    }
    return page;
  }

  Future<void> _reload() async {
    final generation = ++_generation;
    _fillHops = 0;
    if (mounted) {
      setState(() {
        _loading = _people.isEmpty;
        _moreFailed = false;
      });
    }
    final page = await _pull();
    if (!mounted || generation != _generation) return;
    setState(() {
      _people = [...page.people];
      _nextToken = page.pageToken;
      _hasMore = page.hasMore;
      _failed = page.failed;
      _fromCache = page.fromCache;
      _loading = false;
      _loadingMore = false;
    });
    _fillIfShort();
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) return;
    final generation = _generation;
    final token = _nextToken;
    setState(() {
      _loadingMore = true;
      _moreFailed = false;
    });
    final page = await _pull(token: token);
    if (!mounted || generation != _generation) return;
    setState(() {
      _loadingMore = false;
      if (page.failed && page.people.isEmpty) {
        _moreFailed = true;
        return;
      }
      final seen = {for (final person in _people) person.id};
      for (final person in page.people) {
        if (seen.add(person.id)) _people.add(person);
      }
      _nextToken = page.pageToken;
      _hasMore = page.hasMore;
    });
    _fillIfShort();
  }

  void _fillIfShort() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_hasMore || _loadingMore || _loading || _fillHops >= 8) {
        return;
      }
      if (!_allScroll.hasClients) return;
      if (_allScroll.position.maxScrollExtent > 48) return;
      _fillHops += 1;
      unawaited(_loadMore());
    });
  }

  List<NeighborEvent> get _visibleEvents => [
    for (final event in widget.events)
      if ((widget.showPractice || !event.practice) &&
          !widget.blocks.isBlocked(event.personId))
        _overrides[event.id] ?? event,
  ];

  List<NeighborPerson> get _shownPeople => [
    for (final person in _people)
      if ((widget.showPractice || !person.practice) &&
          !widget.blocks.isBlocked(person.id))
        person,
  ];

  List<NeighborPerson> get _savedPeople => [
    for (final person in widget.acquaintances.all)
      if ((widget.showPractice || !person.practice) &&
          !widget.blocks.isBlocked(person.id))
        person,
  ];

  List<NeighborRequest> get _visibleRequests {
    final me = _me?.id;
    if (me == null) return const [];
    return [
      for (final request in _requests)
        if (!widget.blocks.isBlocked(request.otherId(me))) request,
    ];
  }

  List<NeighborRequest> _requestsWith(String personId) {
    final me = _me?.id;
    if (me == null) return const [];
    return [
      for (final request in _visibleRequests)
        if (request.otherId(me) == personId) request,
    ];
  }

  void _openPerson(String id) {
    FocusManager.instance.primaryFocus?.unfocus();
    final me = _me?.id;
    final incoming = [
      for (final event in _visibleEvents)
        if (event.personId == id &&
            event.incoming &&
            !widget.notices.hasSeen(event.id))
          event.id,
      if (me != null)
        for (final request in _requestsWith(id))
          if (request.needsAttention(me) &&
              !widget.notices.hasSeen(request.noticeKey))
            request.noticeKey,
    ];
    setState(() => _selectedId = id);
    if (incoming.isEmpty) return;
    unawaited(
      widget.notices.markSeen(incoming).then((_) {
        if (mounted) widget.onNoticesChanged?.call();
      }),
    );
  }

  NeighborPerson? _selectedPerson() {
    final id = _selectedId;
    if (id == null) return null;
    if (widget.blocks.isBlocked(id)) return null;
    if (_externalPerson?.id == id) return _externalPerson;
    if (_me != null) {
      for (final friend in _friends) {
        if (friend.otherId(_me!.id) == id) return friend.person(_me!.id);
      }
    }
    for (final person in _shownPeople) {
      if (person.id == id) return person;
    }
    for (final person in _savedPeople) {
      if (person.id == id) return person;
    }
    for (final event in _visibleEvents) {
      if (event.personId != id) continue;
      return NeighborPerson(
        id: event.personId,
        name: event.personName,
        stars: 0,
        levelsUnlocked: 0,
        practice: event.practice,
        progressKnown: false,
      );
    }
    final me = _me?.id;
    if (me != null) {
      for (final request in _requestsWith(id)) {
        return NeighborPerson(
          id: id,
          name: request.otherName(me),
          stars: 0,
          levelsUnlocked: 0,
          progressKnown: false,
        );
      }
    }
    return null;
  }

  Future<void> _loadRequests() async {
    final repository = widget.requests;
    if (repository == null) return;
    final pets = await PetStore.open();
    _ownedPets = pets.owned;
    final me = _me ?? await repository.connect();
    if (!mounted) return;
    if (me == null) {
      setState(() => _requestsOnline = false);
      return;
    }
    _me = me;
    if (_friendsSubscription == null && widget.social != null) {
      unawaited(_loadFriends());
    }
    try {
      final list = await repository.fetch(me);
      if (!mounted) return;
      setState(() {
        _me = me;
        _requests = list;
        _requestsOnline = true;
      });
      await _remember(list);
      widget.onRequestsChanged?.call(me.id, list);
      unawaited(_afterRequests());
      if (widget.initialCross &&
          !_initialCrossHandled &&
          widget.initialPerson != null) {
        _initialCrossHandled = true;
        if (mounted) {
          unawaited(_send(widget.initialPerson!, NeighborRequestKind.cross));
        }
      }
    } catch (error) {
      debugPrint('Neighbor requests failed: $error');
      if (!mounted) return;
      setState(() {
        _me = me;
        _requestsOnline = false;
      });
    }
  }

  Future<void> _loadFriends() async {
    final social = widget.social;
    final me = _me;
    if (social == null || me == null || _friendsLoading) return;
    setState(() {
      _friendsLoading = true;
      _friendsFailed = false;
    });
    await _friendsSubscription?.cancel();
    _friendsSubscription = null;
    try {
      await social.syncBlocks(me.id, widget.blocks.blockedIds);
      if (!mounted) return;
      _friendsSubscription = social
          .watchFriends(me.id)
          .listen(
            (friends) {
              if (!mounted) return;
              setState(() {
                _friends = friends;
                _friendsLoading = false;
                _friendsFailed = false;
              });
            },
            onError: (Object error) {
              if (mounted) {
                setState(() {
                  _friendsLoading = false;
                  _friendsFailed = true;
                });
              }
            },
          );
    } catch (_) {
      if (mounted) {
        setState(() {
          _friendsLoading = false;
          _friendsFailed = true;
        });
      }
    }
  }

  Friendship? _friendshipWith(String id) {
    for (final friend in _friends) {
      if (_me != null && friend.otherId(_me!.id) == id) return friend;
    }
    return null;
  }

  void _openExternalPerson(NeighborPerson person) {
    _externalPerson = person;
    _openPerson(person.id);
  }

  Future<void> _fromShowcase(PlantListing listing) async {
    final person = NeighborPerson(
      id: listing.ownerId,
      name: listing.ownerName,
      stars: 0,
      levelsUnlocked: 0,
      progressKnown: false,
    );
    _openExternalPerson(person);
    if (!_requestsOnline) await _loadRequests();
    if (!mounted) return;
    await _send(person, NeighborRequestKind.cross);
  }

  void _upsert(NeighborRequest request) {
    final me = _me;
    if (me == null || !mounted) return;
    setState(() {
      _requests = [
        request,
        for (final item in _requests)
          if (item.id != request.id) item,
      ];
    });
    if (request.otherId(me.id) == _selectedId) {
      unawaited(
        widget.notices.markSeen([request.noticeKey]).then((_) {
          if (mounted) widget.onNoticesChanged?.call();
        }),
      );
    }
    unawaited(_remember([request]));
    widget.onRequestsChanged?.call(me.id, _requests);
  }

  /// Принятые защита, набег и скрещивание попадают в историю игрока.
  Future<void> _remember(Iterable<NeighborRequest> requests) async {
    final me = _me?.id;
    if (me == null) return;
    for (final request in requests) {
      if (!request.accepted) continue;
      final code = switch (request.kind) {
        NeighborRequestKind.defense => NeighborMemoryCode.petDefended,
        NeighborRequestKind.cross => NeighborMemoryCode.crossed,
        NeighborRequestKind.raid => NeighborMemoryCode.raidReport,
        NeighborRequestKind.message => null,
      };
      if (code == null) continue;
      await widget.history.add(
        NeighborMemory(
          id: 'req-${request.id}-${request.createdAt.millisecondsSinceEpoch}',
          personId: request.otherId(me),
          personName: request.otherName(me),
          code: code,
          atMillis:
              (request.respondedAt ?? request.createdAt).millisecondsSinceEpoch,
        ),
      );
    }
  }

  int? _petPower(PointsController? points, PetRole role) {
    if (points == null) return null;
    return assignedPetPower(points.roster, _ownedPets, role);
  }

  Map<SeedSpecies, int> _crossPlants(PointsController? points) {
    if (points == null) return const {};
    final reserved = points.showcaseReservations;
    final counts = <SeedSpecies, int>{};
    for (final plant in points.garden.warehouse) {
      if (reserved.containsKey(plant.id)) continue;
      counts.update(plant.species, (count) => count + 1, ifAbsent: () => 1);
    }
    return {
      for (final species in SeedSpecies.values) species: ?counts[species],
    };
  }

  Map<NeighborRequestKind, String> _actionBlocks(
    AppLocalizations l10n,
    PointsController? points,
  ) {
    return {
      if (_petPower(points, PetRole.defender) == null)
        NeighborRequestKind.defense: l10n.neighborsNeedGuard,
      if (_crossPlants(points).isEmpty)
        NeighborRequestKind.cross: l10n.neighborsNeedPlant,
      if (_petPower(points, PetRole.attacker) == null)
        NeighborRequestKind.raid: l10n.neighborsNeedRaider,
    };
  }

  void _snack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _send(NeighborPerson person, NeighborRequestKind kind) async {
    final repository = widget.requests;
    final me = _me;
    if (person.practice) return;
    if (widget.blocks.isBlocked(person.id)) {
      _snack(AppLocalizations.of(context).neighborsBlocked(person.name));
      return;
    }
    if (repository == null || me == null || !_requestsOnline) {
      _snack(AppLocalizations.of(context).socialUnavailable);
      return;
    }
    final key = neighborSendKey(person.id, kind);
    if (_busyRequests.contains(key)) return;
    final l10n = AppLocalizations.of(context);
    final points = PointsScope.maybeOf(context);
    int? power;
    Map<SeedSpecies, int>? plants;
    String? explain;
    switch (kind) {
      case NeighborRequestKind.message:
        break;
      case NeighborRequestKind.defense:
        power = _petPower(points, PetRole.defender);
        if (power == null) return;
        explain = l10n.neighborsDefendExplain(person.name, power);
      case NeighborRequestKind.raid:
        power = _petPower(points, PetRole.attacker);
        if (power == null) return;
        explain = l10n.neighborsRaidExplain(person.name, power);
      case NeighborRequestKind.cross:
        plants = _crossPlants(points);
        if (plants.isEmpty) {
          _snack(l10n.neighborsNeedPlant);
          return;
        }
        explain = l10n.neighborsCrossExplain;
    }
    final choice = await showNeighborComposeSheet(
      context,
      title: neighborActionLabel(l10n, kind),
      confirmLabel: l10n.neighborsSend,
      phrases: NeighborRequestRules.phrasesFor(kind),
      explain: explain,
      plants: plants,
      danger: kind == NeighborRequestKind.raid,
    );
    if (choice == null || !mounted) return;
    setState(() => _busyRequests.add(key));
    String message;
    try {
      final sent = await repository.send(
        me,
        to: person,
        kind: kind,
        phrase: choice.phrase,
        power: power,
        species: choice.species,
      );
      _upsert(sent);
      message = l10n.neighborsSent(person.name);
      unawaited(AnalyticsService.log('neighbor_send_${kind.name}'));
    } on NeighborRequestRejected catch (error) {
      message = error.problem == NeighborRequestProblem.alreadyOpen
          ? l10n.neighborsAlreadyOpen
          : l10n.neighborsRequestClosed;
    } catch (error) {
      debugPrint('Neighbor request failed: $error');
      message = l10n.neighborsSendFailed;
    }
    if (!mounted) return;
    setState(() => _busyRequests.remove(key));
    _snack(message);
  }

  Future<void> _respond(NeighborRequest request, bool accept) async {
    final repository = widget.requests;
    final me = _me;
    if (repository == null || me == null) return;
    if (_busyRequests.contains(request.id)) return;
    if (request.kind == NeighborRequestKind.raid) {
      if (accept) await _defendRaid(request);
      return;
    }
    final l10n = AppLocalizations.of(context);
    final points = PointsScope.maybeOf(context);
    NeighborComposeResult? choice;
    if (accept) {
      Map<SeedSpecies, int>? plants;
      final explain = neighborRequestHeadline(l10n, request, me.id);
      switch (request.kind) {
        case NeighborRequestKind.message:
        case NeighborRequestKind.defense:
        case NeighborRequestKind.raid:
          break;
        case NeighborRequestKind.cross:
          plants = _crossPlants(points);
          if (plants.isEmpty) {
            _snack(l10n.neighborsNeedPlant);
            return;
          }
      }
      final label = switch (request.kind) {
        NeighborRequestKind.message => l10n.neighborsReply,
        NeighborRequestKind.defense => l10n.neighborsAcceptDefense,
        NeighborRequestKind.cross => l10n.neighborsChooseCrossPlant,
        NeighborRequestKind.raid => l10n.neighborsRepel,
      };
      choice = await showNeighborComposeSheet(
        context,
        title: label,
        confirmLabel: label,
        phrases: NeighborRequestRules.replies,
        explain: request.kind == NeighborRequestKind.cross
            ? '$explain ${l10n.neighborsCrossExplain}'
            : explain,
        plants: plants,
      );
      if (choice == null || !mounted) return;
    }
    setState(() => _busyRequests.add(request.id));
    String? message;
    NeighborRequest? answered;
    try {
      answered = await repository.respond(
        me,
        request,
        accept: accept,
        phrase: choice?.phrase,
        species: choice?.species,
      );
      _upsert(answered);
      if (accept) message = l10n.neighborsReplied;
    } on NeighborRequestRejected {
      message = l10n.neighborsRequestClosed;
    } catch (error) {
      debugPrint('Neighbor reply failed: $error');
      message = l10n.neighborsSendFailed;
    }
    if (!mounted) return;
    setState(() => _busyRequests.remove(request.id));
    if (answered != null && answered.canClaim(me.id)) {
      await _claim(answered);
      return;
    }
    if (message != null) _snack(message);
  }

  Future<void> _cancelRequest(NeighborRequest request) async {
    final repository = widget.requests;
    final me = _me;
    if (repository == null || me == null) return;
    if (!_busyRequests.add(request.id)) return;
    setState(() {});
    final l10n = AppLocalizations.of(context);
    String? message;
    try {
      _upsert(await repository.cancel(me, request));
    } on NeighborRequestRejected {
      message = l10n.neighborsRequestClosed;
    } catch (error) {
      debugPrint('Neighbor cancel failed: $error');
      message = l10n.neighborsSendFailed;
    }
    if (!mounted) return;
    setState(() => _busyRequests.remove(request.id));
    if (message != null) _snack(message);
  }

  Future<void> _afterRequests() async {
    await _settleRaids();
    await _loadHelp();
  }

  /// Просроченные входящие набеги встречает назначенный защитник; уже
  /// решённые, но не списанные потери уходят со склада. Повтор безопасен.
  Future<void> _settleRaids() async {
    final repository = widget.requests;
    final me = _me;
    final points = PointsScope.read(context);
    if (repository == null || me == null || points == null || _settlingRaids) {
      return;
    }
    _settlingRaids = true;
    try {
      final now = DateTime.now();
      for (final request in [..._requests]) {
        if (!mounted) return;
        if (_busyRequests.contains(request.id)) continue;
        try {
          if (request.raidOverdue(me.id, now)) {
            await _resolveRaid(
              request,
              autoRaidDefense(points.roster, _ownedPets),
            );
          } else if (request.owesRaidLoss(me.id)) {
            await _applyRaidLoss(request);
          }
        } catch (error) {
          debugPrint('Raid settle failed: $error');
        }
      }
    } finally {
      _settlingRaids = false;
    }
  }

  /// Ответ на сервер, затем списание со склада. Потерю выбирает жребий
  /// по ключу набега, поэтому повтор после сбоя списывает то же самое.
  Future<NeighborRequest> _resolveRaid(
    NeighborRequest request,
    RaidDefenseOption defense, {
    NeighborPhrase? phrase,
    String? destroyId,
  }) async {
    final repository = widget.requests!;
    final me = _me!;
    final points = PointsScope.read(context);
    final loss = defense.holds(request.power ?? 0) || points == null
        ? const RaidLoss()
        : planRaidLoss(
            opId: request.raidOpId,
            plants: points.raidablePlants,
            destroyId: destroyId,
          );
    final answered = await repository.defendRaid(
      me,
      request,
      defense: defense,
      loss: loss,
      phrase: phrase,
    );
    _upsert(answered);
    if (answered.owesRaidLoss(me.id)) {
      await _applyRaidLoss(answered, loss: loss);
    }
    return answered;
  }

  Future<void> _applyRaidLoss(NeighborRequest request, {RaidLoss? loss}) async {
    final repository = widget.requests;
    final me = _me;
    final points = PointsScope.read(context);
    if (repository == null || me == null || points == null) return;
    final result = await points.settleRaidLoss(
      opId: request.raidOpId,
      destroyId: loss?.destroyed?.id,
      destroySpecies: request.lostSpecies,
      stealId: loss?.stolen?.id,
      stealSpecies: request.stolenSpecies,
    );
    if (!result.settled) return;
    try {
      _upsert(await repository.markClaimed(me, request));
    } catch (error) {
      debugPrint('Raid loss mark failed: $error');
    }
  }

  Future<void> _defendRaid(NeighborRequest request) async {
    final me = _me;
    final points = PointsScope.read(context);
    if (me == null || points == null) return;
    final l10n = AppLocalizations.of(context);
    await _refreshHelp(request);
    if (!mounted) return;
    final options = raidDefenseOptions(
      roster: points.roster,
      owned: _ownedPets,
      requests: _requests,
      me: me.id,
      now: DateTime.now(),
      help: _raidHelpStatus[request.id]?.offers ?? const [],
    );
    final choice = await showRaidDefenseSheet(
      context,
      raid: request,
      headline: neighborRequestHeadline(l10n, request, me.id),
      options: options,
      plants: points.raidablePlants,
    );
    if (choice == null || !mounted) return;
    if (!_busyRequests.add(request.id)) return;
    setState(() {});
    String message;
    try {
      await _resolveRaid(
        request,
        choice.defense,
        phrase: choice.phrase,
        destroyId: choice.destroyId,
      );
      message = l10n.neighborsReplied;
    } on NeighborRequestRejected {
      message = l10n.neighborsRequestClosed;
    } catch (error) {
      debugPrint('Raid defense failed: $error');
      message = l10n.neighborsSendFailed;
    }
    if (!mounted) return;
    setState(() => _busyRequests.remove(request.id));
    _snack(message);
  }

  /// Сначала растение на склад налётчика, затем отметка на сервере.
  Future<void> _takeLoot(NeighborRequest request) async {
    final repository = widget.requests;
    final me = _me;
    final points = PointsScope.read(context);
    final species = request.stolenSpecies;
    if (repository == null || me == null || points == null || species == null) {
      return;
    }
    if (!_busyRequests.add(request.id)) return;
    setState(() {});
    final l10n = AppLocalizations.of(context);
    final result = await points.takeRaidLoot(
      opId: request.raidOpId,
      species: species,
      trait: request.stolenTrait,
    );
    String message;
    if (result.settled) {
      message = l10n.neighborsRaidLootTaken(l10n.seedName(species));
      try {
        _upsert(await repository.markClaimed(me, request));
      } catch (error) {
        debugPrint('Raid loot mark failed: $error');
      }
    } else {
      message = l10n.neighborsSendFailed;
    }
    if (!mounted) return;
    setState(() => _busyRequests.remove(request.id));
    _snack(message);
  }

  Future<void> _refreshHelp(NeighborRequest raid) async {
    final help = widget.raidHelp;
    if (help == null) return;
    try {
      final status = await help.status(raid);
      if (!mounted) return;
      setState(() => _raidHelpStatus[raid.id] = status);
    } catch (error) {
      debugPrint('Raid help status failed: $error');
    }
  }

  /// Свои зовы о помощи и чужие, на которые можно откликнуться.
  Future<void> _loadHelp() async {
    final help = widget.raidHelp;
    final me = _me;
    if (help == null || me == null) return;
    for (final request in _requests) {
      if (request.kind == NeighborRequestKind.raid &&
          request.toId == me.id &&
          request.pending) {
        await _refreshHelp(request);
      }
    }
    try {
      final calls = [
        for (final call in await help.open(me))
          if (!widget.blocks.isBlocked(call.ownerId)) call,
      ];
      final answered = await help.answered(me, calls);
      if (!mounted) return;
      setState(() {
        _helpCalls = calls;
        _helpAnswered = answered;
      });
    } catch (error) {
      debugPrint('Raid help calls failed: $error');
    }
  }

  /// Друзья — бесплатно, все игроки — за поинты. Без подтверждения поинты возвращаются.
  Future<void> _askHelp(NeighborRequest raid, RaidHelpAudience audience) async {
    final help = widget.raidHelp;
    final me = _me;
    final points = PointsScope.read(context);
    if (help == null || me == null || points == null) return;
    if (!_busyRequests.add(raid.id)) return;
    setState(() {});
    final l10n = AppLocalizations.of(context);
    final friends = [
      for (final friend in _friends)
        if (friend.accepted && !widget.blocks.isBlocked(friend.otherId(me.id)))
          friend.otherId(me.id),
    ];
    const price = NeighborRequestRules.helpEveryonePrice;
    String? message;
    var paid = false;
    if (audience == RaidHelpAudience.friends && friends.isEmpty) {
      message = l10n.neighborsHelpNoFriends;
    } else if (audience == RaidHelpAudience.everyone) {
      final spent = await points.spend(price);
      if (spent.status == PointsSpendStatus.insufficient) {
        message = l10n.pointsShortfall(spent.shortfall);
      } else if (!spent.spent) {
        message = l10n.socialUnavailable;
      } else {
        paid = true;
      }
    }
    if (message == null) {
      try {
        await help.call(me, raid, audience: audience, friendIds: friends);
        message = audience == RaidHelpAudience.everyone
            ? l10n.neighborsHelpAskedEveryone
            : l10n.neighborsHelpAskedFriends;
        unawaited(AnalyticsService.log('raid_help_${audience.name}'));
      } catch (error) {
        debugPrint('Raid help call failed: $error');
        if (paid) await points.refund(price);
        message = l10n.neighborsHelpFailed;
      }
    }
    await _refreshHelp(raid);
    if (!mounted) return;
    setState(() => _busyRequests.remove(raid.id));
    _snack(message);
  }

  Future<void> _offerHelp(RaidHelpCall call) async {
    final help = widget.raidHelp;
    final me = _me;
    final points = PointsScope.read(context);
    if (help == null || me == null || points == null) return;
    final l10n = AppLocalizations.of(context);
    final pet = points.roster.guarding(_ownedPets);
    if (pet == null) {
      _snack(l10n.neighborsHelpNeedGuard);
      return;
    }
    if (!_busyHelp.add(call.raidId)) return;
    setState(() {});
    String message;
    try {
      await help.offer(
        me,
        call,
        power: petPowerOf(points.roster, pet),
        pet: pet,
      );
      _helpAnswered = {..._helpAnswered, call.raidId};
      message = l10n.neighborsHelpSent(call.ownerName);
      unawaited(AnalyticsService.log('raid_help_offer'));
    } catch (error) {
      debugPrint('Raid help offer failed: $error');
      message = l10n.neighborsSendFailed;
    }
    if (!mounted) return;
    setState(() => _busyHelp.remove(call.raidId));
    _snack(message);
  }

  /// Сначала семя на устройстве, затем отметка на сервере. Повтор безопасен.
  Future<void> _claim(NeighborRequest request) async {
    if (request.kind == NeighborRequestKind.raid) {
      await _takeLoot(request);
      return;
    }
    final repository = widget.requests;
    final me = _me;
    final points = PointsScope.maybeOf(context);
    if (repository == null || me == null || points == null) return;
    final give = request.givenBy(me.id);
    final receive = request.resultSpecies;
    if (give == null || receive == null) return;
    if (!_busyRequests.add(request.id)) return;
    setState(() {});
    final l10n = AppLocalizations.of(context);
    final result = await points.claimNeighborCross(
      opId: request.opId,
      give: give,
      receive: receive,
      lineage: CrossLineage(
        partnerId: request.otherId(me.id),
        partnerName: request.otherName(me.id),
        parentSpecies: [request.species!.name, request.replySpecies!.name],
        ownPlantId: '',
      ),
    );
    String message;
    if (result.status == CrossStatus.granted) {
      message = l10n.neighborsSeedClaimed;
      try {
        _upsert(await repository.markClaimed(me, request));
      } catch (error) {
        debugPrint('Neighbor claim mark failed: $error');
      }
    } else if (result.status == CrossStatus.missing) {
      message = l10n.neighborsSeedMissing(l10n.seedName(give));
    } else {
      message = l10n.neighborsSendFailed;
    }
    if (!mounted) return;
    setState(() => _busyRequests.remove(request.id));
    _snack(message);
  }

  Future<void> _add(NeighborPerson person) async {
    if (person.practice || !_busyPeople.add(person.id)) return;
    setState(() {});
    final added = await widget.acquaintances.add(person);
    if (!mounted) return;
    setState(() => _busyPeople.remove(person.id));
    if (!added) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).neighborsSaved(person.name)),
      ),
    );
  }

  Future<void> _remove(NeighborPerson person) async {
    if (!_busyPeople.add(person.id)) return;
    setState(() {});
    await widget.acquaintances.remove(person.id);
    if (!mounted) return;
    setState(() => _busyPeople.remove(person.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context).neighborsRemoved(person.name),
        ),
      ),
    );
  }

  Future<void> _command(NeighborEvent event, NeighborCommand command) async {
    if (event.closed || !_busyEvents.add(event.id)) return;
    setState(() {});
    final result = await widget.gateway.submit(
      NeighborActionRequest(event: event, command: command),
    );
    if (!mounted) return;
    if (result.confirmed && result.memory != null) {
      await widget.history.add(result.memory!);
    }
    if (result.confirmed && command == NeighborCommand.thank) {
      await widget.notices.markThanked(event.id);
    }
    if (!mounted) return;
    setState(() {
      _busyEvents.remove(event.id);
      _overrides[event.id] = result.event;
    });
    widget.onNoticesChanged?.call();
    if (!result.confirmed || command != NeighborCommand.thank) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context).neighborsThankSent(event.personName),
        ),
      ),
    );
  }

  Future<void> _block(NeighborPerson person) async {
    if (widget.social != null && _me != null) {
      try {
        await widget.social!.block(_me!.id, person.id);
      } catch (_) {
        if (mounted) _snack(AppLocalizations.of(context).socialUnavailable);
        return;
      }
    }
    await widget.blocks.block(person.id);
    await widget.acquaintances.remove(person.id);
    if (!mounted) return;
    setState(() => _selectedId = null);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context).neighborsBlocked(person.name),
        ),
      ),
    );
  }

  Future<void> _report(NeighborPerson person) async {
    final l10n = AppLocalizations.of(context);
    var sent = await UgcReportRepository.submit(
      targetUid: person.id,
      targetName: person.name,
      reason: UgcReportRepository.reasonOther,
    );
    if (!sent) {
      final uri = Uri(
        scheme: 'mailto',
        path: AppLinks.supportEmail,
        queryParameters: {
          'subject': '${AppLinks.name} name report',
          'body': 'Player id: ${person.id}\nName: ${person.name}',
        },
      );
      sent = await launchUrl(uri);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.reportThanks)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selected = _selectedPerson();
    final me = _me?.id;
    final points = PointsScope.maybeOf(context);
    final notes = <String, NeighborInboxItem>{};
    if (me != null) {
      for (final request in _visibleRequests) {
        final label = neighborRequestSignal(l10n, request, me);
        if (label == null) continue;
        final personId = request.otherId(me);
        notes.putIfAbsent(
          personId,
          () => NeighborInboxItem(
            personId: personId,
            name: request.otherName(me),
            label: label,
            icon: neighborRequestIcon(request, me),
          ),
        );
      }
    }
    final inbox = <NeighborInboxItem>[
      ...notes.values,
      for (final event in _visibleEvents)
        if (event.inbox)
          NeighborInboxItem(
            personId: event.personId,
            name: event.personName,
            label: neighborSignalLabel(l10n, event.signal),
            signal: event.signal,
          ),
    ];

    return IgnorePointer(
      ignoring: !_interactive && !widget.visible,
      child: ExcludeSemantics(
        excluding: !_interactive && !widget.visible,
        child: Focus(
          focusNode: _focus,
          child: SlideTransition(
            position: _slide,
            child: Scaffold(
              backgroundColor: NeighborsPalette.wood,
              resizeToAvoidBottomInset: true,
              body: SafeArea(
                child: Semantics(
                  scopesRoute: true,
                  namesRoute: true,
                  explicitChildNodes: true,
                  label: l10n.neighborsTitle,
                  child: Column(
                    children: [
                      _Header(
                        title: selected?.name ?? l10n.neighborsTitle,
                        onClose: widget.onClose,
                        onProfile: widget.social == null || _me == null
                            ? null
                            : () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => SocialProfileEditor(
                                    repository: widget.social!,
                                    me: _me!.id,
                                  ),
                                ),
                              ),
                      ),
                      if (selected == null && inbox.isNotEmpty)
                        _ForYou(
                          items: inbox,
                          expanded: _forYouExpanded,
                          onToggle: () => setState(
                            () => _forYouExpanded = !_forYouExpanded,
                          ),
                          onOpen: _openPerson,
                        ),
                      if (selected == null && _helpCalls.isNotEmpty)
                        RaidHelpCallsSection(
                          calls: _helpCalls,
                          answered: _helpAnswered,
                          busy: _busyHelp,
                          guardPower: _petPower(points, PetRole.defender),
                          onOffer: (call) => unawaited(_offerHelp(call)),
                        ),
                      if (selected == null)
                        _Tabs(
                          index: _tab,
                          onChanged: (index) {
                            FocusManager.instance.primaryFocus?.unfocus();
                            setState(() => _tab = index);
                          },
                        ),
                      if (selected == null &&
                          PointsScope.maybeOf(context) != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          child: OutlinedButton.icon(
                            key: const ValueKey('neighbors-plant-showcase'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: NeighborsPalette.goldSoft,
                              minimumSize: const Size.fromHeight(48),
                            ),
                            onPressed: () => openPlantShowcase(
                              context,
                              onCross: _fromShowcase,
                            ),
                            icon: const Icon(Icons.local_florist_outlined),
                            label: Text(l10n.showcaseTitle),
                          ),
                        ),
                      Expanded(
                        child: Stack(
                          children: [
                            IndexedStack(
                              index: _tab,
                              sizing: StackFit.expand,
                              children: [
                                _DirectoryList(
                                  people: _shownPeople,
                                  events: _visibleEvents,
                                  notes: notes,
                                  controller: _allScroll,
                                  loading: _loading && _shownPeople.isEmpty,
                                  failed: _failed,
                                  fromCache: _fromCache,
                                  hasMore: _hasMore,
                                  loadingMore: _loadingMore,
                                  moreFailed: _moreFailed,
                                  search: _search,
                                  onRefresh: () => unawaited(_reload()),
                                  onLoadMore: () => unawaited(_loadMore()),
                                  onOpen: _openPerson,
                                ),
                                _SavedList(
                                  people: _savedPeople,
                                  badges: {
                                    for (final person in _people)
                                      if (person.badges != null)
                                        person.id: person.badges!,
                                  },
                                  events: _visibleEvents,
                                  notes: notes,
                                  controller: _savedScroll,
                                  onBrowse: () => setState(() => _tab = 0),
                                  onOpen: _openPerson,
                                ),
                                FriendsList(
                                  me: me,
                                  friends: [
                                    for (final f in _friends)
                                      if (me != null &&
                                          !widget.blocks.isBlocked(
                                            f.otherId(me),
                                          ))
                                        f,
                                  ],
                                  loading: _friendsLoading,
                                  failed: _friendsFailed || me == null,
                                  onOpen: _openExternalPerson,
                                  onBrowse: () => setState(() => _tab = 0),
                                  onRetry: () {
                                    unawaited(_loadRequests());
                                    unawaited(_loadFriends());
                                  },
                                ),
                              ],
                            ),
                            if (selected != null)
                              Positioned.fill(
                                child: NeighborCard(
                                  key: ValueKey('card-${selected.id}'),
                                  socialSection:
                                      widget.social == null ||
                                          _me == null ||
                                          selected.practice
                                      ? null
                                      : SocialPersonSection(
                                          onBlocked: () => setState(
                                            () => _selectedId = null,
                                          ),
                                          repository: widget.social!,
                                          me: _me!,
                                          person: selected,
                                          friendship: _friendshipWith(
                                            selected.id,
                                          ),
                                        ),
                                  person: selected,
                                  events: [
                                    for (final event in _visibleEvents)
                                      if (event.personId == selected.id) event,
                                  ],
                                  history: widget.history.forPerson(
                                    selected.id,
                                  ),
                                  saved: widget.acquaintances.contains(
                                    selected.id,
                                  ),
                                  thankedIds: widget.notices.thankedIds,
                                  busyEventIds: _busyEvents,
                                  busyPerson: _busyPeople.contains(selected.id),
                                  onBack: () =>
                                      setState(() => _selectedId = null),
                                  onAdd: () => unawaited(_add(selected)),
                                  onRemove: () => unawaited(_remove(selected)),
                                  onCommand: (event, command) =>
                                      unawaited(_command(event, command)),
                                  onBlock: () => unawaited(_block(selected)),
                                  onReport: () => unawaited(_report(selected)),
                                  onFindAgain: () => setState(() {
                                    _selectedId = null;
                                    _tab = 1;
                                  }),
                                  me: me,
                                  requestsOnline: _requestsOnline,
                                  requests: _requestsWith(selected.id),
                                  actionBlocks: _actionBlocks(l10n, points),
                                  busyRequestKeys: _busyRequests,
                                  onSend: widget.requests == null
                                      ? null
                                      : (kind) =>
                                            unawaited(_send(selected, kind)),
                                  onRespond: (request, accept) =>
                                      unawaited(_respond(request, accept)),
                                  onCancelRequest: (request) =>
                                      unawaited(_cancelRequest(request)),
                                  onClaim: (request) =>
                                      unawaited(_claim(request)),
                                  raidHelp: _raidHelpStatus,
                                  onAskHelp: widget.raidHelp == null
                                      ? null
                                      : (raid, audience) =>
                                            unawaited(_askHelp(raid, audience)),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.onClose, this.onProfile});

  final String title;
  final VoidCallback onClose;
  final VoidCallback? onProfile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: NeighborsPalette.goldSoft,
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
            ),
          ),
          if (onProfile != null)
            IconButton(
              tooltip: l10n.socialMyProfile,
              onPressed: onProfile,
              icon: const Icon(
                Icons.account_circle_outlined,
                color: NeighborsPalette.goldSoft,
              ),
            ),
          Semantics(
            button: true,
            label: l10n.neighborsClose,
            child: IconButton(
              key: const ValueKey('neighbors-close'),
              tooltip: l10n.neighborsClose,
              onPressed: onClose,
              icon: const Icon(
                Icons.close_rounded,
                color: NeighborsPalette.goldSoft,
              ),
              style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({required this.index, required this.onChanged});

  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              key: const ValueKey('neighbors-tab-all'),
              label: l10n.neighborsTabAll,
              selected: index == 0,
              onPressed: () => onChanged(0),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _TabButton(
              key: const ValueKey('neighbors-tab-saved'),
              label: l10n.neighborsTabSaved,
              selected: index == 1,
              onPressed: () => onChanged(1),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _TabButton(
              key: const ValueKey('neighbors-tab-friends'),
              label: l10n.socialFriends,
              selected: index == 2,
              onPressed: () => onChanged(2),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: selected ? NeighborsPalette.woodTop : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: NeighborsPalette.gold.withValues(
                  alpha: selected ? 0.8 : 0.35,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: NeighborsPalette.ivory,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ForYou extends StatelessWidget {
  const _ForYou({
    required this.items,
    required this.expanded,
    required this.onToggle,
    required this.onOpen,
  });

  final List<NeighborInboxItem> items;
  final bool expanded;
  final VoidCallback onToggle;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final collapsed = items.length > 3 && !expanded;
    final shown = collapsed ? items.take(1).toList() : items;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: DecoratedBox(
        key: const ValueKey('neighbors-for-you'),
        decoration: BoxDecoration(
          color: const Color(0xFF1E3324),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: NeighborsPalette.gold.withValues(alpha: 0.35),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.neighborsForYou,
                style: const TextStyle(
                  color: NeighborsPalette.goldSoft,
                  fontWeight: FontWeight.w800,
                ),
              ),
              for (final item in shown)
                _InboxRow(item: item, onOpen: () => onOpen(item.personId)),
              if (items.length > 3)
                TextButton(
                  key: const ValueKey('neighbors-for-you-toggle'),
                  onPressed: onToggle,
                  child: Text(
                    collapsed
                        ? l10n.neighborsUpdates(items.length)
                        : l10n.neighborsShowLess,
                    style: const TextStyle(color: NeighborsPalette.goldSoft),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InboxRow extends StatelessWidget {
  const _InboxRow({required this.item, required this.onOpen});

  final NeighborInboxItem item;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${item.name}. ${item.label}',
      child: InkWell(
        onTap: onOpen,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Row(
            children: [
              _ItemIcon(item: item),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${item.name} · ${item.label}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: NeighborsPalette.ivory),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemIcon extends StatelessWidget {
  const _ItemIcon({required this.item});

  final NeighborInboxItem item;

  @override
  Widget build(BuildContext context) {
    final signal = item.signal;
    if (signal != null) return NeighborSignalIcon(signal: signal);
    return ExcludeSemantics(
      child: Icon(
        item.icon ?? Icons.mail_rounded,
        color: NeighborsPalette.goldSoft,
        size: 22,
      ),
    );
  }
}

class _DirectoryList extends StatelessWidget {
  const _DirectoryList({
    required this.people,
    required this.events,
    required this.notes,
    required this.controller,
    required this.loading,
    required this.failed,
    required this.fromCache,
    required this.hasMore,
    required this.loadingMore,
    required this.moreFailed,
    required this.search,
    required this.onRefresh,
    required this.onLoadMore,
    required this.onOpen,
  });

  final List<NeighborPerson> people;
  final List<NeighborEvent> events;
  final Map<String, NeighborInboxItem> notes;
  final ScrollController controller;
  final bool loading;
  final bool failed;
  final bool fromCache;
  final bool hasMore;
  final bool loadingMore;
  final bool moreFailed;
  final TextEditingController search;
  final VoidCallback onRefresh;
  final VoidCallback onLoadMore;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (loading) {
      return Center(
        child: Semantics(
          label: l10n.neighborsLoading,
          child: const CircularProgressIndicator(
            color: NeighborsPalette.goldSoft,
          ),
        ),
      );
    }
    final queryEmpty = search.text.trim().isEmpty;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: TextField(
            key: const ValueKey('neighbors-search'),
            controller: search,
            style: const TextStyle(color: NeighborsPalette.ivory),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: l10n.neighborsSearchHint,
              hintStyle: TextStyle(
                color: NeighborsPalette.ivory.withValues(alpha: 0.45),
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: NeighborsPalette.goldSoft,
              ),
              filled: true,
              fillColor: NeighborsPalette.woodTop,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        if (failed)
          _StatusBanner(
            text: fromCache ? l10n.neighborsOffline : l10n.neighborsLoadFailed,
            onRetry: onRefresh,
          ),
        Expanded(
          child: people.isEmpty
              ? _EmptyMessage(
                  text: queryEmpty
                      ? l10n.neighborsEmptyPlayers
                      : l10n.neighborsEmptySearch,
                )
              : ListView.builder(
                  controller: controller,
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                  itemCount:
                      people.length +
                      (hasMore || loadingMore || moreFailed ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= people.length) {
                      return _MoreFooter(
                        loading: loadingMore,
                        failed: moreFailed,
                        onRetry: onLoadMore,
                      );
                    }
                    final person = people[index];
                    return _PersonRow(
                      person: person,
                      signal: leadingNeighborSignal([
                        for (final event in events)
                          if (event.personId == person.id) event,
                      ]),
                      note: notes[person.id],
                      onOpen: () => onOpen(person.id),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _SavedList extends StatelessWidget {
  const _SavedList({
    required this.people,
    required this.events,
    required this.notes,
    required this.controller,
    required this.onBrowse,
    required this.onOpen,
    this.badges = const {},
  });

  final List<NeighborPerson> people;
  final Map<String, ListBadges> badges;
  final List<NeighborEvent> events;
  final Map<String, NeighborInboxItem> notes;
  final ScrollController controller;
  final VoidCallback onBrowse;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (people.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.neighborsEmptySaved,
              textAlign: TextAlign.center,
              style: const TextStyle(color: NeighborsPalette.ivory),
            ),
            const SizedBox(height: 12),
            FilledButton(
              key: const ValueKey('neighbors-browse'),
              style: FilledButton.styleFrom(
                backgroundColor: NeighborsPalette.woodTop,
                foregroundColor: NeighborsPalette.goldSoft,
                minimumSize: const Size(48, 48),
              ),
              onPressed: onBrowse,
              child: Text(l10n.neighborsBrowsePlayers),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
      itemCount: people.length,
      itemBuilder: (context, index) {
        final person = people[index];
        return _PersonRow(
          person: person,
          signal: leadingNeighborSignal([
            for (final event in events)
              if (event.personId == person.id) event,
          ]),
          note: notes[person.id],
          badges: badges[person.id],
          onOpen: () => onOpen(person.id),
        );
      },
    );
  }
}

class _PersonRow extends StatelessWidget {
  const _PersonRow({
    required this.person,
    required this.signal,
    required this.onOpen,
    this.note,
    this.badges,
  });

  final NeighborPerson person;
  final NeighborEvent? signal;
  final NeighborInboxItem? note;
  final VoidCallback onOpen;

  /// Свежее, чем [NeighborPerson.badges] у сохранённых игроков.
  final ListBadges? badges;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final progress = neighborProgressLabel(l10n, person);
    final paid = badges ?? person.badges;
    final shown = paid != null && paid.activeAt(DateTime.now()) ? paid : null;
    final mark =
        note ??
        (signal == null
            ? null
            : NeighborInboxItem(
                personId: person.id,
                name: person.name,
                label: neighborSignalLabel(l10n, signal!.signal),
                signal: signal!.signal,
              ));
    final signalLabel = mark?.label ?? '';
    final detail = [
      progress,
      signalLabel,
    ].where((part) => part.isNotEmpty).join('. ');
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Semantics(
        button: true,
        label: detail.isEmpty ? person.name : '${person.name}. $detail',
        child: Material(
          color: const Color(0xFF3A2418),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: shown == null
                ? BorderSide.none
                : BorderSide(
                    color: NeighborsPalette.gold.withValues(alpha: 0.7),
                  ),
          ),
          child: InkWell(
            key: ValueKey('neighbors-row-${person.id}'),
            onTap: onOpen,
            borderRadius: BorderRadius.circular(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 64),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    NeighborAvatar(
                      name: person.name,
                      picture: shown?.avatarPicture,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  person.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: NeighborsPalette.ivory,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              if (shown != null &&
                                  shown.pictures.isNotEmpty) ...[
                                const SizedBox(width: 6),
                                ProfileBadgeStrip(
                                  key: ValueKey(
                                    'neighbors-badges-${person.id}',
                                  ),
                                  pictures: shown.pictures,
                                ),
                              ],
                            ],
                          ),
                          if (progress.isNotEmpty)
                            Text(
                              progress,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: NeighborsPalette.ivory.withValues(
                                  alpha: 0.72,
                                ),
                              ),
                            ),
                          if (mark != null)
                            Row(
                              children: [
                                _ItemIcon(item: mark),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    signalLabel,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: NeighborsPalette.ivory,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.text, required this.onRetry});

  final String text;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: NeighborsPalette.danger),
            ),
          ),
          TextButton(
            key: const ValueKey('neighbors-retry'),
            onPressed: onRetry,
            child: Text(
              l10n.neighborsRetry,
              style: const TextStyle(color: NeighborsPalette.goldSoft),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoreFooter extends StatelessWidget {
  const _MoreFooter({
    required this.loading,
    required this.failed,
    required this.onRetry,
  });

  final bool loading;
  final bool failed;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (loading) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Semantics(
            label: l10n.neighborsLoadingMore,
            child: const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: NeighborsPalette.goldSoft,
              ),
            ),
          ),
        ),
      );
    }
    if (!failed) return const SizedBox(height: 24);
    return TextButton(
      onPressed: onRetry,
      child: Text(
        l10n.neighborsRetry,
        style: const TextStyle(color: NeighborsPalette.goldSoft),
      ),
    );
  }
}

class _EmptyMessage extends StatelessWidget {
  const _EmptyMessage({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(color: NeighborsPalette.ivory),
        ),
      ),
    );
  }
}
