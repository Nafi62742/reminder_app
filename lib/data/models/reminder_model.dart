class ReminderModel {
  final int id;
  final String title;
  final String? description;
  final DateTime dateTime;
  final bool isCompleted;

  const ReminderModel({
    required this.id,
    required this.title,
    this.description,
    required this.dateTime,
    this.isCompleted = false,
  });

  ReminderModel copyWith({
    String? title,
    String? description,
    bool clearDescription = false,
    DateTime? dateTime,
    bool? isCompleted,
  }) {
    return ReminderModel(
      id: id,
      title: title ?? this.title,
      description: clearDescription ? null : (description ?? this.description),
      dateTime: dateTime ?? this.dateTime,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'dateTime': dateTime.toIso8601String(),
        'isCompleted': isCompleted,
      };

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      dateTime: DateTime.parse(json['dateTime'] as String),
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}
