import '../models/neighbor_social.dart';

class NeighborActionRequest {
  const NeighborActionRequest({required this.event, required this.command});

  final NeighborEvent event;
  final NeighborCommand command;
}

class NeighborActionResult {
  const NeighborActionResult({
    required this.confirmed,
    required this.event,
    this.memory,
  });

  /// Истина только после подтверждения источником. До этого результат не успех.
  final bool confirmed;
  final NeighborEvent event;
  final NeighborMemory? memory;
}

/// Команды совместных действий. Обычная игра не подтверждает то, чего нет на сервере.
abstract class NeighborActionGateway {
  Future<NeighborActionResult> submit(NeighborActionRequest request);
}

/// Живой шлюз: действие не выполняется и не выглядит успешным.
class UnavailableNeighborGateway implements NeighborActionGateway {
  const UnavailableNeighborGateway();

  @override
  Future<NeighborActionResult> submit(NeighborActionRequest request) async {
    return NeighborActionResult(
      confirmed: false,
      event: request.event.copyWith(
        phase: NeighborPhase.failed,
        reason: NeighborReason.unsupported,
      ),
    );
  }
}

/// Шлюз проверки. Подтверждает только то, что тест явно разрешил, и не тратит хозяйство.
class RecordingNeighborGateway implements NeighborActionGateway {
  RecordingNeighborGateway({this.confirm = true, this.stale = false});

  final List<NeighborActionRequest> calls = [];
  bool confirm;
  bool stale;
  Future<void> Function()? pause;

  @override
  Future<NeighborActionResult> submit(NeighborActionRequest request) async {
    calls.add(request);
    final pause = this.pause;
    if (pause != null) await pause();
    if (stale || request.event.closed) {
      return NeighborActionResult(
        confirmed: false,
        event: request.event.copyWith(phase: NeighborPhase.expired),
      );
    }
    if (!confirm) {
      return NeighborActionResult(
        confirmed: false,
        event: request.event.copyWith(phase: NeighborPhase.failed),
      );
    }
    final completed = request.event.copyWith(
      phase: NeighborPhase.completed,
      clearReason: true,
    );
    return NeighborActionResult(
      confirmed: true,
      event: completed,
      memory: request.command == NeighborCommand.thank
          ? NeighborMemory(
              id: 'thanks-${request.event.id}',
              personId: request.event.personId,
              personName: request.event.personName,
              code: NeighborMemoryCode.thanked,
              atMillis: 0,
            )
          : null,
    );
  }
}
