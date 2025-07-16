import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../models/payment.dart';
import '../models/student.dart';

class PaymentCalendarWidget extends StatefulWidget {
  final Student student;
  final List<Payment> payments;
  final VoidCallback? onTap;

  const PaymentCalendarWidget({
    super.key,
    required this.student,
    required this.payments,
    this.onTap,
  });

  @override
  State<PaymentCalendarWidget> createState() => _PaymentCalendarWidgetState();
}

class _PaymentCalendarWidgetState extends State<PaymentCalendarWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: GestureDetector(
              onTap: widget.onTap,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Colors.grey.shade50,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Student header
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFF6C63FF),
                                const Color(0xFF4F46E5),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6C63FF).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              widget.student.name.isNotEmpty 
                                  ? widget.student.name[0].toUpperCase() 
                                  : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.student.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A202C),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.student.phone,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: widget.student.isActive 
                                ? const Color(0xFF10B981).withOpacity(0.1)
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.student.isActive ? 'Active' : 'Inactive',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: widget.student.isActive 
                                  ? const Color(0xFF10B981)
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Calendar title
                    Text(
                      'Payment Calendar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Monthly calendar grid
                    _buildPaymentCalendar(),
                    
                    const SizedBox(height: 20),
                    
                    // Legend
                    _buildLegend(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentCalendar() {
    final now = DateTime.now();
    final currentYear = now.year;
    final months = <Widget>[];
    
    for (int month = 1; month <= 12; month++) {
      final monthDate = DateTime(currentYear, month);
      final monthPayments = widget.payments.where((payment) {
        return payment.dueDate.year == currentYear && 
               payment.dueDate.month == month;
      }).toList();
      
      final status = _getMonthStatus(monthPayments, monthDate, now);
      
      months.add(
        AnimationConfiguration.staggeredGrid(
          position: month - 1,
          duration: const Duration(milliseconds: 600),
          columnCount: 6,
          child: SlideAnimation(
            verticalOffset: 30.0,
            child: FadeInAnimation(
              child: _buildMonthSquare(month, status),
            ),
          ),
        ),
      );
    }
    
    return GridView.count(
      crossAxisCount: 6,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: months,
    );
  }

  Widget _buildMonthSquare(int month, PaymentStatus status) {
    Color backgroundColor;
    Color borderColor;
    IconData? icon;
    
    switch (status) {
      case PaymentStatus.paid:
        backgroundColor = const Color(0xFF10B981).withOpacity(0.1);
        borderColor = const Color(0xFF10B981);
        icon = Icons.check_circle_rounded;
        break;
      case PaymentStatus.overdue:
        backgroundColor = const Color(0xFFEF4444).withOpacity(0.1);
        borderColor = const Color(0xFFEF4444);
        icon = Icons.warning_rounded;
        break;
      case PaymentStatus.upcoming:
        backgroundColor = const Color(0xFFF59E0B).withOpacity(0.1);
        borderColor = const Color(0xFFF59E0B);
        icon = Icons.schedule_rounded;
        break;
      case PaymentStatus.notDue:
        backgroundColor = Colors.grey.withOpacity(0.05);
        borderColor = Colors.grey.shade300;
        icon = Icons.circle_outlined;
        break;
    }
    
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + month * 50),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: borderColor,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: borderColor.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: borderColor,
                  size: 20,
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM').format(DateTime(2024, month)),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: borderColor,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildLegendItem(
            color: const Color(0xFF10B981),
            icon: Icons.check_circle_rounded,
            label: 'Paid',
          ),
          _buildLegendItem(
            color: const Color(0xFFF59E0B),
            icon: Icons.schedule_rounded,
            label: 'Due',
          ),
          _buildLegendItem(
            color: const Color(0xFFEF4444),
            icon: Icons.warning_rounded,
            label: 'Overdue',
          ),
          _buildLegendItem(
            color: Colors.grey.shade400,
            icon: Icons.circle_outlined,
            label: 'Future',
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 16,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  PaymentStatus _getMonthStatus(
    List<Payment> monthPayments,
    DateTime monthDate,
    DateTime now,
  ) {
    if (monthPayments.isEmpty) {
      // If it's a future month, show as not due
      if (monthDate.isAfter(DateTime(now.year, now.month))) {
        return PaymentStatus.notDue;
      }
      // If it's current or past month with no payment, show as overdue
      return PaymentStatus.overdue;
    }
    
    final paidPayments = monthPayments.where((p) => p.isPaid).toList();
    final overduePayments = monthPayments.where((p) => p.isOverdue).toList();
    
    if (paidPayments.isNotEmpty) {
      return PaymentStatus.paid;
    } else if (overduePayments.isNotEmpty) {
      return PaymentStatus.overdue;
    } else {
      return PaymentStatus.upcoming;
    }
  }
}

enum PaymentStatus {
  paid,
  overdue,
  upcoming,
  notDue,
}