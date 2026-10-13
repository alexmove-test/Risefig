import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../models/neighbor_request.dart';
import '../../models/neighbor_social.dart';
import '../../models/raid_help.dart';
import '../../models/seed_catalog.dart';
import 'neighbor_copy.dart';
import 'neighbors_style.dart';

/// Строка «Для вас» и метка в списке игроков.
class NeighborInboxItem {
  const NeighborInboxItem({
    required this.personId,
    required this.name,
    required this.label,
    this.icon,
    this.signal,
  });

  final String personId;
  final String name;
  final String label;
  final IconData? icon;
  final NeighborSignal? signal;
}

IconData neighborRequestIcon(NeighborRequest request, String me) {
  if (request.outgoingFor(me) || !request.pending) return Icons.mail_rounded;
  return switch (request.kind) {
    NeighborRequestKind.message => Icons.chat_bubble_rounded,
    NeighborRequestKind.defense => Icons.shield_rounded,
    NeighborRequestKind.cross => Icons.grass_rounded,
    NeighborRequestKind.raid => Icons.flash_on_rounded,
  };
}

/// Ключ занятости отправки. У ответа ключ — id заявки.
String neighborSendKey(String personId, NeighborRequestKind kind) =>
    'send-$personId-${kind.name}';

/// Кнопки «Написать», «Защитить», «Предложить скрещивание», «Напасть».
class NeighborActionsSection extends StatelessWidget {
  const NeighborActionsSection({
    super.key,
    required this.personId,
    required this.online,
    required this.requests,
    required this.me,
    required this.blocks,
    required this.busyKeys,
    required this.onSend,
  });

  final String personId;
  final bool online;
  final List<NeighborRequest> requests;
  final String? me;

  /// Почему действие сейчас недоступно. Нет ключа — доступно.
  final Map<NeighborRequestKind, String> blocks;
  final Set<String> busyKeys;
  final ValueChanged<NeighborRequestKind> onSend;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final me = this.me;
    return Column(
      key: const ValueKey('neighbors-actions'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.neighborsActions,
          style: const TextStyle(
            color: NeighborsPalette.goldSoft,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        if (!online || me == null)
          Text(
            l10n.neighborsActionsOffline,
            key: const ValueKey('neighbors-actions-offline'),
            style: TextStyle(
              color: NeighborsPalette.ivory.withValues(alpha: 0.82),
            ),
          )
        else
          for (final kind in NeighborRequestKind.values)
            _ActionButton(
              kind: kind,
              busy: busyKeys.contains(neighborSendKey(personId, kind)),
              open: requests.any(
                (request) =>
                    request.kind == kind &&
                    request.outgoingFor(me) &&
                    request.pending,
              ),
              block: blocks[kind] ?? _resting(l10n, kind, me),
              onPressed: () => onSend(kind),
            ),
      ],
    );
  }

  /// Прошлый ответ ещё держит пару: набег отдыхает, семя не забрано.
  String? _resting(AppLocalizations l10n, NeighborRequestKind kind, String me) {
    final now = DateTime.now();
    for (final request in requests) {
      if (request.kind != kind ||
          !request.outgoingFor(me) ||
          request.pending ||
          !request.blocksResend(now)) {
        continue;
      }
      return kind == NeighborRequestKind.raid
          ? l10n.neighborsRaidTooSoon
          : l10n.neighborsAlreadyOpen;
    }
    return null;
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.kind,
    required this.busy,
    required this.open,
    required this.block,
    required this.onPressed,
  });

  final NeighborRequestKind kind;
  final bool busy;
  final bool open;
  final String? block;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final danger = kind == NeighborRequestKind.raid;
    final enabled = !busy && !open && block == null;
    final note = open ? l10n.neighborsWaiting : block;
    final icon = switch (kind) {
      NeighborRequestKind.message => Icons.chat_bubble_rounded,
      NeighborRequestKind.defense => Icons.shield_rounded,
      NeighborRequestKind.cross => Icons.grass_rounded,
      NeighborRequestKind.raid => Icons.flash_on_rounded,
    };
    final accent = danger ? NeighborsPalette.danger : NeighborsPalette.goldSoft;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton.icon(
            key: ValueKey('neighbors-action-${kind.name}'),
            style: FilledButton.styleFrom(
              backgroundColor: danger
                  ? const Color(0xFF6E241C)
                  : NeighborsPalette.woodTop,
              foregroundColor: accent,
              disabledBackgroundColor: const Color(0xFF3A2418),
              disabledForegroundColor: NeighborsPalette.ivory.withValues(
                alpha: 0.5,
              ),
              minimumSize: const Size.fromHeight(48),
              alignment: Alignment.centerLeft,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: accent.withValues(alpha: 0.6)),
              ),
            ),
            onPressed: enabled ? onPressed : null,
            icon: busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: NeighborsPalette.goldSoft,
                    ),
                  )
                : Icon(icon),
            label: Text(neighborActionLabel(l10n, kind)),
          ),
          if (note != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
              child: Text(
                note,
                key: ValueKey('neighbors-action-note-${kind.name}'),
                style: TextStyle(
                  color: NeighborsPalette.ivory.withValues(alpha: 0.72),
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Переписка и заявки с одним игроком, новые сверху.
class NeighborRequestList extends StatelessWidget {
  const NeighborRequestList({
    super.key,
    required this.requests,
    required this.me,
    required this.busyKeys,
    required this.onRespond,
    required this.onCancel,
    required this.onClaim,
    this.raidHelp = const {},
    this.onAskHelp,
  });

  final List<NeighborRequest> requests;
  final String me;
  final Set<String> busyKeys;
  final void Function(NeighborRequest request, bool accept) onRespond;
  final ValueChanged<NeighborRequest> onCancel;
  final ValueChanged<NeighborRequest> onClaim;

  /// Зов о помощи по id входящего набега.
  final Map<String, RaidHelpStatus> raidHelp;

  /// null — зов о помощи недоступен.
  final void Function(NeighborRequest raid, RaidHelpAudience audience)?
  onAskHelp;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      key: const ValueKey('neighbors-requests'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.neighborsMessages,
          style: const TextStyle(
            color: NeighborsPalette.goldSoft,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        for (final request in requests)
          _RequestTile(
            request: request,
            me: me,
            busy: busyKeys.contains(request.id),
            onRespond: (accept) => onRespond(request, accept),
            onCancel: () => onCancel(request),
            onClaim: () => onClaim(request),
            help: raidHelp[request.id] ?? RaidHelpStatus.none,
            onAskHelp: onAskHelp == null
                ? null
                : (audience) => onAskHelp!(request, audience),
          ),
      ],
    );
  }
}

class _RequestTile extends StatelessWidget {
  const _RequestTile({
    required this.request,
    required this.me,
    required this.busy,
    required this.onRespond,
    required this.onCancel,
    required this.onClaim,
    required this.help,
    required this.onAskHelp,
  });

  final NeighborRequest request;
  final String me;
  final bool busy;
  final ValueChanged<bool> onRespond;
  final VoidCallback onCancel;
  final VoidCallback onClaim;
  final RaidHelpStatus help;
  final ValueChanged<RaidHelpAudience>? onAskHelp;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final outgoing = request.outgoingFor(me);
    final raid = request.kind == NeighborRequestKind.raid;
    final senderName = outgoing ? l10n.neighborsYou : request.fromName;
    final replierName = outgoing ? request.toName : l10n.neighborsYou;
    final lines = <String>[
      l10n.neighborsQuote(
        senderName,
        neighborPhraseLabel(l10n, request.phrase),
      ),
      if (request.replyPhrase != null)
        l10n.neighborsQuote(
          replierName,
          neighborPhraseLabel(l10n, request.replyPhrase!),
        ),
    ];
    final result = _result(context, l10n);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DecoratedBox(
        key: ValueKey('neighbors-request-${request.id}'),
        decoration: BoxDecoration(
          color: raid && !outgoing
              ? const Color(0xFF3A1814)
              : const Color(0xFF3A2418),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: (raid ? NeighborsPalette.danger : NeighborsPalette.gold)
                .withValues(alpha: 0.45),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                neighborRequestHeadline(l10n, request, me),
                style: const TextStyle(
                  color: NeighborsPalette.ivory,
                  fontWeight: FontWeight.w800,
                ),
              ),
              for (final line in lines)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    line,
                    style: TextStyle(
                      color: NeighborsPalette.ivory.withValues(alpha: 0.88),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              if (result != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    result,
                    key: ValueKey('neighbors-request-result-${request.id}'),
                    style: const TextStyle(
                      color: NeighborsPalette.goldSoft,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              const SizedBox(height: 4),
              if (busy)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    l10n.neighborsInProgress,
                    style: const TextStyle(color: NeighborsPalette.goldSoft),
                  ),
                )
              else
                ..._buttons(l10n, outgoing),
            ],
          ),
        ),
      ),
    );
  }

  String? _result(BuildContext context, AppLocalizations l10n) {
    switch (request.status) {
      case NeighborRequestStatus.pending:
        if (request.outgoingFor(me)) return l10n.neighborsWaiting;
        if (request.kind == NeighborRequestKind.raid) {
          return _raidWaiting(context, l10n);
        }
        return null;
      case NeighborRequestStatus.declined:
        return l10n.neighborsDeclined;
      case NeighborRequestStatus.cancelled:
        return l10n.neighborsCancelled;
      case NeighborRequestStatus.accepted:
        break;
    }
    switch (request.kind) {
      case NeighborRequestKind.message:
        return null;
      case NeighborRequestKind.raid:
        return _raidResult(l10n);
      case NeighborRequestKind.defense:
        final until = request.protectionUntil;
        if (until == null || !request.protects(DateTime.now())) {
          return l10n.neighborsGuardEnded;
        }
        return l10n.neighborsGuarding(formatNeighborTime(context, until));
      case NeighborRequestKind.cross:
        final result = request.resultSpecies;
        if (result == null) return null;
        final line = l10n.neighborsCrossResult(l10n.seedName(result));
        if (!request.claimedBy(me)) return line;
        return '$line ${l10n.neighborsSeedClaimed}';
    }
  }

  String _raidWaiting(BuildContext context, AppLocalizations l10n) {
    final lines = [
      l10n.neighborsRaidDeadline(
        formatNeighborTime(context, request.raidDeadline!),
      ),
      if (help.audience == RaidHelpAudience.friends)
        l10n.neighborsHelpAskedFriends,
      if (help.audience == RaidHelpAudience.everyone)
        l10n.neighborsHelpAskedEveryone,
      if (help.offers.isNotEmpty) l10n.neighborsHelpArrived(help.offers.length),
    ];
    return lines.join('\n');
  }

  String _raidResult(AppLocalizations l10n) {
    final attack = request.power ?? 0;
    final defense = request.replyPower ?? 0;
    final won = request.raidSucceeded == true;
    final outgoing = request.outgoingFor(me);
    String plant(SeedSpecies species) => l10n.seedName(species);
    final lost = request.lostSpecies;
    final stolen = request.stolenSpecies;
    final helper = request.defenderName;
    final lines = [
      won
          ? l10n.neighborsRaidWon(attack, defense)
          : l10n.neighborsRaidRepelled(attack, defense),
      if (request.defenseSource == RaidDefenseSource.auto)
        l10n.neighborsRaidAutoDefended,
      if (helper != null) l10n.neighborsRaidDefendedBy(helper),
      if (won && outgoing) ...[
        if (stolen == null) l10n.neighborsRaidNoLoot,
        if (stolen != null && !request.fromClaimed)
          l10n.neighborsRaidLoot(plant(stolen)),
        if (stolen != null && request.fromClaimed)
          l10n.neighborsRaidLootTaken(plant(stolen)),
      ],
      if (won && !outgoing) ...[
        if (lost != null) l10n.neighborsRaidDestroyed(plant(lost)),
        if (stolen != null) l10n.neighborsRaidStolen(plant(stolen)),
        if (lost == null && stolen == null) l10n.neighborsRaidEmptyStorage,
      ],
    ];
    return lines.join('\n');
  }

  List<Widget> _buttons(AppLocalizations l10n, bool outgoing) {
    if (outgoing && request.pending) {
      return [
        _TileButton(
          buttonKey: ValueKey('neighbors-request-cancel-${request.id}'),
          label: l10n.neighborsCancelRequest,
          onPressed: onCancel,
        ),
      ];
    }
    if (request.canClaim(me) || request.canTakeLoot(me)) {
      return [
        _TileButton(
          buttonKey: ValueKey('neighbors-request-claim-${request.id}'),
          label: request.kind == NeighborRequestKind.raid
              ? l10n.neighborsRaidTakeLoot
              : l10n.neighborsClaimSeed,
          filled: true,
          onPressed: onClaim,
        ),
      ];
    }
    if (outgoing || !request.pending) return const [];
    final primary = switch (request.kind) {
      NeighborRequestKind.message => l10n.neighborsReply,
      NeighborRequestKind.defense => l10n.neighborsAcceptDefense,
      NeighborRequestKind.cross => l10n.neighborsChooseCrossPlant,
      NeighborRequestKind.raid => l10n.neighborsRepel,
    };
    return [
      _TileButton(
        buttonKey: ValueKey('neighbors-request-accept-${request.id}'),
        label: primary,
        filled: true,
        danger: request.kind == NeighborRequestKind.raid,
        onPressed: () => onRespond(true),
      ),
      if (request.kind == NeighborRequestKind.raid && onAskHelp != null) ...[
        if (help.audience == null)
          _TileButton(
            buttonKey: ValueKey('neighbors-help-friends-${request.id}'),
            label: l10n.neighborsHelpAskFriends,
            onPressed: () => onAskHelp!(RaidHelpAudience.friends),
          ),
        if (help.audience != RaidHelpAudience.everyone)
          _TileButton(
            buttonKey: ValueKey('neighbors-help-everyone-${request.id}'),
            label: l10n.neighborsHelpAskEveryone(
              NeighborRequestRules.helpEveryonePrice,
            ),
            onPressed: () => onAskHelp!(RaidHelpAudience.everyone),
          ),
      ],
      if (request.kind != NeighborRequestKind.raid)
        _TileButton(
          buttonKey: ValueKey('neighbors-request-decline-${request.id}'),
          label: l10n.neighborsCrossDecline,
          onPressed: () => onRespond(false),
        ),
    ];
  }
}

String formatNeighborTime(BuildContext context, DateTime moment) {
  final local = moment.toLocal();
  final dates = MaterialLocalizations.of(context);
  final time = TimeOfDay.fromDateTime(local).format(context);
  return '${dates.formatShortDate(local)} $time';
}

class _TileButton extends StatelessWidget {
  const _TileButton({
    required this.buttonKey,
    required this.label,
    required this.onPressed,
    this.filled = false,
    this.danger = false,
  });

  final Key buttonKey;
  final String label;
  final VoidCallback onPressed;
  final bool filled;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final accent = danger ? NeighborsPalette.danger : NeighborsPalette.goldSoft;
    if (!filled) {
      return Align(
        alignment: Alignment.centerLeft,
        child: TextButton(
          key: buttonKey,
          onPressed: onPressed,
          style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
          child: Text(
            label,
            style: const TextStyle(color: NeighborsPalette.ivory),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: FilledButton(
        key: buttonKey,
        style: FilledButton.styleFrom(
          backgroundColor: danger
              ? const Color(0xFF6E241C)
              : NeighborsPalette.woodTop,
          foregroundColor: accent,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: accent.withValues(alpha: 0.7)),
          ),
        ),
        onPressed: onPressed,
        child: Text(label, textAlign: TextAlign.center),
      ),
    );
  }
}
