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
import 'admin_curriculum_group_dto.dart' as _i2;
import 'admin_curriculum_item_dto.dart' as _i3;
import 'package:smart_course_registration_chatbot_server/src/generated/protocol.dart'
    as _i4;

/// F07 - Noi dung ban nhap gui len de luu (thay toan bo khoi va hoc phan).
abstract class CurriculumDraftInput
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  CurriculumDraftInput._({
    required this.versionId,
    required this.expectedRevision,
    required this.versionCode,
    required this.effectiveYear,
    this.totalCreditsRequired,
    required this.groups,
    required this.items,
  });

  factory CurriculumDraftInput({
    required int versionId,
    required int expectedRevision,
    required String versionCode,
    required int effectiveYear,
    int? totalCreditsRequired,
    required List<_i2.AdminCurriculumGroupDto> groups,
    required List<_i3.AdminCurriculumItemDto> items,
  }) = _CurriculumDraftInputImpl;

  factory CurriculumDraftInput.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CurriculumDraftInput(
      versionId: jsonSerialization['versionId'] as int,
      expectedRevision: jsonSerialization['expectedRevision'] as int,
      versionCode: jsonSerialization['versionCode'] as String,
      effectiveYear: jsonSerialization['effectiveYear'] as int,
      totalCreditsRequired: jsonSerialization['totalCreditsRequired'] as int?,
      groups: _i4.Protocol().deserialize<List<_i2.AdminCurriculumGroupDto>>(
        jsonSerialization['groups'],
      ),
      items: _i4.Protocol().deserialize<List<_i3.AdminCurriculumItemDto>>(
        jsonSerialization['items'],
      ),
    );
  }

  int versionId;

  /// Revision client dang giu; sai lech -> VERSION_CONFLICT
  int expectedRevision;

  String versionCode;

  int effectiveYear;

  int? totalCreditsRequired;

  List<_i2.AdminCurriculumGroupDto> groups;

  List<_i3.AdminCurriculumItemDto> items;

  /// Returns a shallow copy of this [CurriculumDraftInput]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CurriculumDraftInput copyWith({
    int? versionId,
    int? expectedRevision,
    String? versionCode,
    int? effectiveYear,
    int? totalCreditsRequired,
    List<_i2.AdminCurriculumGroupDto>? groups,
    List<_i3.AdminCurriculumItemDto>? items,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CurriculumDraftInput',
      'versionId': versionId,
      'expectedRevision': expectedRevision,
      'versionCode': versionCode,
      'effectiveYear': effectiveYear,
      if (totalCreditsRequired != null)
        'totalCreditsRequired': totalCreditsRequired,
      'groups': groups.toJson(valueToJson: (v) => v.toJson()),
      'items': items.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CurriculumDraftInput',
      'versionId': versionId,
      'expectedRevision': expectedRevision,
      'versionCode': versionCode,
      'effectiveYear': effectiveYear,
      if (totalCreditsRequired != null)
        'totalCreditsRequired': totalCreditsRequired,
      'groups': groups.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'items': items.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CurriculumDraftInputImpl extends CurriculumDraftInput {
  _CurriculumDraftInputImpl({
    required int versionId,
    required int expectedRevision,
    required String versionCode,
    required int effectiveYear,
    int? totalCreditsRequired,
    required List<_i2.AdminCurriculumGroupDto> groups,
    required List<_i3.AdminCurriculumItemDto> items,
  }) : super._(
         versionId: versionId,
         expectedRevision: expectedRevision,
         versionCode: versionCode,
         effectiveYear: effectiveYear,
         totalCreditsRequired: totalCreditsRequired,
         groups: groups,
         items: items,
       );

  /// Returns a shallow copy of this [CurriculumDraftInput]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CurriculumDraftInput copyWith({
    int? versionId,
    int? expectedRevision,
    String? versionCode,
    int? effectiveYear,
    Object? totalCreditsRequired = _Undefined,
    List<_i2.AdminCurriculumGroupDto>? groups,
    List<_i3.AdminCurriculumItemDto>? items,
  }) {
    return CurriculumDraftInput(
      versionId: versionId ?? this.versionId,
      expectedRevision: expectedRevision ?? this.expectedRevision,
      versionCode: versionCode ?? this.versionCode,
      effectiveYear: effectiveYear ?? this.effectiveYear,
      totalCreditsRequired: totalCreditsRequired is int?
          ? totalCreditsRequired
          : this.totalCreditsRequired,
      groups: groups ?? this.groups.map((e0) => e0.copyWith()).toList(),
      items: items ?? this.items.map((e0) => e0.copyWith()).toList(),
    );
  }
}
