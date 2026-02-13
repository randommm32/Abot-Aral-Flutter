class Lesson {
  final String? id;
  final String moduleId;
  final String title;
  final String? contentBody;
  final int orderIndex;

  Lesson({
    this.id,
    required this.moduleId,
    required this.title,
    this.contentBody,
    required this.orderIndex,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as String?,
      moduleId: json['module_id'] as String,
      title: json['title'] as String,
      contentBody: json['content_body'] as String?,
      orderIndex: json['order_index'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'module_id': moduleId,
      'title': title,
      if (contentBody != null) 'content_body': contentBody,
      'order_index': orderIndex,
    };
  }
}
