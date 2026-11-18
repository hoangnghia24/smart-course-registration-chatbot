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

/// F07 - Anh xa (nganh, khoa) -> phien ban CTDT
abstract class CurriculumCohortDto
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  CurriculumCohortDto._({
    required this.majorCode,
    required this.admissionYear,
    required this.curriculumVersionId,
    required this.curriculumCode,
    required this.versionCode,
  });

  factory CurriculumCohortDto({
    required String majorCode,
    required int admissionYear,
    required int curriculumVersionId,
    required String curriculumCode,
    required String versionCode,
  }) = _CurriculumCohortDtoImpl;

  factory CurriculumCohortDto.fromJson(Map<String, dynamic> jsonSerialization) {
    return CurriculumCohortDto(
      majorCode: jsonSerialization['majorCode'] as String,
      admissionYear: jsonSerialization['admissionYear'] as int,
      curriculumVersionId: jsonSerialization['curriculumVersionId'] as int,
      curriculumCode: jsonSerialization['curriculumCode'] as String,
      versionCode: jsonSerialization['versionCode'] as String,
    );
  }

  String majorCode;

  int admissionYear;

  int curriculumVersionId;

  String curriculumCode;

  String versionCode;

  /// Returns a shallow copy of this [CurriculumCohortDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CurriculumCohortDto copyWith({
    String? majorCode,
    int? admissionYear,
    int? curriculumVersionId,
    String? curriculumCode,
    String? versionCode,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CurriculumCohortDto',
      'majorCode': majorCode,
      'admissionYear': admissionYear,
      'curriculumVersionId': curriculumVersionId,
      'curriculumCode': curriculumCode,
      'versionCode': versionCode,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CurriculumCohortDto',
      'majorCode': majorCode,
      'admissionYear': admissionYear,
      'curriculumVersionId': curriculumVersionId,
      'curriculumCode': curriculumCode,
      'versionCode': versionCode,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _CurriculumCohortDtoImpl extends CurriculumCohortDto {
  _CurriculumCohortDtoImpl({
    required String majorCode,
    required int admissionYear,
    required int curriculumVersionId,
    required String curriculumCode,
    required String versionCode,
  }) : super._(
         majorCode: majorCode,
         admissionYear: admissionYear,
         curriculumVersionId: curriculumVersionId,
         curriculumCode: curriculumCode,
         versionCode: versionCode,
       );

  /// Returns a shallow copy of this [CurriculumCohortDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CurriculumCohortDto copyWith({
    String? majorCode,
    int? admissionYear,
    int? curriculumVersionId,
    String? curriculumCode,
    String? versionCode,
  }) {
    return CurriculumCohortDto(
      majorCode: majorCode ?? this.majorCode,
      admissionYear: admissionYear ?? this.admissionYear,
      curriculumVersionId: curriculumVersionId ?? this.curriculumVersionId,
      curriculumCode: curriculumCode ?? this.curriculumCode,
      versionCode: versionCode ?? this.versionCode,
    );
  }
}
