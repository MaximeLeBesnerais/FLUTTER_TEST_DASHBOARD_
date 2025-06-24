import 'dart:math';
import 'package:flutter/foundation.dart';
import 'gladiator.dart';
import 'staff.dart';
import 'opponent.dart';
import 'activity_log.dart';
import '../assets/names.dart';
import '../assets/adjectives.dart';

class GameState extends ChangeNotifier {
  int _money;
  int _day;
  int _debt;
  final List<Gladiator> _gladiators;
  final List<Staff> _staff;
  final List<ActivityLog> _activityLogs;
  List<Opponent> _availableOpponents;
  DateTime _lastSave;
  bool _isGamePaused;

  GameState({
    int money = 1000,
    int day = 1,
    int debt = 5000,
    List<Gladiator>? gladiators,
    List<Staff>? staff,
    List<ActivityLog>? activityLogs,
    List<Opponent>? availableOpponents,
    DateTime? lastSave,
    bool isGamePaused = false,
  })  : _money = money,
        _day = day,
        _debt = debt,
        _gladiators = gladiators ?? [],
        _staff = staff ?? [],
        _activityLogs = activityLogs ?? [],
        _availableOpponents = availableOpponents ?? [],
        _lastSave = lastSave ?? DateTime.now(),
        _isGamePaused = isGamePaused;

  // Getters
  int get money => _money;
  int get day => _day;
  int get debt => _debt;
  List<Gladiator> get gladiators => List.unmodifiable(_gladiators);
  List<Staff> get staff => List.unmodifiable(_staff);
  List<ActivityLog> get activityLogs => List.unmodifiable(_activityLogs);
  List<Opponent> get availableOpponents => List.unmodifiable(_availableOpponents);
  DateTime get lastSave => _lastSave;
  bool get isGamePaused => _isGamePaused;

  // Calculated properties
  int get dailyExpenses => _gladiators.fold(0, (sum, g) => sum + g.dailyWage) +
                          _staff.fold(0, (sum, s) => sum + s.dailySalary);
  
  int get totalGladiators => _gladiators.length;
  int get availableGladiators => _gladiators.where((g) => g.isAvailable).length;
  int get injuredGladiators => _gladiators.where((g) => g.status == GladiatorStatus.injured).length;
  
  double get debtInterestRate => 0.05; // 5% daily interest
  int get dailyDebtInterest => (_debt * debtInterestRate).round();
  
  // Game over conditions
  bool get isGameOver => _debt > 20000 || (_money < 0 && _debt > 10000);
  String get gameOverReason {
    if (_debt > 20000) return 'Your debt has become unmanageable!';
    if (_money < 0 && _debt > 10000) return 'You ran out of money with excessive debt!';
    return '';
  }

  // Activity log management
  void addActivityLog(String message, ActivityType type) {
    final log = ActivityLog(
      id: '${DateTime.now().millisecondsSinceEpoch}_${_activityLogs.length}',
      timestamp: DateTime.now(),
      message: message,
      type: type,
    );
    _activityLogs.insert(0, log); // Add to beginning for newest first
    
    // Keep only last 100 logs to prevent memory issues
    if (_activityLogs.length > 100) {
      _activityLogs.removeRange(100, _activityLogs.length);
    }
  }

  List<ActivityLog> getRecentLogs({int count = 10}) {
    return _activityLogs.take(count).toList();
  }

  // Money operations
  void addMoney(int amount) {
    _money += amount;
    addActivityLog('Earned $amount gold', ActivityType.finance);
    notifyListeners();
  }

  bool spendMoney(int amount) {
    if (_money >= amount) {
      _money -= amount;
      addActivityLog('Spent $amount gold', ActivityType.finance);
      notifyListeners();
      return true;
    }
    return false;
  }

  // Debt operations
  void payDebt(int amount) {
    if (_money >= amount) {
      _money -= amount;
      _debt = (_debt - amount).clamp(0, _debt);
      addActivityLog('Paid $amount debt', ActivityType.finance);
      notifyListeners();
    }
  }

  void addDebt(int amount) {
    _debt += amount;
    addActivityLog('Incurred $amount debt', ActivityType.finance);
    notifyListeners();
  }

  // Day progression
  void advanceDay() {
    _day++;
    
    // Apply daily costs
    _money -= dailyExpenses;
    
    // Apply debt interest
    _debt += dailyDebtInterest;
    
    // Update gladiator states
    _updateGladiatorStates();
    
    // Generate new opponents
    _generateDailyOpponents();
    
    addActivityLog('Advanced to day $_day', ActivityType.general);
    notifyListeners();
  }

  // Gladiator management
  void addGladiator(Gladiator gladiator) {
    _gladiators.add(gladiator);
    addActivityLog('Recruited ${gladiator.name}', ActivityType.recruitment);
    notifyListeners();
  }

  void removeGladiator(String gladiatorId) {
    final gladiator = getGladiator(gladiatorId);
    if (gladiator != null) {
      _gladiators.removeWhere((g) => g.id == gladiatorId);
      addActivityLog('Released ${gladiator.name}', ActivityType.recruitment);
      notifyListeners();
    }
  }

  void updateGladiator(Gladiator updatedGladiator) {
    final index = _gladiators.indexWhere((g) => g.id == updatedGladiator.id);
    if (index != -1) {
      _gladiators[index] = updatedGladiator;
      notifyListeners();
    }
  }

  Gladiator? getGladiator(String id) {
    try {
      return _gladiators.firstWhere((g) => g.id == id);
    } catch (e) {
      return null;
    }
  }

  // Staff management
  void hireStaff(Staff staffMember) {
    if (spendMoney(staffMember.hiringCost)) {
      _staff.add(staffMember);
      addActivityLog('Hired ${staffMember.name} (${staffMember.type})', ActivityType.staff);
      notifyListeners();
    }
  }

  void fireStaff(String staffId) {
    final staff = _staff.where((s) => s.id == staffId).firstOrNull;
    if (staff != null) {
      _staff.removeWhere((s) => s.id == staffId);
      addActivityLog('Fired ${staff.name}', ActivityType.staff);
      notifyListeners();
    }
  }

  // Training operations
  bool trainGladiator(String gladiatorId, TrainingType type) {
    final gladiator = getGladiator(gladiatorId);
    if (gladiator == null || !gladiator.isAvailable) return false;

    const baseCost = 100;
    final trainingCost = (baseCost * (1.0 - _getStaffBonus('trainingCost'))).round();
    
    if (!spendMoney(trainingCost)) return false;

    // Training now takes 1 day instead of real-time hours
    const trainingDurationDays = 1;

    gladiator.startTraining(type, _day, trainingDurationDays);
    updateGladiator(gladiator);
    addActivityLog('${gladiator.name} started ${type.toString().split('.').last} training', ActivityType.training);
    return true;
  }

  // Healing operations
  bool healGladiator(String gladiatorId, {bool isPaid = false}) {
    final gladiator = getGladiator(gladiatorId);
    if (gladiator == null || gladiator.hp >= gladiator.maxHP) return false;

    if (isPaid) {
      final healCost = (200 * (1.0 - _getStaffBonus('healingCost'))).round();
      if (!spendMoney(healCost)) return false;
      
      gladiator.healInstantly();
      addActivityLog('${gladiator.name} received instant healing', ActivityType.healing);
    } else {
      // Healing now takes 1 day instead of real-time hours
      const healingDurationDays = 1;
      
      gladiator.startHealing(_day, healingDurationDays);
      addActivityLog('${gladiator.name} started natural healing', ActivityType.healing);
    }

    updateGladiator(gladiator);
    return true;
  }

  // Game control
  void pauseGame() {
    _isGamePaused = true;
    notifyListeners();
  }

  void resumeGame() {
    _isGamePaused = false;
    notifyListeners();
  }

  void resetGame() {
    _money = 1000;
    _day = 1;
    _debt = 5000;
    _gladiators.clear();
    _staff.clear();
    _activityLogs.clear();
    _availableOpponents.clear();
    _isGamePaused = false;
    _generateDailyOpponents();
    addActivityLog('Game reset - New beginning!', ActivityType.general);
    notifyListeners();
  }

  // Private helper methods
  void _updateGladiatorStates() {
    for (final gladiator in _gladiators) {
      if (gladiator.isTrainingComplete(_day)) {
        gladiator.completeTraining();
        addActivityLog('${gladiator.name} completed training', ActivityType.training);
      }
      if (gladiator.isHealingComplete(_day)) {
        gladiator.completeHealing();
        addActivityLog('${gladiator.name} finished healing', ActivityType.healing);
      }
      
      // Safety check: if gladiator has been fighting for too long, reset them
      if (gladiator.status == GladiatorStatus.fighting) {
        // Reset any gladiator stuck in fighting state
        final resetGladiator = gladiator.copyWith(status: GladiatorStatus.idle);
        updateGladiator(resetGladiator);
        addActivityLog('${gladiator.name} returned from battle', ActivityType.battle);
      }
    }
  }

  void _generateDailyOpponents() {
    final random = Random();
    _availableOpponents.clear();
    
    // Generate 3-5 opponents of varying difficulty
    final numOpponents = 3 + random.nextInt(3);
    
    for (int i = 0; i < numOpponents; i++) {
      final tier = 1 + random.nextInt(5);
      _availableOpponents.add(_generateOpponent(tier));
    }
  }

  Opponent _generateOpponent(int tier) {
    final random = Random();
    final baseStats = 5 + (tier * 3);
    final statVariation = 3;
    
    final strength = baseStats + random.nextInt(statVariation);
    final speed = baseStats + random.nextInt(statVariation);
    final endurance = baseStats + random.nextInt(statVariation);
    final hp = 80 + (tier * 20);
    
    final reward = 100 + (tier * 50) + random.nextInt(50);
    
    return Opponent(
      id: 'opp_${DateTime.now().millisecondsSinceEpoch}_$tier',
      name: _generateOpponentName(),
      strength: strength,
      speed: speed,
      endurance: endurance,
      hp: hp,
      maxHP: hp,
      rewardMoney: reward,
      difficultyTier: tier,
      description: 'Tier $tier opponent',
    );
  }

  String _generateOpponentName() {
    final random = Random();
    final firstName = names[random.nextInt(names.length)];
    final adjective = adjectives[random.nextInt(adjectives.length)];
    
    // Convert to proper case
    final properFirstName = firstName.toLowerCase();
    final properAdjective = adjective.toLowerCase();
    
    return '${properFirstName[0].toUpperCase()}${properFirstName.substring(1)} the ${properAdjective[0].toUpperCase()}${properAdjective.substring(1)}';
  }

  double _getStaffBonus(String bonusType) {
    return _staff.fold(0.0, (total, staff) => total + staff.getBonus(bonusType));
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'money': _money,
      'day': _day,
      'debt': _debt,
      'gladiators': _gladiators.map((g) => g.toJson()).toList(),
      'staff': _staff.map((s) => s.toJson()).toList(),
      'activityLogs': _activityLogs.map((a) => a.toJson()).toList(),
      'availableOpponents': _availableOpponents.map((o) => o.toJson()).toList(),
      'lastSave': _lastSave.millisecondsSinceEpoch,
      'isGamePaused': _isGamePaused,
    };
  }

  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      money: json['money'],
      day: json['day'],
      debt: json['debt'],
      gladiators: (json['gladiators'] as List?)
          ?.map((g) => Gladiator.fromJson(g))
          .toList(),
      staff: (json['staff'] as List?)
          ?.map((s) => Staff.fromJson(s))
          .toList(),
      activityLogs: (json['activityLogs'] as List?)
          ?.map((a) => ActivityLog.fromJson(a))
          .toList(),
      availableOpponents: (json['availableOpponents'] as List?)
          ?.map((o) => Opponent.fromJson(o))
          .toList(),
      lastSave: json['lastSave'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['lastSave'])
          : null,
      isGamePaused: json['isGamePaused'] ?? false,
    );
  }
}
