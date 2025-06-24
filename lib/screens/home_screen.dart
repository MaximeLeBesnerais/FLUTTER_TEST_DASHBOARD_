import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_service.dart';
import '../models/game_state.dart';
import 'gladiator_list_screen.dart';
import 'marketplace_screen.dart';
import 'arena_screen.dart';
import 'staff_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = [
    const DashboardTab(),
    const GladiatorListScreen(),
    const ArenaScreen(),
    const MarketplaceScreen(),
    const StaffScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Gladiators',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_kabaddi),
            label: 'Arena',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Market',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: 'Staff',
          ),
        ],
      ),
    );
  }
}

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameService>(
      builder: (context, gameService, child) {
        final gameState = gameService.gameState;
        
        // Check for game over
        if (gameState.isGameOver) {
          return _buildGameOverScreen(context, gameService, gameState);
        }
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('Gladiator Management System'),
            actions: [
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: () => gameService.saveGame(),
                tooltip: 'Save Game',
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'new_game':
                      _showNewGameDialog(context, gameService);
                      break;
                    case 'settings':
                      // TODO: Implement settings
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'new_game',
                    child: Text('New Game'),
                  ),
                  const PopupMenuItem(
                    value: 'settings',
                    child: Text('Settings'),
                  ),
                ],
              ),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isLargeScreen = constraints.maxWidth > 1200;
              final isMediumScreen = constraints.maxWidth > 800;
              
              if (isLargeScreen) {
                return _buildLargeScreenLayout(gameState, gameService, context);
              } else if (isMediumScreen) {
                return _buildMediumScreenLayout(gameState, gameService, context);
              } else {
                return _buildSmallScreenLayout(gameState, gameService, context);
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildGameOverScreen(BuildContext context, GameService gameService, GameState gameState) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Over'),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          margin: const EdgeInsets.all(24),
          child: Card(
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.warning_rounded,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Game Over',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    gameState.gameOverReason,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Final Statistics:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatColumn(
                        label: 'Days Survived',
                        value: gameState.day.toString(),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      _StatColumn(
                        label: 'Final Debt',
                        value: '${gameState.debt}💰',
                        color: Theme.of(context).colorScheme.error,
                      ),
                      _StatColumn(
                        label: 'Gladiators',
                        value: gameState.totalGladiators.toString(),
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => gameService.newGame(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Start New Game'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLargeScreenLayout(GameState gameState, GameService gameService, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Panel - Statistics
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildFinancialOverview(gameState, gameService, context),
                const SizedBox(height: 16),
                _buildGladiatorsOverview(gameState, context),
              ],
            ),
          ),
          const SizedBox(width: 24),
          // Right Panel - Actions and Alerts
          Expanded(
            flex: 3,
            child: Column(
              children: [
                _buildQuickActions(gameState, gameService, context),
                const SizedBox(height: 16),
                _buildAlertsAndWarnings(gameState, context),
                const SizedBox(height: 16),
                _buildRecentActivity(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediumScreenLayout(GameState gameState, GameService gameService, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Top row - Financial overview
          _buildFinancialOverview(gameState, gameService, context),
          const SizedBox(height: 16),
          
          // Middle row - Split content
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _buildGladiatorsOverview(gameState, context),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      _buildQuickActions(gameState, gameService, context),
                      const SizedBox(height: 16),
                      _buildAlertsAndWarnings(gameState, context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallScreenLayout(GameState gameState, GameService gameService, BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFinancialOverview(gameState, gameService, context),
          const SizedBox(height: 16),
          _buildGladiatorsOverview(gameState, context),
          const SizedBox(height: 16),
          _buildQuickActions(gameState, gameService, context),
          const SizedBox(height: 16),
          _buildAlertsAndWarnings(gameState, context),
        ],
      ),
    );
  }

  Widget _buildFinancialOverview(GameState gameState, GameService gameService, BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Financial Overview',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: 'Available Funds',
                    value: '${gameState.money}💰',
                    icon: Icons.account_balance_wallet,
                    color: gameState.money >= 0 ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: 'Outstanding Debt',
                    value: '${gameState.debt}💰',
                    icon: Icons.trending_down,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: 'Daily Expenses',
                    value: '${gameState.dailyExpenses}💰',
                    icon: Icons.receipt,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: 'Day',
                    value: '${gameState.day}',
                    icon: Icons.calendar_today,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGladiatorsOverview(GameState gameState, BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.people, color: Theme.of(context).colorScheme.secondary),
                const SizedBox(width: 8),
                Text(
                  'Gladiator Management',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatColumn(
                  label: 'Total',
                  value: gameState.totalGladiators.toString(),
                  color: Theme.of(context).colorScheme.primary,
                ),
                _StatColumn(
                  label: 'Available',
                  value: gameState.availableGladiators.toString(),
                  color: Colors.green,
                ),
                _StatColumn(
                  label: 'Injured',
                  value: gameState.injuredGladiators.toString(),
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(GameState gameState, GameService gameService, BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flash_on, color: Theme.of(context).colorScheme.tertiary),
                const SizedBox(width: 8),
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => gameService.advanceDay(),
                    icon: const Icon(Icons.skip_next),
                    label: const Text('Advance Day'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: gameState.debt > 0 && gameState.money >= 100
                        ? () => _showPayDebtDialog(context, gameService)
                        : null,
                    icon: const Icon(Icons.payment),
                    label: const Text('Pay Debt'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertsAndWarnings(GameState gameState, BuildContext context) {
    final alerts = <Widget>[];

    if (gameState.debt > 15000) {
      alerts.add(_AlertCard(
        title: 'Critical Debt Level',
        message: 'Your debt is approaching dangerous levels!',
        icon: Icons.warning,
        color: Colors.red,
      ));
    } else if (gameState.debt > 10000) {
      alerts.add(_AlertCard(
        title: 'High Debt Warning',
        message: 'Consider paying down your debt soon.',
        icon: Icons.info,
        color: Colors.orange,
      ));
    }

    if (gameState.money < 500) {
      alerts.add(_AlertCard(
        title: 'Low Funds',
        message: 'You\'re running low on money.',
        icon: Icons.account_balance_wallet,
        color: Colors.orange,
      ));
    }

    if (gameState.availableGladiators == 0) {
      alerts.add(_AlertCard(
        title: 'No Available Gladiators',
        message: 'All gladiators are busy or injured.',
        icon: Icons.person_off,
        color: Colors.red,
      ));
    }

    if (alerts.isEmpty) {
      alerts.add(_AlertCard(
        title: 'All Systems Normal',
        message: 'Your gladiator school is operating smoothly.',
        icon: Icons.check_circle,
        color: Colors.green,
      ));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notifications, color: Theme.of(context).colorScheme.error),
                const SizedBox(width: 8),
                Text(
                  'Alerts & Notifications',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...alerts,
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: Theme.of(context).colorScheme.secondary),
                const SizedBox(width: 8),
                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Activity log coming soon...'),
          ],
        ),
      ),
    );
  }

  void _showNewGameDialog(BuildContext context, GameService gameService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start New Game'),
        content: const Text('Are you sure you want to start a new game? All current progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              gameService.newGame();
            },
            child: const Text('New Game'),
          ),
        ],
      ),
    );
  }

  void _showPayDebtDialog(BuildContext context, GameService gameService) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pay Debt'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current debt: ${gameService.gameState.debt}💰'),
            Text('Available money: ${gameService.gameState.money}💰'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount to pay',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = int.tryParse(controller.text) ?? 0;
              if (amount > 0) {
                gameService.payDebt(amount);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Pay'),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
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
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

class _AlertCard extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color color;

  const _AlertCard({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
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
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
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
