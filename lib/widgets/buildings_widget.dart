import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../providers/app_provider.dart';
import '../models/building.dart';
import '../models/room.dart';
import '../models/fee_structure.dart';

class BuildingsWidget extends StatelessWidget {
  const BuildingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        if (appProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final buildings = appProvider.buildings;

        return Column(
          children: [
            // Header with Add Building Button
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    'Buildings & Rooms',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () => _showAddBuildingDialog(context, appProvider),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Building'),
                  ),
                ],
              ),
            ),
            
            // Buildings List
            Expanded(
              child: buildings.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.apartment, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No buildings found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Add a building to get started',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: buildings.length,
                      itemBuilder: (context, index) {
                        final building = buildings[index];
                        return _buildBuildingCard(context, appProvider, building);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBuildingCard(BuildContext context, AppProvider appProvider, Building building) {
    final rooms = appProvider.getRoomsByBuilding(building.id);
    final totalCapacity = rooms.fold(0, (sum, room) => sum + room.capacity);
    final totalOccupancy = rooms.fold(0, (sum, room) => sum + room.currentOccupancy);
    final feeStructure = appProvider.getFeeStructureByBuilding(building.id);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            building.name.isNotEmpty ? building.name[0].toUpperCase() : 'B',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          building.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (building.address != null)
              Text('📍 ${building.address}'),
            Text('🏠 ${rooms.length} rooms'),
            Text('👥 $totalOccupancy/$totalCapacity occupancy'),
            if (feeStructure != null)
              Text('💰 ₹${feeStructure.amount} ${feeStructure.recurrenceText}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleBuildingAction(context, appProvider, building, value),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'add_room',
              child: Row(
                children: [
                  Icon(Icons.add_home),
                  SizedBox(width: 8),
                  Text('Add Room'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'fee_structure',
              child: Row(
                children: [
                  Icon(Icons.monetization_on),
                  SizedBox(width: 8),
                  Text('Fee Structure'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Edit Building'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete Building', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        children: [
          if (rooms.isEmpty)
            const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('No rooms in this building'),
              subtitle: Text('Add rooms to get started'),
            )
          else
            ...rooms.map((room) => _buildRoomTile(context, appProvider, room)),
          
          // Add Room Button
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('Add Room'),
            onTap: () => _showAddRoomDialog(context, appProvider, building.id),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomTile(BuildContext context, AppProvider appProvider, Room room) {
    final students = appProvider.students.where((s) => s.roomId == room.id && s.isActive).toList();
    final isFullyOccupied = room.currentOccupancy >= room.capacity;

    return Slidable(
      key: ValueKey(room.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => _editRoom(context, appProvider, room),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
          ),
          SlidableAction(
            onPressed: (context) => _deleteRoom(context, appProvider, room),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isFullyOccupied ? Colors.red : Colors.green,
          child: Text(
            room.number,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        title: Text('Room ${room.number}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Capacity: ${room.capacity}'),
            Text('Occupancy: ${room.currentOccupancy}/${room.capacity}'),
            if (students.isNotEmpty)
              Text('Students: ${students.map((s) => s.name).join(', ')}'),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isFullyOccupied ? Colors.red : Colors.green,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            isFullyOccupied ? 'Full' : 'Available',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ),
        onTap: () => _showRoomDetails(context, appProvider, room),
      ),
    );
  }

  void _handleBuildingAction(
    BuildContext context,
    AppProvider appProvider,
    Building building,
    String action,
  ) {
    switch (action) {
      case 'add_room':
        _showAddRoomDialog(context, appProvider, building.id);
        break;
      case 'fee_structure':
        _showFeeStructureDialog(context, appProvider, building);
        break;
      case 'edit':
        _editBuilding(context, appProvider, building);
        break;
      case 'delete':
        _deleteBuilding(context, appProvider, building);
        break;
    }
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
              maxLines: 2,
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

  void _showAddRoomDialog(BuildContext context, AppProvider appProvider, String buildingId) {
    final numberController = TextEditingController();
    final capacityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Room'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: numberController,
              decoration: const InputDecoration(labelText: 'Room Number'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: capacityController,
              decoration: const InputDecoration(labelText: 'Capacity'),
              keyboardType: TextInputType.number,
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
              if (numberController.text.isNotEmpty && capacityController.text.isNotEmpty) {
                await appProvider.addRoom(
                  numberController.text,
                  buildingId,
                  int.parse(capacityController.text),
                );
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Room added successfully')),
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

  void _showFeeStructureDialog(BuildContext context, AppProvider appProvider, Building building) {
    final amountController = TextEditingController();
    FeeRecurrence selectedRecurrence = FeeRecurrence.monthly;
    final existingFeeStructure = appProvider.getFeeStructureByBuilding(building.id);

    if (existingFeeStructure != null) {
      amountController.text = existingFeeStructure.amount.toString();
      selectedRecurrence = existingFeeStructure.recurrence;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Fee Structure - ${building.name}'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Amount (₹)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<FeeRecurrence>(
                value: selectedRecurrence,
                decoration: const InputDecoration(labelText: 'Recurrence'),
                items: FeeRecurrence.values.map((recurrence) {
                  return DropdownMenuItem(
                    value: recurrence,
                    child: Text(recurrence.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedRecurrence = value!;
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          if (existingFeeStructure != null)
            TextButton(
              onPressed: () async {
                await appProvider.deleteFeeStructure(existingFeeStructure.id);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fee structure deleted')),
                  );
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ElevatedButton(
            onPressed: () async {
              if (amountController.text.isNotEmpty) {
                if (existingFeeStructure != null) {
                  final updatedFeeStructure = existingFeeStructure.copyWith(
                    amount: double.parse(amountController.text),
                    recurrence: selectedRecurrence,
                  );
                  await appProvider.updateFeeStructure(updatedFeeStructure);
                } else {
                  await appProvider.addFeeStructure(
                    building.id,
                    double.parse(amountController.text),
                    selectedRecurrence,
                  );
                }
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        existingFeeStructure != null
                            ? 'Fee structure updated'
                            : 'Fee structure added',
                      ),
                    ),
                  );
                }
              }
            },
            child: Text(existingFeeStructure != null ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  void _showRoomDetails(BuildContext context, AppProvider appProvider, Room room) {
    final building = appProvider.getBuildingById(room.buildingId);
    final students = appProvider.students.where((s) => s.roomId == room.id).toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Room ${room.number}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Building: ${building?.name ?? 'Unknown'}'),
              Text('Capacity: ${room.capacity}'),
              Text('Current Occupancy: ${room.currentOccupancy}'),
              Text('Available Spots: ${room.availableSpots}'),
              const SizedBox(height: 16),
              const Text(
                'Students:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (students.isEmpty)
                const Text('No students in this room')
              else
                ...students.map((student) => ListTile(
                      leading: CircleAvatar(
                        backgroundColor: student.isActive ? Colors.green : Colors.grey,
                        child: Text(student.name[0].toUpperCase()),
                      ),
                      title: Text(student.name),
                      subtitle: Text(student.phone),
                      trailing: Container(
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
                    )),
            ],
          ),
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

  void _editBuilding(BuildContext context, AppProvider appProvider, Building building) {
    final nameController = TextEditingController(text: building.name);
    final addressController = TextEditingController(text: building.address ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Building'),
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
              maxLines: 2,
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
                final updatedBuilding = building.copyWith(
                  name: nameController.text,
                  address: addressController.text.isEmpty ? null : addressController.text,
                );
                await appProvider.updateBuilding(updatedBuilding);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Building updated successfully')),
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

  void _editRoom(BuildContext context, AppProvider appProvider, Room room) {
    final numberController = TextEditingController(text: room.number);
    final capacityController = TextEditingController(text: room.capacity.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Room'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: numberController,
              decoration: const InputDecoration(labelText: 'Room Number'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: capacityController,
              decoration: const InputDecoration(labelText: 'Capacity'),
              keyboardType: TextInputType.number,
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
              if (numberController.text.isNotEmpty && capacityController.text.isNotEmpty) {
                final updatedRoom = room.copyWith(
                  number: numberController.text,
                  capacity: int.parse(capacityController.text),
                );
                await appProvider.updateRoom(updatedRoom);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Room updated successfully')),
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

  void _deleteBuilding(BuildContext context, AppProvider appProvider, Building building) {
    final rooms = appProvider.getRoomsByBuilding(building.id);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Building'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete "${building.name}"?'),
            const SizedBox(height: 8),
            if (rooms.isNotEmpty)
              Text(
                'This will also delete ${rooms.length} room(s) in this building.',
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 8),
            const Text(
              'This action cannot be undone.',
              style: TextStyle(fontWeight: FontWeight.bold),
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
              await appProvider.deleteBuilding(building.id);
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Building deleted successfully')),
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

  void _deleteRoom(BuildContext context, AppProvider appProvider, Room room) {
    final students = appProvider.students.where((s) => s.roomId == room.id).toList();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Room'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete Room ${room.number}?'),
            const SizedBox(height: 8),
            if (students.isNotEmpty)
              Text(
                'This room has ${students.length} student(s). Please move them to another room first.',
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 8),
            const Text(
              'This action cannot be undone.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: students.isEmpty ? () async {
              await appProvider.deleteRoom(room.id);
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Room deleted successfully')),
                );
              }
            } : null,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}