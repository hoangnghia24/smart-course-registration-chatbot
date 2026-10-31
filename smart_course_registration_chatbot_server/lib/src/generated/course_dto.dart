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

abstract class CourseDto
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  CourseDto._({
    this.id,
    required this.code,
    required this.name,
    required this.credits,
    this.description,
    required this.isActive,
  });

  factory CourseDto({
    int? id,
    required String code,
    required String name,
    required int credits,
    String? description,
    required bool isActive,
  }) = _CourseDtoImpl;

  factory CourseDto.fromJson(Map<String, dynamic> jsonSerialization) {
    return CourseDto(
      id: jsonSerialization['id'] as int?,
      code: jsonSerialization['code'] as String,
      name: jsonSerialization['name'] as String,
      credits: jsonSerialization['credits'] as int,
      description: jsonSerialization['description'] as String?,
      isActive: _i1.BoolJsonExtension.fromJson(jsonSerialization['isActive']),
    );
  }

  int? id;

  String code;

  String name;

  int credits;

  String? description;

  bool isActive;

  /// Returns a shallow copy of this [CourseDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CourseDto copyWith({
    int? id,
    String? code,
    String? name,
    int? credits,
    String? description,
    bool? isActive,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CourseDto',
      if (id != null) 'id': id,
      'code': code,
      'name': name,
      'credits': credits,
      if (description != null) 'description': description,
      'isActive': isActive,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CourseDto',
      if (id != null) 'id': id,
      'code': code,
      'name': name,
      'credits': credits,
      if (description != null) 'description': description,
      'isActive': isActive,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CourseDtoImpl extends CourseDto {
  _CourseDtoImpl({
    int? id,
    required String code,
    required String name,
    required int credits,
    String? description,
    required bool isActive,
  }) : super._(
         id: id,
         code: code,
         name: name,
         credits: credits,
         description: description,
         isActive: isActive,
       );

  /// Returns a shallow copy of this [CourseDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CourseDto copyWith({
    Object? id = _Undefined,
    String? code,
    String? name,
    int? credits,
    Object? description = _Undefined,
    bool? isActive,
  }) {
    return CourseDto(
      id: id is int? ? id : this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      credits: credits ?? this.credits,
      description: description is String? ? description : this.description,
      isActive: isActive ?? this.isActive,
    );
  }
}
