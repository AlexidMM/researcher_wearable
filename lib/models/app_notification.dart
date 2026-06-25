class AppNotification {
  const AppNotification({
    required this.id,
    required this.message,
    required this.type,
    required this.isRead,
    this.createdAt,
    this.publicationTitle,
  });

  final int id;
  final String message;
  final String type;
  final bool isRead;
  final DateTime? createdAt;
  final String? publicationTitle;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final publication = json['publication'] as Map<String, dynamic>?;

    return AppNotification(
      id: _asInt(json['id']),
      message: json['message']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      isRead: _asBool(json['isRead'] ?? json['is_read']),
      createdAt: _parseDate(json['createdAt'] ?? json['created_at']),
      publicationTitle: publication?['title']?.toString(),
    );
  }

  bool get isOpened => type == 'publication_opened';
  bool get isClosed => type == 'publication_closed';
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

bool _asBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = value?.toString().toLowerCase();
  return text == 'true' || text == '1';
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
