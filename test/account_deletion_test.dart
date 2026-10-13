import 'package:flutter_test/flutter_test.dart';
import 'package:mahjong/services/account_deletion.dart';

void main() {
  test('online failure leaves the device and the sign-in untouched', () async {
    final steps = <String>[];
    final deletion = AccountDeletion(
      signedIn: () => true,
      eraseOnline: () async => throw StateError('offline'),
      eraseLocal: () async => steps.add('local'),
      deleteAuthentication: () async => steps.add('auth'),
      signOut: () async => steps.add('signOut'),
      cancelReminders: () async => steps.add('reminders'),
    );

    await expectLater(deletion.run(), throwsStateError);
    expect(steps, isEmpty);
  });

  test('a refused auth delete signs out, then clears the device', () async {
    final steps = <String>[];
    final deletion = AccountDeletion(
      signedIn: () => true,
      eraseOnline: () async => steps.add('online'),
      eraseLocal: () async => steps.add('local'),
      deleteAuthentication: () async => throw StateError('rejected'),
      signOut: () async => steps.add('signOut'),
      cancelReminders: () async => steps.add('reminders'),
    );

    await deletion.run();
    expect(steps, ['online', 'signOut', 'local', 'reminders']);
  });

  test('without a signed-in account only the device is cleared', () async {
    final steps = <String>[];
    final deletion = AccountDeletion(
      signedIn: () => false,
      eraseOnline: () async => steps.add('online'),
      eraseLocal: () async => steps.add('local'),
      deleteAuthentication: () async => steps.add('auth'),
      signOut: () async => steps.add('signOut'),
      cancelReminders: () async => steps.add('reminders'),
    );

    await deletion.run();
    expect(steps, ['local', 'reminders']);
  });
}
