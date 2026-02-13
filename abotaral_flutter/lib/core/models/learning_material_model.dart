class LearningMaterial {
  final String? id;
  final String? courseId;
  final String? moduleId;
  final String title;
  final String? description;
  final String fileUrl;
  final String? fileType;
  final String? uploaderId;
  final DateTime? createdAt;

  LearningMaterial({
    this.id,
    this.courseId,
    this.moduleId,
    required this.title,
    this.description,
    required this.fileUrl,
    this.fileType,
    this.uploaderId,
    this.createdAt,
  });

  factory LearningMaterial.fromJson(Map<String, dynamic> json) {
    return LearningMaterial(
      id: json['id'] as String?,
      courseId: json['course_id'] as String?,
      moduleId: json['module_id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      fileUrl: json['file_url'] as String,
      fileType: json['file_type'] as String?,
      uploaderId: json['uploader_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (courseId != null) 'course_id': courseId,
      if (moduleId != null) 'module_id': moduleId,
      'title': title,
      if (description != null) 'description': description,
      'file_url': fileUrl,
      if (fileType != null) 'file_type': fileType,
      if (uploaderId != null) 'uploader_id': uploaderId,
      // created_at is usually handled by DB default
    };
  }
}
