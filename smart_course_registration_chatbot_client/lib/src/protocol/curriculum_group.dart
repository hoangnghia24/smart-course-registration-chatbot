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

abstract class CurriculumGroup implements _i1.SerializableModel {
  CurriculumGroup._({
    this.id,
    required this.curriculumVersionId,
    required this.groupCode,
    required this.groupName,
    required this.groupOrder,
  });

  factory CurriculumGroup({
    int? id,
    required int curriculumVersionId,
    required String groupCode,
    required String groupName,
    required int groupOrder,
  }) = _CurriculumGroupImpl;

  factory CurriculumGroup.fromJson(Map<String, dynamic> jsonSerialization) {
    return CurriculumGroup(
      id: jsonSerialization['id'] as int?,
      curriculumVersionId: jsonSerialization['curriculumVersionId'] as int,
      groupCode: jsonSerialization['groupCode'] as String,
      groupName: jsonSerialization['groupName'] as String,
      groupOrder: jsonSerialization['groupOrder'] as int,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int curriculumVersionId;

  String groupCode;

  String groupName;

  int groupOrder;

  /// Returns a shallow copy of this [CurriculumGroup]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CurriculumGroup copyWith({
    int? id,
    int? curriculumVersionId,
    String? groupCode,
    String? groupName,
    int? groupOrder,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CurriculumGroup',
      if (id != null) 'id': id,
      'curriculumVersionId': curriculumVersionId,
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

class _Undefined {}

class _CurriculumGroupImpl extends CurriculumGroup {
  _CurriculumGroupImpl({
    int? id,
    required int curriculumVersionId,
    required String groupCode,
    required String groupName,
    required int groupOrder,
  }) : super._(
         id: id,
         curriculumVersionId: curriculumVersionId,
         groupCode: groupCode,
         groupName: groupName,
         groupOrder: groupOrder,
       );

  /// Returns a shallow copy of this [CurriculumGroup]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CurriculumGroup copyWith({
    Object? id = _Undefined,
    int? curriculumVersionId,
    String? groupCode,
    String? groupName,
    int? groupOrder,
  }) {
    return CurriculumGroup(
      id: id is int? ? id : this.id,
      curriculumVersionId: curriculumVersionId ?? this.curriculumVersionId,
      groupCode: groupCode ?? this.groupCode,
      groupName: groupName ?? this.groupName,
      groupOrder: groupOrder ?? this.groupOrder,
    );
  }
}
