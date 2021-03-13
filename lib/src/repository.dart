import 'package:hive/hive.dart';
import 'package:quiver/core.dart';

const int maxInt = 9007199254740992;

/// A repository of type T
class Repository<T> {
  final Box<T> _box;

  Repository(this._box);

  /// Puts an [item] in the box at the given [key]
  Future<void> put(key, T item) {
    return _box.put(key, item);
  }

  /// Add an [item] to the box. In this case, the key will be computed
  Future<void> add(T item) {
    return _box.add(item);
  }

  /// Returns an optional wrapping a single item, found (or not) by [key]
  Optional<T> find(String key) {
    return Optional.fromNullable(_box.get(key));
  }

  /// Deletes an item at the given [key]
  Future<void> delete(String key) {
    return _box.delete(key);
  }

  /// Returns a stream of max [limit] values
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

  /// Returns a list of max [limit] values
  Future<List<T>> list({int limit = maxInt}) => stream(limit: limit).toList();

  /// Returns the number of items contained in the box
  int count() => _box.keys.length;
}

class LazyRepository<T> {
  final LazyBox<T> _box;

  LazyRepository(this._box);

  /// Puts an [item] in the box at the given [key]
  Future<void> put(key, T item) {
    return _box.put(key, item);
  }

  /// Add an [item] to the box. In this case, the key will be computed
  Future<void> add(T item) {
    return _box.add(item);
  }

  /// Returns an optional wrapping a single item, found (or not) by [key]
  Future<Optional<T>> find(String key) async {
    return Optional.fromNullable(await _box.get(key));
  }

  /// Deletes an item at the given [key]
  Future<void> delete(String key) {
    return _box.delete(key);
  }

  /// Returns a stream of max [limit] values
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

  /// Returns a list of max [limit] values
  Future<List<T>> list({int limit = maxInt}) => stream(limit: limit).toList();

  /// Returns the number of items contained in the box
  int count() => _box.keys.length;
}
