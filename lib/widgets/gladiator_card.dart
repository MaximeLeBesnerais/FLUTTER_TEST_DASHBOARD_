import 'package:flutter/material.dart';
import '../models/gladiator.dart';

class GladiatorCard extends StatelessWidget {
  final Gladiator gladiator;
  final int currentDay;
  final VoidCallback? onTap;

  const GladiatorCard({
    super.key,
    required this.gladiator,
    required this.currentDay,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Header with name and status
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          gladiator.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _StatusChip(status: gladiator.status),
                            const SizedBox(width: 8),
                            Text(
                              'Win Rate: ${(gladiator.winRate * 100).toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Power: ${gladiator.totalPower}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Text(
                        'Wage: ${gladiator.dailyWage}💰/day',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // HP Bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Health',
                          style: TextStyle(
                            fontSize: 12, 
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        Text(
                          '${gladiator.hp}/${gladiator.maxHP}',
                          style: TextStyle(
                            fontSize: 12, 
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: gladiator.hp / gladiator.maxHP,
                    backgroundColor: Colors.red.shade100,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      gladiator.hp >= gladiator.maxHP * 0.7
                          ? Colors.green
                          : gladiator.hp >= gladiator.maxHP * 0.3
                              ? Colors.orange
                              : Colors.red,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Stats Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(
                    label: 'STR',
                    value: gladiator.strength,
                    icon: Icons.fitness_center,
                    color: Colors.red,
                  ),
                  _StatItem(
                    label: 'SPD',
                    value: gladiator.speed,
                    icon: Icons.speed,
                    color: Colors.blue,
                  ),
                  _StatItem(
                    label: 'END',
                    value: gladiator.endurance,
                    icon: Icons.shield,
                    color: Colors.green,
                  ),
                ],
              ),
              
              // Progress indicators for training/healing
              if (gladiator.status == GladiatorStatus.training && gladiator.trainingCompletesOnDay != null)
                _buildTrainingProgress(),
              if (gladiator.status == GladiatorStatus.healing && gladiator.healingCompletesOnDay != null)
                _buildHealingProgress(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrainingProgress() {
    final isComplete = gladiator.isTrainingComplete(currentDay);
    final daysRemaining = gladiator.trainingCompletesOnDay! - currentDay;
    
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Training ${gladiator.currentTraining?.name.toUpperCase()}',
                style: const TextStyle(fontSize: 12, color: Colors.orange),
              ),
              Text(
                isComplete ? 'Complete!' : '$daysRemaining day${daysRemaining == 1 ? '' : 's'} left',
                style: TextStyle(
                  fontSize: 12,
                  color: isComplete ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: isComplete ? 1.0 : 0.5, // Simplified progress
            backgroundColor: Colors.orange.shade900,
            valueColor: AlwaysStoppedAnimation<Color>(
              isComplete ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealingProgress() {
    final isComplete = gladiator.isHealingComplete(currentDay);
    final daysRemaining = gladiator.healingCompletesOnDay! - currentDay;
    
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Healing',
                style: TextStyle(fontSize: 12, color: Colors.blue),
              ),
              Text(
                isComplete ? 'Complete!' : '$daysRemaining day${daysRemaining == 1 ? '' : 's'} left',
                style: TextStyle(
                  fontSize: 12,
                  color: isComplete ? Colors.green : Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: isComplete ? 1.0 : 0.5, // Simplified progress
            backgroundColor: Colors.blue.shade900,
            valueColor: AlwaysStoppedAnimation<Color>(
              isComplete ? Colors.green : Colors.blue,
            ),
          ),
        ],
      ),
    );
  }


}

class _StatusChip extends StatelessWidget {
  final GladiatorStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: config.color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: 14, color: config.color),
          const SizedBox(width: 4),
          Text(
            config.label,
            style: TextStyle(
              fontSize: 12,
              color: config.color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _getStatusConfig(GladiatorStatus status) {
    switch (status) {
      case GladiatorStatus.idle:
        return _StatusConfig(
          label: 'Ready',
          icon: Icons.check_circle,
          color: Colors.green,
        );
      case GladiatorStatus.training:
        return _StatusConfig(
          label: 'Training',
          icon: Icons.fitness_center,
          color: Colors.orange,
        );
      case GladiatorStatus.healing:
        return _StatusConfig(
          label: 'Healing',
          icon: Icons.healing,
          color: Colors.blue,
        );
      case GladiatorStatus.injured:
        return _StatusConfig(
          label: 'Injured',
          icon: Icons.local_hospital,
          color: Colors.red,
        );
      case GladiatorStatus.fighting:
        return _StatusConfig(
          label: 'Fighting',
          icon: Icons.sports_kabaddi,
          color: Colors.purple,
        );
    }
  }
}

class _StatusConfig {
  final String label;
  final IconData icon;
  final Color color;

  _StatusConfig({
    required this.label,
    required this.icon,
    required this.color,
  });
}

class _StatItem extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
