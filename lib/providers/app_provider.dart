import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/student.dart';
import '../models/building.dart';
import '../models/room.dart';
import '../models/payment.dart';
import '../models/fee_structure.dart';
import '../database/database_helper.dart';

class AppProvider extends ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final Uuid _uuid = const Uuid();

  // State variables
  List<Student> _students = [];
  List<Building> _buildings = [];
  List<Room> _rooms = [];
  List<Payment> _payments = [];
  List<FeeStructure> _feeStructures = [];
  bool _isLoading = false;
  String _searchQuery = '';

  // Getters
  List<Student> get students => _students;
  List<Building> get buildings => _buildings;
  List<Room> get rooms => _rooms;
  List<Payment> get payments => _payments;
  List<FeeStructure> get feeStructures => _feeStructures;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  // Filtered getters
  List<Student> get activeStudents => _students.where((s) => s.isActive).toList();
  List<Student> get filteredStudents {
    if (_searchQuery.isEmpty) return _students;
    return _students.where((student) =>
        student.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        student.phone.contains(_searchQuery)).toList();
  }

  List<Payment> get unpaidPayments => _payments.where((p) => p.status == PaymentStatus.unpaid).toList();
  List<Payment> get overduePayments => _payments.where((p) => p.isOverdue).toList();

  // Initialize data
  Future<void> loadData() async {
    _setLoading(true);
    try {
      await Future.wait([
        _loadBuildings(),
        _loadRooms(),
        _loadStudents(),
        _loadPayments(),
        _loadFeeStructures(),
      ]);
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Building operations
  Future<void> _loadBuildings() async {
    _buildings = await _databaseHelper.getAllBuildings();
  }

  Future<void> addBuilding(String name, String? address) async {
    final building = Building(
      id: _uuid.v4(),
      name: name,
      address: address,
    );
    
    await _databaseHelper.insertBuilding(building);
    _buildings.add(building);
    notifyListeners();
  }

  Future<void> updateBuilding(Building building) async {
    await _databaseHelper.updateBuilding(building);
    final index = _buildings.indexWhere((b) => b.id == building.id);
    if (index != -1) {
      _buildings[index] = building;
      notifyListeners();
    }
  }

  Future<void> deleteBuilding(String id) async {
    await _databaseHelper.deleteBuilding(id);
    _buildings.removeWhere((b) => b.id == id);
    // Also remove associated rooms
    _rooms.removeWhere((r) => r.buildingId == id);
    notifyListeners();
  }

  // Room operations
  Future<void> _loadRooms() async {
    _rooms = await _databaseHelper.getAllRooms();
  }

  Future<void> addRoom(String number, String buildingId, int capacity) async {
    final room = Room(
      id: _uuid.v4(),
      number: number,
      buildingId: buildingId,
      capacity: capacity,
    );
    
    await _databaseHelper.insertRoom(room);
    _rooms.add(room);
    notifyListeners();
  }

  Future<void> updateRoom(Room room) async {
    await _databaseHelper.updateRoom(room);
    final index = _rooms.indexWhere((r) => r.id == room.id);
    if (index != -1) {
      _rooms[index] = room;
      notifyListeners();
    }
  }

  Future<void> deleteRoom(String id) async {
    await _databaseHelper.deleteRoom(id);
    _rooms.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  List<Room> getRoomsByBuilding(String buildingId) {
    return _rooms.where((room) => room.buildingId == buildingId).toList();
  }

  // Student operations
  Future<void> _loadStudents() async {
    _students = await _databaseHelper.getAllStudents();
  }

  Future<void> addStudent(String name, String phone, String? email, String roomId) async {
    final student = Student(
      id: _uuid.v4(),
      name: name,
      phone: phone,
      email: email,
      joinDate: DateTime.now(),
      roomId: roomId,
    );
    
    await _databaseHelper.insertStudent(student);
    _students.add(student);
    
    // Update room occupancy
    await _loadRooms();
    notifyListeners();
  }

  Future<void> updateStudent(Student student) async {
    await _databaseHelper.updateStudent(student);
    final index = _students.indexWhere((s) => s.id == student.id);
    if (index != -1) {
      _students[index] = student;
      // Update room occupancy
      await _loadRooms();
      notifyListeners();
    }
  }

  Future<void> deleteStudent(String id) async {
    await _databaseHelper.deleteStudent(id);
    _students.removeWhere((s) => s.id == id);
    // Remove associated payments
    _payments.removeWhere((p) => p.studentId == id);
    // Update room occupancy
    await _loadRooms();
    notifyListeners();
  }

  Future<void> toggleStudentStatus(String id) async {
    final student = _students.firstWhere((s) => s.id == id);
    final updatedStudent = student.copyWith(isActive: !student.isActive);
    await updateStudent(updatedStudent);
  }

  Student? getStudentById(String id) {
    try {
      return _students.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  // Payment operations
  Future<void> _loadPayments() async {
    _payments = await _databaseHelper.getAllPayments();
  }

  Future<void> addPayment(String studentId, double amount, DateTime dueDate, String? note) async {
    final payment = Payment(
      id: _uuid.v4(),
      studentId: studentId,
      amount: amount,
      dueDate: dueDate,
      status: PaymentStatus.unpaid,
      note: note,
    );
    
    await _databaseHelper.insertPayment(payment);
    _payments.add(payment);
    notifyListeners();
  }

  Future<void> markPaymentAsPaid(String paymentId) async {
    final payment = _payments.firstWhere((p) => p.id == paymentId);
    final updatedPayment = payment.copyWith(
      status: PaymentStatus.paid,
      paidDate: DateTime.now(),
    );
    
    await _databaseHelper.updatePayment(updatedPayment);
    final index = _payments.indexWhere((p) => p.id == paymentId);
    if (index != -1) {
      _payments[index] = updatedPayment;
      notifyListeners();
    }
  }

  Future<void> markPaymentAsUnpaid(String paymentId) async {
    final payment = _payments.firstWhere((p) => p.id == paymentId);
    final updatedPayment = payment.copyWith(
      status: PaymentStatus.unpaid,
      paidDate: null,
    );
    
    await _databaseHelper.updatePayment(updatedPayment);
    final index = _payments.indexWhere((p) => p.id == paymentId);
    if (index != -1) {
      _payments[index] = updatedPayment;
      notifyListeners();
    }
  }

  Future<void> updatePayment(Payment payment) async {
    await _databaseHelper.updatePayment(payment);
    final index = _payments.indexWhere((p) => p.id == payment.id);
    if (index != -1) {
      _payments[index] = payment;
      notifyListeners();
    }
  }

  Future<void> deletePayment(String id) async {
    await _databaseHelper.deletePayment(id);
    _payments.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  List<Payment> getPaymentsByStudent(String studentId) {
    return _payments.where((payment) => payment.studentId == studentId).toList();
  }

  // Fee structure operations
  Future<void> _loadFeeStructures() async {
    _feeStructures = await _databaseHelper.getAllFeeStructures();
  }

  Future<void> addFeeStructure(String? buildingId, double amount, FeeRecurrence recurrence) async {
    final feeStructure = FeeStructure(
      id: _uuid.v4(),
      buildingId: buildingId,
      amount: amount,
      recurrence: recurrence,
      startDate: DateTime.now(),
    );
    
    await _databaseHelper.insertFeeStructure(feeStructure);
    _feeStructures.add(feeStructure);
    notifyListeners();
  }

  Future<void> updateFeeStructure(FeeStructure feeStructure) async {
    await _databaseHelper.updateFeeStructure(feeStructure);
    final index = _feeStructures.indexWhere((f) => f.id == feeStructure.id);
    if (index != -1) {
      _feeStructures[index] = feeStructure;
      notifyListeners();
    }
  }

  Future<void> deleteFeeStructure(String id) async {
    await _databaseHelper.deleteFeeStructure(id);
    _feeStructures.removeWhere((f) => f.id == id);
    notifyListeners();
  }

  FeeStructure? getFeeStructureByBuilding(String buildingId) {
    try {
      return _feeStructures.firstWhere((f) => f.buildingId == buildingId);
    } catch (e) {
      return null;
    }
  }

  // Utility methods
  Building? getBuildingById(String id) {
    try {
      return _buildings.firstWhere((b) => b.id == id);
    } catch (e) {
      return null;
    }
  }

  Room? getRoomById(String id) {
    try {
      return _rooms.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  String getBuildingNameByRoomId(String roomId) {
    final room = getRoomById(roomId);
    if (room != null) {
      final building = getBuildingById(room.buildingId);
      return building?.name ?? 'Unknown Building';
    }
    return 'Unknown Building';
  }

  // Generate recurring payments
  Future<void> generateRecurringPayments() async {
    for (final student in activeStudents) {
      final room = getRoomById(student.roomId);
      if (room != null) {
        final feeStructure = getFeeStructureByBuilding(room.buildingId);
        if (feeStructure != null) {
          final lastPayment = getPaymentsByStudent(student.id)
              .where((p) => p.status == PaymentStatus.paid)
              .fold<Payment?>(null, (prev, curr) => 
                  prev == null || curr.dueDate.isAfter(prev.dueDate) ? curr : prev);
          
          final lastDueDate = lastPayment?.dueDate ?? student.joinDate;
          final nextDueDate = feeStructure.getNextDueDate(lastDueDate);
          
          // Only create payment if it doesn't exist and is not too far in the future
          final existingPayment = _payments.any((p) => 
              p.studentId == student.id && 
              p.dueDate.year == nextDueDate.year &&
              p.dueDate.month == nextDueDate.month);
          
          if (!existingPayment && nextDueDate.isBefore(DateTime.now().add(const Duration(days: 30)))) {
            await addPayment(student.id, feeStructure.amount, nextDueDate, 'Auto-generated payment');
          }
        }
      }
    }
  }

  // Summary data
  Map<String, dynamic> getSummaryData() {
    final totalStudents = _students.length;
    final activeStudentsCount = activeStudents.length;
    final totalUnpaidAmount = unpaidPayments.fold<double>(0, (sum, payment) => sum + payment.amount);
    final overdueCount = overduePayments.length;
    
    return {
      'totalStudents': totalStudents,
      'activeStudents': activeStudentsCount,
      'totalUnpaidAmount': totalUnpaidAmount,
      'overdueCount': overdueCount,
      'totalBuildings': _buildings.length,
      'totalRooms': _rooms.length,
    };
  }
}