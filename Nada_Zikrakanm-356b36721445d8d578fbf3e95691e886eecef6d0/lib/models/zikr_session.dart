class ZikrSession {
  final String itemId;
  final int count;
  final DateTime timestamp;

  ZikrSession({required this.itemId, required this.count, required this.timestamp});

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'title': itemId,
      'count': count,
      'timestamp': timestamp.toIso8601String(),
      'date': timestamp.toIso8601String(),
    };
  }

  factory ZikrSession.fromMap(Map<String, dynamic> map) {
    final rawDate = map['timestamp'] as String? ?? map['date'] as String?;
    return ZikrSession(
      itemId: map['itemId'] as String? ?? (map['title'] as String? ?? 'default'),
      count: (map['count'] as num?)?.toInt() ?? 0,
      timestamp: rawDate != null ? (DateTime.tryParse(rawDate) ?? DateTime.now()) : DateTime.now(),
    );
  }
}
