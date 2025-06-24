enum StaffType {
  trainer,
  medic,
  manager,
}

class Staff {
  final String id;
  final String name;
  final StaffType type;
  final int hiringCost;
  final int dailySalary;
  final Map<String, double> bonuses; // e.g., {'healingSpeed': 0.5, 'trainingSpeed': 0.3}
  final String description;

  Staff({
    required this.id,
    required this.name,
    required this.type,
    required this.hiringCost,
    required this.dailySalary,
    required this.bonuses,
    required this.description,
  });

  // Get bonus value for a specific type
  double getBonus(String bonusType) {
    return bonuses[bonusType] ?? 0.0;
  }

  // Copy with new values
  Staff copyWith({
    String? id,
    String? name,
    StaffType? type,
    int? hiringCost,
    int? dailySalary,
    Map<String, double>? bonuses,
    String? description,
  }) {
    return Staff(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      hiringCost: hiringCost ?? this.hiringCost,
      dailySalary: dailySalary ?? this.dailySalary,
      bonuses: bonuses ?? this.bonuses,
      description: description ?? this.description,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.index,
      'hiringCost': hiringCost,
      'dailySalary': dailySalary,
      'bonuses': bonuses,
      'description': description,
    };
  }

  // Create from JSON
  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: json['id'],
      name: json['name'],
      type: StaffType.values[json['type']],
      hiringCost: json['hiringCost'],
      dailySalary: json['dailySalary'],
      bonuses: Map<String, double>.from(json['bonuses']),
      description: json['description'],
    );
  }

  // Create preset staff members
  static Staff createTrainer(String id, String name) {
    return Staff(
      id: id,
      name: name,
      type: StaffType.trainer,
      hiringCost: 500,
      dailySalary: 50,
      bonuses: {
        'trainingSpeed': 0.5, // 50% faster training
        'trainingEffectiveness': 0.2, // 20% better stat gains
      },
      description: 'Improves training speed and effectiveness',
    );
  }

  static Staff createMedic(String id, String name) {
    return Staff(
      id: id,
      name: name,
      type: StaffType.medic,
      hiringCost: 600,
      dailySalary: 60,
      bonuses: {
        'healingSpeed': 0.6, // 60% faster healing
        'healingCost': -0.3, // 30% cheaper paid healing
      },
      description: 'Improves healing speed and reduces healing costs',
    );
  }

  static Staff createManager(String id, String name) {
    return Staff(
      id: id,
      name: name,
      type: StaffType.manager,
      hiringCost: 800,
      dailySalary: 80,
      bonuses: {
        'fightRewards': 0.25, // 25% more fight rewards
        'recruitmentCost': -0.2, // 20% cheaper gladiator recruitment
      },
      description: 'Increases fight rewards and reduces recruitment costs',
    );
  }
}
