import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_service.dart';
import '../models/gladiator.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  List<Gladiator> _availableGladiators = [];

  @override
  void initState() {
    super.initState();
    _refreshMarket();
  }

  void _refreshMarket() {
    final gameService = Provider.of<GameService>(context, listen: false);
    setState(() {
      _availableGladiators = gameService.generateRecruitableGladiators();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameService>(
      builder: (context, gameService, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Marketplace'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _refreshMarket,
                tooltip: 'Refresh Market',
              ),
            ],
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
                
                const Text(
                  'Available Gladiators',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Expanded(
                  child: _availableGladiators.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.store_outlined,
                                size: 64,
                                color: Colors.white38,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No gladiators available',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white70,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Tap refresh to see new gladiators',
                                style: TextStyle(
                                  color: Colors.white54,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _availableGladiators.length,
                          itemBuilder: (context, index) {
                            final gladiator = _availableGladiators[index];
                            final cost = gameService.calculateRecruitmentCost(gladiator);
                            final canAfford = gameService.gameState.money >= cost;
                            
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
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
                                                gladiator.name,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                'Power: ${gladiator.totalPower}',
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
                                            Text(
                                              '$cost 🪙',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: canAfford ? Colors.green : Colors.red,
                                              ),
                                            ),
                                            Text(
                                              '${gladiator.dailyWage} 🪙/day wage',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    
                                    const SizedBox(height: 12),
                                    
                                    // Stats
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        _StatDisplay(
                                          label: 'STR',
                                          value: gladiator.strength,
                                          icon: Icons.fitness_center,
                                          color: Colors.red,
                                        ),
                                        _StatDisplay(
                                          label: 'SPD',
                                          value: gladiator.speed,
                                          icon: Icons.speed,
                                          color: Colors.blue,
                                        ),
                                        _StatDisplay(
                                          label: 'END',
                                          value: gladiator.endurance,
                                          icon: Icons.shield,
                                          color: Colors.green,
                                        ),
                                        _StatDisplay(
                                          label: 'HP',
                                          value: gladiator.maxHP,
                                          icon: Icons.favorite,
                                          color: Colors.pink,
                                        ),
                                      ],
                                    ),
                                    
                                    const SizedBox(height: 12),
                                    
                                    // Recruit Button
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: canAfford
                                            ? () => _recruitGladiator(gameService, gladiator)
                                            : null,
                                        icon: const Icon(Icons.person_add),
                                        label: Text(
                                          canAfford ? 'Recruit' : 'Not enough money',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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

  void _recruitGladiator(GameService gameService, Gladiator gladiator) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Recruit ${gladiator.name}?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cost: ${gameService.calculateRecruitmentCost(gladiator)} 🪙'),
            Text('Daily Wage: ${gladiator.dailyWage} 🪙'),
            Text('Power: ${gladiator.totalPower}'),
            const SizedBox(height: 8),
            const Text(
              'This gladiator will join your roster and start earning their daily wage.',
              style: TextStyle(fontSize: 12, color: Colors.white70),
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
              final success = await gameService.recruitGladiator(gladiator);
              if (context.mounted) {
                Navigator.of(context).pop();
                
                if (success) {
                  setState(() {
                    _availableGladiators.remove(gladiator);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${gladiator.name} has joined your school!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Not enough money to recruit this gladiator'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Recruit'),
          ),
        ],
      ),
    );
  }
}

class _StatDisplay extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _StatDisplay({
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
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}
