import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_service.dart';
import '../models/gladiator.dart';

class GladiatorDetailScreen extends StatelessWidget {
  final String gladiatorId;

  const GladiatorDetailScreen({
    super.key,
    required this.gladiatorId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<GameService>(
      builder: (context, gameService, child) {
        final gladiator = gameService.gameState.getGladiator(gladiatorId);
        
        if (gladiator == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Gladiator Not Found')),
            body: const Center(
              child: Text('Gladiator not found'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(gladiator.name),
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'rename':
                      _showRenameDialog(context, gameService, gladiator);
                      break;
                    case 'release':
                      _showReleaseDialog(context, gameService, gladiator);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'rename',
                    child: Text('Rename'),
                  ),
                  const PopupMenuItem(
                    value: 'release',
                    child: Text('Release'),
                  ),
                ],
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Basic Info Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              gladiator.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Power: ${gladiator.totalPower}',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Color(0xFFDAA520),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Health Bar
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Health'),
                                Text('${gladiator.hp}/${gladiator.maxHP}'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: gladiator.hp / gladiator.maxHP,
                              backgroundColor: Colors.red.shade900,
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
                        
                        const SizedBox(height: 16),
                        
                        // Stats
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _DetailStatItem(
                              label: 'Strength',
                              value: gladiator.strength,
                              icon: Icons.fitness_center,
                              color: Colors.red,
                            ),
                            _DetailStatItem(
                              label: 'Speed',
                              value: gladiator.speed,
                              icon: Icons.speed,
                              color: Colors.blue,
                            ),
                            _DetailStatItem(
                              label: 'Endurance',
                              value: gladiator.endurance,
                              icon: Icons.shield,
                              color: Colors.green,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Record Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Combat Record',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _RecordItem(
                              label: 'Wins',
                              value: gladiator.wins.toString(),
                              color: Colors.green,
                            ),
                            _RecordItem(
                              label: 'Losses',
                              value: gladiator.losses.toString(),
                              color: Colors.red,
                            ),
                            _RecordItem(
                              label: 'Win Rate',
                              value: '${(gladiator.winRate * 100).toStringAsFixed(0)}%',
                              color: Colors.blue,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Financial Info Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Financial Info',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Daily Wage:'),
                            Text('${gladiator.dailyWage} 🪙'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Action Buttons
                if (gladiator.isAvailable) ...[
                  // Training Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Training',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => gameService.trainGladiator(
                                    gladiatorId,
                                    TrainingType.strength,
                                  ),
                                  icon: const Icon(Icons.fitness_center),
                                  label: const Text('Strength\n100 🪙'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => gameService.trainGladiator(
                                    gladiatorId,
                                    TrainingType.speed,
                                  ),
                                  icon: const Icon(Icons.speed),
                                  label: const Text('Speed\n100 🪙'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => gameService.trainGladiator(
                                    gladiatorId,
                                    TrainingType.endurance,
                                  ),
                                  icon: const Icon(Icons.shield),
                                  label: const Text('Endurance\n100 🪙'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                
                // Healing Section
                if (gladiator.hp < gladiator.maxHP)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Healing',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => gameService.healGladiator(
                                    gladiatorId,
                                    isPaid: false,
                                  ),
                                  icon: const Icon(Icons.schedule),
                                  label: const Text('Free Healing\n(24 hours)'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => gameService.healGladiator(
                                    gladiatorId,
                                    isPaid: true,
                                  ),
                                  icon: const Icon(Icons.flash_on),
                                  label: const Text('Instant Heal\n200 🪙'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRenameDialog(BuildContext context, GameService gameService, Gladiator gladiator) {
    final controller = TextEditingController(text: gladiator.name);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Gladiator'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'New name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                final updated = gladiator.copyWith(name: controller.text);
                gameService.gameState.updateGladiator(updated);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _showReleaseDialog(BuildContext context, GameService gameService, Gladiator gladiator) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Release Gladiator'),
        content: Text('Are you sure you want to release ${gladiator.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              gameService.gameState.removeGladiator(gladiator.id);
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to list
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Release'),
          ),
        ],
      ),
    );
  }
}

class _DetailStatItem extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _DetailStatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

class _RecordItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _RecordItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}
