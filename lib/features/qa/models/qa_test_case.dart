enum QACategory {
  alarm,
  ringing,
  permission,
  worldClock,
  stopwatch,
  sleepTimer,
  bedtime,
  storage,
  background,
}

enum QAStatus {
  notTested,
  passed,
  failed,
  blocked,
}

class QATestCase {
  final String id;
  final String name;
  final QACategory category;
  final String relatedScreen;
  final String preconditions;
  final List<String> steps;
  final String expectedResult;
  String actualResult;
  QAStatus status;
  DateTime? executedAt;
  String? errorMessage;
  final bool isAutomated;

  QATestCase({
    required this.id,
    required this.name,
    required this.category,
    required this.relatedScreen,
    required this.preconditions,
    required this.steps,
    required this.expectedResult,
    this.actualResult = 'Not yet executed',
    this.status = QAStatus.notTested,
    this.executedAt,
    this.errorMessage,
    this.isAutomated = false,
  });

  String get categoryName {
    switch (category) {
      case QACategory.alarm:
        return 'Alarms';
      case QACategory.ringing:
        return 'Ringing';
      case QACategory.permission:
        return 'Permissions';
      case QACategory.worldClock:
        return 'World Clock';
      case QACategory.stopwatch:
        return 'Stopwatch';
      case QACategory.sleepTimer:
        return 'Sleep Timer';
      case QACategory.bedtime:
        return 'Bedtime';
      case QACategory.storage:
        return 'Local Storage';
      case QACategory.background:
        return 'Background';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category.index,
      'relatedScreen': relatedScreen,
      'preconditions': preconditions,
      'steps': steps,
      'expectedResult': expectedResult,
      'actualResult': actualResult,
      'status': status.index,
      'executedAt': executedAt?.toIso8601String(),
      'errorMessage': errorMessage,
      'isAutomated': isAutomated,
    };
  }

  factory QATestCase.fromJson(Map<String, dynamic> json) {
    return QATestCase(
      id: json['id'] as String,
      name: json['name'] as String,
      category: QACategory.values[json['category'] as int],
      relatedScreen: json['relatedScreen'] as String,
      preconditions: json['preconditions'] as String,
      steps: List<String>.from(json['steps'] as List),
      expectedResult: json['expectedResult'] as String,
      actualResult: json['actualResult'] as String? ?? 'Not yet executed',
      status: QAStatus.values[json['status'] as int],
      executedAt: json['executedAt'] != null
          ? DateTime.tryParse(json['executedAt'] as String)
          : null,
      errorMessage: json['errorMessage'] as String?,
      isAutomated: json['isAutomated'] as bool? ?? false,
    );
  }
}

class QALogEntry {
  final DateTime timestamp;
  final String level; // INFO, WARN, ERROR, DEBUG
  final String tag;
  final String message;

  const QALogEntry({
    required this.timestamp,
    required this.level,
    required this.tag,
    required this.message,
  });

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'level': level,
        'tag': tag,
        'message': message,
      };

  factory QALogEntry.fromJson(Map<String, dynamic> json) => QALogEntry(
        timestamp: DateTime.parse(json['timestamp'] as String),
        level: json['level'] as String,
        tag: json['tag'] as String,
        message: json['message'] as String,
      );
}

