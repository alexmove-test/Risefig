import '../../l10n/l10n.dart';
import '../../models/neighbor_request.dart';
import '../../models/neighbor_social.dart';

String neighborSignalLabel(AppLocalizations l10n, NeighborSignal signal) {
  return switch (signal) {
    NeighborSignal.asksHelp => l10n.neighborsSignalAsksHelp,
    NeighborSignal.seeksDefense => l10n.neighborsSignalSeeksDefense,
    NeighborSignal.offersCross => l10n.neighborsSignalOffersCross,
    NeighborSignal.awaitsReply => l10n.neighborsSignalAwaitsReply,
    NeighborSignal.helpedYou => l10n.neighborsSignalHelpedYou,
  };
}

String neighborPhaseLabel(AppLocalizations l10n, NeighborPhase phase) {
  return switch (phase) {
    NeighborPhase.awaitingReply => l10n.neighborsWaiting,
    NeighborPhase.inProgress => l10n.neighborsInProgress,
    NeighborPhase.completed => l10n.neighborsDone,
    NeighborPhase.declined => l10n.neighborsDeclined,
    NeighborPhase.cancelled => l10n.neighborsCancelled,
    NeighborPhase.expired => l10n.neighborsEnded,
    NeighborPhase.unavailable => l10n.neighborsUnavailable,
    NeighborPhase.failed => l10n.neighborsFailed,
    NeighborPhase.available || NeighborPhase.needsDecision => '',
  };
}

String neighborReasonLabel(AppLocalizations l10n, NeighborReason reason) {
  return switch (reason) {
    NeighborReason.unsupported => l10n.neighborsReasonUnsupported,
    NeighborReason.notAllowed => l10n.neighborsReasonNotAllowed,
    NeighborReason.missingPet => l10n.neighborsReasonMissingPet,
    NeighborReason.missingPlant => l10n.neighborsReasonMissingPlant,
  };
}

String neighborMemoryLabel(AppLocalizations l10n, NeighborMemory memory) {
  return switch (memory.code) {
    NeighborMemoryCode.helpedPlant => l10n.neighborsMemoryHelped(
      memory.personName,
    ),
    NeighborMemoryCode.petDefended => l10n.neighborsMemoryDefended(
      memory.personName,
    ),
    NeighborMemoryCode.crossed => l10n.neighborsMemoryCrossed(
      memory.personName,
    ),
    NeighborMemoryCode.thanked => l10n.neighborsMemoryThanked(
      memory.personName,
    ),
    NeighborMemoryCode.raidReport => l10n.neighborsMemoryRaid(
      memory.personName,
    ),
  };
}

String neighborPhraseLabel(AppLocalizations l10n, NeighborPhrase phrase) {
  return switch (phrase) {
    NeighborPhrase.hello => l10n.neighborsPhraseHello,
    NeighborPhrase.goodLuck => l10n.neighborsPhraseGoodLuck,
    NeighborPhrase.thanks => l10n.neighborsPhraseThanks,
    NeighborPhrase.niceGarden => l10n.neighborsPhraseNiceGarden,
    NeighborPhrase.letsCross => l10n.neighborsPhraseLetsCross,
    NeighborPhrase.iWillGuard => l10n.neighborsPhraseIWillGuard,
    NeighborPhrase.readyForRaid => l10n.neighborsPhraseReadyForRaid,
    NeighborPhrase.wellPlayed => l10n.neighborsPhraseWellPlayed,
  };
}

String neighborActionLabel(AppLocalizations l10n, NeighborRequestKind kind) {
  return switch (kind) {
    NeighborRequestKind.message => l10n.neighborsActionMessage,
    NeighborRequestKind.defense => l10n.neighborsActionDefend,
    NeighborRequestKind.cross => l10n.neighborsActionCross,
    NeighborRequestKind.raid => l10n.neighborsActionRaid,
  };
}

/// Что произошло, с точки зрения игрока [me].
String neighborRequestHeadline(
  AppLocalizations l10n,
  NeighborRequest request,
  String me,
) {
  final power = request.power ?? 0;
  final plant = request.species == null ? '' : l10n.seedName(request.species!);
  if (request.outgoingFor(me)) {
    return switch (request.kind) {
      NeighborRequestKind.message => l10n.neighborsOutMessage,
      NeighborRequestKind.defense => l10n.neighborsOutDefense(power),
      NeighborRequestKind.cross => l10n.neighborsOutCross(plant),
      NeighborRequestKind.raid => l10n.neighborsOutRaid(power),
    };
  }
  final name = request.fromName;
  return switch (request.kind) {
    NeighborRequestKind.message => l10n.neighborsInMessage(name),
    NeighborRequestKind.defense => l10n.neighborsInDefense(name, power),
    NeighborRequestKind.cross => l10n.neighborsInCross(name, plant),
    NeighborRequestKind.raid => l10n.neighborsInRaid(name, power),
  };
}

/// Короткая метка для строки списка. null — заявка внимания не требует.
String? neighborRequestSignal(
  AppLocalizations l10n,
  NeighborRequest request,
  String me,
) {
  if (!request.needsAttention(me)) return null;
  if (request.outgoingFor(me) || !request.pending) {
    return l10n.neighborsSignalResult;
  }
  return switch (request.kind) {
    NeighborRequestKind.message => l10n.neighborsSignalMessage,
    NeighborRequestKind.defense => l10n.neighborsSignalDefense,
    NeighborRequestKind.cross => l10n.neighborsSignalOffersCross,
    NeighborRequestKind.raid => l10n.neighborsSignalRaid,
  };
}

/// Строка для плашки на главном экране: кто и что. null — внимания не нужно.
String? neighborHubLine(
  AppLocalizations l10n,
  NeighborRequest request,
  String me,
) {
  final signal = neighborRequestSignal(l10n, request, me);
  if (signal == null) return null;
  final String text;
  if (request.canClaim(me)) {
    text = l10n.neighborsClaimSeed;
  } else if (request.canTakeLoot(me)) {
    text = l10n.neighborsRaidTakeLoot;
  } else if (request.status == NeighborRequestStatus.declined) {
    text = l10n.neighborsDeclined;
  } else if (request.raidSucceeded != null) {
    final attack = request.power ?? 0;
    final defense = request.replyPower ?? 0;
    text = request.raidSucceeded!
        ? l10n.neighborsRaidWon(attack, defense)
        : l10n.neighborsRaidRepelled(attack, defense);
  } else {
    text = signal;
  }
  return l10n.hubNeighborEvent(request.otherName(me), text);
}

String neighborProgressLabel(AppLocalizations l10n, NeighborPerson person) {
  if (!person.progressKnown) return '';
  return '${l10n.starsCount(person.stars)} · ${l10n.neighborsLevel(person.levelsUnlocked)}';
}
