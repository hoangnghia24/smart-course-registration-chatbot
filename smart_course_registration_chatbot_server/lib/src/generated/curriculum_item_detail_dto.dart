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
    this.groupCode,
    this.groupName,
    this.groupOrder,
    this.itemOrder,
  });

  factory CurriculumItemDetailDto({
    required _i2.CourseItemDto course,
    required int semester,
    required bool isRequired,
    String? groupCode,
    String? groupName,
    int? groupOrder,
    int? itemOrder,
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
      groupCode: jsonSerialization['groupCode'] as String?,
      groupName: jsonSerialization['groupName'] as String?,
      groupOrder: jsonSerialization['groupOrder'] as int?,
      itemOrder: jsonSerialization['itemOrder'] as int?,
    );
  }

  _i2.CourseItemDto course;

  int semester;

  bool isRequired;

  String? groupCode;

  String? groupName;

  int? groupOrder;

  int? itemOrder;

  /// Returns a shallow copy of this [CurriculumItemDetailDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CurriculumItemDetailDto copyWith({
    _i2.CourseItemDto? course,
    int? semester,
    bool? isRequired,
    String? groupCode,
    String? groupName,
    int? groupOrder,
    int? itemOrder,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CurriculumItemDetailDto',
      'course': course.toJson(),
      'semester': semester,
      'isRequired': isRequired,
      if (groupCode != null) 'groupCode': groupCode,
      if (groupName != null) 'groupName': groupName,
      if (groupOrder != null) 'groupOrder': groupOrder,
      if (itemOrder != null) 'itemOrder': itemOrder,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CurriculumItemDetailDto',
      'course': course.toJsonForProtocol(),
      'semester': semester,
      'isRequired': isRequired,
      if (groupCode != null) 'groupCode': groupCode,
      if (groupName != null) 'groupName': groupName,
      if (groupOrder != null) 'groupOrder': groupOrder,
      if (itemOrder != null) 'itemOrder': itemOrder,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CurriculumItemDetailDtoImpl extends CurriculumItemDetailDto {
  _CurriculumItemDetailDtoImpl({
    required _i2.CourseItemDto course,
    required int semester,
    required bool isRequired,
    String? groupCode,
    String? groupName,
    int? groupOrder,
    int? itemOrder,
  }) : super._(
         course: course,
         semester: semester,
         isRequired: isRequired,
         groupCode: groupCode,
         groupName: groupName,
         groupOrder: groupOrder,
         itemOrder: itemOrder,
       );

  /// Returns a shallow copy of this [CurriculumItemDetailDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CurriculumItemDetailDto copyWith({
    _i2.CourseItemDto? course,
    int? semester,
    bool? isRequired,
    Object? groupCode = _Undefined,
    Object? groupName = _Undefined,
    Object? groupOrder = _Undefined,
    Object? itemOrder = _Undefined,
  }) {
    return CurriculumItemDetailDto(
      course: course ?? this.course.copyWith(),
      semester: semester ?? this.semester,
      isRequired: isRequired ?? this.isRequired,
      groupCode: groupCode is String? ? groupCode : this.groupCode,
      groupName: groupName is String? ? groupName : this.groupName,
      groupOrder: groupOrder is int? ? groupOrder : this.groupOrder,
      itemOrder: itemOrder is int? ? itemOrder : this.itemOrder,
    );
  }
}
