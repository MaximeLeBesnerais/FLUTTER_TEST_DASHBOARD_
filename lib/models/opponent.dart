class Opponent {
  final String id;
  final String name;
  final int strength;
  final int speed;
  final int endurance;
  final int hp;
  final int maxHP;
  final int rewardMoney;
  final int difficultyTier; // 1-5, higher = harder
  final String description;

  Opponent({
    required this.id,
    required this.name,
    required this.strength,
    required this.speed,
    required this.endurance,
    required this.hp,
    required this.maxHP,
    required this.rewardMoney,
    required this.difficultyTier,
    required this.description,
  });

  // Calculate total power/rating
  int get totalPower => strength + speed + endurance;

  // Calculate difficulty relative to gladiator
  double getDifficultyRatio(int gladiatorPower) {
    return totalPower / gladiatorPower;
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'strength': strength,
      'speed': speed,
      'endurance': endurance,
      'hp': hp,
      'maxHP': maxHP,
      'rewardMoney': rewardMoney,
      'difficultyTier': difficultyTier,
      'description': description,
    };
  }

  // Create from JSON
  factory Opponent.fromJson(Map<String, dynamic> json) {
    return Opponent(
      id: json['id'],
      name: json['name'],
      strength: json['strength'],
      speed: json['speed'],
      endurance: json['endurance'],
      hp: json['hp'],
      maxHP: json['maxHP'],
      rewardMoney: json['rewardMoney'],
      difficultyTier: json['difficultyTier'],
      description: json['description'],
    );
  }
}
