// ═══════════════════════════════════════════════════════════════════
// FILE 3: department_repository_impl.dart
// Path: lib/repo/department/department_repository_impl.dart
// ═══════════════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';


import '../../domain/base_repository/department_repo.dart';
import '../models/department_model.dart';

class DepartmentRepoImpl implements DepartmentRepo {
  final FirebaseFirestore _firestore;

  DepartmentRepoImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('departments');

  @override
  Future<List<DepartmentModel>> fetchAllDepartments() async {
    try {
      // No orderBy: Firestore silently drops documents that have no
      // createdAt field from an orderBy query. Sort in memory instead.
      final snapshot =
          await _collection.get(const GetOptions(source: Source.server));

      final depts = snapshot.docs
          .map((doc) => DepartmentModel.fromMap(doc.id, doc.data()))
          .toList()
        ..sort((a, b) => (b.createdAt ?? DateTime(0))
            .compareTo(a.createdAt ?? DateTime(0)));
      assert(() {
        // ignore: avoid_print
        print('🏷️ departments loaded: ${depts.map((d) => '${d.nameEn} → ${d.nameAr.isEmpty ? '(no Arabic name)' : d.nameAr}').join(' | ')}');
        return true;
      }());

      return depts;
    } catch (e) {
      try {
        final snapshot =
            await _collection.get(const GetOptions(source: Source.cache));
        return snapshot.docs
            .map((doc) => DepartmentModel.fromMap(doc.id, doc.data()))
            .toList();
      } catch (cacheError) {
        rethrow;
      }
    }
  }

  @override
  Future<DepartmentModel> createDepartment(DepartmentModel dept) async {
    try {
      final docRef = await _collection.add(dept.toMap());
      final created = dept.copyWith(id: docRef.id);
      return created;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<DepartmentModel> updateDepartment(DepartmentModel dept) async {
    try {
      await _collection.doc(dept.id).update(dept.toMap());
      return dept;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteDepartment(String id) async {
    try {
      await _collection.doc(id).delete();
    } catch (e) {
      rethrow;
    }
  }
}