/// A workout routine item with instructions, estimated duration, and target reps/sets.
class WorkoutItemModel {
  final int id;
  final String title;
  final String instructions;
  final int durationMinutes;
  final int targetReps;
  final int sets;
  final String category;
  final int order;

  const WorkoutItemModel({
    required this.id,
    required this.title,
    required this.instructions,
    required this.durationMinutes,
    required this.targetReps,
    this.sets = 3,
    required this.category,
    required this.order,
  });

  WorkoutItemModel copyWith({
    String? title,
    String? instructions,
    int? durationMinutes,
    int? targetReps,
    int? sets,
    String? category,
    int? order,
  }) {
    return WorkoutItemModel(
      id: id,
      title: title ?? this.title,
      instructions: instructions ?? this.instructions,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      targetReps: targetReps ?? this.targetReps,
      sets: sets ?? this.sets,
      category: category ?? this.category,
      order: order ?? this.order,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'instructions': instructions,
        'durationMinutes': durationMinutes,
        'targetReps': targetReps,
        'sets': sets,
        'category': category,
        'order': order,
      };

  factory WorkoutItemModel.fromJson(Map<String, dynamic> json) {
    return WorkoutItemModel(
      id: json['id'] as int,
      title: json['title'] as String,
      instructions: json['instructions'] as String? ?? '',
      durationMinutes: json['durationMinutes'] as int? ?? 5,
      targetReps: json['targetReps'] as int? ?? 12,
      sets: json['sets'] as int? ?? 3,
      category: json['category'] as String? ?? 'General',
      order: json['order'] as int? ?? 0,
    );
  }

  /// Built-in preset workout routines with instructions and estimated times.
  static List<WorkoutItemModel> get defaultPresets => const [
        WorkoutItemModel(
          id: 1,
          title: 'Push-ups',
          instructions:
              'Place hands shoulder-width apart on the floor. Keep your back flat and core braced. Lower your chest until it is an inch from the floor, then press firmly back up to full arm extension.',
          durationMinutes: 6,
          targetReps: 15,
          sets: 3,
          category: 'Upper Body',
          order: 0,
        ),
        WorkoutItemModel(
          id: 2,
          title: 'Bodyweight Squats',
          instructions:
              'Stand with feet shoulder-width apart. Push hips back and bend your knees down until thighs are parallel to the ground. Keep your chest high and drive through your heels to stand.',
          durationMinutes: 8,
          targetReps: 20,
          sets: 3,
          category: 'Lower Body',
          order: 1,
        ),
        WorkoutItemModel(
          id: 3,
          title: 'Plank Hold',
          instructions:
              'Rest on forearms and toes with elbows aligned under shoulders. Squeeze your glutes, draw your navel toward your spine, and hold your body in a rigid straight line without sagging.',
          durationMinutes: 4,
          targetReps: 60, // 60 seconds
          sets: 3,
          category: 'Core',
          order: 2,
        ),
        WorkoutItemModel(
          id: 4,
          title: 'Forward Lunges',
          instructions:
              'Step forward with one leg and lower hips until both knees are bent at 90-degree angles. Keep your front knee behind your toes and torso tall. Push off front foot to return.',
          durationMinutes: 6,
          targetReps: 12, // per leg
          sets: 3,
          category: 'Lower Body',
          order: 3,
        ),
        WorkoutItemModel(
          id: 5,
          title: 'Jumping Jacks',
          instructions:
              'Start standing with feet together and arms at your sides. In one motion, jump feet outward while swinging arms up overhead. Immediately jump back to the starting stance.',
          durationMinutes: 5,
          targetReps: 30,
          sets: 3,
          category: 'Cardio',
          order: 4,
        ),
        WorkoutItemModel(
          id: 6,
          title: 'Mountain Climbers',
          instructions:
              'Assume a push-up position. Alternately drive each knee toward your chest in a quick running motion while keeping your hips level and shoulders directly over your hands.',
          durationMinutes: 5,
          targetReps: 25,
          sets: 3,
          category: 'Core & Cardio',
          order: 5,
        ),
      ];
}
