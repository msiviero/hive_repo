import 'dart:io';

import 'package:hive/hive.dart';
import 'package:hive_repo/hive_repo.dart';
import 'package:test/test.dart';

void main() {
  group('Repository', () {
    final testDatabasePath = Directory.systemTemp.path + '/integration_test';

    setUpAll(() {
      Hive.init(testDatabasePath);
      Hive.registerAdapter(_TestUserAdapter());
    });

    setUp(() async {
      await Hive.openBox<_FakeUser>('_test_user');
    });

    tearDown(() async {
      await Hive.deleteBoxFromDisk('_test_user');
      await Directory(testDatabasePath).delete(recursive: true);
    });

    test('Should create, read, update and delete items', () async {
      final item = _FakeUser('Joe');
      final underTest =
          Repository<_FakeUser>(Hive.box<_FakeUser>('_test_user'));

      await underTest.put('user_1', item);

      _FakeUser value;

      expect(underTest.count(), 1);
      value = underTest.one('user_1');
      expect(value.name, 'Joe');

      await underTest.put('user_1', _FakeUser('Boe'));

      expect(underTest.count(), 1);
      value = underTest.one('user_1');
      expect(value.name, 'Boe');
    });

    test('Should count, stream and list items', () async {
      final underTest =
          Repository<_FakeUser>(Hive.box<_FakeUser>('_test_user'));

      await underTest.add(_FakeUser('Mick'));
      await underTest.add(_FakeUser('Keith'));
      await underTest.add(_FakeUser('Ronnie'));
      await underTest.add(_FakeUser('Charlie'));

      expect(underTest.count(), 4);

      final stream = underTest.stream();

      await expectLater(
        stream,
        emitsInOrder([
          emits(_FakeUser('Mick')),
          emits(_FakeUser('Keith')),
          emits(_FakeUser('Ronnie')),
          emits(_FakeUser('Charlie')),
          emitsDone,
        ]),
      );
    });

    test('Should limit stream', () async {
      final underTest =
          Repository<_FakeUser>(Hive.box<_FakeUser>('_test_user'));

      await underTest.add(_FakeUser('Mick'));
      await underTest.add(_FakeUser('Keith'));
      await underTest.add(_FakeUser('Ronnie'));
      await underTest.add(_FakeUser('Charlie'));

      expect(underTest.count(), 4);

      final stream = underTest.stream(limit: 2);

      await expectLater(
        stream,
        emitsInOrder([
          emits(_FakeUser('Mick')),
          emits(_FakeUser('Keith')),
          emitsDone,
        ]),
      );
    });
  });
}

class _FakeUser {
  final String name;

  _FakeUser(this.name);

  @override
  String toString() {
    return '_FakeUser($name)';
  }

  @override
  bool operator ==(o) => o is _FakeUser && o.name == name;
}

class _TestUserAdapter extends TypeAdapter<_FakeUser> {
  @override
  final typeId = 0;

  @override
  _FakeUser read(BinaryReader reader) => _FakeUser(reader.read());

  @override
  void write(BinaryWriter writer, _FakeUser obj) => writer.write(obj.name);
}