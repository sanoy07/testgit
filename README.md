# 🏠 Hostel Payment Tracker

A comprehensive Flutter application for managing hostel fee payments with offline capabilities and local storage.

## 📱 Features

### 🎯 Core Features
- **Student Management**: Add, edit, delete, and manage student information
- **Building & Room Management**: Organize students by buildings and rooms
- **Payment Tracking**: Track fee payments with due dates and payment history
- **Fee Structure Management**: Set up recurring payment structures per building
- **Offline Support**: Full offline functionality with SQLite local storage
- **Dashboard**: Overview of payments, overdue amounts, and key metrics

### 🔧 Advanced Features
- **Search & Filter**: Find students and payments quickly
- **Payment Status**: Track paid, unpaid, and overdue payments
- **Auto-generation**: Generate recurring payments based on fee structures
- **Swipe Actions**: Quick actions with swipe gestures
- **Beautiful UI**: Modern Material Design with smooth animations
- **Data Persistence**: All data stored locally with SQLite

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK (2.17.0 or higher)
- Android Studio / VS Code
- Android device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd hostel_payment_tracker
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 📖 Usage Guide

### 🏢 Buildings Management
1. Navigate to the "Buildings" tab
2. Tap the "+" button to add a new building
3. Expand buildings to view and manage rooms
4. Set fee structures for each building
5. Use the menu to edit or delete buildings

### 👥 Students Management
1. Go to the "Students" tab
2. Use the floating action button to add new students
3. Search students using the search functionality
4. Swipe left on student cards for quick actions:
   - Edit student information
   - Activate/Deactivate student
   - Delete student
5. Tap on a student to view detailed information

### 💰 Payment Management
1. Access the "Payments" tab
2. Filter payments by status (All, Paid, Unpaid, Overdue)
3. Sort payments by date, amount, student, or status
4. Swipe left on payment cards for actions:
   - Mark as paid/unpaid
   - Edit payment details
   - Delete payment
5. Add new payments using the floating action button

### 📊 Dashboard
- View key metrics and summaries
- See overdue payments at a glance
- Access quick actions for common tasks
- Monitor recent payment activities

## 🗂️ Data Models

### Student
```dart
class Student {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final DateTime joinDate;
  final String roomId;
  final bool isActive;
}
```

### Building
```dart
class Building {
  final String id;
  final String name;
  final String? address;
}
```

### Room
```dart
class Room {
  final String id;
  final String number;
  final String buildingId;
  final int capacity;
  final int currentOccupancy;
}
```

### Payment
```dart
class Payment {
  final String id;
  final String studentId;
  final double amount;
  final DateTime dueDate;
  final DateTime? paidDate;
  final PaymentStatus status;
  final String? note;
}
```

### Fee Structure
```dart
class FeeStructure {
  final String id;
  final String? buildingId;
  final double amount;
  final FeeRecurrence recurrence;
  final DateTime startDate;
}
```

## 🛠️ Technical Details

### Architecture
- **State Management**: Provider pattern
- **Database**: SQLite with sqflite package
- **UI**: Material Design with custom theming
- **Navigation**: Bottom navigation with PageView

### Key Dependencies
- `sqflite`: Local database storage
- `provider`: State management
- `intl`: Date formatting and internationalization
- `flutter_slidable`: Swipe actions
- `uuid`: Unique ID generation

### Project Structure
```
lib/
├── models/           # Data models
├── database/         # Database helper and operations
├── providers/        # State management
├── screens/          # App screens
├── widgets/          # Reusable widgets
└── main.dart         # App entry point
```

## 🔒 Security Features

- **Local Storage**: All data stored locally on device
- **No Internet Required**: Fully offline application
- **Data Validation**: Input validation and error handling
- **Secure Deletion**: Proper data cleanup on deletion

## 🎨 UI/UX Features

- **Material Design**: Modern, consistent design language
- **Responsive Layout**: Works on different screen sizes
- **Smooth Animations**: Engaging user interactions
- **Intuitive Navigation**: Easy-to-use interface
- **Visual Feedback**: Clear status indicators and feedback

## 🔧 Customization

### Theming
The app uses a custom blue theme that can be modified in `main.dart`:
```dart
theme: ThemeData(
  primaryColor: const Color(0xFF1976D2),
  // ... other theme properties
)
```

### Adding New Features
1. Create new models in `lib/models/`
2. Update database schema in `lib/database/database_helper.dart`
3. Add provider methods in `lib/providers/app_provider.dart`
4. Create UI components in `lib/widgets/`

## 📝 Future Enhancements

- [ ] Cloud sync capabilities
- [ ] SMS/WhatsApp payment reminders
- [ ] PDF report generation
- [ ] Export to CSV functionality
- [ ] Multi-language support
- [ ] Dark mode theme
- [ ] Backup and restore features

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For support and questions:
- Create an issue in the repository
- Check existing documentation
- Review the code comments for implementation details

## 🏆 Acknowledgments

- Flutter team for the amazing framework
- Material Design for the design system
- SQLite for reliable local storage
- All contributors and testers

---

**Made with ❤️ using Flutter**