import 'package:hive/hive.dart';
import 'package:quiver/core.dart';

const int maxInt = 9007199254740992;

class Repository<T> {
  final Box<T> _box;

  Repository(this._box);

  Future<void> put(key, T item) {
    return _box.put(key, item);
  }

  Future<void> add(T item) {
    return _box.add(item);
  }

  Optional<T> find(String key) {
    return Optional.fromNullable(_box.get(key));
  }

  Future<void> delete(String key) {
    return _box.delete(key);
  }

  Stream<T> stream({int limit = maxInt}) async* {
    var i = 0;
    for (final key in _box.keys) {
      yield _box.get(key)!;
      i++;
      if (i >= limit) {
        break;
      }
    }
  }

  Future<List<T>> list({int limit = maxInt}) => stream(limit: limit).toList();

  int count() => _box.keys.length;
}

class LazyRepository<T> {
  final LazyBox<T> _box;

  LazyRepository(this._box);

  Future<void> put(key, T item) {
    return _box.put(key, item);
  }

  Future<void> add(T item) {
    return _box.add(item);
  }

  Future<Optional<T>> find(String key) async {
    return Optional.fromNullable(await _box.get(key));
  }

  Future<void> delete(String key) {
    return _box.delete(key);
  }

  Stream<T> stream({int limit = maxInt}) async* {
    var i = 0;
    for (final key in _box.keys) {
      final it = await _box.get(key);
      if (it != null) yield it;
      i++;
      if (i >= limit) {
        break;
      }
    }
  }

  Future<List<T>> list({int limit = maxInt}) => stream(limit: limit).toList();

  int count() => _box.keys.length;
}
