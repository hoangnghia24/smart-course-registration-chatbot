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
import 'account_role.dart' as _i2;
import 'account_status.dart' as _i3;
import 'app_exception.dart' as _i4;
import 'course_dto.dart' as _i5;
import 'course_item_dto.dart' as _i6;
import 'current_user_dto.dart' as _i7;
import 'curriculum_details_dto.dart' as _i8;
import 'curriculum_dto.dart' as _i9;
import 'curriculum_item_detail_dto.dart' as _i10;
import 'curriculum_version_dto.dart' as _i11;
import 'greetings/greeting.dart' as _i12;
import 'lecturer_status.dart' as _i13;
import 'package:smart_course_registration_chatbot_client/src/protocol/course_dto.dart'
    as _i14;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i15;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i16;
export 'account_role.dart';
export 'account_status.dart';
export 'app_exception.dart';
export 'course_dto.dart';
export 'course_item_dto.dart';
export 'current_user_dto.dart';
export 'curriculum_details_dto.dart';
export 'curriculum_dto.dart';
export 'curriculum_item_detail_dto.dart';
export 'curriculum_version_dto.dart';
export 'greetings/greeting.dart';
export 'lecturer_status.dart';
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

    if (t == _i2.AccountRole) {
      return _i2.AccountRole.fromJson(data) as T;
    }
    if (t == _i3.AccountStatus) {
      return _i3.AccountStatus.fromJson(data) as T;
    }
    if (t == _i4.AppException) {
      return _i4.AppException.fromJson(data) as T;
    }
    if (t == _i5.CourseDto) {
      return _i5.CourseDto.fromJson(data) as T;
    }
    if (t == _i6.CourseItemDto) {
      return _i6.CourseItemDto.fromJson(data) as T;
    }
    if (t == _i7.CurrentUserDto) {
      return _i7.CurrentUserDto.fromJson(data) as T;
    }
    if (t == _i8.CurriculumDetailsDto) {
      return _i8.CurriculumDetailsDto.fromJson(data) as T;
    }
    if (t == _i9.CurriculumDto) {
      return _i9.CurriculumDto.fromJson(data) as T;
    }
    if (t == _i10.CurriculumItemDetailDto) {
      return _i10.CurriculumItemDetailDto.fromJson(data) as T;
    }
    if (t == _i11.CurriculumVersionDto) {
      return _i11.CurriculumVersionDto.fromJson(data) as T;
    }
    if (t == _i12.Greeting) {
      return _i12.Greeting.fromJson(data) as T;
    }
    if (t == _i13.LecturerStatus) {
      return _i13.LecturerStatus.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.AccountRole?>()) {
      return (data != null ? _i2.AccountRole.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.AccountStatus?>()) {
      return (data != null ? _i3.AccountStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.AppException?>()) {
      return (data != null ? _i4.AppException.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.CourseDto?>()) {
      return (data != null ? _i5.CourseDto.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.CourseItemDto?>()) {
      return (data != null ? _i6.CourseItemDto.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.CurrentUserDto?>()) {
      return (data != null ? _i7.CurrentUserDto.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.CurriculumDetailsDto?>()) {
      return (data != null ? _i8.CurriculumDetailsDto.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i9.CurriculumDto?>()) {
      return (data != null ? _i9.CurriculumDto.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.CurriculumItemDetailDto?>()) {
      return (data != null ? _i10.CurriculumItemDetailDto.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i11.CurriculumVersionDto?>()) {
      return (data != null ? _i11.CurriculumVersionDto.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i12.Greeting?>()) {
      return (data != null ? _i12.Greeting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i13.LecturerStatus?>()) {
      return (data != null ? _i13.LecturerStatus.fromJson(data) : null) as T;
    }
    if (t == List<_i10.CurriculumItemDetailDto>) {
      return (data as List)
              .map((e) => deserialize<_i10.CurriculumItemDetailDto>(e))
              .toList()
          as T;
    }
    if (t == List<_i14.CourseDto>) {
      return (data as List).map((e) => deserialize<_i14.CourseDto>(e)).toList()
          as T;
    }
    try {
      return _i15.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i16.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.AccountRole => 'AccountRole',
      _i3.AccountStatus => 'AccountStatus',
      _i4.AppException => 'AppException',
      _i5.CourseDto => 'CourseDto',
      _i6.CourseItemDto => 'CourseItemDto',
      _i7.CurrentUserDto => 'CurrentUserDto',
      _i8.CurriculumDetailsDto => 'CurriculumDetailsDto',
      _i9.CurriculumDto => 'CurriculumDto',
      _i10.CurriculumItemDetailDto => 'CurriculumItemDetailDto',
      _i11.CurriculumVersionDto => 'CurriculumVersionDto',
      _i12.Greeting => 'Greeting',
      _i13.LecturerStatus => 'LecturerStatus',
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
      case _i2.AccountRole():
        return 'AccountRole';
      case _i3.AccountStatus():
        return 'AccountStatus';
      case _i4.AppException():
        return 'AppException';
      case _i5.CourseDto():
        return 'CourseDto';
      case _i6.CourseItemDto():
        return 'CourseItemDto';
      case _i7.CurrentUserDto():
        return 'CurrentUserDto';
      case _i8.CurriculumDetailsDto():
        return 'CurriculumDetailsDto';
      case _i9.CurriculumDto():
        return 'CurriculumDto';
      case _i10.CurriculumItemDetailDto():
        return 'CurriculumItemDetailDto';
      case _i11.CurriculumVersionDto():
        return 'CurriculumVersionDto';
      case _i12.Greeting():
        return 'Greeting';
      case _i13.LecturerStatus():
        return 'LecturerStatus';
    }
    className = _i15.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    className = _i16.Protocol().getClassNameForObject(data);
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
    if (dataClassName == 'AccountRole') {
      return deserialize<_i2.AccountRole>(data['data']);
    }
    if (dataClassName == 'AccountStatus') {
      return deserialize<_i3.AccountStatus>(data['data']);
    }
    if (dataClassName == 'AppException') {
      return deserialize<_i4.AppException>(data['data']);
    }
    if (dataClassName == 'CourseDto') {
      return deserialize<_i5.CourseDto>(data['data']);
    }
    if (dataClassName == 'CourseItemDto') {
      return deserialize<_i6.CourseItemDto>(data['data']);
    }
    if (dataClassName == 'CurrentUserDto') {
      return deserialize<_i7.CurrentUserDto>(data['data']);
    }
    if (dataClassName == 'CurriculumDetailsDto') {
      return deserialize<_i8.CurriculumDetailsDto>(data['data']);
    }
    if (dataClassName == 'CurriculumDto') {
      return deserialize<_i9.CurriculumDto>(data['data']);
    }
    if (dataClassName == 'CurriculumItemDetailDto') {
      return deserialize<_i10.CurriculumItemDetailDto>(data['data']);
    }
    if (dataClassName == 'CurriculumVersionDto') {
      return deserialize<_i11.CurriculumVersionDto>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_i12.Greeting>(data['data']);
    }
    if (dataClassName == 'LecturerStatus') {
      return deserialize<_i13.LecturerStatus>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i15.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i16.Protocol().deserializeByClassName(data);
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
      return _i15.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i16.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
