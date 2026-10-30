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

abstract class CurriculumVersionDto
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  CurriculumVersionDto._({
    required this.versionCode,
    required this.effectiveYear,
    required this.status,
  });

  factory CurriculumVersionDto({
    required String versionCode,
    required int effectiveYear,
    required String status,
  }) = _CurriculumVersionDtoImpl;

  factory CurriculumVersionDto.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CurriculumVersionDto(
      versionCode: jsonSerialization['versionCode'] as String,
      effectiveYear: jsonSerialization['effectiveYear'] as int,
      status: jsonSerialization['status'] as String,
    );
  }

  String versionCode;

  int effectiveYear;

  String status;

  /// Returns a shallow copy of this [CurriculumVersionDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CurriculumVersionDto copyWith({
    String? versionCode,
    int? effectiveYear,
    String? status,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CurriculumVersionDto',
      'versionCode': versionCode,
      'effectiveYear': effectiveYear,
      'status': status,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CurriculumVersionDto',
      'versionCode': versionCode,
      'effectiveYear': effectiveYear,
      'status': status,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _CurriculumVersionDtoImpl extends CurriculumVersionDto {
  _CurriculumVersionDtoImpl({
    required String versionCode,
    required int effectiveYear,
    required String status,
  }) : super._(
         versionCode: versionCode,
         effectiveYear: effectiveYear,
         status: status,
       );

  /// Returns a shallow copy of this [CurriculumVersionDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CurriculumVersionDto copyWith({
    String? versionCode,
    int? effectiveYear,
    String? status,
  }) {
    return CurriculumVersionDto(
      versionCode: versionCode ?? this.versionCode,
      effectiveYear: effectiveYear ?? this.effectiveYear,
      status: status ?? this.status,
    );
  }
}
