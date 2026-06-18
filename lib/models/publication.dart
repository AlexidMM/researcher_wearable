class Publication {
  const Publication({
    required this.id,
    required this.title,
    required this.status,
    this.type,
  });

  final int id;
  final String title;
  final bool status;
  final String? type;

  factory Publication.fromJson(Map<String, dynamic> json) {
    return Publication(
      id: json['id'] as int,
      title: json['title'] as String,
      status: json['status'] as bool? ?? true,
      type: json['type'] as String?,
    );
  }
}
