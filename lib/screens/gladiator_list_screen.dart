import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_service.dart';
import '../models/gladiator.dart';
import '../widgets/gladiator_card.dart';
import 'gladiator_detail_screen.dart';

class GladiatorListScreen extends StatelessWidget {
  const GladiatorListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameService>(
      builder: (context, gameService, child) {
        final gladiators = gameService.gameState.gladiators;
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('My Gladiators'),
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => _showGladiatorInfo(context),
              ),
            ],
          ),
          body: gladiators.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 64,
                        color: Colors.white38,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No gladiators yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Visit the marketplace to recruit gladiators',
                        style: TextStyle(
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Summary Stats
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _StatColumn(
                                label: 'Total',
                                value: gladiators.length.toString(),
                                color: Colors.blue,
                              ),
                              _StatColumn(
                                label: 'Ready',
                                value: gladiators.where((g) => g.isAvailable).length.toString(),
                                color: Colors.green,
                              ),
                              _StatColumn(
                                label: 'Training',
                                value: gladiators.where((g) => g.status == GladiatorStatus.training).length.toString(),
                                color: Colors.orange,
                              ),
                              _StatColumn(
                                label: 'Injured',
                                value: gladiators.where((g) => g.status == GladiatorStatus.injured).length.toString(),
                                color: Colors.red,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Gladiators List
                      Expanded(
                        child: ListView.builder(
                          itemCount: gladiators.length,
                          itemBuilder: (context, index) {
                            final gladiator = gladiators[index];
                            return GladiatorCard(
                              gladiator: gladiator,
                              currentDay: gameService.gameState.day,
                              onTap: () => _navigateToGladiatorDetail(context, gladiator),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  void _navigateToGladiatorDetail(BuildContext context, Gladiator gladiator) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GladiatorDetailScreen(gladiatorId: gladiator.id),
      ),
    );
  }

  void _showGladiatorInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gladiator Status Guide'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _InfoItem(
                icon: Icons.check_circle,
                color: Colors.green,
                title: 'Ready',
                description: 'Available for training or combat',
              ),
              _InfoItem(
                icon: Icons.fitness_center,
                color: Colors.orange,
                title: 'Training',
                description: 'Currently improving stats',
              ),
              _InfoItem(
                icon: Icons.healing,
                color: Colors.blue,
                title: 'Healing',
                description: 'Recovering health over time',
              ),
              _InfoItem(
                icon: Icons.local_hospital,
                color: Colors.red,
                title: 'Injured',
                description: 'Needs healing before combat',
              ),
              _InfoItem(
                icon: Icons.sports_kabaddi,
                color: Colors.purple,
                title: 'Fighting',
                description: 'Currently in the arena',
              ),
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
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatColumn({
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

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String description;

  const _InfoItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
