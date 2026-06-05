import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/models.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'internship_system.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT UNIQUE,
        role TEXT,
        password TEXT,
        bio TEXT,
        skills TEXT,
        education TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE supervisors (
        id INTEGER PRIMARY KEY,
        name TEXT,
        email TEXT UNIQUE,
        department TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE activities (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id INTEGER,
        title TEXT,
        description TEXT,
        status TEXT,
        date TEXT,
        feedback TEXT,
        FOREIGN KEY (student_id) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE student_supervisor_link (
        student_id INTEGER PRIMARY KEY,
        supervisor_id INTEGER,
        FOREIGN KEY (student_id) REFERENCES users (id),
        FOREIGN KEY (supervisor_id) REFERENCES supervisors (id)
      )
    ''');

    // Pre-populate verified supervisors
    await _prePopulateSupervisors(db);
  }

  Future<void> _prePopulateSupervisors(Database db) async {
    List<Map<String, dynamic>> supervisors = [
      {'id': 101, 'name': 'Dr. Sarah Connor', 'email': 's.connor@university.edu', 'department': 'Computer Science'},
      {'id': 102, 'name': 'Prof. Charles Xavier', 'email': 'c.xavier@university.edu', 'department': 'Software Engineering'},
      {'id': 103, 'name': 'Dr. Bruce Banner', 'email': 'b.banner@university.edu', 'department': 'Data Science'},
      {'id': 104, 'name': 'Dr. Reed Richards', 'email': 'r.richards@university.edu', 'department': 'Cybersecurity'},
    ];

    for (var supervisor in supervisors) {
      await db.insert('supervisors', supervisor);
    }
  }

  // User methods
  Future<int> registerUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> loginUser(String email, String password) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (results.isNotEmpty) {
      return User.fromMap(results.first);
    }
    return null;
  }

  // Supervisor methods
  Future<List<Supervisor>> getSupervisors() async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query('supervisors');
    return results.map((m) => Supervisor.fromMap(m)).toList();
  }

  Future<void> linkStudentToSupervisor(int studentId, int supervisorId) async {
    final db = await database;
    await db.insert(
      'student_supervisor_link',
      {'student_id': studentId, 'supervisor_id': supervisorId},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Supervisor?> getAssignedSupervisor(int studentId) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT s.* FROM supervisors s
      JOIN student_supervisor_link l ON s.id = l.supervisor_id
      WHERE l.student_id = ?
    ''', [studentId]);
    if (results.isNotEmpty) {
      return Supervisor.fromMap(results.first);
    }
    return null;
  }

  // Activity methods
  Future<int> addActivity(Activity activity) async {
    final db = await database;
    return await db.insert('activities', activity.toMap());
  }

  Future<List<Activity>> getStudentActivities(int studentId) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'activities',
      where: 'student_id = ?',
      whereArgs: [studentId],
      orderBy: 'date DESC',
    );
    return results.map((m) => Activity.fromMap(m)).toList();
  }

  Future<List<User>> getAssignedStudents(int supervisorId) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT u.* FROM users u
      JOIN student_supervisor_link l ON u.id = l.student_id
      WHERE l.supervisor_id = ?
    ''', [supervisorId]);
    return results.map((m) => User.fromMap(m)).toList();
  }

  Future<void> updateActivityStatus(int activityId, String status, String feedback) async {
    final db = await database;
    await db.update(
      'activities',
      {'status': status, 'feedback': feedback},
      where: 'id = ?',
      whereArgs: [activityId],
    );
  }
}
