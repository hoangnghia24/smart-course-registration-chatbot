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
import 'course_item_dto.dart' as _i2;
import 'package:smart_course_registration_chatbot_server/src/generated/protocol.dart'
    as _i3;

abstract class CurriculumItemDetailDto
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  CurriculumItemDetailDto._({
    required this.course,
    required this.semester,
    required this.isRequired,
  });

  factory CurriculumItemDetailDto({
    required _i2.CourseItemDto course,
    required int semester,
    required bool isRequired,
  }) = _CurriculumItemDetailDtoImpl;

  factory CurriculumItemDetailDto.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CurriculumItemDetailDto(
      course: _i3.Protocol().deserialize<_i2.CourseItemDto>(
        jsonSerialization['course'],
      ),
      semester: jsonSerialization['semester'] as int,
      isRequired: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['isRequired'],
      ),
    );
  }

  _i2.CourseItemDto course;

  int semester;

  bool isRequired;

  /// Returns a shallow copy of this [CurriculumItemDetailDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CurriculumItemDetailDto copyWith({
    _i2.CourseItemDto? course,
    int? semester,
    bool? isRequired,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CurriculumItemDetailDto',
      'course': course.toJson(),
      'semester': semester,
      'isRequired': isRequired,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CurriculumItemDetailDto',
      'course': course.toJsonForProtocol(),
      'semester': semester,
      'isRequired': isRequired,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _CurriculumItemDetailDtoImpl extends CurriculumItemDetailDto {
  _CurriculumItemDetailDtoImpl({
    required _i2.CourseItemDto course,
    required int semester,
    required bool isRequired,
  }) : super._(
         course: course,
         semester: semester,
         isRequired: isRequired,
       );

  /// Returns a shallow copy of this [CurriculumItemDetailDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CurriculumItemDetailDto copyWith({
    _i2.CourseItemDto? course,
    int? semester,
    bool? isRequired,
  }) {
    return CurriculumItemDetailDto(
      course: course ?? this.course.copyWith(),
      semester: semester ?? this.semester,
      isRequired: isRequired ?? this.isRequired,
    );
  }
}
