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
import 'package:smart_course_registration_chatbot_server/src/generated/protocol.dart'
    as _i3;

/// F07 - CTDT trong man hinh quan tri
abstract class AdminCurriculumDto
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  AdminCurriculumDto._({
    required this.id,
    required this.code,
    required this.name,
    required this.majorCode,
    required this.status,
    required this.versions,
  });

  factory AdminCurriculumDto({
    required int id,
    required String code,
    required String name,
    required String majorCode,
    required String status,
    required List<_i2.AdminCurriculumVersionSummaryDto> versions,
  }) = _AdminCurriculumDtoImpl;

  factory AdminCurriculumDto.fromJson(Map<String, dynamic> jsonSerialization) {
    return AdminCurriculumDto(
      id: jsonSerialization['id'] as int,
      code: jsonSerialization['code'] as String,
      name: jsonSerialization['name'] as String,
      majorCode: jsonSerialization['majorCode'] as String,
      status: jsonSerialization['status'] as String,
      versions: _i3.Protocol()
          .deserialize<List<_i2.AdminCurriculumVersionSummaryDto>>(
            jsonSerialization['versions'],
          ),
    );
  }

  int id;

  String code;

  String name;

  String majorCode;

  /// ACTIVE, INACTIVE
  String status;

  List<_i2.AdminCurriculumVersionSummaryDto> versions;

  /// Returns a shallow copy of this [AdminCurriculumDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AdminCurriculumDto copyWith({
    int? id,
    String? code,
    String? name,
    String? majorCode,
    String? status,
    List<_i2.AdminCurriculumVersionSummaryDto>? versions,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AdminCurriculumDto',
      'id': id,
      'code': code,
      'name': name,
      'majorCode': majorCode,
      'status': status,
      'versions': versions.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AdminCurriculumDto',
      'id': id,
      'code': code,
      'name': name,
      'majorCode': majorCode,
      'status': status,
      'versions': versions.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _AdminCurriculumDtoImpl extends AdminCurriculumDto {
  _AdminCurriculumDtoImpl({
    required int id,
    required String code,
    required String name,
    required String majorCode,
    required String status,
    required List<_i2.AdminCurriculumVersionSummaryDto> versions,
  }) : super._(
         id: id,
         code: code,
         name: name,
         majorCode: majorCode,
         status: status,
         versions: versions,
       );

  /// Returns a shallow copy of this [AdminCurriculumDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AdminCurriculumDto copyWith({
    int? id,
    String? code,
    String? name,
    String? majorCode,
    String? status,
    List<_i2.AdminCurriculumVersionSummaryDto>? versions,
  }) {
    return AdminCurriculumDto(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      majorCode: majorCode ?? this.majorCode,
      status: status ?? this.status,
      versions: versions ?? this.versions.map((e0) => e0.copyWith()).toList(),
    );
  }
}
