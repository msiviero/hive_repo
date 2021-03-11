import 'dart:io';

import 'package:hive/hive.dart';
import 'package:hive_repo/hive_repo.dart';

void main() async {
  Hive.init(Directory.systemTemp.path + '/test');
  Hive.registerAdapter(UserAdapter());

  final repository = Repository<User>(Hive.box<User>('_test_user'));
  final users = await repository.list();

  print(users);

  /// [User1, User2, etc...]
}

class User {
  final String name;

  User(this.name);
}

class UserAdapter extends TypeAdapter<User> {
  @override
  final typeId = 0;

  @override
  User read(BinaryReader reader) {
    return User(reader.read());
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer.write(obj.name);
  }
}
