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

/// F23 - Tien do tung hoc phan
abstract class AcademicCourseProgressDto
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  AcademicCourseProgressDto._({
    required this.courseId,
    required this.course,
    required this.semester,
    required this.isRequired,
    this.groupCode,
    this.groupName,
    this.groupOrder,
    this.itemOrder,
    required this.status,
    this.statusDetail,
    this.score,
    required this.scoreStatus,
  });

  factory AcademicCourseProgressDto({
    required int courseId,
    required _i2.CourseItemDto course,
    required int semester,
    required bool isRequired,
    String? groupCode,
    String? groupName,
    int? groupOrder,
    int? itemOrder,
    required String status,
    String? statusDetail,
    double? score,
    required String scoreStatus,
  }) = _AcademicCourseProgressDtoImpl;

  factory AcademicCourseProgressDto.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return AcademicCourseProgressDto(
      courseId: jsonSerialization['courseId'] as int,
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
      status: jsonSerialization['status'] as String,
      statusDetail: jsonSerialization['statusDetail'] as String?,
      score: (jsonSerialization['score'] as num?)?.toDouble(),
      scoreStatus: jsonSerialization['scoreStatus'] as String,
    );
  }

  /// ID mon hoc
  int courseId;

  /// Thong tin mon hoc, tai su dung DTO F04
  _i2.CourseItemDto course;

  /// Hoc ky goi y trong CTDT
  int semester;

  /// Mon bat buoc hay tu chon
  bool isRequired;

  /// Thong tin khoi kien thuc tu F04
  String? groupCode;

  String? groupName;

  int? groupOrder;

  int? itemOrder;

  /// PASSED, FAILED, IN_PROGRESS, NOT_STARTED
  String status;

  /// Chi tiet trang thai, vi du PENDING_GRADE
  String? statusDetail;

  /// Diem chinh thuc neu xac dinh duoc
  double? score;

  /// AVAILABLE, NOT_PUBLISHED, NO_DATA, POLICY_PENDING
  String scoreStatus;

  /// Returns a shallow copy of this [AcademicCourseProgressDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AcademicCourseProgressDto copyWith({
    int? courseId,
    _i2.CourseItemDto? course,
    int? semester,
    bool? isRequired,
    String? groupCode,
    String? groupName,
    int? groupOrder,
    int? itemOrder,
    String? status,
    String? statusDetail,
    double? score,
    String? scoreStatus,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AcademicCourseProgressDto',
      'courseId': courseId,
      'course': course.toJson(),
      'semester': semester,
      'isRequired': isRequired,
      if (groupCode != null) 'groupCode': groupCode,
      if (groupName != null) 'groupName': groupName,
      if (groupOrder != null) 'groupOrder': groupOrder,
      if (itemOrder != null) 'itemOrder': itemOrder,
      'status': status,
      if (statusDetail != null) 'statusDetail': statusDetail,
      if (score != null) 'score': score,
      'scoreStatus': scoreStatus,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AcademicCourseProgressDto',
      'courseId': courseId,
      'course': course.toJsonForProtocol(),
      'semester': semester,
      'isRequired': isRequired,
      if (groupCode != null) 'groupCode': groupCode,
      if (groupName != null) 'groupName': groupName,
      if (groupOrder != null) 'groupOrder': groupOrder,
      if (itemOrder != null) 'itemOrder': itemOrder,
      'status': status,
      if (statusDetail != null) 'statusDetail': statusDetail,
      if (score != null) 'score': score,
      'scoreStatus': scoreStatus,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AcademicCourseProgressDtoImpl extends AcademicCourseProgressDto {
  _AcademicCourseProgressDtoImpl({
    required int courseId,
    required _i2.CourseItemDto course,
    required int semester,
    required bool isRequired,
    String? groupCode,
    String? groupName,
    int? groupOrder,
    int? itemOrder,
    required String status,
    String? statusDetail,
    double? score,
    required String scoreStatus,
  }) : super._(
         courseId: courseId,
         course: course,
         semester: semester,
         isRequired: isRequired,
         groupCode: groupCode,
         groupName: groupName,
         groupOrder: groupOrder,
         itemOrder: itemOrder,
         status: status,
         statusDetail: statusDetail,
         score: score,
         scoreStatus: scoreStatus,
       );

  /// Returns a shallow copy of this [AcademicCourseProgressDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AcademicCourseProgressDto copyWith({
    int? courseId,
    _i2.CourseItemDto? course,
    int? semester,
    bool? isRequired,
    Object? groupCode = _Undefined,
    Object? groupName = _Undefined,
    Object? groupOrder = _Undefined,
    Object? itemOrder = _Undefined,
    String? status,
    Object? statusDetail = _Undefined,
    Object? score = _Undefined,
    String? scoreStatus,
  }) {
    return AcademicCourseProgressDto(
      courseId: courseId ?? this.courseId,
      course: course ?? this.course.copyWith(),
      semester: semester ?? this.semester,
      isRequired: isRequired ?? this.isRequired,
      groupCode: groupCode is String? ? groupCode : this.groupCode,
      groupName: groupName is String? ? groupName : this.groupName,
      groupOrder: groupOrder is int? ? groupOrder : this.groupOrder,
      itemOrder: itemOrder is int? ? itemOrder : this.itemOrder,
      status: status ?? this.status,
      statusDetail: statusDetail is String? ? statusDetail : this.statusDetail,
      score: score is double? ? score : this.score,
      scoreStatus: scoreStatus ?? this.scoreStatus,
    );
  }
}
