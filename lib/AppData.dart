import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppData
{
  //Singleton

  static final AppData _appData = AppData._internal();

  AppData._internal();

  factory AppData(){
    return _appData;
  }
  var path ="";
  Future<Database>getDatabaseInstance() async {
    path = join(await getDatabasesPath(), 'task_database.db');
    final database = openDatabase(

    join(await getDatabasesPath(), 'task_database.db'),

  onCreate: (db, version) {
   db.execute(
  'CREATE TABLE locations (id TEXT PRIMARY KEY,latitude DOUBLE,longitude DOUBLE )',
  );
   db.execute("CREATE TABLE DeviceProfile (setting_id TEXT PRIMARY KEY,id INTEGER,themeColor TEXT,textSize DOUBLE,FOREIGN KEY (id) REFERENCES locations(id))");
  },version: 1
    );
     var db = await database;
     var ans = await db.query('locations');
   //  await db.insert('locations', {"id":1,"latitude":123.40,"longitude":12300.021},conflictAlgorithm: ConflictAlgorithm.replace,);
   //  await db.insert('DeviceProfile', {"setting_id":1,"id":1,"themeColor":"123.40","textSize":12},conflictAlgorithm: ConflictAlgorithm.replace,);
     print(ans);
    return database;
  }

}
