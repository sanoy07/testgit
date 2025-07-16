import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/student.dart';
import '../models/building.dart';
import '../models/room.dart';
import '../models/payment.dart';
import '../models/fee_structure.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'hostel_payment_tracker.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // Buildings table
    await db.execute('''
      CREATE TABLE buildings (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        address TEXT
      )
    ''');

    // Rooms table
    await db.execute('''
      CREATE TABLE rooms (
        id TEXT PRIMARY KEY,
        number TEXT NOT NULL,
        buildingId TEXT NOT NULL,
        capacity INTEGER NOT NULL,
        currentOccupancy INTEGER DEFAULT 0,
        FOREIGN KEY (buildingId) REFERENCES buildings (id)
      )
    ''');

    // Students table
    await db.execute('''
      CREATE TABLE students (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT,
        joinDate TEXT NOT NULL,
        roomId TEXT NOT NULL,
        isActive INTEGER DEFAULT 1,
        FOREIGN KEY (roomId) REFERENCES rooms (id)
      )
    ''');

    // Payments table
    await db.execute('''
      CREATE TABLE payments (
        id TEXT PRIMARY KEY,
        studentId TEXT NOT NULL,
        amount REAL NOT NULL,
        dueDate TEXT NOT NULL,
        paidDate TEXT,
        status TEXT NOT NULL,
        note TEXT,
        FOREIGN KEY (studentId) REFERENCES students (id)
      )
    ''');

    // Fee structures table
    await db.execute('''
      CREATE TABLE fee_structures (
        id TEXT PRIMARY KEY,
        buildingId TEXT,
        amount REAL NOT NULL,
        recurrence TEXT NOT NULL,
        startDate TEXT NOT NULL,
        FOREIGN KEY (buildingId) REFERENCES buildings (id)
      )
    ''');
  }

  // Building operations
  Future<void> insertBuilding(Building building) async {
    final db = await database;
    await db.insert('buildings', building.toMap());
  }

  Future<List<Building>> getAllBuildings() async {
    final db = await database;
    final maps = await db.query('buildings');
    return maps.map((map) => Building.fromMap(map)).toList();
  }

  Future<void> updateBuilding(Building building) async {
    final db = await database;
    await db.update(
      'buildings',
      building.toMap(),
      where: 'id = ?',
      whereArgs: [building.id],
    );
  }

  Future<void> deleteBuilding(String id) async {
    final db = await database;
    await db.delete('buildings', where: 'id = ?', whereArgs: [id]);
  }

  // Room operations
  Future<void> insertRoom(Room room) async {
    final db = await database;
    await db.insert('rooms', room.toMap());
  }

  Future<List<Room>> getAllRooms() async {
    final db = await database;
    final maps = await db.query('rooms');
    return maps.map((map) => Room.fromMap(map)).toList();
  }

  Future<List<Room>> getRoomsByBuilding(String buildingId) async {
    final db = await database;
    final maps = await db.query(
      'rooms',
      where: 'buildingId = ?',
      whereArgs: [buildingId],
    );
    return maps.map((map) => Room.fromMap(map)).toList();
  }

  Future<void> updateRoom(Room room) async {
    final db = await database;
    await db.update(
      'rooms',
      room.toMap(),
      where: 'id = ?',
      whereArgs: [room.id],
    );
  }

  Future<void> deleteRoom(String id) async {
    final db = await database;
    await db.delete('rooms', where: 'id = ?', whereArgs: [id]);
  }

  // Student operations
  Future<void> insertStudent(Student student) async {
    final db = await database;
    await db.insert('students', student.toMap());
    
    // Update room occupancy
    await _updateRoomOccupancy(student.roomId);
  }

  Future<List<Student>> getAllStudents() async {
    final db = await database;
    final maps = await db.query('students');
    return maps.map((map) => Student.fromMap(map)).toList();
  }

  Future<List<Student>> getActiveStudents() async {
    final db = await database;
    final maps = await db.query(
      'students',
      where: 'isActive = ?',
      whereArgs: [1],
    );
    return maps.map((map) => Student.fromMap(map)).toList();
  }

  Future<List<Student>> getStudentsByRoom(String roomId) async {
    final db = await database;
    final maps = await db.query(
      'students',
      where: 'roomId = ?',
      whereArgs: [roomId],
    );
    return maps.map((map) => Student.fromMap(map)).toList();
  }

  Future<void> updateStudent(Student student) async {
    final db = await database;
    await db.update(
      'students',
      student.toMap(),
      where: 'id = ?',
      whereArgs: [student.id],
    );
    
    // Update room occupancy
    await _updateRoomOccupancy(student.roomId);
  }

  Future<void> deleteStudent(String id) async {
    final db = await database;
    
    // Get student's room before deletion
    final studentMaps = await db.query(
      'students',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (studentMaps.isNotEmpty) {
      final roomId = studentMaps.first['roomId'] as String;
      await db.delete('students', where: 'id = ?', whereArgs: [id]);
      await _updateRoomOccupancy(roomId);
    }
  }

  Future<void> _updateRoomOccupancy(String roomId) async {
    final db = await database;
    final count = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM students WHERE roomId = ? AND isActive = 1',
      [roomId],
    )) ?? 0;
    
    await db.update(
      'rooms',
      {'currentOccupancy': count},
      where: 'id = ?',
      whereArgs: [roomId],
    );
  }

  // Payment operations
  Future<void> insertPayment(Payment payment) async {
    final db = await database;
    await db.insert('payments', payment.toMap());
  }

  Future<List<Payment>> getAllPayments() async {
    final db = await database;
    final maps = await db.query('payments');
    return maps.map((map) => Payment.fromMap(map)).toList();
  }

  Future<List<Payment>> getPaymentsByStudent(String studentId) async {
    final db = await database;
    final maps = await db.query(
      'payments',
      where: 'studentId = ?',
      whereArgs: [studentId],
    );
    return maps.map((map) => Payment.fromMap(map)).toList();
  }

  Future<List<Payment>> getUnpaidPayments() async {
    final db = await database;
    final maps = await db.query(
      'payments',
      where: 'status = ?',
      whereArgs: ['unpaid'],
    );
    return maps.map((map) => Payment.fromMap(map)).toList();
  }

  Future<List<Payment>> getOverduePayments() async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    final maps = await db.query(
      'payments',
      where: 'status = ? AND dueDate < ?',
      whereArgs: ['unpaid', now],
    );
    return maps.map((map) => Payment.fromMap(map)).toList();
  }

  Future<void> updatePayment(Payment payment) async {
    final db = await database;
    await db.update(
      'payments',
      payment.toMap(),
      where: 'id = ?',
      whereArgs: [payment.id],
    );
  }

  Future<void> deletePayment(String id) async {
    final db = await database;
    await db.delete('payments', where: 'id = ?', whereArgs: [id]);
  }

  // Fee structure operations
  Future<void> insertFeeStructure(FeeStructure feeStructure) async {
    final db = await database;
    await db.insert('fee_structures', feeStructure.toMap());
  }

  Future<List<FeeStructure>> getAllFeeStructures() async {
    final db = await database;
    final maps = await db.query('fee_structures');
    return maps.map((map) => FeeStructure.fromMap(map)).toList();
  }

  Future<FeeStructure?> getFeeStructureByBuilding(String buildingId) async {
    final db = await database;
    final maps = await db.query(
      'fee_structures',
      where: 'buildingId = ?',
      whereArgs: [buildingId],
    );
    return maps.isNotEmpty ? FeeStructure.fromMap(maps.first) : null;
  }

  Future<void> updateFeeStructure(FeeStructure feeStructure) async {
    final db = await database;
    await db.update(
      'fee_structures',
      feeStructure.toMap(),
      where: 'id = ?',
      whereArgs: [feeStructure.id],
    );
  }

  Future<void> deleteFeeStructure(String id) async {
    final db = await database;
    await db.delete('fee_structures', where: 'id = ?', whereArgs: [id]);
  }

  // Search operations
  Future<List<Student>> searchStudents(String query) async {
    final db = await database;
    final maps = await db.query(
      'students',
      where: 'name LIKE ? OR phone LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return maps.map((map) => Student.fromMap(map)).toList();
  }

  // Reporting operations
  Future<Map<String, dynamic>> getPaymentSummary() async {
    final db = await database;
    
    final totalPaid = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT SUM(amount) FROM payments WHERE status = ?',
      ['paid'],
    )) ?? 0;
    
    final totalUnpaid = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT SUM(amount) FROM payments WHERE status = ?',
      ['unpaid'],
    )) ?? 0;
    
    final overdueCount = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM payments WHERE status = ? AND dueDate < ?',
      ['unpaid', DateTime.now().toIso8601String()],
    )) ?? 0;
    
    return {
      'totalPaid': totalPaid,
      'totalUnpaid': totalUnpaid,
      'overdueCount': overdueCount,
    };
  }

  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
  }
}