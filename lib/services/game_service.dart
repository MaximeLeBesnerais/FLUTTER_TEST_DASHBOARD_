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

class GameService extends ChangeNotifier {
  late GameState _gameState;
  Timer? _autoSaveTimer;
  bool _isInitialized = false;

  GameState get gameState => _gameState;
  bool get isInitialized => _isInitialized;

  GameService() {
    // Initialize with a default game state immediately
    _gameState = _createNewGame();
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
    final gladiator = _gameState.getGladiator(gladiatorId);
    final opponent = _gameState.availableOpponents
        .where((o) => o.id == opponentId)
        .firstOrNull;

    // Debug logging
    debugPrint('Battle attempt: gladiator=$gladiator, opponent=$opponent');
    if (gladiator != null) {
      debugPrint('Gladiator available: ${gladiator.isAvailable}, status: ${gladiator.status}');
    }

    if (gladiator == null || opponent == null || !gladiator.isAvailable) {
      debugPrint('Battle failed - gladiator null: ${gladiator == null}, opponent null: ${opponent == null}, not available: ${gladiator != null ? !gladiator.isAvailable : 'N/A'}');
      return null;
    }

    // Set gladiator as fighting
    _gameState.updateGladiator(gladiator.copyWith(status: GladiatorStatus.fighting));
    notifyListeners(); // Update UI immediately

    try {
      // Simulate battle
      final result = BattleEngine.simulateBattle(gladiator, opponent);

      // Update gladiator based on result - ALWAYS set back to idle or injured
      final updatedGladiator = gladiator.copyWith(
        hp: gladiator.hp - result.gladiatorDamage,
        wins: result.gladiatorWon ? gladiator.wins + 1 : gladiator.wins,
        losses: !result.gladiatorWon ? gladiator.losses + 1 : gladiator.losses,
        status: result.gladiatorDamage > 0 ? GladiatorStatus.injured : GladiatorStatus.idle,
        // Use a very short cooldown - 30 seconds real time 
        cooldownUntil: DateTime.now().add(const Duration(seconds: 30)),
      );

      _gameState.updateGladiator(updatedGladiator);

      // Add money if won
      if (result.gladiatorWon) {
        final rewardWithBonus = (result.rewardMoney * (1.0 + _gameState.staff
            .fold(0.0, (sum, staff) => sum + staff.getBonus('fightRewards')))).round();
        _gameState.addMoney(rewardWithBonus);
      }

      await _autoSave();
      notifyListeners();
      return result;
      
    } catch (e) {
      // If anything goes wrong, make sure gladiator is not stuck in fighting state
      debugPrint('Battle error: $e');
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

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    super.dispose();
  }
}
