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

/// F07 - Phien ban CTDT dang gan cho sinh vien
abstract class StudentCurriculumAssignmentDto implements _i1.SerializableModel {
  StudentCurriculumAssignmentDto._({
    required this.studentId,
    required this.studentCode,
    this.admissionYear,
    required this.curriculumVersionId,
    required this.curriculumCode,
    required this.majorCode,
    required this.versionCode,
    required this.versionStatus,
    this.suggestedVersionId,
  });

  factory StudentCurriculumAssignmentDto({
    required int studentId,
    required String studentCode,
    int? admissionYear,
    required int curriculumVersionId,
    required String curriculumCode,
    required String majorCode,
    required String versionCode,
    required String versionStatus,
    int? suggestedVersionId,
  }) = _StudentCurriculumAssignmentDtoImpl;

  factory StudentCurriculumAssignmentDto.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return StudentCurriculumAssignmentDto(
      studentId: jsonSerialization['studentId'] as int,
      studentCode: jsonSerialization['studentCode'] as String,
      admissionYear: jsonSerialization['admissionYear'] as int?,
      curriculumVersionId: jsonSerialization['curriculumVersionId'] as int,
      curriculumCode: jsonSerialization['curriculumCode'] as String,
      majorCode: jsonSerialization['majorCode'] as String,
      versionCode: jsonSerialization['versionCode'] as String,
      versionStatus: jsonSerialization['versionStatus'] as String,
      suggestedVersionId: jsonSerialization['suggestedVersionId'] as int?,
    );
  }

  int studentId;

  String studentCode;

  int? admissionYear;

  int curriculumVersionId;

  String curriculumCode;

  String majorCode;

  String versionCode;

  String versionStatus;

  /// Phien ban ma quy tac nam hieu luc se chon cho sinh vien
  /// (cung CTDT, PUBLISHED, effectiveYear lon nhat <= nam nhap hoc); null neu khong co
  int? suggestedVersionId;

  /// Returns a shallow copy of this [StudentCurriculumAssignmentDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  StudentCurriculumAssignmentDto copyWith({
    int? studentId,
    String? studentCode,
    int? admissionYear,
    int? curriculumVersionId,
    String? curriculumCode,
    String? majorCode,
    String? versionCode,
    String? versionStatus,
    int? suggestedVersionId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'StudentCurriculumAssignmentDto',
      'studentId': studentId,
      'studentCode': studentCode,
      if (admissionYear != null) 'admissionYear': admissionYear,
      'curriculumVersionId': curriculumVersionId,
      'curriculumCode': curriculumCode,
      'majorCode': majorCode,
      'versionCode': versionCode,
      'versionStatus': versionStatus,
      if (suggestedVersionId != null) 'suggestedVersionId': suggestedVersionId,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _StudentCurriculumAssignmentDtoImpl
    extends StudentCurriculumAssignmentDto {
  _StudentCurriculumAssignmentDtoImpl({
    required int studentId,
    required String studentCode,
    int? admissionYear,
    required int curriculumVersionId,
    required String curriculumCode,
    required String majorCode,
    required String versionCode,
    required String versionStatus,
    int? suggestedVersionId,
  }) : super._(
         studentId: studentId,
         studentCode: studentCode,
         admissionYear: admissionYear,
         curriculumVersionId: curriculumVersionId,
         curriculumCode: curriculumCode,
         majorCode: majorCode,
         versionCode: versionCode,
         versionStatus: versionStatus,
         suggestedVersionId: suggestedVersionId,
       );

  /// Returns a shallow copy of this [StudentCurriculumAssignmentDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  StudentCurriculumAssignmentDto copyWith({
    int? studentId,
    String? studentCode,
    Object? admissionYear = _Undefined,
    int? curriculumVersionId,
    String? curriculumCode,
    String? majorCode,
    String? versionCode,
    String? versionStatus,
    Object? suggestedVersionId = _Undefined,
  }) {
    return StudentCurriculumAssignmentDto(
      studentId: studentId ?? this.studentId,
      studentCode: studentCode ?? this.studentCode,
      admissionYear: admissionYear is int? ? admissionYear : this.admissionYear,
      curriculumVersionId: curriculumVersionId ?? this.curriculumVersionId,
      curriculumCode: curriculumCode ?? this.curriculumCode,
      majorCode: majorCode ?? this.majorCode,
      versionCode: versionCode ?? this.versionCode,
      versionStatus: versionStatus ?? this.versionStatus,
      suggestedVersionId: suggestedVersionId is int?
          ? suggestedVersionId
          : this.suggestedVersionId,
    );
  }
}
