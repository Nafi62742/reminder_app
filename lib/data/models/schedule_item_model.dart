/// A recurring daily-routine item (e.g. "Wake up", "Drink water"). Completion
/// is tracked separately, per calendar day — see [ScheduleRepository].
class ScheduleItemModel {
  final int id;
  final String title;
  final int? timeMinutes; // minutes since midnight; null = no fixed time
  final int order;

  const ScheduleItemModel({
    required this.id,
    required this.title,
    this.timeMinutes,
    required this.order,
  });

  ScheduleItemModel copyWith({
    String? title,
    int? timeMinutes,
    bool clearTime = false,
    int? order,
  }) {
    return ScheduleItemModel(
      id: id,
      title: title ?? this.title,
      timeMinutes: clearTime ? null : (timeMinutes ?? this.timeMinutes),
      order: order ?? this.order,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'timeMinutes': timeMinutes,
        'order': order,
      };

  factory ScheduleItemModel.fromJson(Map<String, dynamic> json) {
    return ScheduleItemModel(
      id: json['id'] as int,
      title: json['title'] as String,
      timeMinutes: json['timeMinutes'] as int?,
      order: json['order'] as int? ?? 0,
    );
  }
}
