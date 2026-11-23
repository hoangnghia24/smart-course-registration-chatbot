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
import 'dart:async' as _i2;
import 'package:smart_course_registration_chatbot_client/src/protocol/academic_progress_dto.dart'
    as _i3;
import 'package:smart_course_registration_chatbot_client/src/protocol/current_user_dto.dart'
    as _i4;
import 'package:smart_course_registration_chatbot_client/src/protocol/course_dto.dart'
    as _i5;
import 'package:smart_course_registration_chatbot_client/src/protocol/admin_curriculum_dto.dart'
    as _i6;
import 'package:smart_course_registration_chatbot_client/src/protocol/admin_curriculum_version_detail_dto.dart'
    as _i7;
import 'package:smart_course_registration_chatbot_client/src/protocol/curriculum_draft_input.dart'
    as _i8;
import 'package:smart_course_registration_chatbot_client/src/protocol/admin_curriculum_version_summary_dto.dart'
    as _i9;
import 'package:smart_course_registration_chatbot_client/src/protocol/student_curriculum_assignment_dto.dart'
    as _i10;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i11;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i12;
import 'package:smart_course_registration_chatbot_client/src/protocol/curriculum_details_dto.dart'
    as _i13;
import 'package:smart_course_registration_chatbot_client/src/protocol/greetings/greeting.dart'
    as _i14;
import 'protocol.dart' as _i15;

/// {@category Endpoint}
class EndpointAcademic extends _i1.EndpointRef {
  EndpointAcademic(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'academic';

  _i2.Future<_i3.AcademicProgressDto?> getMyProgress() =>
      caller.callServerEndpoint<_i3.AcademicProgressDto?>(
        'academic',
        'getMyProgress',
        {},
      );
}

/// API dành cho người dùng đang đăng nhập.
/// {@category Endpoint}
class EndpointAccount extends _i1.EndpointRef {
  EndpointAccount(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'account';

  /// Lấy thông tin người dùng từ session.
  _i2.Future<_i4.CurrentUserDto> me() =>
      caller.callServerEndpoint<_i4.CurrentUserDto>(
        'account',
        'me',
        {},
      );

  /// Đăng xuất tài khoản khỏi tất cả các thiết bị.
  _i2.Future<bool> logoutAll() => caller.callServerEndpoint<bool>(
    'account',
    'logoutAll',
    {},
  );
}

/// API quản trị tài khoản.
/// Chỉ tài khoản Admin mới được thực hiện các thao tác.
/// {@category Endpoint}
class EndpointAdminAccount extends _i1.EndpointRef {
  EndpointAdminAccount(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'adminAccount';

  /// Kiểm tra quyền truy cập Admin.
  _i2.Future<String> checkAccess() => caller.callServerEndpoint<String>(
    'adminAccount',
    'checkAccess',
    {},
  );

  /// Khóa hoặc mở khóa tài khoản.
  ///
  /// active = true: kích hoạt tài khoản.
  /// active = false: khóa tài khoản.
  _i2.Future<bool> setActive(
    int accountId,
    bool active,
  ) => caller.callServerEndpoint<bool>(
    'adminAccount',
    'setActive',
    {
      'accountId': accountId,
      'active': active,
    },
  );
}

/// {@category Endpoint}
class EndpointChatbot extends _i1.EndpointRef {
  EndpointChatbot(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'chatbot';

  /// Hàm để sinh viên gửi câu hỏi.
  _i2.Future<String> sendMessage(String message) =>
      caller.callServerEndpoint<String>(
        'chatbot',
        'sendMessage',
        {'message': message},
      );
}

/// {@category Endpoint}
class EndpointCourse extends _i1.EndpointRef {
  EndpointCourse(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'course';

  _i2.Future<List<_i5.CourseDto>> getCoursesPage(
    int page,
    int pageSize,
  ) => caller.callServerEndpoint<List<_i5.CourseDto>>(
    'course',
    'getCoursesPage',
    {
      'page': page,
      'pageSize': pageSize,
    },
  );

  _i2.Future<_i5.CourseDto> createCourse(_i5.CourseDto courseDto) =>
      caller.callServerEndpoint<_i5.CourseDto>(
        'course',
        'createCourse',
        {'courseDto': courseDto},
      );

  /// Cập nhật thông tin môn học.
  _i2.Future<_i5.CourseDto> updateCourse(_i5.CourseDto courseDto) =>
      caller.callServerEndpoint<_i5.CourseDto>(
        'course',
        'updateCourse',
        {'courseDto': courseDto},
      );

  _i2.Future<bool> deleteCourse(int courseId) =>
      caller.callServerEndpoint<bool>(
        'course',
        'deleteCourse',
        {'courseId': courseId},
      );

  /// Tìm kiếm môn học có phân trang.
  /// Admin: Xem tất cả môn học.
  /// Student, Lecturer: Chỉ xem môn học đang hoạt động.
  _i2.Future<List<_i5.CourseDto>> searchCourses(
    String query,
    int page,
    int pageSize,
  ) => caller.callServerEndpoint<List<_i5.CourseDto>>(
    'course',
    'searchCourses',
    {
      'query': query,
      'page': page,
      'pageSize': pageSize,
    },
  );

  _i2.Future<_i5.CourseDto> getCourseById(int courseId) =>
      caller.callServerEndpoint<_i5.CourseDto>(
        'course',
        'getCourseById',
        {'courseId': courseId},
      );
}

/// F07 - API quan tri CTDT / phien ban / lien ket sinh vien.
/// Tat ca phuong thuc chi danh cho Admin.
/// {@category Endpoint}
class EndpointCurriculumAdmin extends _i1.EndpointRef {
  EndpointCurriculumAdmin(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'curriculumAdmin';

  _i2.Future<List<_i6.AdminCurriculumDto>> listCurriculums(String query) =>
      caller.callServerEndpoint<List<_i6.AdminCurriculumDto>>(
        'curriculumAdmin',
        'listCurriculums',
        {'query': query},
      );

  _i2.Future<_i6.AdminCurriculumDto> createCurriculum(
    String code,
    String name,
    String majorCode,
  ) => caller.callServerEndpoint<_i6.AdminCurriculumDto>(
    'curriculumAdmin',
    'createCurriculum',
    {
      'code': code,
      'name': name,
      'majorCode': majorCode,
    },
  );

  _i2.Future<_i7.AdminCurriculumVersionDetailDto> createDraftVersion(
    int curriculumId,
    String versionCode,
    int effectiveYear,
    int? copyFromVersionId,
  ) => caller.callServerEndpoint<_i7.AdminCurriculumVersionDetailDto>(
    'curriculumAdmin',
    'createDraftVersion',
    {
      'curriculumId': curriculumId,
      'versionCode': versionCode,
      'effectiveYear': effectiveYear,
      'copyFromVersionId': copyFromVersionId,
    },
  );

  _i2.Future<_i7.AdminCurriculumVersionDetailDto> getVersion(int versionId) =>
      caller.callServerEndpoint<_i7.AdminCurriculumVersionDetailDto>(
        'curriculumAdmin',
        'getVersion',
        {'versionId': versionId},
      );

  _i2.Future<_i7.AdminCurriculumVersionDetailDto> saveDraftVersion(
    _i8.CurriculumDraftInput input,
  ) => caller.callServerEndpoint<_i7.AdminCurriculumVersionDetailDto>(
    'curriculumAdmin',
    'saveDraftVersion',
    {'input': input},
  );

  _i2.Future<_i7.AdminCurriculumVersionDetailDto> publishVersion(
    int versionId,
    int expectedRevision,
  ) => caller.callServerEndpoint<_i7.AdminCurriculumVersionDetailDto>(
    'curriculumAdmin',
    'publishVersion',
    {
      'versionId': versionId,
      'expectedRevision': expectedRevision,
    },
  );

  _i2.Future<_i7.AdminCurriculumVersionDetailDto> archiveVersion(
    int versionId,
  ) => caller.callServerEndpoint<_i7.AdminCurriculumVersionDetailDto>(
    'curriculumAdmin',
    'archiveVersion',
    {'versionId': versionId},
  );

  _i2.Future<bool> deleteDraftVersion(int versionId) =>
      caller.callServerEndpoint<bool>(
        'curriculumAdmin',
        'deleteDraftVersion',
        {'versionId': versionId},
      );

  /// Xem truoc phien ban se gan cho sinh vien CTDT [curriculumCode]
  /// nhap hoc nam [admissionYear]; null neu chua co phien ban phu hop.
  _i2.Future<_i9.AdminCurriculumVersionSummaryDto?> previewVersionForAdmission(
    String curriculumCode,
    int admissionYear,
  ) => caller.callServerEndpoint<_i9.AdminCurriculumVersionSummaryDto?>(
    'curriculumAdmin',
    'previewVersionForAdmission',
    {
      'curriculumCode': curriculumCode,
      'admissionYear': admissionYear,
    },
  );

  _i2.Future<_i10.StudentCurriculumAssignmentDto> getStudentAssignment(
    String studentCode,
  ) => caller.callServerEndpoint<_i10.StudentCurriculumAssignmentDto>(
    'curriculumAdmin',
    'getStudentAssignment',
    {'studentCode': studentCode},
  );

  _i2.Future<_i10.StudentCurriculumAssignmentDto> changeStudentVersion(
    String studentCode,
    int versionId,
    String reason,
  ) => caller.callServerEndpoint<_i10.StudentCurriculumAssignmentDto>(
    'curriculumAdmin',
    'changeStudentVersion',
    {
      'studentCode': studentCode,
      'versionId': versionId,
      'reason': reason,
    },
  );

  _i2.Future<_i10.StudentCurriculumAssignmentDto> setStudentAdmissionYear(
    String studentCode,
    int admissionYear,
  ) => caller.callServerEndpoint<_i10.StudentCurriculumAssignmentDto>(
    'curriculumAdmin',
    'setStudentAdmissionYear',
    {
      'studentCode': studentCode,
      'admissionYear': admissionYear,
    },
  );
}

/// By extending [EmailIdpBaseEndpoint], the email identity provider endpoints
/// are made available on the server and enable the corresponding sign-in widget
/// on the client.
/// {@category Endpoint}
class EndpointEmailIdp extends _i11.EndpointEmailIdpBase {
  EndpointEmailIdp(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'emailIdp';

  /// Logs in the user and returns a new session.
  ///
  /// Throws an [EmailAccountLoginException] in case of errors, with reason:
  /// - [EmailAccountLoginExceptionReason.invalidCredentials] if the email or
  ///   password is incorrect.
  /// - [EmailAccountLoginExceptionReason.tooManyAttempts] if there have been
  ///   too many failed login attempts.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _i2.Future<_i12.AuthSuccess> login({
    required String email,
    required String password,
  }) => caller.callServerEndpoint<_i12.AuthSuccess>(
    'emailIdp',
    'login',
    {
      'email': email,
      'password': password,
    },
  );

  /// Starts the registration for a new user account with an email-based login
  /// associated to it.
  ///
  /// Upon successful completion of this method, an email will have been
  /// sent to [email] with a verification link, which the user must open to
  /// complete the registration.
  ///
  /// Always returns a account request ID, which can be used to complete the
  /// registration. If the email is already registered, the returned ID will not
  /// be valid.
  @override
  _i2.Future<_i1.UuidValue> startRegistration({required String email}) =>
      caller.callServerEndpoint<_i1.UuidValue>(
        'emailIdp',
        'startRegistration',
        {'email': email},
      );

  /// Verifies an account request code and returns a token
  /// that can be used to complete the account creation.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if no request exists
  ///   for the given [accountRequestId] or [verificationCode] is invalid.
  @override
  _i2.Future<String> verifyRegistrationCode({
    required _i1.UuidValue accountRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyRegistrationCode',
    {
      'accountRequestId': accountRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a new account registration, creating a new auth user with a
  /// profile and attaching the given email account to it.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if the [registrationToken]
  ///   is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  ///
  /// Returns a session for the newly created user.
  @override
  _i2.Future<_i12.AuthSuccess> finishRegistration({
    required String registrationToken,
    required String password,
  }) => caller.callServerEndpoint<_i12.AuthSuccess>(
    'emailIdp',
    'finishRegistration',
    {
      'registrationToken': registrationToken,
      'password': password,
    },
  );

  /// Requests a password reset for [email].
  ///
  /// If the email address is registered, an email with reset instructions will
  /// be send out. If the email is unknown, this method will have no effect.
  ///
  /// Always returns a password reset request ID, which can be used to complete
  /// the reset. If the email is not registered, the returned ID will not be
  /// valid.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to request a password reset.
  ///
  @override
  _i2.Future<_i1.UuidValue> startPasswordReset({required String email}) =>
      caller.callServerEndpoint<_i1.UuidValue>(
        'emailIdp',
        'startPasswordReset',
        {'email': email},
      );

  /// Verifies a password reset code and returns a finishPasswordResetToken
  /// that can be used to finish the password reset.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to verify the password reset.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// If multiple steps are required to complete the password reset, this endpoint
  /// should be overridden to return credentials for the next step instead
  /// of the credentials for setting the password.
  @override
  _i2.Future<String> verifyPasswordResetCode({
    required _i1.UuidValue passwordResetRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyPasswordResetCode',
    {
      'passwordResetRequestId': passwordResetRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a password reset request by setting a new password.
  ///
  /// The [verificationCode] returned from [verifyPasswordResetCode] is used to
  /// validate the password reset request.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.policyViolation] if the new
  ///   password does not comply with the password policy.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _i2.Future<void> finishPasswordReset({
    required String finishPasswordResetToken,
    required String newPassword,
  }) => caller.callServerEndpoint<void>(
    'emailIdp',
    'finishPasswordReset',
    {
      'finishPasswordResetToken': finishPasswordResetToken,
      'newPassword': newPassword,
    },
  );

  @override
  _i2.Future<bool> hasAccount() => caller.callServerEndpoint<bool>(
    'emailIdp',
    'hasAccount',
    {},
  );
}

/// {@category Endpoint}
class EndpointStudent extends _i1.EndpointRef {
  EndpointStudent(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'student';

  _i2.Future<_i13.CurriculumDetailsDto?> getMyCurriculum() =>
      caller.callServerEndpoint<_i13.CurriculumDetailsDto?>(
        'student',
        'getMyCurriculum',
        {},
      );
}

/// This is an example endpoint that returns a greeting message through
/// its [hello] method.
/// {@category Endpoint}
class EndpointGreeting extends _i1.EndpointRef {
  EndpointGreeting(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'greeting';

  /// Returns a personalized greeting message: "Hello {name}".
  _i2.Future<_i14.Greeting> hello(String name) =>
      caller.callServerEndpoint<_i14.Greeting>(
        'greeting',
        'hello',
        {'name': name},
      );
}

class Modules {
  Modules(Client client) {
    serverpod_auth_idp = _i11.Caller(client);
    serverpod_auth_core = _i12.Caller(client);
  }

  late final _i11.Caller serverpod_auth_idp;

  late final _i12.Caller serverpod_auth_core;
}

class Client extends _i1.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    @Deprecated(
      'Use authKeyProvider instead. This will be removed in future releases.',
    )
    super.authenticationKeyManager,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _i1.MethodCallContext,
      Object,
      StackTrace,
    )?
    onFailedCall,
    Function(_i1.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
  }) : super(
         host,
         _i15.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
       ) {
    academic = EndpointAcademic(this);
    account = EndpointAccount(this);
    adminAccount = EndpointAdminAccount(this);
    chatbot = EndpointChatbot(this);
    course = EndpointCourse(this);
    curriculumAdmin = EndpointCurriculumAdmin(this);
    emailIdp = EndpointEmailIdp(this);
    student = EndpointStudent(this);
    greeting = EndpointGreeting(this);
    modules = Modules(this);
  }

  late final EndpointAcademic academic;

  late final EndpointAccount account;

  late final EndpointAdminAccount adminAccount;

  late final EndpointChatbot chatbot;

  late final EndpointCourse course;

  late final EndpointCurriculumAdmin curriculumAdmin;

  late final EndpointEmailIdp emailIdp;

  late final EndpointStudent student;

  late final EndpointGreeting greeting;

  late final Modules modules;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
    'academic': academic,
    'account': account,
    'adminAccount': adminAccount,
    'chatbot': chatbot,
    'course': course,
    'curriculumAdmin': curriculumAdmin,
    'emailIdp': emailIdp,
    'student': student,
    'greeting': greeting,
  };

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup => {
    'serverpod_auth_idp': modules.serverpod_auth_idp,
    'serverpod_auth_core': modules.serverpod_auth_core,
  };
}
