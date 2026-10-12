// ═══════════════════════════════════════════════════════════════════
// FILE 1: department_model.dart
// Path: lib/model/department_model.dart
// ═══════════════════════════════════════════════════════════════════

class DepartmentModel {
  final String id;
  final String nameEn;
  final String nameAr;
  final String iconUrl;
  final DateTime? createdAt;

  const DepartmentModel({
    required this.id,
    this.nameEn = '',
    this.nameAr = '',
    this.iconUrl = '',
    this.createdAt,
  });

  factory DepartmentModel.empty() => DepartmentModel(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    createdAt: DateTime.now(),
  );

  factory DepartmentModel.fromMap(String id, Map<String, dynamic> map) {
    return DepartmentModel(
      id: id,
      // Tolerant parsing: ONE document with an unexpected type (e.g. a
      // Firestore Timestamp in createdAt) used to throw here and make the
      // WHOLE department list fail → Arabic names never reached the site.
      nameEn: (map['nameEn'] ?? '').toString(),
      nameAr: (map['nameAr'] ?? '').toString(),
      iconUrl: (map['iconUrl'] ?? '').toString(),
      createdAt: _parseDate(map['createdAt']),
    );
  }

  /// createdAt may be an ISO string, a Firestore Timestamp or millis.
  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v);
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    try {
      return (v as dynamic).toDate() as DateTime; // Timestamp
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> toMap() => {
    'nameEn': nameEn,
    'nameAr': nameAr,
    'iconUrl': iconUrl,
    'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
  };

  DepartmentModel copyWith({
    String? id,
    String? nameEn,
    String? nameAr,
    String? iconUrl,
    DateTime? createdAt,
  }) =>
      DepartmentModel(
        id: id ?? this.id,
        nameEn: nameEn ?? this.nameEn,
        nameAr: nameAr ?? this.nameAr,
        iconUrl: iconUrl ?? this.iconUrl,
        createdAt: createdAt ?? this.createdAt,
      );
}