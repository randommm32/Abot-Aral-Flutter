class Course {
  final String? id;
  final String title;
  final String description;
  final String category;
  final String difficulty;
  final int duration;
  final int maxLearners;
  final List<String> objectives;
  final String facilitatorId; // formerly instructorId
  final String? coverUrl;
  final DateTime? createdAt;

  Course({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.duration,
    required this.maxLearners,
    required this.objectives,
    required this.facilitatorId,
    this.coverUrl,
    this.createdAt,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      difficulty: json['difficulty'] as String,
      duration: json['duration'] as int,
      maxLearners: json['max_learners'] as int,
      objectives: List<String>.from(json['objectives'] ?? []),
      facilitatorId: json['facilitator_id'] as String,
      coverUrl: json['cover_image_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'category': category,
      'difficulty': difficulty,
      'duration': duration,
      'max_learners': maxLearners,
      'objectives': objectives,
      'facilitator_id': facilitatorId,
      'cover_image_url': coverUrl,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
}
