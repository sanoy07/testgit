import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../providers/app_provider.dart';
import '../models/student.dart';
import 'payment_calendar_widget.dart';

class StudentsWidget extends StatelessWidget {
  const StudentsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        if (appProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final students = appProvider.filteredStudents;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFFF8F9FF),
                Colors.white.withOpacity(0.8),
              ],
            ),
          ),
          child: Column(
            children: [
              // Modern Search and Filter Bar
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search students...',
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: Colors.grey.shade500,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                          ),
                          onChanged: (value) => appProvider.setSearchQuery(value),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: PopupMenuButton<String>(
                        icon: Icon(
                          Icons.filter_list_rounded,
                          color: Colors.grey.shade600,
                        ),
                        onSelected: (value) => _handleFilter(context, appProvider, value),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'all',
                            child: Text('All Students'),
                          ),
                          const PopupMenuItem(
                            value: 'active',
                            child: Text('Active Only'),
                          ),
                          const PopupMenuItem(
                            value: 'inactive',
                            child: Text('Inactive Only'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Students List with Payment Calendar
              Expanded(
                child: students.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Icon(
                                Icons.people_outline_rounded,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'No students found',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add students to get started',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : AnimationLimiter(
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 20),
                          itemCount: students.length,
                          itemBuilder: (context, index) {
                            final student = students[index];
                            final payments = appProvider.getPaymentsByStudent(student.id);
                            
                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 600),
                              child: SlideAnimation(
                                verticalOffset: 50.0,
                                child: FadeInAnimation(
                                  child: PaymentCalendarWidget(
                                    student: student,
                                    payments: payments,
                                    onTap: () => _showStudentDetails(context, appProvider, student),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStudentCard(BuildContext context, AppProvider appProvider, Student student) {
    final room = appProvider.getRoomById(student.roomId);
    final building = room != null ? appProvider.getBuildingById(room.buildingId) : null;
    final payments = appProvider.getPaymentsByStudent(student.id);
    final unpaidPayments = payments.where((p) => !p.isPaid).toList();
    final overduePayments = payments.where((p) => p.isOverdue).toList();

    return Slidable(
      key: ValueKey(student.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => _editStudent(context, appProvider, student),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
          ),
          SlidableAction(
            onPressed: (context) => _toggleStudentStatus(context, appProvider, student),
            backgroundColor: student.isActive ? Colors.orange : Colors.green,
            foregroundColor: Colors.white,
            icon: student.isActive ? Icons.pause : Icons.play_arrow,
            label: student.isActive ? 'Deactivate' : 'Activate',
          ),
          SlidableAction(
            onPressed: (context) => _deleteStudent(context, appProvider, student),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: student.isActive ? Colors.green : Colors.grey,
            child: Text(
              student.name.isNotEmpty ? student.name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            student.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: student.isActive ? Colors.black : Colors.grey,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('📞 ${student.phone}'),
              if (student.email != null) Text('✉️ ${student.email}'),
              Text('🏢 ${building?.name ?? 'Unknown'} - Room ${room?.number ?? 'Unknown'}'),
              Text('📅 Joined: ${DateFormat('MMM dd, yyyy').format(student.joinDate)}'),
              if (unpaidPayments.isNotEmpty)
                Text(
                  '💰 ${unpaidPayments.length} unpaid payment(s)',
                  style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                ),
              if (overduePayments.isNotEmpty)
                Text(
                  '⚠️ ${overduePayments.length} overdue payment(s)',
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: student.isActive ? Colors.green : Colors.grey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  student.isActive ? 'Active' : 'Inactive',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Icon(Icons.chevron_right),
            ],
          ),
          onTap: () => _showStudentDetails(context, appProvider, student),
        ),
      ),
    );
  }

  void _handleFilter(BuildContext context, AppProvider appProvider, String filter) {
    // This would require additional filtering logic in the provider
    // For now, we'll just show a message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Filter: $filter')),
    );
  }

  void _showStudentDetails(BuildContext context, AppProvider appProvider, Student student) {
    final room = appProvider.getRoomById(student.roomId);
    final building = room != null ? appProvider.getBuildingById(room.buildingId) : null;
    final payments = appProvider.getPaymentsByStudent(student.id);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(student.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Phone', student.phone),
              if (student.email != null) _buildDetailRow('Email', student.email!),
              _buildDetailRow('Building', building?.name ?? 'Unknown'),
              _buildDetailRow('Room', room?.number ?? 'Unknown'),
              _buildDetailRow('Join Date', DateFormat('MMM dd, yyyy').format(student.joinDate)),
              _buildDetailRow('Status', student.isActive ? 'Active' : 'Inactive'),
              const SizedBox(height: 16),
              const Text(
                'Payment History',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (payments.isEmpty)
                const Text('No payments recorded')
              else
                ...payments.take(5).map((payment) => ListTile(
                      leading: Icon(
                        payment.isPaid ? Icons.check_circle : Icons.pending,
                        color: payment.isPaid ? Colors.green : Colors.orange,
                      ),
                      title: Text('₹${NumberFormat('#,##0').format(payment.amount)}'),
                      subtitle: Text(
                        'Due: ${DateFormat('MMM dd, yyyy').format(payment.dueDate)}',
                      ),
                      trailing: payment.isPaid
                          ? Text(
                              'Paid: ${DateFormat('MMM dd').format(payment.paidDate!)}',
                              style: const TextStyle(color: Colors.green),
                            )
                          : Text(
                              payment.isOverdue ? 'Overdue' : 'Pending',
                              style: TextStyle(
                                color: payment.isOverdue ? Colors.red : Colors.orange,
                              ),
                            ),
                    )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _editStudent(context, appProvider, student);
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _editStudent(BuildContext context, AppProvider appProvider, Student student) {
    final nameController = TextEditingController(text: student.name);
    final phoneController = TextEditingController(text: student.phone);
    final emailController = TextEditingController(text: student.email ?? '');
    String? selectedRoomId = student.roomId;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Student'),
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
                final updatedStudent = student.copyWith(
                  name: nameController.text,
                  phone: phoneController.text,
                  email: emailController.text.isEmpty ? null : emailController.text,
                  roomId: selectedRoomId,
                );
                await appProvider.updateStudent(updatedStudent);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Student updated successfully')),
                  );
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _toggleStudentStatus(BuildContext context, AppProvider appProvider, Student student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${student.isActive ? 'Deactivate' : 'Activate'} Student'),
        content: Text(
          'Are you sure you want to ${student.isActive ? 'deactivate' : 'activate'} ${student.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await appProvider.toggleStudentStatus(student.id);
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Student ${student.isActive ? 'deactivated' : 'activated'} successfully',
                    ),
                  ),
                );
              }
            },
            child: Text(student.isActive ? 'Deactivate' : 'Activate'),
          ),
        ],
      ),
    );
  }

  void _deleteStudent(BuildContext context, AppProvider appProvider, Student student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student'),
        content: Text('Are you sure you want to delete ${student.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await appProvider.deleteStudent(student.id);
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Student deleted successfully')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}