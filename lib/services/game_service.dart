import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/game_state.dart';
import '../models/gladiator.dart';
import '../models/staff.dart';
import '../assets/names.dart';
import '../assets/adjectives.dart';
import 'battle_engine.dart';
import 'storage_service.dart';
import 'game_clock.dart';

class GameService extends ChangeNotifier {
  late GameState _gameState;
  Timer? _autoSaveTimer;
  bool _isInitialized = false;

  GameState get gameState => _gameState;
  bool get isInitialized => _isInitialized;

  GameService() {
    // Initialize with a default game state immediately
    _gameState = _createNewGame();
    
    // Start the game clock
    final gameClock = GameClock();
    if (!gameClock.isRunning) {
      print('GAME SERVICE: Starting game clock');
      gameClock.start();
    }
    
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    // Try to load existing game
    final savedState = await StorageService.loadGameState();
    if (savedState != null) {
      _gameState = savedState;
    }
    
    _isInitialized = true;
    
    // Start auto-save timer
    _startAutoSave();
    notifyListeners();
  }

  GameState _createNewGame() {
    final gameState = GameState();
    
    // Add starting gladiator
    final startingGladiator = _generateStartingGladiator();
    gameState.addGladiator(startingGladiator);
    
    // Generate initial opponents
    gameState.advanceDay(); // This will generate opponents
    
    return gameState;
  }

  Gladiator _generateStartingGladiator() {
    final random = Random();
    
    return Gladiator(
      id: 'starter_${DateTime.now().millisecondsSinceEpoch}',
      name: _generateGladiatorName(),
      hp: 100,
      maxHP: 100,
      strength: 8 + random.nextInt(4), // 8-11
      speed: 8 + random.nextInt(4),    // 8-11
      endurance: 8 + random.nextInt(4), // 8-11
      dailyWage: 50,
    );
  }

  // Gladiator operations
  Future<bool> trainGladiator(String gladiatorId, TrainingType type) async {
    final success = _gameState.trainGladiator(gladiatorId, type);
    if (success) {
      await _autoSave();
      notifyListeners();
    }
    return success;
  }

  Future<bool> healGladiator(String gladiatorId, {bool isPaid = false}) async {
    final success = _gameState.healGladiator(gladiatorId, isPaid: isPaid);
    if (success) {
      await _autoSave();
      notifyListeners();
    }
    return success;
  }

  // Battle operations
  Future<BattleResult?> fightOpponent(String gladiatorId, String opponentId) async {
    print('BATTLE START: Attempting battle with gladiator=${gladiatorId}, opponent=${opponentId}');
    
    final gladiator = _gameState.getGladiator(gladiatorId);
    final opponent = _gameState.availableOpponents
        .where((o) => o.id == opponentId)
        .firstOrNull;

    // Enhanced debug logging
    print('BATTLE VALIDATION: gladiator found=${gladiator != null}');
    if (gladiator != null) {
      print('BATTLE VALIDATION: gladiator name=${gladiator.name}, available=${gladiator.isAvailable}, status=${gladiator.status}, cooldownUntil=${gladiator.cooldownUntil}');
    }
    print('BATTLE VALIDATION: opponent found=${opponent != null}');
    if (opponent != null) {
      print('BATTLE VALIDATION: opponent name=${opponent.name}');
    }

    if (gladiator == null || opponent == null || !gladiator.isAvailable) {
      print('BATTLE FAILED: Validation failed - gladiator null: ${gladiator == null}, opponent null: ${opponent == null}, not available: ${gladiator != null ? !gladiator.isAvailable : 'N/A'}');
      return null;
    }

    print('BATTLE PROGRESS: Setting gladiator to fighting status');
    // Set gladiator as fighting
    _gameState.updateGladiator(gladiator.copyWith(status: GladiatorStatus.fighting));
    notifyListeners(); // Update UI immediately

    try {
      print('BATTLE PROGRESS: Starting battle simulation');
      // Simulate battle
      final result = BattleEngine.simulateBattle(gladiator, opponent);
      print('BATTLE RESULT: gladiatorWon=${result.gladiatorWon}, damage=${result.gladiatorDamage}, reward=${result.rewardMoney}');

      // Calculate new status based on result
      final newStatus = result.gladiatorDamage > 0 ? GladiatorStatus.injured : GladiatorStatus.idle;
      
      // Use game time for cooldown - 30 seconds in game time (faster than real time)
      final gameClock = GameClock();
      final newCooldown = gameClock.gameTime.add(const Duration(seconds: 30));
      
      print('BATTLE PROGRESS: Updating gladiator - newHP=${gladiator.hp - result.gladiatorDamage}, newStatus=${newStatus}, cooldownUntil=${newCooldown}');
      print('BATTLE PROGRESS: Current game time=${gameClock.gameTime}');

      // Update gladiator based on result - ALWAYS set back to idle or injured
      final updatedGladiator = gladiator.copyWith(
        hp: gladiator.hp - result.gladiatorDamage,
        wins: result.gladiatorWon ? gladiator.wins + 1 : gladiator.wins,
        losses: !result.gladiatorWon ? gladiator.losses + 1 : gladiator.losses,
        status: newStatus,
        cooldownUntil: newCooldown,
      );

      _gameState.updateGladiator(updatedGladiator);

      // Add money if won
      if (result.gladiatorWon) {
        final rewardWithBonus = (result.rewardMoney * (1.0 + _gameState.staff
            .fold(0.0, (sum, staff) => sum + staff.getBonus('fightRewards')))).round();
        print('BATTLE PROGRESS: Adding reward money=${rewardWithBonus}');
        _gameState.addMoney(rewardWithBonus);
      }

      await _autoSave();
      
      // CRITICAL: Force multiple notifications to ensure UI updates
      print('BATTLE PROGRESS: Forcing UI updates');
      notifyListeners();
      
      // Wait a small amount and notify again to ensure UI picks up the changes
      await Future.delayed(const Duration(milliseconds: 100));
      notifyListeners();
      
      print('BATTLE COMPLETE: Battle successfully completed and saved');
      return result;
      
    } catch (e) {
      // If anything goes wrong, make sure gladiator is not stuck in fighting state
      print('BATTLE ERROR: Exception occurred: $e');
      print('BATTLE ERROR: Resetting gladiator status to idle');
      _gameState.updateGladiator(gladiator.copyWith(status: GladiatorStatus.idle));
      notifyListeners();
      return null;
    }
  }

  // Staff operations
  Future<bool> hireStaff(Staff staff) async {
    if (_gameState.money >= staff.hiringCost) {
      _gameState.hireStaff(staff);
      await _autoSave();
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> fireStaff(String staffId) async {
    _gameState.fireStaff(staffId);
    await _autoSave();
    notifyListeners();
  }

  // Gladiator recruitment
  List<Gladiator> generateRecruitableGladiators() {
    final random = Random();
    final gladiators = <Gladiator>[];
    
    // Generate 3-6 recruitable gladiators
    final count = 3 + random.nextInt(4);
    
    for (int i = 0; i < count; i++) {
      final tier = 1 + random.nextInt(3); // Tiers 1-3 for recruits
      final baseStats = 5 + (tier * 2);
      
      gladiators.add(Gladiator(
        id: 'recruit_${DateTime.now().millisecondsSinceEpoch}_$i',
        name: _generateGladiatorName(),
        hp: 80 + (tier * 10),
        maxHP: 80 + (tier * 10),
        strength: baseStats + random.nextInt(4),
        speed: baseStats + random.nextInt(4),
        endurance: baseStats + random.nextInt(4),
        dailyWage: 30 + (tier * 20),
      ));
    }
    
    return gladiators;
  }

  String _generateGladiatorName() {
    final random = Random();
    final firstName = names[random.nextInt(names.length)];
    final adjective = adjectives[random.nextInt(adjectives.length)];
    
    // Convert to proper case
    final properFirstName = firstName.toLowerCase();
    final properAdjective = adjective.toLowerCase();
    
    return '${properFirstName[0].toUpperCase()}${properFirstName.substring(1)} the ${properAdjective[0].toUpperCase()}${properAdjective.substring(1)}';
  }

  int calculateRecruitmentCost(Gladiator gladiator) {
    final baseCost = gladiator.totalPower * 25;
    final costWithBonus = (baseCost * (1.0 - _gameState.staff
        .fold(0.0, (sum, staff) => sum + staff.getBonus('recruitmentCost')))).round();
    return costWithBonus.clamp(100, 10000);
  }

  Future<bool> recruitGladiator(Gladiator gladiator) async {
    final cost = calculateRecruitmentCost(gladiator);
    if (_gameState.spendMoney(cost)) {
      _gameState.addGladiator(gladiator);
      await _autoSave();
      notifyListeners();
      return true;
    }
    return false;
  }

  // Day progression
  Future<void> advanceDay() async {
    _gameState.advanceDay();
    await _autoSave();
    notifyListeners();
  }

  // Debt management
  Future<void> payDebt(int amount) async {
    _gameState.payDebt(amount);
    await _autoSave();
    notifyListeners();
  }

  // Game control
  Future<void> saveGame() async {
    await StorageService.saveGameState(_gameState);
  }

  Future<void> newGame() async {
    await StorageService.deleteSavedGame();
    _gameState = _createNewGame();
    await _autoSave();
    notifyListeners();
  }

  void pauseGame() {
    _gameState.pauseGame();
    notifyListeners();
  }

  void resumeGame() {
    _gameState.resumeGame();
    notifyListeners();
  }

  // Auto-save functionality
  void _startAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      _autoSave();
    });
  }

  Future<void> _autoSave() async {
    await StorageService.autoSave(_gameState);
  }

  // Debug helper method
  void debugPrintGladiatorStates() {
    print('=== GLADIATOR STATES DEBUG ===');
    print('Total gladiators: ${_gameState.gladiators.length}');
    final gameClock = GameClock();
    print('Current game time: ${gameClock.gameTime}');
    print('Game clock running: ${gameClock.isRunning}');
    
    for (final gladiator in _gameState.gladiators) {
      print('Gladiator: ${gladiator.name}');
      print('  Status: ${gladiator.status}');
      print('  HP: ${gladiator.hp}/${gladiator.maxHP}');
      print('  Cooldown until: ${gladiator.cooldownUntil}');
      print('  Is on cooldown: ${gladiator.isOnCooldown}');
      print('  Is available: ${gladiator.isAvailable}');
      print('  ---');
    }
    print('=== END DEBUG ===');
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    super.dispose();
  }
}
