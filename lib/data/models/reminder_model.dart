class ReminderModel {
  final int id;
  final String title;
  final String? description;
  final DateTime? dateTime;
  final bool isCompleted;

  const ReminderModel({
    required this.id,
    required this.title,
    this.description,
    this.dateTime,
    this.isCompleted = false,
  });

  ReminderModel copyWith({
    String? title,
    String? description,
    bool clearDescription = false,
    DateTime? dateTime,
    bool clearDateTime = false,
    bool? isCompleted,
  }) {
    return ReminderModel(
      id: id,
      title: title ?? this.title,
      description: clearDescription ? null : (description ?? this.description),
      dateTime: clearDateTime ? null : (dateTime ?? this.dateTime),
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'dateTime': dateTime?.toIso8601String(),
        'isCompleted': isCompleted,
      };

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      dateTime: json['dateTime'] == null
          ? null
          : DateTime.parse(json['dateTime'] as String),
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}
