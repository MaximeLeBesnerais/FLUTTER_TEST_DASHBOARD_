import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_service.dart';
import '../models/staff.dart';

class StaffScreen extends StatelessWidget {
  const StaffScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameService>(
      builder: (context, gameService, child) {
        final currentStaff = gameService.gameState.staff;
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('Staff Management'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Player Money Display
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Your Money:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${gameService.gameState.money} 🪙',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFDAA520),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Current Staff Section
                if (currentStaff.isNotEmpty) ...[
                  const Text(
                    'Current Staff',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...currentStaff.map((staff) => _StaffCard(
                    staff: staff,
                    isHired: true,
                    onAction: () => _fireStaff(context, gameService, staff),
                    actionLabel: 'Fire',
                    actionColor: Colors.red,
                  )),
                  const SizedBox(height: 16),
                ],
                
                // Available Staff Section
                const Text(
                  'Available for Hire',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Expanded(
                  child: ListView(
                    children: [
                      _StaffCard(
                        staff: Staff.createTrainer('trainer_1', 'Marcus the Trainer'),
                        isHired: _hasStaffType(currentStaff, StaffType.trainer),
                        onAction: _hasStaffType(currentStaff, StaffType.trainer)
                            ? null
                            : () => _hireStaff(context, gameService, Staff.createTrainer('trainer_1', 'Marcus the Trainer')),
                        actionLabel: _hasStaffType(currentStaff, StaffType.trainer) ? 'Hired' : 'Hire',
                        actionColor: Colors.green,
                      ),
                      _StaffCard(
                        staff: Staff.createMedic('medic_1', 'Helena the Medic'),
                        isHired: _hasStaffType(currentStaff, StaffType.medic),
                        onAction: _hasStaffType(currentStaff, StaffType.medic)
                            ? null
                            : () => _hireStaff(context, gameService, Staff.createMedic('medic_1', 'Helena the Medic')),
                        actionLabel: _hasStaffType(currentStaff, StaffType.medic) ? 'Hired' : 'Hire',
                        actionColor: Colors.green,
                      ),
                      _StaffCard(
                        staff: Staff.createManager('manager_1', 'Quintus the Manager'),
                        isHired: _hasStaffType(currentStaff, StaffType.manager),
                        onAction: _hasStaffType(currentStaff, StaffType.manager)
                            ? null
                            : () => _hireStaff(context, gameService, Staff.createManager('manager_1', 'Quintus the Manager')),
                        actionLabel: _hasStaffType(currentStaff, StaffType.manager) ? 'Hired' : 'Hire',
                        actionColor: Colors.green,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _hasStaffType(List<Staff> staff, StaffType type) {
    return staff.any((s) => s.type == type);
  }

  void _hireStaff(BuildContext context, GameService gameService, Staff staff) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hire ${staff.name}?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Position: ${_getStaffTypeLabel(staff.type)}'),
            Text('Hiring Cost: ${staff.hiringCost} 🪙'),
            Text('Daily Salary: ${staff.dailySalary} 🪙'),
            const SizedBox(height: 8),
            Text(
              staff.description,
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 8),
            const Text(
              'Benefits:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...staff.bonuses.entries.map((bonus) => Text(
              '• ${_getBonusDescription(bonus.key, bonus.value)}',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: gameService.gameState.money >= staff.hiringCost
                ? () async {
                    final success = await gameService.hireStaff(staff);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${staff.name} has been hired!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }
                  }
                : null,
            child: const Text('Hire'),
          ),
        ],
      ),
    );
  }

  void _fireStaff(BuildContext context, GameService gameService, Staff staff) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Fire ${staff.name}?'),
        content: const Text('Are you sure you want to fire this staff member? You will lose all their benefits.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              gameService.fireStaff(staff.id);
              Navigator.of(context).pop();
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${staff.name} has been fired.'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Fire'),
          ),
        ],
      ),
    );
  }

  String _getStaffTypeLabel(StaffType type) {
    switch (type) {
      case StaffType.trainer:
        return 'Trainer';
      case StaffType.medic:
        return 'Medic';
      case StaffType.manager:
        return 'Manager';
    }
  }

  String _getBonusDescription(String bonusType, double value) {
    final percentage = (value * 100).round();
    switch (bonusType) {
      case 'trainingSpeed':
        return 'Training $percentage% faster';
      case 'trainingEffectiveness':
        return 'Training $percentage% more effective';
      case 'healingSpeed':
        return 'Healing $percentage% faster';
      case 'healingCost':
        return 'Healing ${percentage.abs()}% cheaper';
      case 'fightRewards':
        return 'Fight rewards $percentage% higher';
      case 'recruitmentCost':
        return 'Recruitment ${percentage.abs()}% cheaper';
      default:
        return '$bonusType: ${value > 0 ? '+' : ''}$percentage%';
    }
  }
}

class _StaffCard extends StatelessWidget {
  final Staff staff;
  final bool isHired;
  final VoidCallback? onAction;
  final String actionLabel;
  final Color actionColor;

  const _StaffCard({
    required this.staff,
    required this.isHired,
    required this.onAction,
    required this.actionLabel,
    required this.actionColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        staff.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _getStaffTypeLabel(staff.type),
                        style: const TextStyle(
                          color: Color(0xFFDAA520),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (!isHired)
                      Text(
                        '${staff.hiringCost} 🪙',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    Text(
                      '${staff.dailySalary} 🪙/day',
                      style: TextStyle(
                        fontSize: 12,
                        color: isHired ? Colors.red : Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Description
            Text(
              staff.description,
              style: const TextStyle(
                color: Colors.white70,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Benefits
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: staff.bonuses.entries.map((bonus) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue, width: 1),
                  ),
                  child: Text(
                    _getBonusDescription(bonus.key, bonus.value),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.blue,
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 12),
            
            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: onAction == null ? Colors.grey : actionColor,
                ),
                child: Text(actionLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStaffTypeLabel(StaffType type) {
    switch (type) {
      case StaffType.trainer:
        return 'Trainer';
      case StaffType.medic:
        return 'Medic';
      case StaffType.manager:
        return 'Manager';
    }
  }

  String _getBonusDescription(String bonusType, double value) {
    final percentage = (value * 100).round();
    switch (bonusType) {
      case 'trainingSpeed':
        return 'Training $percentage% faster';
      case 'trainingEffectiveness':
        return 'Training $percentage% more effective';
      case 'healingSpeed':
        return 'Healing $percentage% faster';
      case 'healingCost':
        return 'Healing ${percentage.abs()}% cheaper';
      case 'fightRewards':
        return 'Fight rewards $percentage% higher';
      case 'recruitmentCost':
        return 'Recruitment ${percentage.abs()}% cheaper';
      default:
        return '$bonusType: ${value > 0 ? '+' : ''}$percentage%';
    }
  }
}
