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

/// F07 - Khoi kien thuc trong phien ban
abstract class AdminCurriculumGroupDto
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  AdminCurriculumGroupDto._({
    required this.groupCode,
    required this.groupName,
    required this.groupOrder,
  });

  factory AdminCurriculumGroupDto({
    required String groupCode,
    required String groupName,
    required int groupOrder,
  }) = _AdminCurriculumGroupDtoImpl;

  factory AdminCurriculumGroupDto.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return AdminCurriculumGroupDto(
      groupCode: jsonSerialization['groupCode'] as String,
      groupName: jsonSerialization['groupName'] as String,
      groupOrder: jsonSerialization['groupOrder'] as int,
    );
  }

  String groupCode;

  String groupName;

  int groupOrder;

  /// Returns a shallow copy of this [AdminCurriculumGroupDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AdminCurriculumGroupDto copyWith({
    String? groupCode,
    String? groupName,
    int? groupOrder,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AdminCurriculumGroupDto',
      'groupCode': groupCode,
      'groupName': groupName,
      'groupOrder': groupOrder,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AdminCurriculumGroupDto',
      'groupCode': groupCode,
      'groupName': groupName,
      'groupOrder': groupOrder,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _AdminCurriculumGroupDtoImpl extends AdminCurriculumGroupDto {
  _AdminCurriculumGroupDtoImpl({
    required String groupCode,
    required String groupName,
    required int groupOrder,
  }) : super._(
         groupCode: groupCode,
         groupName: groupName,
         groupOrder: groupOrder,
       );

  /// Returns a shallow copy of this [AdminCurriculumGroupDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AdminCurriculumGroupDto copyWith({
    String? groupCode,
    String? groupName,
    int? groupOrder,
  }) {
    return AdminCurriculumGroupDto(
      groupCode: groupCode ?? this.groupCode,
      groupName: groupName ?? this.groupName,
      groupOrder: groupOrder ?? this.groupOrder,
    );
  }
}
