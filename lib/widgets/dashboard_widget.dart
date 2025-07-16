import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/payment.dart';

class DashboardWidget extends StatelessWidget {
  const DashboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        if (appProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final summaryData = appProvider.getSummaryData();
        final overduePayments = appProvider.overduePayments;
        final recentPayments = appProvider.payments
            .where((p) => p.status == PaymentStatus.paid)
            .take(5)
            .toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Cards
              _buildSummaryCards(summaryData),
              const SizedBox(height: 24),
              
              // Quick Actions
              _buildQuickActions(context, appProvider),
              const SizedBox(height: 24),
              
              // Overdue Payments
              if (overduePayments.isNotEmpty) ...[
                _buildOverduePayments(context, appProvider, overduePayments),
                const SizedBox(height: 24),
              ],
              
              // Recent Payments
              _buildRecentPayments(context, appProvider, recentPayments),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCards(Map<String, dynamic> summaryData) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildSummaryCard(
          title: 'Total Students',
          value: summaryData['totalStudents'].toString(),
          icon: Icons.people,
          color: Colors.blue,
        ),
        _buildSummaryCard(
          title: 'Active Students',
          value: summaryData['activeStudents'].toString(),
          icon: Icons.person_check,
          color: Colors.green,
        ),
        _buildSummaryCard(
          title: 'Unpaid Amount',
          value: '₹${NumberFormat('#,##0').format(summaryData['totalUnpaidAmount'])}',
          icon: Icons.money_off,
          color: Colors.orange,
        ),
        _buildSummaryCard(
          title: 'Overdue',
          value: summaryData['overdueCount'].toString(),
          icon: Icons.warning,
          color: Colors.red,
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AppProvider appProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  context,
                  icon: Icons.person_add,
                  label: 'Add Student',
                  onPressed: () => _showAddStudentDialog(context, appProvider),
                ),
                _buildActionButton(
                  context,
                  icon: Icons.payment,
                  label: 'Add Payment',
                  onPressed: () => _showAddPaymentDialog(context, appProvider),
                ),
                _buildActionButton(
                  context,
                  icon: Icons.apartment,
                  label: 'Add Building',
                  onPressed: () => _showAddBuildingDialog(context, appProvider),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
          ),
          child: Icon(icon, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildOverduePayments(
    BuildContext context,
    AppProvider appProvider,
    List<Payment> overduePayments,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning, color: Colors.red),
                const SizedBox(width: 8),
                const Text(
                  'Overdue Payments',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${overduePayments.length} overdue',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: overduePayments.take(3).length,
              itemBuilder: (context, index) {
                final payment = overduePayments[index];
                final student = appProvider.getStudentById(payment.studentId);
                
                return ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.red,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(student?.name ?? 'Unknown Student'),
                  subtitle: Text(
                    'Due: ${DateFormat('MMM dd, yyyy').format(payment.dueDate)}',
                  ),
                  trailing: Text(
                    '₹${NumberFormat('#,##0').format(payment.amount)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  onTap: () => _markPaymentAsPaid(context, appProvider, payment),
                );
              },
            ),
            if (overduePayments.length > 3)
              TextButton(
                onPressed: () {
                  // Navigate to payments page with overdue filter
                },
                child: Text('View all ${overduePayments.length} overdue payments'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentPayments(
    BuildContext context,
    AppProvider appProvider,
    List<Payment> recentPayments,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Payments',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (recentPayments.isEmpty)
              const Center(
                child: Text(
                  'No recent payments',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentPayments.length,
                itemBuilder: (context, index) {
                  final payment = recentPayments[index];
                  final student = appProvider.getStudentById(payment.studentId);
                  
                  return ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Icon(Icons.check, color: Colors.white),
                    ),
                    title: Text(student?.name ?? 'Unknown Student'),
                    subtitle: Text(
                      'Paid: ${DateFormat('MMM dd, yyyy').format(payment.paidDate!)}',
                    ),
                    trailing: Text(
                      '₹${NumberFormat('#,##0').format(payment.amount)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showAddStudentDialog(BuildContext context, AppProvider appProvider) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    String? selectedRoomId;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Student'),
        content: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email (Optional)'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRoomId,
                  decoration: const InputDecoration(labelText: 'Room'),
                  items: appProvider.rooms.map((room) {
                    final building = appProvider.getBuildingById(room.buildingId);
                    return DropdownMenuItem(
                      value: room.id,
                      child: Text('${building?.name ?? 'Unknown'} - Room ${room.number}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedRoomId = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty &&
                  phoneController.text.isNotEmpty &&
                  selectedRoomId != null) {
                await appProvider.addStudent(
                  nameController.text,
                  phoneController.text,
                  emailController.text.isEmpty ? null : emailController.text,
                  selectedRoomId!,
                );
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Student added successfully')),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddPaymentDialog(BuildContext context, AppProvider appProvider) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    String? selectedStudentId;
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Payment'),
        content: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedStudentId,
                  decoration: const InputDecoration(labelText: 'Student'),
                  items: appProvider.activeStudents.map((student) {
                    return DropdownMenuItem(
                      value: student.id,
                      child: Text(student.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedStudentId = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(labelText: 'Amount'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Due Date'),
                  subtitle: Text(DateFormat('MMM dd, yyyy').format(selectedDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        selectedDate = date;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(labelText: 'Note (Optional)'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (selectedStudentId != null && amountController.text.isNotEmpty) {
                await appProvider.addPayment(
                  selectedStudentId!,
                  double.parse(amountController.text),
                  selectedDate,
                  noteController.text.isEmpty ? null : noteController.text,
                );
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Payment added successfully')),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddBuildingDialog(BuildContext context, AppProvider appProvider) {
    final nameController = TextEditingController();
    final addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Building'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Building Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: 'Address (Optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                await appProvider.addBuilding(
                  nameController.text,
                  addressController.text.isEmpty ? null : addressController.text,
                );
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Building added successfully')),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _markPaymentAsPaid(BuildContext context, AppProvider appProvider, Payment payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Paid'),
        content: Text('Mark this payment of ₹${NumberFormat('#,##0').format(payment.amount)} as paid?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await appProvider.markPaymentAsPaid(payment.id);
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Payment marked as paid')),
                );
              }
            },
            child: const Text('Mark Paid'),
          ),
        ],
      ),
    );
  }
}