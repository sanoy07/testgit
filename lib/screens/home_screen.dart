import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../widgets/dashboard_widget.dart';
import '../widgets/students_widget.dart';
import '../widgets/buildings_widget.dart';
import '../widgets/payments_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _pages = [
    const DashboardWidget(),
    const StudentsWidget(),
    const BuildingsWidget(),
    const PaymentsWidget(),
  ];

  final List<String> _titles = [
    'Dashboard',
    'Students',
    'Buildings',
    'Payments',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        actions: [
          if (_currentIndex == 1) // Students page
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => _showSearchDialog(context),
            ),
          if (_currentIndex == 0) // Dashboard
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _refreshData(),
            ),
          PopupMenuButton<String>(
            onSelected: _handleMenuSelection,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'generate_payments',
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome),
                    SizedBox(width: 8),
                    Text('Generate Payments'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'backup',
                child: Row(
                  children: [
                    Icon(Icons.backup),
                    SizedBox(width: 8),
                    Text('Backup Data'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Students',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apartment),
            label: 'Buildings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            label: 'Payments',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 1 // Students page
          ? FloatingActionButton(
              onPressed: () => _showAddStudentDialog(context),
              tooltip: 'Add Student',
              child: const Icon(Icons.person_add),
            )
          : _currentIndex == 2 // Buildings page
              ? FloatingActionButton(
                  onPressed: () => _showAddBuildingDialog(context),
                  tooltip: 'Add Building',
                  child: const Icon(Icons.apartment),
                )
              : _currentIndex == 3 // Payments page
                  ? FloatingActionButton(
                      onPressed: () => _showAddPaymentDialog(context),
                      tooltip: 'Add Payment',
                      child: const Icon(Icons.payment),
                    )
                  : null,
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Students'),
        content: TextField(
          onChanged: (value) {
            Provider.of<AppProvider>(context, listen: false).setSearchQuery(value);
          },
          decoration: const InputDecoration(
            hintText: 'Enter name or phone number',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Provider.of<AppProvider>(context, listen: false).setSearchQuery('');
              Navigator.of(context).pop();
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _refreshData() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    await appProvider.loadData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data refreshed successfully')),
      );
    }
  }

  void _handleMenuSelection(String value) async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    
    switch (value) {
      case 'generate_payments':
        await appProvider.generateRecurringPayments();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Recurring payments generated')),
          );
        }
        break;
      case 'backup':
        _showBackupDialog();
        break;
      case 'settings':
        _showSettingsDialog();
        break;
    }
  }

  void _showBackupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup Data'),
        content: const Text('Backup functionality will be implemented in a future update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settings'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('App Version: 1.0.0'),
            SizedBox(height: 8),
            Text('Database: SQLite'),
            SizedBox(height: 8),
            Text('Storage: Local'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAddStudentDialog(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
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

  void _showAddBuildingDialog(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
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

  void _showAddPaymentDialog(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
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
}