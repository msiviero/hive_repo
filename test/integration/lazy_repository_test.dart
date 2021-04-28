import 'dart:io';

import 'package:hive/hive.dart';
import 'package:hive_repo/hive_repo.dart';
import 'package:quiver/core.dart';
import 'package:test/test.dart';

void main() {
  group('Lazy Repository', () {
    final testDatabasePath =
        Directory.systemTemp.path + '/integration_test_lazy';

    setUpAll(() {
      Hive.init(testDatabasePath);
      Hive.registerAdapter(_TestUserAdapter2());
    });

    setUp(() async {
      await Hive.openLazyBox<_FakeUser2>('_test_user_lazy');
    });

    tearDown(() async {
      await Hive.deleteBoxFromDisk('_test_user_lazy');
      await Directory(testDatabasePath).delete(recursive: true);
    });

    test('Should create, read, update and delete items', () async {
      final item = _FakeUser2('Joe');
      final underTest = LazyRepository<_FakeUser2>(
          Hive.lazyBox<_FakeUser2>('_test_user_lazy'));

      await underTest.put('user_1', item);

      Optional<_FakeUser2> record;

      expect(underTest.count(), 1);
      record = await underTest.find('user_1');
      expect(record.value.name, 'Joe');

      await underTest.put('user_1', _FakeUser2('Boe'));

      expect(underTest.count(), 1);
      record = await underTest.find('user_1');
      expect(record.value.name, 'Boe');
    });

    test('Should count, stream and list items', () async {
      final underTest = LazyRepository<_FakeUser2>(
          Hive.lazyBox<_FakeUser2>('_test_user_lazy'));

      await underTest.put(0, _FakeUser2('Mick'));
      await underTest.put(1, _FakeUser2('Keith'));
      await underTest.put(2, _FakeUser2('Ronnie'));
      await underTest.put(3, _FakeUser2('Charlie'));

      expect(underTest.count(), 4);

      final stream = underTest.stream();

      await expectLater(
        stream,
        emitsInOrder([
          emits(_FakeUser2('Mick')),
          emits(_FakeUser2('Keith')),
          emits(_FakeUser2('Ronnie')),
          emits(_FakeUser2('Charlie')),
          emitsDone,
        ]),
      );
    });
  });
}

class _FakeUser2 {
  final String name;

  _FakeUser2(this.name);

  @override
  String toString() {
    return '_FakeUser($name)';
  }

  @override
  bool operator ==(o) => o is _FakeUser2 && o.name == name;
}

class _TestUserAdapter2 extends TypeAdapter<_FakeUser2> {
  @override
  final typeId = 0;

  @override
  _FakeUser2 read(BinaryReader reader) => _FakeUser2(reader.read());

  @override
  void write(BinaryWriter writer, _FakeUser2 obj) => writer.write(obj.name);
}
