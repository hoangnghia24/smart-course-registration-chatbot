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
import 'academic_course_progress_dto.dart' as _i2;
import 'academic_progress_dto.dart' as _i3;
import 'academic_term.dart' as _i4;
import 'account_role.dart' as _i5;
import 'account_status.dart' as _i6;
import 'admin_curriculum_dto.dart' as _i7;
import 'admin_curriculum_group_dto.dart' as _i8;
import 'admin_curriculum_item_dto.dart' as _i9;
import 'admin_curriculum_version_detail_dto.dart' as _i10;
import 'admin_curriculum_version_summary_dto.dart' as _i11;
import 'app_exception.dart' as _i12;
import 'chatbot_message_role.dart' as _i13;
import 'chatbot_reply_dto.dart' as _i14;
import 'course_dto.dart' as _i15;
import 'course_item_dto.dart' as _i16;
import 'course_section.dart' as _i17;
import 'current_user_dto.dart' as _i18;
import 'curriculum_details_dto.dart' as _i19;
import 'curriculum_draft_input.dart' as _i20;
import 'curriculum_dto.dart' as _i21;
import 'curriculum_group.dart' as _i22;
import 'curriculum_item_detail_dto.dart' as _i23;
import 'curriculum_version_dto.dart' as _i24;
import 'greetings/greeting.dart' as _i25;
import 'lecturer_status.dart' as _i26;
import 'registration_origin.dart' as _i27;
import 'student_curriculum_assignment_dto.dart' as _i28;
import 'package:smart_course_registration_chatbot_client/src/protocol/course_dto.dart'
    as _i29;
import 'package:smart_course_registration_chatbot_client/src/protocol/admin_curriculum_dto.dart'
    as _i30;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i31;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i32;
export 'academic_course_progress_dto.dart';
export 'academic_progress_dto.dart';
export 'academic_term.dart';
export 'account_role.dart';
export 'account_status.dart';
export 'admin_curriculum_dto.dart';
export 'admin_curriculum_group_dto.dart';
export 'admin_curriculum_item_dto.dart';
export 'admin_curriculum_version_detail_dto.dart';
export 'admin_curriculum_version_summary_dto.dart';
export 'app_exception.dart';
export 'chatbot_message_role.dart';
export 'chatbot_reply_dto.dart';
export 'course_dto.dart';
export 'course_item_dto.dart';
export 'course_section.dart';
export 'current_user_dto.dart';
export 'curriculum_details_dto.dart';
export 'curriculum_draft_input.dart';
export 'curriculum_dto.dart';
export 'curriculum_group.dart';
export 'curriculum_item_detail_dto.dart';
export 'curriculum_version_dto.dart';
export 'greetings/greeting.dart';
export 'lecturer_status.dart';
export 'registration_origin.dart';
export 'student_curriculum_assignment_dto.dart';
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on FormatException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i2.AcademicCourseProgressDto) {
      return _i2.AcademicCourseProgressDto.fromJson(data) as T;
    }
    if (t == _i3.AcademicProgressDto) {
      return _i3.AcademicProgressDto.fromJson(data) as T;
    }
    if (t == _i4.AcademicTerm) {
      return _i4.AcademicTerm.fromJson(data) as T;
    }
    if (t == _i5.AccountRole) {
      return _i5.AccountRole.fromJson(data) as T;
    }
    if (t == _i6.AccountStatus) {
      return _i6.AccountStatus.fromJson(data) as T;
    }
    if (t == _i7.AdminCurriculumDto) {
      return _i7.AdminCurriculumDto.fromJson(data) as T;
    }
    if (t == _i8.AdminCurriculumGroupDto) {
      return _i8.AdminCurriculumGroupDto.fromJson(data) as T;
    }
    if (t == _i9.AdminCurriculumItemDto) {
      return _i9.AdminCurriculumItemDto.fromJson(data) as T;
    }
    if (t == _i10.AdminCurriculumVersionDetailDto) {
      return _i10.AdminCurriculumVersionDetailDto.fromJson(data) as T;
    }
    if (t == _i11.AdminCurriculumVersionSummaryDto) {
      return _i11.AdminCurriculumVersionSummaryDto.fromJson(data) as T;
    }
    if (t == _i12.AppException) {
      return _i12.AppException.fromJson(data) as T;
    }
    if (t == _i13.ChatbotMessageRole) {
      return _i13.ChatbotMessageRole.fromJson(data) as T;
    }
    if (t == _i14.ChatbotReplyDto) {
      return _i14.ChatbotReplyDto.fromJson(data) as T;
    }
    if (t == _i15.CourseDto) {
      return _i15.CourseDto.fromJson(data) as T;
    }
    if (t == _i16.CourseItemDto) {
      return _i16.CourseItemDto.fromJson(data) as T;
    }
    if (t == _i17.CourseSection) {
      return _i17.CourseSection.fromJson(data) as T;
    }
    if (t == _i18.CurrentUserDto) {
      return _i18.CurrentUserDto.fromJson(data) as T;
    }
    if (t == _i19.CurriculumDetailsDto) {
      return _i19.CurriculumDetailsDto.fromJson(data) as T;
    }
    if (t == _i20.CurriculumDraftInput) {
      return _i20.CurriculumDraftInput.fromJson(data) as T;
    }
    if (t == _i21.CurriculumDto) {
      return _i21.CurriculumDto.fromJson(data) as T;
    }
    if (t == _i22.CurriculumGroup) {
      return _i22.CurriculumGroup.fromJson(data) as T;
    }
    if (t == _i23.CurriculumItemDetailDto) {
      return _i23.CurriculumItemDetailDto.fromJson(data) as T;
    }
    if (t == _i24.CurriculumVersionDto) {
      return _i24.CurriculumVersionDto.fromJson(data) as T;
    }
    if (t == _i25.Greeting) {
      return _i25.Greeting.fromJson(data) as T;
    }
    if (t == _i26.LecturerStatus) {
      return _i26.LecturerStatus.fromJson(data) as T;
    }
    if (t == _i27.RegistrationOrigin) {
      return _i27.RegistrationOrigin.fromJson(data) as T;
    }
    if (t == _i28.StudentCurriculumAssignmentDto) {
      return _i28.StudentCurriculumAssignmentDto.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.AcademicCourseProgressDto?>()) {
      return (data != null
              ? _i2.AcademicCourseProgressDto.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i3.AcademicProgressDto?>()) {
      return (data != null ? _i3.AcademicProgressDto.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i4.AcademicTerm?>()) {
      return (data != null ? _i4.AcademicTerm.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.AccountRole?>()) {
      return (data != null ? _i5.AccountRole.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.AccountStatus?>()) {
      return (data != null ? _i6.AccountStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.AdminCurriculumDto?>()) {
      return (data != null ? _i7.AdminCurriculumDto.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.AdminCurriculumGroupDto?>()) {
      return (data != null ? _i8.AdminCurriculumGroupDto.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i9.AdminCurriculumItemDto?>()) {
      return (data != null ? _i9.AdminCurriculumItemDto.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i10.AdminCurriculumVersionDetailDto?>()) {
      return (data != null
              ? _i10.AdminCurriculumVersionDetailDto.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i11.AdminCurriculumVersionSummaryDto?>()) {
      return (data != null
              ? _i11.AdminCurriculumVersionSummaryDto.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i12.AppException?>()) {
      return (data != null ? _i12.AppException.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i13.ChatbotMessageRole?>()) {
      return (data != null ? _i13.ChatbotMessageRole.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i14.ChatbotReplyDto?>()) {
      return (data != null ? _i14.ChatbotReplyDto.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i15.CourseDto?>()) {
      return (data != null ? _i15.CourseDto.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i16.CourseItemDto?>()) {
      return (data != null ? _i16.CourseItemDto.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i17.CourseSection?>()) {
      return (data != null ? _i17.CourseSection.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i18.CurrentUserDto?>()) {
      return (data != null ? _i18.CurrentUserDto.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i19.CurriculumDetailsDto?>()) {
      return (data != null ? _i19.CurriculumDetailsDto.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i20.CurriculumDraftInput?>()) {
      return (data != null ? _i20.CurriculumDraftInput.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i21.CurriculumDto?>()) {
      return (data != null ? _i21.CurriculumDto.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i22.CurriculumGroup?>()) {
      return (data != null ? _i22.CurriculumGroup.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i23.CurriculumItemDetailDto?>()) {
      return (data != null ? _i23.CurriculumItemDetailDto.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i24.CurriculumVersionDto?>()) {
      return (data != null ? _i24.CurriculumVersionDto.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i25.Greeting?>()) {
      return (data != null ? _i25.Greeting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i26.LecturerStatus?>()) {
      return (data != null ? _i26.LecturerStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i27.RegistrationOrigin?>()) {
      return (data != null ? _i27.RegistrationOrigin.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i28.StudentCurriculumAssignmentDto?>()) {
      return (data != null
              ? _i28.StudentCurriculumAssignmentDto.fromJson(data)
              : null)
          as T;
    }
    if (t == List<_i2.AcademicCourseProgressDto>) {
      return (data as List)
              .map((e) => deserialize<_i2.AcademicCourseProgressDto>(e))
              .toList()
          as T;
    }
    if (t == List<_i11.AdminCurriculumVersionSummaryDto>) {
      return (data as List)
              .map((e) => deserialize<_i11.AdminCurriculumVersionSummaryDto>(e))
              .toList()
          as T;
    }
    if (t == List<_i8.AdminCurriculumGroupDto>) {
      return (data as List)
              .map((e) => deserialize<_i8.AdminCurriculumGroupDto>(e))
              .toList()
          as T;
    }
    if (t == List<_i9.AdminCurriculumItemDto>) {
      return (data as List)
              .map((e) => deserialize<_i9.AdminCurriculumItemDto>(e))
              .toList()
          as T;
    }
    if (t == List<_i23.CurriculumItemDetailDto>) {
      return (data as List)
              .map((e) => deserialize<_i23.CurriculumItemDetailDto>(e))
              .toList()
          as T;
    }
    if (t == List<_i29.CourseDto>) {
      return (data as List).map((e) => deserialize<_i29.CourseDto>(e)).toList()
          as T;
    }
    if (t == List<_i30.AdminCurriculumDto>) {
      return (data as List)
              .map((e) => deserialize<_i30.AdminCurriculumDto>(e))
              .toList()
          as T;
    }
    try {
      return _i31.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i32.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.AcademicCourseProgressDto => 'AcademicCourseProgressDto',
      _i3.AcademicProgressDto => 'AcademicProgressDto',
      _i4.AcademicTerm => 'AcademicTerm',
      _i5.AccountRole => 'AccountRole',
      _i6.AccountStatus => 'AccountStatus',
      _i7.AdminCurriculumDto => 'AdminCurriculumDto',
      _i8.AdminCurriculumGroupDto => 'AdminCurriculumGroupDto',
      _i9.AdminCurriculumItemDto => 'AdminCurriculumItemDto',
      _i10.AdminCurriculumVersionDetailDto => 'AdminCurriculumVersionDetailDto',
      _i11.AdminCurriculumVersionSummaryDto =>
        'AdminCurriculumVersionSummaryDto',
      _i12.AppException => 'AppException',
      _i13.ChatbotMessageRole => 'ChatbotMessageRole',
      _i14.ChatbotReplyDto => 'ChatbotReplyDto',
      _i15.CourseDto => 'CourseDto',
      _i16.CourseItemDto => 'CourseItemDto',
      _i17.CourseSection => 'CourseSection',
      _i18.CurrentUserDto => 'CurrentUserDto',
      _i19.CurriculumDetailsDto => 'CurriculumDetailsDto',
      _i20.CurriculumDraftInput => 'CurriculumDraftInput',
      _i21.CurriculumDto => 'CurriculumDto',
      _i22.CurriculumGroup => 'CurriculumGroup',
      _i23.CurriculumItemDetailDto => 'CurriculumItemDetailDto',
      _i24.CurriculumVersionDto => 'CurriculumVersionDto',
      _i25.Greeting => 'Greeting',
      _i26.LecturerStatus => 'LecturerStatus',
      _i27.RegistrationOrigin => 'RegistrationOrigin',
      _i28.StudentCurriculumAssignmentDto => 'StudentCurriculumAssignmentDto',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst(
        'smart_course_registration_chatbot.',
        '',
      );
    }

    switch (data) {
      case _i2.AcademicCourseProgressDto():
        return 'AcademicCourseProgressDto';
      case _i3.AcademicProgressDto():
        return 'AcademicProgressDto';
      case _i4.AcademicTerm():
        return 'AcademicTerm';
      case _i5.AccountRole():
        return 'AccountRole';
      case _i6.AccountStatus():
        return 'AccountStatus';
      case _i7.AdminCurriculumDto():
        return 'AdminCurriculumDto';
      case _i8.AdminCurriculumGroupDto():
        return 'AdminCurriculumGroupDto';
      case _i9.AdminCurriculumItemDto():
        return 'AdminCurriculumItemDto';
      case _i10.AdminCurriculumVersionDetailDto():
        return 'AdminCurriculumVersionDetailDto';
      case _i11.AdminCurriculumVersionSummaryDto():
        return 'AdminCurriculumVersionSummaryDto';
      case _i12.AppException():
        return 'AppException';
      case _i13.ChatbotMessageRole():
        return 'ChatbotMessageRole';
      case _i14.ChatbotReplyDto():
        return 'ChatbotReplyDto';
      case _i15.CourseDto():
        return 'CourseDto';
      case _i16.CourseItemDto():
        return 'CourseItemDto';
      case _i17.CourseSection():
        return 'CourseSection';
      case _i18.CurrentUserDto():
        return 'CurrentUserDto';
      case _i19.CurriculumDetailsDto():
        return 'CurriculumDetailsDto';
      case _i20.CurriculumDraftInput():
        return 'CurriculumDraftInput';
      case _i21.CurriculumDto():
        return 'CurriculumDto';
      case _i22.CurriculumGroup():
        return 'CurriculumGroup';
      case _i23.CurriculumItemDetailDto():
        return 'CurriculumItemDetailDto';
      case _i24.CurriculumVersionDto():
        return 'CurriculumVersionDto';
      case _i25.Greeting():
        return 'Greeting';
      case _i26.LecturerStatus():
        return 'LecturerStatus';
      case _i27.RegistrationOrigin():
        return 'RegistrationOrigin';
      case _i28.StudentCurriculumAssignmentDto():
        return 'StudentCurriculumAssignmentDto';
    }
    className = _i31.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    className = _i32.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_core.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'AcademicCourseProgressDto') {
      return deserialize<_i2.AcademicCourseProgressDto>(data['data']);
    }
    if (dataClassName == 'AcademicProgressDto') {
      return deserialize<_i3.AcademicProgressDto>(data['data']);
    }
    if (dataClassName == 'AcademicTerm') {
      return deserialize<_i4.AcademicTerm>(data['data']);
    }
    if (dataClassName == 'AccountRole') {
      return deserialize<_i5.AccountRole>(data['data']);
    }
    if (dataClassName == 'AccountStatus') {
      return deserialize<_i6.AccountStatus>(data['data']);
    }
    if (dataClassName == 'AdminCurriculumDto') {
      return deserialize<_i7.AdminCurriculumDto>(data['data']);
    }
    if (dataClassName == 'AdminCurriculumGroupDto') {
      return deserialize<_i8.AdminCurriculumGroupDto>(data['data']);
    }
    if (dataClassName == 'AdminCurriculumItemDto') {
      return deserialize<_i9.AdminCurriculumItemDto>(data['data']);
    }
    if (dataClassName == 'AdminCurriculumVersionDetailDto') {
      return deserialize<_i10.AdminCurriculumVersionDetailDto>(data['data']);
    }
    if (dataClassName == 'AdminCurriculumVersionSummaryDto') {
      return deserialize<_i11.AdminCurriculumVersionSummaryDto>(data['data']);
    }
    if (dataClassName == 'AppException') {
      return deserialize<_i12.AppException>(data['data']);
    }
    if (dataClassName == 'ChatbotMessageRole') {
      return deserialize<_i13.ChatbotMessageRole>(data['data']);
    }
    if (dataClassName == 'ChatbotReplyDto') {
      return deserialize<_i14.ChatbotReplyDto>(data['data']);
    }
    if (dataClassName == 'CourseDto') {
      return deserialize<_i15.CourseDto>(data['data']);
    }
    if (dataClassName == 'CourseItemDto') {
      return deserialize<_i16.CourseItemDto>(data['data']);
    }
    if (dataClassName == 'CourseSection') {
      return deserialize<_i17.CourseSection>(data['data']);
    }
    if (dataClassName == 'CurrentUserDto') {
      return deserialize<_i18.CurrentUserDto>(data['data']);
    }
    if (dataClassName == 'CurriculumDetailsDto') {
      return deserialize<_i19.CurriculumDetailsDto>(data['data']);
    }
    if (dataClassName == 'CurriculumDraftInput') {
      return deserialize<_i20.CurriculumDraftInput>(data['data']);
    }
    if (dataClassName == 'CurriculumDto') {
      return deserialize<_i21.CurriculumDto>(data['data']);
    }
    if (dataClassName == 'CurriculumGroup') {
      return deserialize<_i22.CurriculumGroup>(data['data']);
    }
    if (dataClassName == 'CurriculumItemDetailDto') {
      return deserialize<_i23.CurriculumItemDetailDto>(data['data']);
    }
    if (dataClassName == 'CurriculumVersionDto') {
      return deserialize<_i24.CurriculumVersionDto>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_i25.Greeting>(data['data']);
    }
    if (dataClassName == 'LecturerStatus') {
      return deserialize<_i26.LecturerStatus>(data['data']);
    }
    if (dataClassName == 'RegistrationOrigin') {
      return deserialize<_i27.RegistrationOrigin>(data['data']);
    }
    if (dataClassName == 'StudentCurriculumAssignmentDto') {
      return deserialize<_i28.StudentCurriculumAssignmentDto>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i31.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i32.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _i31.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i32.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
