Repository functionalities on top of hive

## Usage

Just pass a box to the constructor and use the Repository and LazyRepository methods

```dart
import 'package:hive_repo/hive_repo.dart';

main() {

  Hive.init(Directory.systemTemp.path + '/test');
  Hive.registerAdapter(UserAdapter());

  final repository = Repository<User>(Hive.box<User>('_test_user'));

  final List<User> users = await repository.list();
}
```
