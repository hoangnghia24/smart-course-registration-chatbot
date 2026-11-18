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
import 'admin_curriculum_version_summary_dto.dart' as _i2;
import 'admin_curriculum_group_dto.dart' as _i3;
import 'admin_curriculum_item_dto.dart' as _i4;
import 'package:smart_course_registration_chatbot_server/src/generated/protocol.dart'
    as _i5;

/// F07 - Chi tiet phien ban CTDT
abstract class AdminCurriculumVersionDetailDto
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  AdminCurriculumVersionDetailDto._({
    required this.summary,
    required this.curriculumCode,
    required this.curriculumName,
    required this.majorCode,
    required this.groups,
    required this.items,
    required this.totalItemCredits,
    required this.requiredItemCredits,
  });

  factory AdminCurriculumVersionDetailDto({
    required _i2.AdminCurriculumVersionSummaryDto summary,
    required String curriculumCode,
    required String curriculumName,
    required String majorCode,
    required List<_i3.AdminCurriculumGroupDto> groups,
    required List<_i4.AdminCurriculumItemDto> items,
    required int totalItemCredits,
    required int requiredItemCredits,
  }) = _AdminCurriculumVersionDetailDtoImpl;

  factory AdminCurriculumVersionDetailDto.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return AdminCurriculumVersionDetailDto(
      summary: _i5.Protocol().deserialize<_i2.AdminCurriculumVersionSummaryDto>(
        jsonSerialization['summary'],
      ),
      curriculumCode: jsonSerialization['curriculumCode'] as String,
      curriculumName: jsonSerialization['curriculumName'] as String,
      majorCode: jsonSerialization['majorCode'] as String,
      groups: _i5.Protocol().deserialize<List<_i3.AdminCurriculumGroupDto>>(
        jsonSerialization['groups'],
      ),
      items: _i5.Protocol().deserialize<List<_i4.AdminCurriculumItemDto>>(
        jsonSerialization['items'],
      ),
      totalItemCredits: jsonSerialization['totalItemCredits'] as int,
      requiredItemCredits: jsonSerialization['requiredItemCredits'] as int,
    );
  }

  _i2.AdminCurriculumVersionSummaryDto summary;

  String curriculumCode;

  String curriculumName;

  String majorCode;

  List<_i3.AdminCurriculumGroupDto> groups;

  List<_i4.AdminCurriculumItemDto> items;

  /// Tong tin chi tat ca hoc phan / hoc phan bat buoc
  int totalItemCredits;

  int requiredItemCredits;

  /// Returns a shallow copy of this [AdminCurriculumVersionDetailDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AdminCurriculumVersionDetailDto copyWith({
    _i2.AdminCurriculumVersionSummaryDto? summary,
    String? curriculumCode,
    String? curriculumName,
    String? majorCode,
    List<_i3.AdminCurriculumGroupDto>? groups,
    List<_i4.AdminCurriculumItemDto>? items,
    int? totalItemCredits,
    int? requiredItemCredits,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AdminCurriculumVersionDetailDto',
      'summary': summary.toJson(),
      'curriculumCode': curriculumCode,
      'curriculumName': curriculumName,
      'majorCode': majorCode,
      'groups': groups.toJson(valueToJson: (v) => v.toJson()),
      'items': items.toJson(valueToJson: (v) => v.toJson()),
      'totalItemCredits': totalItemCredits,
      'requiredItemCredits': requiredItemCredits,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AdminCurriculumVersionDetailDto',
      'summary': summary.toJsonForProtocol(),
      'curriculumCode': curriculumCode,
      'curriculumName': curriculumName,
      'majorCode': majorCode,
      'groups': groups.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'items': items.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'totalItemCredits': totalItemCredits,
      'requiredItemCredits': requiredItemCredits,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _AdminCurriculumVersionDetailDtoImpl
    extends AdminCurriculumVersionDetailDto {
  _AdminCurriculumVersionDetailDtoImpl({
    required _i2.AdminCurriculumVersionSummaryDto summary,
    required String curriculumCode,
    required String curriculumName,
    required String majorCode,
    required List<_i3.AdminCurriculumGroupDto> groups,
    required List<_i4.AdminCurriculumItemDto> items,
    required int totalItemCredits,
    required int requiredItemCredits,
  }) : super._(
         summary: summary,
         curriculumCode: curriculumCode,
         curriculumName: curriculumName,
         majorCode: majorCode,
         groups: groups,
         items: items,
         totalItemCredits: totalItemCredits,
         requiredItemCredits: requiredItemCredits,
       );

  /// Returns a shallow copy of this [AdminCurriculumVersionDetailDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AdminCurriculumVersionDetailDto copyWith({
    _i2.AdminCurriculumVersionSummaryDto? summary,
    String? curriculumCode,
    String? curriculumName,
    String? majorCode,
    List<_i3.AdminCurriculumGroupDto>? groups,
    List<_i4.AdminCurriculumItemDto>? items,
    int? totalItemCredits,
    int? requiredItemCredits,
  }) {
    return AdminCurriculumVersionDetailDto(
      summary: summary ?? this.summary.copyWith(),
      curriculumCode: curriculumCode ?? this.curriculumCode,
      curriculumName: curriculumName ?? this.curriculumName,
      majorCode: majorCode ?? this.majorCode,
      groups: groups ?? this.groups.map((e0) => e0.copyWith()).toList(),
      items: items ?? this.items.map((e0) => e0.copyWith()).toList(),
      totalItemCredits: totalItemCredits ?? this.totalItemCredits,
      requiredItemCredits: requiredItemCredits ?? this.requiredItemCredits,
    );
  }
}
