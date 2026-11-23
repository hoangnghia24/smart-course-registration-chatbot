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

/// F07 - Tom tat phien ban CTDT
abstract class AdminCurriculumVersionSummaryDto
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  AdminCurriculumVersionSummaryDto._({
    required this.id,
    required this.curriculumId,
    required this.versionCode,
    required this.effectiveYear,
    required this.status,
    this.totalCreditsRequired,
    required this.revision,
    this.publishedAt,
    required this.studentCount,
  });

  factory AdminCurriculumVersionSummaryDto({
    required int id,
    required int curriculumId,
    required String versionCode,
    required int effectiveYear,
    required String status,
    int? totalCreditsRequired,
    required int revision,
    DateTime? publishedAt,
    required int studentCount,
  }) = _AdminCurriculumVersionSummaryDtoImpl;

  factory AdminCurriculumVersionSummaryDto.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return AdminCurriculumVersionSummaryDto(
      id: jsonSerialization['id'] as int,
      curriculumId: jsonSerialization['curriculumId'] as int,
      versionCode: jsonSerialization['versionCode'] as String,
      effectiveYear: jsonSerialization['effectiveYear'] as int,
      status: jsonSerialization['status'] as String,
      totalCreditsRequired: jsonSerialization['totalCreditsRequired'] as int?,
      revision: jsonSerialization['revision'] as int,
      publishedAt: jsonSerialization['publishedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['publishedAt'],
            ),
      studentCount: jsonSerialization['studentCount'] as int,
    );
  }

  int id;

  int curriculumId;

  String versionCode;

  int effectiveYear;

  /// DRAFT, PUBLISHED, ARCHIVED
  String status;

  int? totalCreditsRequired;

  int revision;

  DateTime? publishedAt;

  /// So sinh vien dang gan voi phien ban
  int studentCount;

  /// Returns a shallow copy of this [AdminCurriculumVersionSummaryDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AdminCurriculumVersionSummaryDto copyWith({
    int? id,
    int? curriculumId,
    String? versionCode,
    int? effectiveYear,
    String? status,
    int? totalCreditsRequired,
    int? revision,
    DateTime? publishedAt,
    int? studentCount,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AdminCurriculumVersionSummaryDto',
      'id': id,
      'curriculumId': curriculumId,
      'versionCode': versionCode,
      'effectiveYear': effectiveYear,
      'status': status,
      if (totalCreditsRequired != null)
        'totalCreditsRequired': totalCreditsRequired,
      'revision': revision,
      if (publishedAt != null) 'publishedAt': publishedAt?.toJson(),
      'studentCount': studentCount,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AdminCurriculumVersionSummaryDto',
      'id': id,
      'curriculumId': curriculumId,
      'versionCode': versionCode,
      'effectiveYear': effectiveYear,
      'status': status,
      if (totalCreditsRequired != null)
        'totalCreditsRequired': totalCreditsRequired,
      'revision': revision,
      if (publishedAt != null) 'publishedAt': publishedAt?.toJson(),
      'studentCount': studentCount,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AdminCurriculumVersionSummaryDtoImpl
    extends AdminCurriculumVersionSummaryDto {
  _AdminCurriculumVersionSummaryDtoImpl({
    required int id,
    required int curriculumId,
    required String versionCode,
    required int effectiveYear,
    required String status,
    int? totalCreditsRequired,
    required int revision,
    DateTime? publishedAt,
    required int studentCount,
  }) : super._(
         id: id,
         curriculumId: curriculumId,
         versionCode: versionCode,
         effectiveYear: effectiveYear,
         status: status,
         totalCreditsRequired: totalCreditsRequired,
         revision: revision,
         publishedAt: publishedAt,
         studentCount: studentCount,
       );

  /// Returns a shallow copy of this [AdminCurriculumVersionSummaryDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AdminCurriculumVersionSummaryDto copyWith({
    int? id,
    int? curriculumId,
    String? versionCode,
    int? effectiveYear,
    String? status,
    Object? totalCreditsRequired = _Undefined,
    int? revision,
    Object? publishedAt = _Undefined,
    int? studentCount,
  }) {
    return AdminCurriculumVersionSummaryDto(
      id: id ?? this.id,
      curriculumId: curriculumId ?? this.curriculumId,
      versionCode: versionCode ?? this.versionCode,
      effectiveYear: effectiveYear ?? this.effectiveYear,
      status: status ?? this.status,
      totalCreditsRequired: totalCreditsRequired is int?
          ? totalCreditsRequired
          : this.totalCreditsRequired,
      revision: revision ?? this.revision,
      publishedAt: publishedAt is DateTime? ? publishedAt : this.publishedAt,
      studentCount: studentCount ?? this.studentCount,
    );
  }
}
