import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_service.dart';
import '../services/battle_engine.dart';
import '../models/gladiator.dart';
import '../models/opponent.dart';

class ArenaScreen extends StatelessWidget {
  const ArenaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameService>(
      builder: (context, gameService, child) {
        print('ARENA UI: Building arena screen');
        final availableGladiators = gameService.gameState.gladiators
            .where((g) => g.isAvailable)
            .toList();
        final opponents = gameService.gameState.availableOpponents;
        
        print('ARENA UI: Found ${availableGladiators.length} available gladiators out of ${gameService.gameState.gladiators.length} total');
        for (final g in gameService.gameState.gladiators) {
          print('ARENA UI: Gladiator ${g.name} - status: ${g.status}, available: ${g.isAvailable}');
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Arena'),
            actions: [
              IconButton(
                icon: const Icon(Icons.bug_report),
                onPressed: () => gameService.debugPrintGladiatorStates(),
                tooltip: 'Debug Gladiator States',
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => gameService.advanceDay(),
                tooltip: 'New Day (New Opponents)',
              ),
            ],
          ),
          body: availableGladiators.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.sports_kabaddi,
                        size: 64,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No gladiators available',
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Heal your injured gladiators or wait for training to complete',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Available Gladiators
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Select Your Fighter',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 120,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: availableGladiators.length,
                                  itemBuilder: (context, index) {
                                    final gladiator = availableGladiators[index];
                                    return _GladiatorSelectionCard(
                                      gladiator: gladiator,
                                      onSelected: (selected) {
                                        if (selected) {
                                          _showOpponentSelection(context, gameService, gladiator);
                                        }
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Today's Opponents
                      const Text(
                        "Today's Opponents",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      Expanded(
                        child: ListView.builder(
                          itemCount: opponents.length,
                          itemBuilder: (context, index) {
                            final opponent = opponents[index];
                            return _OpponentCard(
                              opponent: opponent,
                              onFight: () => _showOpponentSelection(context, gameService, null),
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

  void _showOpponentSelection(BuildContext context, GameService gameService, Gladiator? selectedGladiator) {
    if (selectedGladiator == null) {
      // Show gladiator selection first
      _showGladiatorSelection(context, gameService);
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Select Opponent for ${selectedGladiator.name}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: gameService.gameState.availableOpponents.length,
                    itemBuilder: (context, index) {
                      final opponent = gameService.gameState.availableOpponents[index];
                      final winProbability = BattleEngine.calculateWinProbability(selectedGladiator, opponent);
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(opponent.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Power: ${opponent.totalPower} | Tier ${opponent.difficultyTier}'),
                              Text('Reward: ${opponent.rewardMoney} 🪙'),
                              Text(
                                'Win Chance: ${(winProbability * 100).toStringAsFixed(0)}% (${BattleEngine.getDifficultyDescription(winProbability)})',
                                style: TextStyle(
                                  color: winProbability >= 0.6 ? Colors.green : 
                                         winProbability >= 0.4 ? Colors.orange : Colors.red,
                                ),
                              ),
                            ],
                          ),
                          trailing: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _startBattle(context, gameService, selectedGladiator, opponent);
                            },
                            child: const Text('Fight!'),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showGladiatorSelection(BuildContext context, GameService gameService) {
    final availableGladiators = gameService.gameState.gladiators
        .where((g) => g.isAvailable)
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Your Fighter',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...availableGladiators.map((gladiator) => ListTile(
              title: Text(gladiator.name),
              subtitle: Text('Power: ${gladiator.totalPower} | HP: ${gladiator.hp}/${gladiator.maxHP}'),
              trailing: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showOpponentSelection(context, gameService, gladiator);
                },
                child: const Text('Select'),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Future<void> _startBattle(BuildContext context, GameService gameService, Gladiator gladiator, Opponent opponent) async {
    print('ARENA UI: Starting battle UI flow');
    print('ARENA UI: Selected gladiator=${gladiator.name}, opponent=${opponent.name}');
    print('ARENA UI: Gladiator available=${gladiator.isAvailable}, status=${gladiator.status}');
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Battle in progress...'),
          ],
        ),
      ),
    );

    // Shorter delay for better UX - battle should be quick!
    await Future.delayed(const Duration(milliseconds: 500));

    print('ARENA UI: Calling gameService.fightOpponent()');
    // Execute battle
    final result = await gameService.fightOpponent(gladiator.id, opponent.id);
    print('ARENA UI: Battle result received: ${result != null ? 'SUCCESS' : 'FAILED'}');
    if (result != null) {
      print('ARENA UI: Battle won=${result.gladiatorWon}, damage=${result.gladiatorDamage}');
    }

    if (context.mounted) {
      print('ARENA UI: Closing loading dialog and showing result');
      Navigator.of(context).pop(); // Close loading dialog

      if (result != null) {
        print('ARENA UI: Showing battle result dialog');
        _showBattleResult(context, result);
      } else {
        // Show error dialog if battle failed
        print('ARENA UI: Showing battle error dialog');
        _showBattleError(context);
      }
    } else {
      print('ARENA UI: Context not mounted, skipping dialog display');
    }
  }

  void _showBattleResult(BuildContext context, BattleResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(result.gladiatorWon ? '🏆 Victory!' : '💀 Defeat'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (result.gladiatorWon)
                Text('Reward: ${result.rewardMoney} 🪙', 
                     style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text('Battle Log:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  result.battleLog,
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showBattleError(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Battle Failed'),
        content: const Text(
          'Unable to start the battle. Please make sure your gladiator is available and try again.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _GladiatorSelectionCard extends StatelessWidget {
  final Gladiator gladiator;
  final Function(bool) onSelected;

  const _GladiatorSelectionCard({
    required this.gladiator,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 8),
      child: Card(
        child: InkWell(
          onTap: () => onSelected(true),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gladiator.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text('Power: ${gladiator.totalPower}'),
                Text('HP: ${gladiator.hp}/${gladiator.maxHP}'),
                const Spacer(),
                Text(
                  'Tap to select',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OpponentCard extends StatelessWidget {
  final Opponent opponent;
  final VoidCallback onFight;

  const _OpponentCard({
    required this.opponent,
    required this.onFight,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        opponent.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        opponent.description,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Tier ${opponent.difficultyTier}',
                      style: TextStyle(
                        color: _getTierColor(opponent.difficultyTier),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${opponent.rewardMoney} 🪙',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatChip(
                  label: 'STR',
                  value: opponent.strength,
                  color: Colors.red,
                ),
                _StatChip(
                  label: 'SPD',
                  value: opponent.speed,
                  color: Colors.blue,
                ),
                _StatChip(
                  label: 'END',
                  value: opponent.endurance,
                  color: Colors.green,
                ),
                _StatChip(
                  label: 'HP',
                  value: opponent.hp,
                  color: Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getTierColor(int tier) {
    switch (tier) {
      case 1: return Colors.green;
      case 2: return Colors.yellow;
      case 3: return Colors.orange;
      case 4: return Colors.red;
      case 5: return Colors.purple;
      default: return Colors.grey;
    }
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
