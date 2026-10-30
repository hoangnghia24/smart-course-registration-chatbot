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

abstract class CurriculumDto implements _i1.SerializableModel {
  CurriculumDto._({
    required this.code,
    required this.name,
    required this.majorCode,
  });

  factory CurriculumDto({
    required String code,
    required String name,
    required String majorCode,
  }) = _CurriculumDtoImpl;

  factory CurriculumDto.fromJson(Map<String, dynamic> jsonSerialization) {
    return CurriculumDto(
      code: jsonSerialization['code'] as String,
      name: jsonSerialization['name'] as String,
      majorCode: jsonSerialization['majorCode'] as String,
    );
  }

  String code;

  String name;

  String majorCode;

  /// Returns a shallow copy of this [CurriculumDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CurriculumDto copyWith({
    String? code,
    String? name,
    String? majorCode,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CurriculumDto',
      'code': code,
      'name': name,
      'majorCode': majorCode,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _CurriculumDtoImpl extends CurriculumDto {
  _CurriculumDtoImpl({
    required String code,
    required String name,
    required String majorCode,
  }) : super._(
         code: code,
         name: name,
         majorCode: majorCode,
       );

  /// Returns a shallow copy of this [CurriculumDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CurriculumDto copyWith({
    String? code,
    String? name,
    String? majorCode,
  }) {
    return CurriculumDto(
      code: code ?? this.code,
      name: name ?? this.name,
      majorCode: majorCode ?? this.majorCode,
    );
  }
}
