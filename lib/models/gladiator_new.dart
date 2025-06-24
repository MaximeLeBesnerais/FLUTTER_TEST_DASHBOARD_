enum GladiatorStatus {
  idle,
  training,
  injured,
  fighting,
  healing,
}

enum TrainingType {
  strength,
  speed,
  endurance,
}

class Gladiator {
  final String id;
  final String name;
  int hp;
  final int maxHP;
  int strength;
  int speed;
  int endurance;
  GladiatorStatus status;
  DateTime? cooldownUntil;
  int dailyWage;
  int wins;
  int losses;
  TrainingType? currentTraining;
  int? trainingCompletesOnDay;
  int? healingCompletesOnDay;

  Gladiator({
    required this.id,
    required this.name,
    required this.hp,
    required this.maxHP,
    required this.strength,
    required this.speed,
    required this.endurance,
    this.status = GladiatorStatus.idle,
    this.cooldownUntil,
    required this.dailyWage,
    this.wins = 0,
    this.losses = 0,
    this.currentTraining,
    this.trainingCompletesOnDay,
    this.healingCompletesOnDay,
  });

  // Calculate total power/rating
  int get totalPower => strength + speed + endurance;

  // Check if gladiator is available for action
  bool get isAvailable => status == GladiatorStatus.idle && !isOnCooldown;

  // Check if on cooldown
  bool get isOnCooldown => cooldownUntil != null && DateTime.now().isBefore(cooldownUntil!);

  // Check if training is complete (needs current day to check)
  bool isTrainingComplete(int currentDay) => 
    trainingCompletesOnDay != null && currentDay >= trainingCompletesOnDay!;

  // Check if healing is complete (needs current day to check)
  bool isHealingComplete(int currentDay) => 
    healingCompletesOnDay != null && currentDay >= healingCompletesOnDay!;

  // Get injury percentage
  double get injuryPercentage => (maxHP - hp) / maxHP;

  // Check if critically injured
  bool get isCriticallyInjured => hp < (maxHP * 0.3);

  // Win rate
  double get winRate => (wins + losses) > 0 ? wins / (wins + losses) : 0.0;

  // Complete training
  void completeTraining() {
    if (currentTraining != null) {
      switch (currentTraining!) {
        case TrainingType.strength:
          strength += 1;
          break;
        case TrainingType.speed:
          speed += 1;
          break;
        case TrainingType.endurance:
          endurance += 1;
          break;
      }
      currentTraining = null;
      trainingCompletesOnDay = null;
      status = GladiatorStatus.idle;
    }
  }

  // Complete healing
  void completeHealing() {
    hp = maxHP;
    healingCompletesOnDay = null;
    status = GladiatorStatus.idle;
  }

  // Start training (duration now in days)
  void startTraining(TrainingType type, int currentDay, int durationInDays) {
    currentTraining = type;
    trainingCompletesOnDay = currentDay + durationInDays;
    status = GladiatorStatus.training;
  }

  // Start healing (duration now in days)
  void startHealing(int currentDay, int durationInDays) {
    healingCompletesOnDay = currentDay + durationInDays;
    status = GladiatorStatus.healing;
  }

  // Take damage
  void takeDamage(int damage) {
    hp = (hp - damage).clamp(0, maxHP);
    if (hp < maxHP) {
      status = GladiatorStatus.injured;
    }
  }

  // Heal instantly
  void healInstantly() {
    hp = maxHP;
    healingCompletesOnDay = null;
    status = GladiatorStatus.idle;
  }

  // Copy with new values
  Gladiator copyWith({
    String? id,
    String? name,
    int? hp,
    int? maxHP,
    int? strength,
    int? speed,
    int? endurance,
    GladiatorStatus? status,
    DateTime? cooldownUntil,
    int? dailyWage,
    int? wins,
    int? losses,
    TrainingType? currentTraining,
    int? trainingCompletesOnDay,
    int? healingCompletesOnDay,
  }) {
    return Gladiator(
      id: id ?? this.id,
      name: name ?? this.name,
      hp: hp ?? this.hp,
      maxHP: maxHP ?? this.maxHP,
      strength: strength ?? this.strength,
      speed: speed ?? this.speed,
      endurance: endurance ?? this.endurance,
      status: status ?? this.status,
      cooldownUntil: cooldownUntil ?? this.cooldownUntil,
      dailyWage: dailyWage ?? this.dailyWage,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      currentTraining: currentTraining ?? this.currentTraining,
      trainingCompletesOnDay: trainingCompletesOnDay ?? this.trainingCompletesOnDay,
      healingCompletesOnDay: healingCompletesOnDay ?? this.healingCompletesOnDay,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'hp': hp,
      'maxHP': maxHP,
      'strength': strength,
      'speed': speed,
      'endurance': endurance,
      'status': status.index,
      'cooldownUntil': cooldownUntil?.millisecondsSinceEpoch,
      'dailyWage': dailyWage,
      'wins': wins,
      'losses': losses,
      'currentTraining': currentTraining?.index,
      'trainingCompletesOnDay': trainingCompletesOnDay,
      'healingCompletesOnDay': healingCompletesOnDay,
    };
  }

  // Create from JSON
  factory Gladiator.fromJson(Map<String, dynamic> json) {
    return Gladiator(
      id: json['id'],
      name: json['name'],
      hp: json['hp'],
      maxHP: json['maxHP'],
      strength: json['strength'],
      speed: json['speed'],
      endurance: json['endurance'],
      status: GladiatorStatus.values[json['status']],
      cooldownUntil: json['cooldownUntil'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['cooldownUntil'])
          : null,
      dailyWage: json['dailyWage'],
      wins: json['wins'] ?? 0,
      losses: json['losses'] ?? 0,
      currentTraining: json['currentTraining'] != null 
          ? TrainingType.values[json['currentTraining']]
          : null,
      trainingCompletesOnDay: json['trainingCompletesOnDay'],
      healingCompletesOnDay: json['healingCompletesOnDay'],
    );
  }
}
