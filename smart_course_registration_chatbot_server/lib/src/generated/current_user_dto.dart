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
import 'account_role.dart' as _i2;
import 'account_status.dart' as _i3;

abstract class CurrentUserDto
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  CurrentUserDto._({
    required this.accountId,
    required this.role,
    required this.status,
    this.studentCode,
    this.lecturerCode,
  });

  factory CurrentUserDto({
    required int accountId,
    required _i2.AccountRole role,
    required _i3.AccountStatus status,
    String? studentCode,
    String? lecturerCode,
  }) = _CurrentUserDtoImpl;

  factory CurrentUserDto.fromJson(Map<String, dynamic> jsonSerialization) {
    return CurrentUserDto(
      accountId: jsonSerialization['accountId'] as int,
      role: _i2.AccountRole.fromJson((jsonSerialization['role'] as String)),
      status: _i3.AccountStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      studentCode: jsonSerialization['studentCode'] as String?,
      lecturerCode: jsonSerialization['lecturerCode'] as String?,
    );
  }

  int accountId;

  _i2.AccountRole role;

  _i3.AccountStatus status;

  String? studentCode;

  String? lecturerCode;

  /// Returns a shallow copy of this [CurrentUserDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CurrentUserDto copyWith({
    int? accountId,
    _i2.AccountRole? role,
    _i3.AccountStatus? status,
    String? studentCode,
    String? lecturerCode,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CurrentUserDto',
      'accountId': accountId,
      'role': role.toJson(),
      'status': status.toJson(),
      if (studentCode != null) 'studentCode': studentCode,
      if (lecturerCode != null) 'lecturerCode': lecturerCode,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CurrentUserDto',
      'accountId': accountId,
      'role': role.toJson(),
      'status': status.toJson(),
      if (studentCode != null) 'studentCode': studentCode,
      if (lecturerCode != null) 'lecturerCode': lecturerCode,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CurrentUserDtoImpl extends CurrentUserDto {
  _CurrentUserDtoImpl({
    required int accountId,
    required _i2.AccountRole role,
    required _i3.AccountStatus status,
    String? studentCode,
    String? lecturerCode,
  }) : super._(
         accountId: accountId,
         role: role,
         status: status,
         studentCode: studentCode,
         lecturerCode: lecturerCode,
       );

  /// Returns a shallow copy of this [CurrentUserDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CurrentUserDto copyWith({
    int? accountId,
    _i2.AccountRole? role,
    _i3.AccountStatus? status,
    Object? studentCode = _Undefined,
    Object? lecturerCode = _Undefined,
  }) {
    return CurrentUserDto(
      accountId: accountId ?? this.accountId,
      role: role ?? this.role,
      status: status ?? this.status,
      studentCode: studentCode is String? ? studentCode : this.studentCode,
      lecturerCode: lecturerCode is String? ? lecturerCode : this.lecturerCode,
    );
  }
}
