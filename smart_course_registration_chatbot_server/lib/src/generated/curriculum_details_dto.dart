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
import 'curriculum_dto.dart' as _i2;
import 'curriculum_version_dto.dart' as _i3;
import 'curriculum_item_detail_dto.dart' as _i4;
import 'package:smart_course_registration_chatbot_server/src/generated/protocol.dart'
    as _i5;

abstract class CurriculumDetailsDto
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  CurriculumDetailsDto._({
    required this.curriculum,
    required this.version,
    required this.items,
  });

  factory CurriculumDetailsDto({
    required _i2.CurriculumDto curriculum,
    required _i3.CurriculumVersionDto version,
    required List<_i4.CurriculumItemDetailDto> items,
  }) = _CurriculumDetailsDtoImpl;

  factory CurriculumDetailsDto.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CurriculumDetailsDto(
      curriculum: _i5.Protocol().deserialize<_i2.CurriculumDto>(
        jsonSerialization['curriculum'],
      ),
      version: _i5.Protocol().deserialize<_i3.CurriculumVersionDto>(
        jsonSerialization['version'],
      ),
      items: _i5.Protocol().deserialize<List<_i4.CurriculumItemDetailDto>>(
        jsonSerialization['items'],
      ),
    );
  }

  _i2.CurriculumDto curriculum;

  _i3.CurriculumVersionDto version;

  List<_i4.CurriculumItemDetailDto> items;

  /// Returns a shallow copy of this [CurriculumDetailsDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CurriculumDetailsDto copyWith({
    _i2.CurriculumDto? curriculum,
    _i3.CurriculumVersionDto? version,
    List<_i4.CurriculumItemDetailDto>? items,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CurriculumDetailsDto',
      'curriculum': curriculum.toJson(),
      'version': version.toJson(),
      'items': items.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CurriculumDetailsDto',
      'curriculum': curriculum.toJsonForProtocol(),
      'version': version.toJsonForProtocol(),
      'items': items.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _CurriculumDetailsDtoImpl extends CurriculumDetailsDto {
  _CurriculumDetailsDtoImpl({
    required _i2.CurriculumDto curriculum,
    required _i3.CurriculumVersionDto version,
    required List<_i4.CurriculumItemDetailDto> items,
  }) : super._(
         curriculum: curriculum,
         version: version,
         items: items,
       );

  /// Returns a shallow copy of this [CurriculumDetailsDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CurriculumDetailsDto copyWith({
    _i2.CurriculumDto? curriculum,
    _i3.CurriculumVersionDto? version,
    List<_i4.CurriculumItemDetailDto>? items,
  }) {
    return CurriculumDetailsDto(
      curriculum: curriculum ?? this.curriculum.copyWith(),
      version: version ?? this.version.copyWith(),
      items: items ?? this.items.map((e0) => e0.copyWith()).toList(),
    );
  }
}
