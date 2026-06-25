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
      id: _asInt(json['id']),
      title: json['title']?.toString() ?? 'Sin título',
      status: _asBool(json['status']),
      type: json['type']?.toString(),
    );
  }
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
