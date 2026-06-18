class PublicationStats {
  const PublicationStats({
    required this.total,
    required this.active,
    required this.closed,
    required this.byType,
  });

  final int total;
  final int active;
  final int closed;
  final Map<String, int> byType;

  factory PublicationStats.fromJson(Map<String, dynamic> json) {
    final byTypeJson = json['byType'] as Map<String, dynamic>? ?? {};

    return PublicationStats(
      total: json['total'] as int? ?? 0,
      active: json['active'] as int? ?? 0,
      closed: json['closed'] as int? ?? 0,
      byType: {
        'scholarship': byTypeJson['scholarship'] as int? ?? 0,
        'internship': byTypeJson['internship'] as int? ?? 0,
        'project': byTypeJson['project'] as int? ?? 0,
      },
    );
  }
}
