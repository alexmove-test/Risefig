import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../models/neighbor_request.dart';
import '../../models/neighbor_social.dart';
import '../../models/raid_help.dart';
import 'neighbor_copy.dart';
import 'neighbor_requests_section.dart';
import 'neighbors_style.dart';

/// Карточка игрока внутри панели. Нажатие по строке списка сюда только открывает её.
class NeighborCard extends StatefulWidget {
  const NeighborCard({
    super.key,
    required this.person,
    required this.events,
    required this.history,
    required this.saved,
    required this.thankedIds,
    required this.busyEventIds,
    required this.busyPerson,
    required this.onBack,
    required this.onAdd,
    required this.onRemove,
    required this.onCommand,
    required this.onBlock,
    required this.onReport,
    required this.onFindAgain,
    this.me,
    this.requestsOnline = false,
    this.requests = const [],
    this.actionBlocks = const {},
    this.busyRequestKeys = const {},
    this.onSend,
    this.onRespond,
    this.onCancelRequest,
    this.onClaim,
    this.raidHelp = const {},
    this.onAskHelp,
    this.socialSection,
  });

  final NeighborPerson person;
  final Widget? socialSection;
  final List<NeighborEvent> events;
  final List<NeighborMemory> history;
  final bool saved;
  final Set<String> thankedIds;
  final Set<String> busyEventIds;
  final bool busyPerson;
  final VoidCallback onBack;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final void Function(NeighborEvent event, NeighborCommand command) onCommand;
  final VoidCallback onBlock;
  final VoidCallback onReport;
  final VoidCallback onFindAgain;

  /// Свой id в сети. null — действия с игроками недоступны.
  final String? me;
  final bool requestsOnline;

  /// Заявки только с этим игроком, новые сверху.
  final List<NeighborRequest> requests;
  final Map<NeighborRequestKind, String> actionBlocks;
  final Set<String> busyRequestKeys;
  final ValueChanged<NeighborRequestKind>? onSend;
  final void Function(NeighborRequest request, bool accept)? onRespond;
  final ValueChanged<NeighborRequest>? onCancelRequest;
  final ValueChanged<NeighborRequest>? onClaim;
  final Map<String, RaidHelpStatus> raidHelp;
  final void Function(NeighborRequest raid, RaidHelpAudience audience)?
  onAskHelp;

  @override
  State<NeighborCard> createState() => _NeighborCardState();
}

class _NeighborCardState extends State<NeighborCard> {
  String? _armedId;
  NeighborCommand? _armedCommand;

  @override
  void didUpdateWidget(NeighborCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final armed = _armedId;
    if (armed == null) return;
    final event = _event(armed);
    if (event == null ||
        event.closed ||
        event.phase == NeighborPhase.completed) {
      _armedId = null;
      _armedCommand = null;
    }
  }

  NeighborEvent? _event(String id) {
    for (final event in widget.events) {
      if (event.id == id) return event;
    }
    return null;
  }

  void _arm(NeighborEvent event, NeighborCommand command) {
    if (widget.busyEventIds.contains(event.id)) return;
    setState(() {
      _armedId = event.id;
      _armedCommand = command;
    });
  }

  void _confirm() {
    final id = _armedId;
    final command = _armedCommand;
    if (id == null || command == null) return;
    final event = _event(id);
    if (event == null || widget.busyEventIds.contains(event.id)) return;
    setState(() {
      _armedId = null;
      _armedCommand = null;
    });
    widget.onCommand(event, command);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final progress = neighborProgressLabel(l10n, widget.person);
    final peaceful = [
      for (final event in widget.events)
        if (event.kind != NeighborKind.raid) event,
    ];
    final attacks = [
      for (final event in widget.events)
        if (event.kind == NeighborKind.raid) event,
    ];
    final decision = _primaryDecision(peaceful);

    return Material(
      color: NeighborsPalette.wood,
      child: ListView(
        key: const ValueKey('neighbors-card'),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          Row(
            children: [
              _IconAction(
                key: const ValueKey('neighbors-back'),
                tooltip: l10n.neighborsBack,
                icon: Icons.arrow_back_rounded,
                onPressed: widget.onBack,
              ),
              const Spacer(),
              if (!widget.person.practice)
                _BookmarkAction(
                  key: ValueKey(
                    widget.saved ? 'neighbors-remove' : 'neighbors-add',
                  ),
                  saved: widget.saved,
                  busy: widget.busyPerson,
                  tooltip: widget.saved
                      ? l10n.neighborsRemove
                      : l10n.neighborsAdd,
                  onPressed: widget.saved ? widget.onRemove : widget.onAdd,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NeighborAvatar(name: widget.person.name, large: true),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.person.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: NeighborsPalette.ivory,
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                      ),
                    ),
                    if (progress.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        progress,
                        style: const TextStyle(
                          color: NeighborsPalette.goldSoft,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (widget.socialSection != null) widget.socialSection!,
          if (decision != null) ...[
            const SizedBox(height: 18),
            Text(
              l10n.neighborsPeaceful,
              style: const TextStyle(
                color: NeighborsPalette.goldSoft,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            _OfferBody(event: decision),
            const SizedBox(height: 12),
            _DecisionButtons(
              event: decision,
              busy: widget.busyEventIds.contains(decision.id),
              armed: _armedId == decision.id,
              onArm: () => _arm(decision, NeighborCommand.accept),
              onConfirm: _confirm,
              onCancel: () => setState(() {
                _armedId = null;
                _armedCommand = null;
              }),
              onDecline: () =>
                  widget.onCommand(decision, NeighborCommand.decline),
              onRetry: () => widget.onCommand(decision, NeighborCommand.retry),
            ),
          ] else if (peaceful.isNotEmpty) ...[
            const SizedBox(height: 18),
            for (final event in peaceful) ...[
              _OfferBody(event: event),
              const SizedBox(height: 8),
              _StatusLine(event: event),
              if (event.phase == NeighborPhase.failed)
                _RetryButton(
                  busy: widget.busyEventIds.contains(event.id),
                  onPressed: () =>
                      widget.onCommand(event, NeighborCommand.retry),
                ),
              const SizedBox(height: 8),
            ],
          ] else
            Padding(
              padding: const EdgeInsets.only(top: 18),
              child: Text(
                l10n.neighborsSavedHint,
                style: TextStyle(
                  color: NeighborsPalette.ivory.withValues(alpha: 0.82),
                ),
              ),
            ),
          const SizedBox(height: 16),
          if (widget.saved)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                key: const ValueKey('neighbors-find-again'),
                onPressed: widget.onFindAgain,
                child: Text(
                  l10n.neighborsFindAgain,
                  style: const TextStyle(color: NeighborsPalette.goldSoft),
                ),
              ),
            ),
          if (!widget.person.practice && widget.onSend != null) ...[
            const SizedBox(height: 18),
            NeighborActionsSection(
              personId: widget.person.id,
              online: widget.requestsOnline,
              requests: widget.requests,
              me: widget.me,
              blocks: widget.actionBlocks,
              busyKeys: widget.busyRequestKeys,
              onSend: widget.onSend!,
            ),
          ],
          if (widget.me != null && widget.requests.isNotEmpty) ...[
            const SizedBox(height: 14),
            NeighborRequestList(
              requests: widget.requests,
              me: widget.me!,
              busyKeys: widget.busyRequestKeys,
              onRespond: (request, accept) =>
                  widget.onRespond?.call(request, accept),
              onCancel: (request) => widget.onCancelRequest?.call(request),
              onClaim: (request) => widget.onClaim?.call(request),
              raidHelp: widget.raidHelp,
              onAskHelp: widget.onAskHelp,
            ),
          ],
          for (final event in peaceful)
            if (event.phase == NeighborPhase.completed)
              _FollowUps(
                event: event,
                thanked: widget.thankedIds.contains(event.id),
                busy: widget.busyEventIds.contains(event.id),
                saved: widget.saved,
                onCommand: widget.onCommand,
                onAdd: widget.onAdd,
              ),
          if (attacks.isNotEmpty) ...[
            const SizedBox(height: 22),
            _AttackSection(
              events: attacks,
              busyEventIds: widget.busyEventIds,
              armedId: _armedCommand == NeighborCommand.confirmAttack
                  ? _armedId
                  : null,
              onArm: (event) => _arm(event, NeighborCommand.confirmAttack),
              onConfirm: _confirm,
              onCancel: () => setState(() {
                _armedId = null;
                _armedCommand = null;
              }),
              onRetry: (event) =>
                  widget.onCommand(event, NeighborCommand.retry),
            ),
          ],
          if (widget.history.isNotEmpty) ...[
            const SizedBox(height: 22),
            Text(
              l10n.neighborsHistory,
              style: const TextStyle(
                color: NeighborsPalette.goldSoft,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            for (final memory in widget.history)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  neighborMemoryLabel(l10n, memory),
                  style: const TextStyle(color: NeighborsPalette.ivory),
                ),
              ),
          ],
          if (!widget.person.practice) ...[
            const SizedBox(height: 12),
            TextButton(
              key: const ValueKey('neighbors-report'),
              onPressed: widget.onReport,
              child: Text(
                l10n.socialProfileReport,
                style: const TextStyle(color: NeighborsPalette.ivory),
              ),
            ),
            TextButton(
              key: const ValueKey('neighbors-block'),
              onPressed: widget.onBlock,
              child: Text(
                l10n.neighborsBlock,
                style: const TextStyle(color: NeighborsPalette.danger),
              ),
            ),
          ],
        ],
      ),
    );
  }

  NeighborEvent? _primaryDecision(List<NeighborEvent> peaceful) {
    NeighborEvent? best;
    for (final event in peaceful) {
      if (event.phase != NeighborPhase.needsDecision || !event.incoming) {
        continue;
      }
      if (best == null || event.attention.index < best.attention.index) {
        best = event;
      }
    }
    return best;
  }
}

class _OfferBody extends StatelessWidget {
  const _OfferBody({required this.event});

  final NeighborEvent event;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lines = <String>[
      if (event.cost != null && event.cost!.isNotEmpty)
        l10n.neighborsCost(event.cost!),
      if (event.outcome != null && event.outcome!.isNotEmpty)
        l10n.neighborsOutcome(event.outcome!),
      if (event.plantName != null && event.plantName!.isNotEmpty)
        l10n.neighborsUsesPlant(event.plantName!),
      if (event.plantName != null && event.ownerKeepsPlant == true)
        l10n.neighborsPlantStays,
      if (event.plantName != null && event.ownerKeepsPlant == false)
        l10n.neighborsPlantLeaves,
      if (event.protectorName != null && event.protectorName!.isNotEmpty)
        l10n.neighborsProtector(event.protectorName!),
      if (event.untilMillis != null)
        l10n.neighborsUntil(_formatUntil(context, event.untilMillis!)),
      if (event.attackStrength != null)
        l10n.neighborsAttackPower(event.attackStrength!),
      if (event.defenseStrength != null)
        l10n.neighborsDefensePower(event.defenseStrength!),
      if (event.lootEssence != null) l10n.neighborsLoot(event.lootEssence!),
      if (event.reason != null) neighborReasonLabel(l10n, event.reason!),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            NeighborSignalIcon(signal: event.signal),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                neighborSignalLabel(l10n, event.signal),
                style: const TextStyle(
                  color: NeighborsPalette.ivory,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        for (final line in lines)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              line,
              style: const TextStyle(color: NeighborsPalette.ivory),
            ),
          ),
      ],
    );
  }
}

String _formatUntil(BuildContext context, int millis) {
  final local = DateTime.fromMillisecondsSinceEpoch(millis).toLocal();
  final dates = MaterialLocalizations.of(context);
  final time = TimeOfDay.fromDateTime(local).format(context);
  return '${dates.formatShortDate(local)} $time';
}

class _DecisionButtons extends StatelessWidget {
  const _DecisionButtons({
    required this.event,
    required this.busy,
    required this.armed,
    required this.onArm,
    required this.onConfirm,
    required this.onCancel,
    required this.onDecline,
    required this.onRetry,
  });

  final NeighborEvent event;
  final bool busy;
  final bool armed;
  final VoidCallback onArm;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final VoidCallback onDecline;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (busy) {
      return Text(
        l10n.neighborsInProgress,
        style: const TextStyle(color: NeighborsPalette.goldSoft),
      );
    }
    if (event.phase == NeighborPhase.failed) {
      return _RetryButton(busy: false, onPressed: onRetry);
    }
    if (event.closed || event.phase == NeighborPhase.unavailable) {
      return _StatusLine(event: event);
    }
    if (event.phase == NeighborPhase.awaitingReply) {
      return Text(
        l10n.neighborsWaiting,
        style: const TextStyle(color: NeighborsPalette.goldSoft),
      );
    }
    if (armed) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _WideButton(
            key: const ValueKey('neighbors-confirm'),
            label: l10n.neighborsConfirm,
            filled: true,
            busy: false,
            onPressed: onConfirm,
          ),
          TextButton(
            onPressed: onCancel,
            child: Text(
              l10n.cancel,
              style: const TextStyle(color: NeighborsPalette.ivory),
            ),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _WideButton(
          key: const ValueKey('neighbors-primary'),
          label: switch (event.kind) {
            NeighborKind.help => l10n.neighborsHelpAction,
            NeighborKind.defense => l10n.neighborsDefenseAction,
            NeighborKind.cross => l10n.neighborsViewOffer,
            NeighborKind.raid || NeighborKind.thanks => l10n.neighborsReply,
          },
          filled: true,
          busy: false,
          onPressed: onArm,
        ),
        TextButton(
          key: const ValueKey('neighbors-decline'),
          onPressed: onDecline,
          child: Text(
            l10n.neighborsCrossDecline,
            style: const TextStyle(color: NeighborsPalette.ivory),
          ),
        ),
      ],
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.event});

  final NeighborEvent event;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final phase = neighborPhaseLabel(l10n, event.phase);
    final reason = event.reason == null
        ? ''
        : neighborReasonLabel(l10n, event.reason!);
    final text = [phase, reason].where((line) => line.isNotEmpty).join(' ');
    if (text.isEmpty) return const SizedBox.shrink();
    final failed = event.phase == NeighborPhase.failed;
    return Text(
      text,
      key: const ValueKey('neighbors-status'),
      style: TextStyle(
        color: failed ? NeighborsPalette.danger : NeighborsPalette.goldSoft,
      ),
    );
  }
}

class _RetryButton extends StatelessWidget {
  const _RetryButton({required this.busy, required this.onPressed});

  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(
        key: const ValueKey('neighbors-retry-action'),
        onPressed: busy ? null : onPressed,
        child: Text(
          AppLocalizations.of(context).neighborsRetry,
          style: const TextStyle(color: NeighborsPalette.goldSoft),
        ),
      ),
    );
  }
}

class _FollowUps extends StatelessWidget {
  const _FollowUps({
    required this.event,
    required this.thanked,
    required this.busy,
    required this.saved,
    required this.onCommand,
    required this.onAdd,
  });

  final NeighborEvent event;
  final bool thanked;
  final bool busy;
  final bool saved;
  final void Function(NeighborEvent event, NeighborCommand command) onCommand;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (event.followUps.contains(NeighborFollowUp.thank))
          TextButton(
            key: const ValueKey('neighbors-thank'),
            onPressed: busy || thanked
                ? null
                : () => onCommand(event, NeighborCommand.thank),
            child: Text(
              thanked
                  ? l10n.neighborsThankSent(event.personName)
                  : l10n.neighborsThank,
              style: const TextStyle(color: NeighborsPalette.goldSoft),
            ),
          ),
        if (event.followUps.contains(NeighborFollowUp.offerAgain))
          TextButton(
            key: const ValueKey('neighbors-offer-again'),
            onPressed: busy
                ? null
                : () => onCommand(event, NeighborCommand.offerAgain),
            child: Text(
              l10n.neighborsOfferAgain,
              style: const TextStyle(color: NeighborsPalette.goldSoft),
            ),
          ),
        if (event.followUps.contains(NeighborFollowUp.save) && !saved)
          TextButton(
            onPressed: onAdd,
            child: Text(
              l10n.neighborsAdd,
              style: const TextStyle(color: NeighborsPalette.goldSoft),
            ),
          ),
      ],
    );
  }
}

class _AttackSection extends StatelessWidget {
  const _AttackSection({
    required this.events,
    required this.busyEventIds,
    required this.armedId,
    required this.onArm,
    required this.onConfirm,
    required this.onCancel,
    required this.onRetry,
  });

  final List<NeighborEvent> events;
  final Set<String> busyEventIds;
  final String? armedId;
  final void Function(NeighborEvent event) onArm;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final void Function(NeighborEvent event) onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final event = events.first;
    final busy = busyEventIds.contains(event.id);
    final actionable =
        event.phase == NeighborPhase.available ||
        event.phase == NeighborPhase.needsDecision;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF3A1814),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: NeighborsPalette.danger.withValues(alpha: 0.7),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.neighborsAttackSection,
              style: const TextStyle(
                color: NeighborsPalette.danger,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.neighborsAttackExplain,
              style: const TextStyle(color: NeighborsPalette.ivory),
            ),
            const SizedBox(height: 8),
            _OfferBody(event: event),
            const SizedBox(height: 8),
            if (busy)
              Text(
                l10n.neighborsInProgress,
                style: const TextStyle(color: NeighborsPalette.danger),
              )
            else if (event.phase == NeighborPhase.failed)
              _RetryButton(busy: false, onPressed: () => onRetry(event))
            else if (event.closed ||
                event.phase == NeighborPhase.awaitingReply ||
                event.phase == NeighborPhase.completed)
              _StatusLine(event: event)
            else if (armedId == event.id)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _WideButton(
                    key: const ValueKey('neighbors-attack-confirm'),
                    label: l10n.neighborsConfirm,
                    filled: true,
                    danger: true,
                    busy: false,
                    onPressed: onConfirm,
                  ),
                  TextButton(
                    onPressed: onCancel,
                    child: Text(
                      l10n.cancel,
                      style: const TextStyle(color: NeighborsPalette.ivory),
                    ),
                  ),
                ],
              )
            else if (actionable)
              _WideButton(
                key: const ValueKey('neighbors-attack'),
                label: l10n.neighborsAttackSection,
                filled: true,
                danger: true,
                busy: false,
                onPressed: () => onArm(event),
              ),
          ],
        ),
      ),
    );
  }
}

class _WideButton extends StatelessWidget {
  const _WideButton({
    super.key,
    required this.label,
    required this.filled,
    required this.busy,
    required this.onPressed,
    this.danger = false,
  });

  final String label;
  final bool filled;
  final bool busy;
  final bool danger;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final child = busy
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: NeighborsPalette.goldSoft,
            ),
          )
        : Text(label, textAlign: TextAlign.center);
    if (!filled) {
      return OutlinedButton(onPressed: busy ? null : onPressed, child: child);
    }
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: danger
            ? const Color(0xFF6E241C)
            : NeighborsPalette.woodTop,
        foregroundColor: danger
            ? NeighborsPalette.danger
            : NeighborsPalette.goldSoft,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: (danger ? NeighborsPalette.danger : NeighborsPalette.gold)
                .withValues(alpha: 0.75),
          ),
        ),
      ),
      onPressed: busy ? null : onPressed,
      child: child,
    );
  }
}

class _BookmarkAction extends StatelessWidget {
  const _BookmarkAction({
    super.key,
    required this.saved,
    required this.busy,
    required this.tooltip,
    required this.onPressed,
  });

  final bool saved;
  final bool busy;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: saved,
      label: tooltip,
      child: IconButton(
        tooltip: tooltip,
        onPressed: busy ? null : onPressed,
        icon: busy
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: NeighborsPalette.goldSoft,
                ),
              )
            : Icon(
                saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                color: saved
                    ? NeighborsPalette.gold
                    : NeighborsPalette.goldSoft,
              ),
        style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon, color: NeighborsPalette.goldSoft),
        style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
    );
  }
}

class NeighborAvatar extends StatelessWidget {
  const NeighborAvatar({
    super.key,
    required this.name,
    this.large = false,
    this.picture,
  });

  final String name;
  final bool large;

  /// Аватар из профиля вместо первой буквы имени.
  final String? picture;

  @override
  Widget build(BuildContext context) {
    final trimmed = name.trim();
    final letter =
        picture ??
        (trimmed.isEmpty
            ? '?'
            : String.fromCharCode(trimmed.runes.first).toUpperCase());
    final size = large ? 64.0 : 44.0;
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: NeighborsPalette.woodTop,
          border: Border.all(
            color: NeighborsPalette.gold.withValues(alpha: 0.8),
          ),
        ),
        child: Text(
          letter,
          style: TextStyle(
            color: NeighborsPalette.goldSoft,
            fontWeight: FontWeight.w800,
            fontSize: (large ? 26 : 18) + (picture == null ? 0 : 4),
          ),
        ),
      ),
    );
  }
}

class NeighborSignalIcon extends StatelessWidget {
  const NeighborSignalIcon({super.key, required this.signal});

  final NeighborSignal signal;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (signal) {
      NeighborSignal.asksHelp => (
        Icons.front_hand_rounded,
        const Color(0xFFB7D7A8),
      ),
      NeighborSignal.seeksDefense => (
        Icons.shield_rounded,
        const Color(0xFF9ECAE3),
      ),
      NeighborSignal.offersCross => (
        Icons.grass_rounded,
        const Color(0xFFD7C56A),
      ),
      NeighborSignal.awaitsReply => (
        Icons.mail_rounded,
        NeighborsPalette.goldSoft,
      ),
      NeighborSignal.helpedYou => (
        Icons.check_rounded,
        const Color(0xFFB7D7A8),
      ),
    };
    return ExcludeSemantics(child: Icon(icon, color: color, size: 22));
  }
}
