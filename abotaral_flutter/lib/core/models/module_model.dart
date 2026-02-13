class Module {
  final String? id;
  final String courseId;
  final String title;
  final String? contentBody;
  final int orderIndex;

  Module({
    this.id,
    required this.courseId,
    required this.title,
    this.contentBody,
    required this.orderIndex,
  });

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      id: json['id'] as String?,
      courseId: json['course_id'] as String,
      title: json['title'] as String,
      contentBody: json['content_body'] as String?,
      orderIndex: json['order_index'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'course_id': courseId,
      'title': title,
      if (contentBody != null) 'content_body': contentBody,
      'order_index': orderIndex,
    };
  }
}
