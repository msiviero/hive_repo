import 'package:hive/hive.dart';
import 'package:quiver/core.dart';

const int maxInt = 9007199254740992;

class Entry<T> {
  final dynamic key;
  final T value;

  Entry(this.key, this.value);

  @override
  String toString() {
    return 'Entry[key=$key, value=$value]';
  }

  @override
  bool operator ==(o) => o is Entry && key == o.key && value == o.value;

  @override
  int get hashCode => hash2(key.hashCode, value.hashCode);
}

class RepositoryBase<T> {
  final BoxBase<T> _box;

  RepositoryBase(this._box);

  /// Puts an [item] in the box at the given [key]
  Future<void> put(dynamic key, T item) {
    return _box.put(key, item);
  }

  /// Add an [item] to the box. In this case, the key will be auto-incremented and returned
  Future<int> add(T item) {
    return _box.add(item);
  }

  /// Deletes an item at the given [key]
  Future<void> delete(dynamic key) {
    return _box.delete(key);
  }

  /// Returns the number of items contained in the box
  int count() => _box.keys.length;
}

/// A repository of type T backed by a standard hive box
class Repository<T> extends RepositoryBase<T> {
  @override
  final Box<T> _box;

  Repository(this._box) : super(_box);

  /// Returns an optional wrapping a single item, found (or not) by [key]
  Optional<T> find(dynamic key) {
    return Optional.fromNullable(_box.get(key));
  }

  /// Returns a stream of max [limit] values
  Stream<Entry<T>> stream({int limit = maxInt}) async* {
    var i = 0;
    for (final key in _box.keys) {
      final it = _box.get(key);
      if (it != null) yield Entry(key, it);
      i++;
      if (i >= limit) {
        break;
      }
    }
  }

  /// Returns a list of max [limit] values
  Future<List<Entry<T>>> list({int limit = maxInt}) =>
      stream(limit: limit).toList();
}

/// A repository of type T backed by a lazy hive box
class LazyRepository<T> extends RepositoryBase<T> {
  @override
  final LazyBox<T> _box;

  LazyRepository(this._box) : super(_box);

  /// Returns an optional wrapping a single item, found (or not) by [key]
  Future<Optional<T>> find(dynamic key) async {
    return Optional.fromNullable(await _box.get(key));
  }

  /// Returns a stream of max [limit] values
  Stream<Entry<T>> stream({int limit = maxInt}) async* {
    var i = 0;
    for (final key in _box.keys) {
      final it = await _box.get(key);
      if (it != null) yield Entry(key, it);
      i++;
      if (i >= limit) {
        break;
      }
    }
  }

  /// Returns a list of max [limit] values
  Future<List<Entry<T>>> list({int limit = maxInt}) =>
      stream(limit: limit).toList();
}
