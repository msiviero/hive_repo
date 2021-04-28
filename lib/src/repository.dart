import 'package:hive/hive.dart';
import 'package:quiver/core.dart';

class RepositoryBase<T> {
  final BoxBase<T> box;
  final String keyNamespace;

  RepositoryBase(
    this.box, {
    this.keyNamespace = 'msiviero.dev',
  });

  /// Puts an [item] in the box at the given [key]
  Future<void> put(dynamic key, T item) {
    return box.put(key, item);
  }

  /// Deletes an item at the given [key]
  Future<void> delete(dynamic key) {
    return box.delete(key);
  }

  /// Returns the number of items contained in the box
  int count() => box.keys.length;
}

/// A repository of type T backed by a standard hive box
class Repository<T> extends RepositoryBase<T> {
  @override
  final Box<T> box;

  Repository(this.box) : super(box);

  /// Returns an optional wrapping a single item, found (or not) by [key]
  Optional<T> find(dynamic key) {
    return Optional.fromNullable(box.get(key));
  }

  /// Returns a stream of  values
  Stream<T> stream() async* {
    for (final key in box.keys) {
      final it = box.get(key);
      if (it != null) yield it;
    }
  }
}

/// A repository of type T backed by a lazy hive box
class LazyRepository<T> extends RepositoryBase<T> {
  @override
  final LazyBox<T> box;

  LazyRepository(this.box) : super(box);

  /// Returns an optional wrapping a single item, found (or not) by [key]
  Future<Optional<T>> find(dynamic key) async {
    return Optional.fromNullable(await box.get(key));
  }

  /// Returns a stream of entries
  Stream<T> stream() async* {
    for (final key in box.keys) {
      final it = await box.get(key);
      if (it != null) yield it;
    }
  }
}
