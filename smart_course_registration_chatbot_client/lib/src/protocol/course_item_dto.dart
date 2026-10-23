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

abstract class CourseItemDto implements _i1.SerializableModel {
  CourseItemDto._({
    required this.code,
    required this.name,
    required this.credits,
    this.description,
  });

  factory CourseItemDto({
    required String code,
    required String name,
    required int credits,
    String? description,
  }) = _CourseItemDtoImpl;

  factory CourseItemDto.fromJson(Map<String, dynamic> jsonSerialization) {
    return CourseItemDto(
      code: jsonSerialization['code'] as String,
      name: jsonSerialization['name'] as String,
      credits: jsonSerialization['credits'] as int,
      description: jsonSerialization['description'] as String?,
    );
  }

  String code;

  String name;

  int credits;

  String? description;

  /// Returns a shallow copy of this [CourseItemDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CourseItemDto copyWith({
    String? code,
    String? name,
    int? credits,
    String? description,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CourseItemDto',
      'code': code,
      'name': name,
      'credits': credits,
      if (description != null) 'description': description,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CourseItemDtoImpl extends CourseItemDto {
  _CourseItemDtoImpl({
    required String code,
    required String name,
    required int credits,
    String? description,
  }) : super._(
         code: code,
         name: name,
         credits: credits,
         description: description,
       );

  /// Returns a shallow copy of this [CourseItemDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CourseItemDto copyWith({
    String? code,
    String? name,
    int? credits,
    Object? description = _Undefined,
  }) {
    return CourseItemDto(
      code: code ?? this.code,
      name: name ?? this.name,
      credits: credits ?? this.credits,
      description: description is String? ? description : this.description,
    );
  }
}
