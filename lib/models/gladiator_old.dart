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
  
  DateTime? trainingUntil;
  DateTime? healingUntil;

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
    this.trainingUntil,
    this.healingUntil,
  });

  // Calculate total power/rating
  int get totalPower => strength + speed + endurance;

  // Check if gladiator is available for action
  bool get isAvailable => status == GladiatorStatus.idle && !isOnCooldown;

  // Check if on cooldown
  bool get isOnCooldown => cooldownUntil != null && DateTime.now().isBefore(cooldownUntil!);

  // Check if training is complete
  bool get isTrainingComplete => trainingUntil != null && DateTime.now().isAfter(trainingUntil!);

  // Check if healing is complete
  bool get isHealingComplete => healingUntil != null && DateTime.now().isAfter(healingUntil!);

  // Get injury percentage
  double get injuryPercentage => (maxHP - hp) / maxHP;

  // Check if critically injured
  bool get isCriticallyInjured => hp < (maxHP * 0.3);

  // Win rate
  double get winRate => (wins + losses) > 0 ? wins / (wins + losses) : 0.0;

  // Complete training
  void completeTraining() {
    if (currentTraining != null && isTrainingComplete) {
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
      trainingUntil = null;
      status = GladiatorStatus.idle;
    }
  }

  // Complete healing
  void completeHealing() {
    if (isHealingComplete) {
      hp = maxHP;
      healingUntil = null;
      status = GladiatorStatus.idle;
    }
  }

  // Start training
  void startTraining(TrainingType type, Duration duration) {
    currentTraining = type;
    trainingUntil = DateTime.now().add(duration);
    status = GladiatorStatus.training;
  }

  // Start healing
  void startHealing(Duration duration) {
    healingUntil = DateTime.now().add(duration);
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
    healingUntil = null;
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
    DateTime? trainingUntil,
    DateTime? healingUntil,
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
      trainingUntil: trainingUntil ?? this.trainingUntil,
      healingUntil: healingUntil ?? this.healingUntil,
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
      'trainingUntil': trainingUntil?.millisecondsSinceEpoch,
      'healingUntil': healingUntil?.millisecondsSinceEpoch,
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
      trainingUntil: json['trainingUntil'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['trainingUntil'])
          : null,
      healingUntil: json['healingUntil'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['healingUntil'])
          : null,
    );
  }
}
