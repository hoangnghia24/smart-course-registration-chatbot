/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:serverpod_client/serverpod_client.dart' as _i1;

abstract class CourseSection implements _i1.SerializableModel {
  CourseSection._({
    this.id,
    required this.courseId,
    required this.termId,
    required this.lecturerId,
    required this.sectionCode,
    required this.capacity,
    this.minimumEnrollment,
    required this.status,
    required this.createdAt,
  });

  factory CourseSection({
    int? id,
    required int courseId,
    required int termId,
    required int lecturerId,
    required String sectionCode,
    required int capacity,
    int? minimumEnrollment,
    required String status,
    required DateTime createdAt,
  }) = _CourseSectionImpl;

  factory CourseSection.fromJson(Map<String, dynamic> jsonSerialization) {
    return CourseSection(
      id: jsonSerialization['id'] as int?,
      courseId: jsonSerialization['courseId'] as int,
      termId: jsonSerialization['termId'] as int,
      lecturerId: jsonSerialization['lecturerId'] as int,
      sectionCode: jsonSerialization['sectionCode'] as String,
      capacity: jsonSerialization['capacity'] as int,
      minimumEnrollment: jsonSerialization['minimumEnrollment'] as int?,
      status: jsonSerialization['status'] as String,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// Mon hoc duoc mo lop
  int courseId;

  /// Hoc ky mo lop
  int termId;

  /// Giang vien duoc phan cong
  int lecturerId;

  /// Ma lop hoc phan
  String sectionCode;

  /// Si so toi da
  int capacity;

  /// Si so toi thieu de mo lop
  int? minimumEnrollment;

  /// Trang thai lop hoc phan
  /// DRAFT, OPEN, CLOSED, CANCELLED, COMPLETED
  String status;

  /// Thoi gian tao lop
  DateTime createdAt;

  /// Returns a shallow copy of this [CourseSection]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CourseSection copyWith({
    int? id,
    int? courseId,
    int? termId,
    int? lecturerId,
    String? sectionCode,
    int? capacity,
    int? minimumEnrollment,
    String? status,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CourseSection',
      if (id != null) 'id': id,
      'courseId': courseId,
      'termId': termId,
      'lecturerId': lecturerId,
      'sectionCode': sectionCode,
      'capacity': capacity,
      if (minimumEnrollment != null) 'minimumEnrollment': minimumEnrollment,
      'status': status,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CourseSectionImpl extends CourseSection {
  _CourseSectionImpl({
    int? id,
    required int courseId,
    required int termId,
    required int lecturerId,
    required String sectionCode,
    required int capacity,
    int? minimumEnrollment,
    required String status,
    required DateTime createdAt,
  }) : super._(
         id: id,
         courseId: courseId,
         termId: termId,
         lecturerId: lecturerId,
         sectionCode: sectionCode,
         capacity: capacity,
         minimumEnrollment: minimumEnrollment,
         status: status,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [CourseSection]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CourseSection copyWith({
    Object? id = _Undefined,
    int? courseId,
    int? termId,
    int? lecturerId,
    String? sectionCode,
    int? capacity,
    Object? minimumEnrollment = _Undefined,
    String? status,
    DateTime? createdAt,
  }) {
    return CourseSection(
      id: id is int? ? id : this.id,
      courseId: courseId ?? this.courseId,
      termId: termId ?? this.termId,
      lecturerId: lecturerId ?? this.lecturerId,
      sectionCode: sectionCode ?? this.sectionCode,
      capacity: capacity ?? this.capacity,
      minimumEnrollment: minimumEnrollment is int?
          ? minimumEnrollment
          : this.minimumEnrollment,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
