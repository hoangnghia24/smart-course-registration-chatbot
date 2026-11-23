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

/// F07 - Hoc phan trong phien ban.
/// Khi gui len: chi can courseId, semester, isRequired, groupCode, itemOrder.
/// Khi tra ve: server dien courseCode, courseName, credits (snapshot).
abstract class AdminCurriculumItemDto implements _i1.SerializableModel {
  AdminCurriculumItemDto._({
    required this.courseId,
    this.courseCode,
    this.courseName,
    this.credits,
    required this.semester,
    required this.isRequired,
    this.groupCode,
    this.itemOrder,
  });

  factory AdminCurriculumItemDto({
    required int courseId,
    String? courseCode,
    String? courseName,
    int? credits,
    required int semester,
    required bool isRequired,
    String? groupCode,
    int? itemOrder,
  }) = _AdminCurriculumItemDtoImpl;

  factory AdminCurriculumItemDto.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return AdminCurriculumItemDto(
      courseId: jsonSerialization['courseId'] as int,
      courseCode: jsonSerialization['courseCode'] as String?,
      courseName: jsonSerialization['courseName'] as String?,
      credits: jsonSerialization['credits'] as int?,
      semester: jsonSerialization['semester'] as int,
      isRequired: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['isRequired'],
      ),
      groupCode: jsonSerialization['groupCode'] as String?,
      itemOrder: jsonSerialization['itemOrder'] as int?,
    );
  }

  int courseId;

  String? courseCode;

  String? courseName;

  int? credits;

  int semester;

  bool isRequired;

  String? groupCode;

  int? itemOrder;

  /// Returns a shallow copy of this [AdminCurriculumItemDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AdminCurriculumItemDto copyWith({
    int? courseId,
    String? courseCode,
    String? courseName,
    int? credits,
    int? semester,
    bool? isRequired,
    String? groupCode,
    int? itemOrder,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AdminCurriculumItemDto',
      'courseId': courseId,
      if (courseCode != null) 'courseCode': courseCode,
      if (courseName != null) 'courseName': courseName,
      if (credits != null) 'credits': credits,
      'semester': semester,
      'isRequired': isRequired,
      if (groupCode != null) 'groupCode': groupCode,
      if (itemOrder != null) 'itemOrder': itemOrder,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AdminCurriculumItemDtoImpl extends AdminCurriculumItemDto {
  _AdminCurriculumItemDtoImpl({
    required int courseId,
    String? courseCode,
    String? courseName,
    int? credits,
    required int semester,
    required bool isRequired,
    String? groupCode,
    int? itemOrder,
  }) : super._(
         courseId: courseId,
         courseCode: courseCode,
         courseName: courseName,
         credits: credits,
         semester: semester,
         isRequired: isRequired,
         groupCode: groupCode,
         itemOrder: itemOrder,
       );

  /// Returns a shallow copy of this [AdminCurriculumItemDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AdminCurriculumItemDto copyWith({
    int? courseId,
    Object? courseCode = _Undefined,
    Object? courseName = _Undefined,
    Object? credits = _Undefined,
    int? semester,
    bool? isRequired,
    Object? groupCode = _Undefined,
    Object? itemOrder = _Undefined,
  }) {
    return AdminCurriculumItemDto(
      courseId: courseId ?? this.courseId,
      courseCode: courseCode is String? ? courseCode : this.courseCode,
      courseName: courseName is String? ? courseName : this.courseName,
      credits: credits is int? ? credits : this.credits,
      semester: semester ?? this.semester,
      isRequired: isRequired ?? this.isRequired,
      groupCode: groupCode is String? ? groupCode : this.groupCode,
      itemOrder: itemOrder is int? ? itemOrder : this.itemOrder,
    );
  }
}
