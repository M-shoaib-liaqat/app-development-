import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDbHelper {
  static Database? _db;

  static Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  static Future<Database> initDb() async {
    final dbPath = await getDatabasesPath();
    return await openDatabase(
      join(dbPath, 'local_events.db'),
      version: 2, // bump version when adding columns
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE events(
            id TEXT PRIMARY KEY,
            organizer TEXT,
            event_name TEXT,
            venue TEXT,
            description TEXT,
            date TEXT,
            time TEXT,
            created_at TEXT,
            createdByRole TEXT,
            approved TEXT,
            status TEXT,
            synced INTEGER
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute("ALTER TABLE events ADD COLUMN time TEXT");
          await db.execute("ALTER TABLE events ADD COLUMN created_at TEXT");
          await db.execute("ALTER TABLE events ADD COLUMN createdByRole TEXT");
          await db.execute("ALTER TABLE events ADD COLUMN approved TEXT");
          await db.execute("ALTER TABLE events ADD COLUMN status TEXT");
        }
      },
    );
  }

  static Future<void> insertEvent(Map<String, dynamic> event) async {
    final database = await db;

    // Only insert keys that match the table columns
    final validKeys = [
      'id',
      'organizer',
      'event_name',
      'venue',
      'description',
      'date',
      'time',
      'created_at',
      'createdByRole',
      'approved',
      'status',
      'synced'
    ];

    final filteredEvent = {
      for (var key in event.keys)
        if (validKeys.contains(key)) key: event[key]
    };

    await database.insert(
      'events',
      filteredEvent,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Map<String, dynamic>>> getUnsyncedEvents() async {
    final database = await db;
    return await database.query('events', where: 'synced = ?', whereArgs: [0]);
  }

  static Future<void> markEventSynced(String id) async {
    final database = await db;
    await database.update('events', {'synced': 1}, where: 'id = ?', whereArgs: [id]);
  }
}
