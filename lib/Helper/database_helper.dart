import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqlite/Helper/Constance.dart';
import 'package:sqlite/model/UserModel.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static late Database _database;
  static final DatabaseHelper db = DatabaseHelper._();

  Future<Database> get database async {
    _database = await initDb();
    return _database;
  }

  initDb() async {
    String path = join(await getDatabasesPath(), 'UserData.db');
    return await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
  CREATE TABLE $tableUser(
  $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
  $columnName TEXT NOT NULL,
  $columnPhone TEXT NOT NULL,
  $columnEmail TEXT NOT NULL
  )
''');
    });
  }

  insertUser(UserModel user) async {
    var dbClient = await database;
    await dbClient.insert(tableUser, user.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  updateUser(UserModel user) async {
    var dbClient = await database;
    await dbClient.update(
      tableUser,
      user.toJson(),
      where: '$columnId= ?',
      whereArgs: [user.id],
    );
  }

  Future<UserModel?> getUser(int id) async {
    var dbClient = await database;

    List<Map> maps =
        await dbClient.query(tableUser, where: '$columnId=?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return UserModel.fromJson(maps.first);
    } else {
      return null;
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    var dbClient = await database;
    List<Map> maps = await dbClient.query(tableUser);

    return maps.isNotEmpty
        ? maps.map((user) => UserModel.fromJson(user)).toList()
        : [];
  }

  Future<void> deleteUser(int id) async {
    var dbClient = await database;
    dbClient.delete(tableUser, where: '$columnId=?', whereArgs: [id]);
  }
}
