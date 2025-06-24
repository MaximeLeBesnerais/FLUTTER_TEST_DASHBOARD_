class ActivityLog {
  final String id;
  final DateTime timestamp;
  final String message;
  final ActivityType type;

  ActivityLog({
    required this.id,
    required this.timestamp,
    required this.message,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'message': message,
      'type': type.toString(),
    };
  }

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      message: json['message'],
      type: ActivityType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => ActivityType.general,
      ),
    );
  }
}

enum ActivityType {
  battle,
  training,
  healing,
  recruitment,
  staff,
  finance,
  general,
}
