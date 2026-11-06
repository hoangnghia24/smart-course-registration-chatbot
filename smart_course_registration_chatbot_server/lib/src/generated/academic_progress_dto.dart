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

import 'package:serverpod/serverpod.dart' as _i1;
import 'academic_course_progress_dto.dart' as _i2;
import 'package:smart_course_registration_chatbot_server/src/generated/protocol.dart'
    as _i3;

/// F23 - Tong hop tien do hoc tap
abstract class AcademicProgressDto
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  AcademicProgressDto._({
    required this.curriculumVersionId,
    this.totalCredits,
    this.earnedCredits,
    this.remainingCredits,
    required this.creditStatus,
    this.gpa,
    required this.gpaStatus,
    required this.courses,
  });

  factory AcademicProgressDto({
    required int curriculumVersionId,
    double? totalCredits,
    double? earnedCredits,
    double? remainingCredits,
    required String creditStatus,
    double? gpa,
    required String gpaStatus,
    required List<_i2.AcademicCourseProgressDto> courses,
  }) = _AcademicProgressDtoImpl;

  factory AcademicProgressDto.fromJson(Map<String, dynamic> jsonSerialization) {
    return AcademicProgressDto(
      curriculumVersionId: jsonSerialization['curriculumVersionId'] as int,
      totalCredits: (jsonSerialization['totalCredits'] as num?)?.toDouble(),
      earnedCredits: (jsonSerialization['earnedCredits'] as num?)?.toDouble(),
      remainingCredits: (jsonSerialization['remainingCredits'] as num?)
          ?.toDouble(),
      creditStatus: jsonSerialization['creditStatus'] as String,
      gpa: (jsonSerialization['gpa'] as num?)?.toDouble(),
      gpaStatus: jsonSerialization['gpaStatus'] as String,
      courses: _i3.Protocol().deserialize<List<_i2.AcademicCourseProgressDto>>(
        jsonSerialization['courses'],
      ),
    );
  }

  /// Phien ban CTDT cua sinh vien
  int curriculumVersionId;

  /// Tong tin chi CTDT yeu cau
  double? totalCredits;

  /// Tin chi da duoc cong nhan
  double? earnedCredits;

  /// Tin chi con thieu
  double? remainingCredits;

  /// CONFIRMED, POLICY_PENDING
  String creditStatus;

  /// Diem trung binh tich luy
  double? gpa;

  /// AVAILABLE, NO_DATA, POLICY_PENDING
  String gpaStatus;

  /// Danh sach tien do tung hoc phan
  List<_i2.AcademicCourseProgressDto> courses;

  /// Returns a shallow copy of this [AcademicProgressDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AcademicProgressDto copyWith({
    int? curriculumVersionId,
    double? totalCredits,
    double? earnedCredits,
    double? remainingCredits,
    String? creditStatus,
    double? gpa,
    String? gpaStatus,
    List<_i2.AcademicCourseProgressDto>? courses,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AcademicProgressDto',
      'curriculumVersionId': curriculumVersionId,
      if (totalCredits != null) 'totalCredits': totalCredits,
      if (earnedCredits != null) 'earnedCredits': earnedCredits,
      if (remainingCredits != null) 'remainingCredits': remainingCredits,
      'creditStatus': creditStatus,
      if (gpa != null) 'gpa': gpa,
      'gpaStatus': gpaStatus,
      'courses': courses.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AcademicProgressDto',
      'curriculumVersionId': curriculumVersionId,
      if (totalCredits != null) 'totalCredits': totalCredits,
      if (earnedCredits != null) 'earnedCredits': earnedCredits,
      if (remainingCredits != null) 'remainingCredits': remainingCredits,
      'creditStatus': creditStatus,
      if (gpa != null) 'gpa': gpa,
      'gpaStatus': gpaStatus,
      'courses': courses.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AcademicProgressDtoImpl extends AcademicProgressDto {
  _AcademicProgressDtoImpl({
    required int curriculumVersionId,
    double? totalCredits,
    double? earnedCredits,
    double? remainingCredits,
    required String creditStatus,
    double? gpa,
    required String gpaStatus,
    required List<_i2.AcademicCourseProgressDto> courses,
  }) : super._(
         curriculumVersionId: curriculumVersionId,
         totalCredits: totalCredits,
         earnedCredits: earnedCredits,
         remainingCredits: remainingCredits,
         creditStatus: creditStatus,
         gpa: gpa,
         gpaStatus: gpaStatus,
         courses: courses,
       );

  /// Returns a shallow copy of this [AcademicProgressDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AcademicProgressDto copyWith({
    int? curriculumVersionId,
    Object? totalCredits = _Undefined,
    Object? earnedCredits = _Undefined,
    Object? remainingCredits = _Undefined,
    String? creditStatus,
    Object? gpa = _Undefined,
    String? gpaStatus,
    List<_i2.AcademicCourseProgressDto>? courses,
  }) {
    return AcademicProgressDto(
      curriculumVersionId: curriculumVersionId ?? this.curriculumVersionId,
      totalCredits: totalCredits is double? ? totalCredits : this.totalCredits,
      earnedCredits: earnedCredits is double?
          ? earnedCredits
          : this.earnedCredits,
      remainingCredits: remainingCredits is double?
          ? remainingCredits
          : this.remainingCredits,
      creditStatus: creditStatus ?? this.creditStatus,
      gpa: gpa is double? ? gpa : this.gpa,
      gpaStatus: gpaStatus ?? this.gpaStatus,
      courses: courses ?? this.courses.map((e0) => e0.copyWith()).toList(),
    );
  }
}
