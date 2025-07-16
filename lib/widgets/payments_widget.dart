import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../providers/app_provider.dart';
import '../models/payment.dart';

class PaymentsWidget extends StatefulWidget {
  const PaymentsWidget({super.key});

  @override
  State<PaymentsWidget> createState() => _PaymentsWidgetState();
}

class _PaymentsWidgetState extends State<PaymentsWidget> {
  String _selectedFilter = 'all';
  String _sortBy = 'dueDate';
  bool _sortAscending = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        if (appProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        List<Payment> payments = _getFilteredPayments(appProvider);
        payments = _getSortedPayments(payments, appProvider);

        return Column(
          children: [
            // Filter and Sort Controls
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Filter Dropdown
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedFilter,
                      decoration: const InputDecoration(
                        labelText: 'Filter',
                        prefixIcon: Icon(Icons.filter_list),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All Payments')),
                        DropdownMenuItem(value: 'paid', child: Text('Paid')),
                        DropdownMenuItem(value: 'unpaid', child: Text('Unpaid')),
                        DropdownMenuItem(value: 'overdue', child: Text('Overdue')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedFilter = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Sort Dropdown
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _sortBy,
                      decoration: const InputDecoration(
                        labelText: 'Sort by',
                        prefixIcon: Icon(Icons.sort),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'dueDate', child: Text('Due Date')),
                        DropdownMenuItem(value: 'amount', child: Text('Amount')),
                        DropdownMenuItem(value: 'student', child: Text('Student')),
                        DropdownMenuItem(value: 'status', child: Text('Status')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _sortBy = value!;
                        });
                      },
                    ),
                  ),
                  
                  // Sort Direction Button
                  IconButton(
                    icon: Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
                    onPressed: () {
                      setState(() {
                        _sortAscending = !_sortAscending;
                      });
                    },
                  ),
                ],
              ),
            ),
            
            // Summary Cards
            _buildSummaryCards(appProvider),
            
            // Payments List
            Expanded(
              child: payments.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _selectedFilter == 'all' ? Icons.payment : Icons.filter_list_off,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _selectedFilter == 'all' 
                                ? 'No payments found'
                                : 'No ${_selectedFilter} payments',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: payments.length,
                      itemBuilder: (context, index) {
                        final payment = payments[index];
                        return _buildPaymentCard(context, appProvider, payment);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCards(AppProvider appProvider) {
    final allPayments = appProvider.payments;
    final paidPayments = allPayments.where((p) => p.isPaid).toList();
    final unpaidPayments = allPayments.where((p) => !p.isPaid).toList();
    final overduePayments = allPayments.where((p) => p.isOverdue).toList();

    final totalPaid = paidPayments.fold<double>(0, (sum, p) => sum + p.amount);
    final totalUnpaid = unpaidPayments.fold<double>(0, (sum, p) => sum + p.amount);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Text(
                      '₹${NumberFormat('#,##0').format(totalPaid)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const Text(
                      'Total Paid',
                      style: TextStyle(fontSize: 12, color: Colors.green),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Text(
                      '₹${NumberFormat('#,##0').format(totalUnpaid)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const Text(
                      'Total Unpaid',
                      style: TextStyle(fontSize: 12, color: Colors.orange),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Card(
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Text(
                      '${overduePayments.length}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const Text(
                      'Overdue',
                      style: TextStyle(fontSize: 12, color: Colors.red),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(BuildContext context, AppProvider appProvider, Payment payment) {
    final student = appProvider.getStudentById(payment.studentId);
    final room = student != null ? appProvider.getRoomById(student.roomId) : null;
    final building = room != null ? appProvider.getBuildingById(room.buildingId) : null;

    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (payment.isPaid) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText = 'Paid';
    } else if (payment.isOverdue) {
      statusColor = Colors.red;
      statusIcon = Icons.warning;
      statusText = 'Overdue';
    } else {
      statusColor = Colors.orange;
      statusIcon = Icons.schedule;
      statusText = 'Pending';
    }

    return Slidable(
      key: ValueKey(payment.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          if (!payment.isPaid)
            SlidableAction(
              onPressed: (context) => _markAsPaid(context, appProvider, payment),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              icon: Icons.check,
              label: 'Mark Paid',
            ),
          if (payment.isPaid)
            SlidableAction(
              onPressed: (context) => _markAsUnpaid(context, appProvider, payment),
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              icon: Icons.undo,
              label: 'Mark Unpaid',
            ),
          SlidableAction(
            onPressed: (context) => _editPayment(context, appProvider, payment),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
          ),
          SlidableAction(
            onPressed: (context) => _deletePayment(context, appProvider, payment),
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
            backgroundColor: statusColor,
            child: Icon(statusIcon, color: Colors.white),
          ),
          title: Text(
            student?.name ?? 'Unknown Student',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🏢 ${building?.name ?? 'Unknown'} - Room ${room?.number ?? 'Unknown'}'),
              Text('📅 Due: ${DateFormat('MMM dd, yyyy').format(payment.dueDate)}'),
              if (payment.isPaid && payment.paidDate != null)
                Text('✅ Paid: ${DateFormat('MMM dd, yyyy').format(payment.paidDate!)}'),
              if (payment.note != null && payment.note!.isNotEmpty)
                Text('📝 ${payment.note}'),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${NumberFormat('#,##0').format(payment.amount)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          onTap: () => _showPaymentDetails(context, appProvider, payment),
        ),
      ),
    );
  }

  List<Payment> _getFilteredPayments(AppProvider appProvider) {
    switch (_selectedFilter) {
      case 'paid':
        return appProvider.payments.where((p) => p.isPaid).toList();
      case 'unpaid':
        return appProvider.payments.where((p) => !p.isPaid).toList();
      case 'overdue':
        return appProvider.payments.where((p) => p.isOverdue).toList();
      default:
        return appProvider.payments;
    }
  }

  List<Payment> _getSortedPayments(List<Payment> payments, AppProvider appProvider) {
    payments.sort((a, b) {
      int comparison = 0;
      
      switch (_sortBy) {
        case 'dueDate':
          comparison = a.dueDate.compareTo(b.dueDate);
          break;
        case 'amount':
          comparison = a.amount.compareTo(b.amount);
          break;
        case 'student':
          final studentA = appProvider.getStudentById(a.studentId);
          final studentB = appProvider.getStudentById(b.studentId);
          comparison = (studentA?.name ?? '').compareTo(studentB?.name ?? '');
          break;
        case 'status':
          comparison = a.status.name.compareTo(b.status.name);
          break;
      }
      
      return _sortAscending ? comparison : -comparison;
    });
    
    return payments;
  }

  void _showPaymentDetails(BuildContext context, AppProvider appProvider, Payment payment) {
    final student = appProvider.getStudentById(payment.studentId);
    final room = student != null ? appProvider.getRoomById(student.roomId) : null;
    final building = room != null ? appProvider.getBuildingById(room.buildingId) : null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Payment Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Student', student?.name ?? 'Unknown'),
              _buildDetailRow('Phone', student?.phone ?? 'Unknown'),
              _buildDetailRow('Building', building?.name ?? 'Unknown'),
              _buildDetailRow('Room', room?.number ?? 'Unknown'),
              _buildDetailRow('Amount', '₹${NumberFormat('#,##0').format(payment.amount)}'),
              _buildDetailRow('Due Date', DateFormat('MMM dd, yyyy').format(payment.dueDate)),
              _buildDetailRow('Status', payment.isPaid ? 'Paid' : 'Unpaid'),
              if (payment.isPaid && payment.paidDate != null)
                _buildDetailRow('Paid Date', DateFormat('MMM dd, yyyy').format(payment.paidDate!)),
              if (payment.note != null && payment.note!.isNotEmpty)
                _buildDetailRow('Note', payment.note!),
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
              _editPayment(context, appProvider, payment);
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

  void _markAsPaid(BuildContext context, AppProvider appProvider, Payment payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Paid'),
        content: Text('Mark payment of ₹${NumberFormat('#,##0').format(payment.amount)} as paid?'),
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

  void _markAsUnpaid(BuildContext context, AppProvider appProvider, Payment payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Unpaid'),
        content: Text('Mark payment of ₹${NumberFormat('#,##0').format(payment.amount)} as unpaid?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await appProvider.markPaymentAsUnpaid(payment.id);
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Payment marked as unpaid')),
                );
              }
            },
            child: const Text('Mark Unpaid'),
          ),
        ],
      ),
    );
  }

  void _editPayment(BuildContext context, AppProvider appProvider, Payment payment) {
    final amountController = TextEditingController(text: payment.amount.toString());
    final noteController = TextEditingController(text: payment.note ?? '');
    DateTime selectedDueDate = payment.dueDate;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Payment'),
        content: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(labelText: 'Amount'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Due Date'),
                  subtitle: Text(DateFormat('MMM dd, yyyy').format(selectedDueDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDueDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (date != null) {
                      setState(() {
                        selectedDueDate = date;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(labelText: 'Note (Optional)'),
                  maxLines: 2,
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
              if (amountController.text.isNotEmpty) {
                final updatedPayment = payment.copyWith(
                  amount: double.parse(amountController.text),
                  dueDate: selectedDueDate,
                  note: noteController.text.isEmpty ? null : noteController.text,
                );
                await appProvider.updatePayment(updatedPayment);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Payment updated successfully')),
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

  void _deletePayment(BuildContext context, AppProvider appProvider, Payment payment) {
    final student = appProvider.getStudentById(payment.studentId);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Payment'),
        content: Text(
          'Are you sure you want to delete this payment of ₹${NumberFormat('#,##0').format(payment.amount)} for ${student?.name ?? 'Unknown Student'}?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await appProvider.deletePayment(payment.id);
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Payment deleted successfully')),
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