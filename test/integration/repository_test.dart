import 'dart:io';

import 'package:hive/hive.dart';
import 'package:hive_repo/hive_repo.dart';
import 'package:quiver/core.dart';
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

      Optional<_FakeUser> record;

      expect(underTest.count(), 1);
      record = underTest.find('user_1');
      expect(record.value.name, 'Joe');

      await underTest.put('user_1', _FakeUser('Boe'));

      expect(underTest.count(), 1);
      record = underTest.find('user_1');
      expect(record.value.name, 'Boe');
    });

    test('Should count, stream and list items', () async {
      final underTest =
          Repository<_FakeUser>(Hive.box<_FakeUser>('_test_user'));

      await underTest.put(0, _FakeUser('Mick'));
      await underTest.put(1, _FakeUser('Keith'));
      await underTest.put(2, _FakeUser('Ronnie'));
      await underTest.put(3, _FakeUser('Charlie'));

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
