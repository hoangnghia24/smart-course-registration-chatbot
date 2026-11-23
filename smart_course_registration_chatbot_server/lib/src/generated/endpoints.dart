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
import '../endpoints/academic_endpoint.dart' as _i2;
import '../endpoints/account_endpoint.dart' as _i3;
import '../endpoints/admin_account_endpoint.dart' as _i4;
import '../endpoints/chatbot_endpoint.dart' as _i5;
import '../endpoints/course_endpoint.dart' as _i6;
import '../endpoints/curriculum_admin_endpoint.dart' as _i7;
import '../endpoints/email_idp_endpoint.dart' as _i8;
import '../endpoints/student_endpoint.dart' as _i9;
import '../greetings/greeting_endpoint.dart' as _i10;
import 'package:smart_course_registration_chatbot_server/src/generated/course_dto.dart'
    as _i11;
import 'package:smart_course_registration_chatbot_server/src/generated/curriculum_draft_input.dart'
    as _i12;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _i13;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _i14;

class Endpoints extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    var endpoints = <String, _i1.Endpoint>{
      'academic': _i2.AcademicEndpoint()
        ..initialize(
          server,
          'academic',
          null,
        ),
      'account': _i3.AccountEndpoint()
        ..initialize(
          server,
          'account',
          null,
        ),
      'adminAccount': _i4.AdminAccountEndpoint()
        ..initialize(
          server,
          'adminAccount',
          null,
        ),
      'chatbot': _i5.ChatbotEndpoint()
        ..initialize(
          server,
          'chatbot',
          null,
        ),
      'course': _i6.CourseEndpoint()
        ..initialize(
          server,
          'course',
          null,
        ),
      'curriculumAdmin': _i7.CurriculumAdminEndpoint()
        ..initialize(
          server,
          'curriculumAdmin',
          null,
        ),
      'emailIdp': _i8.EmailIdpEndpoint()
        ..initialize(
          server,
          'emailIdp',
          null,
        ),
      'student': _i9.StudentEndpoint()
        ..initialize(
          server,
          'student',
          null,
        ),
      'greeting': _i10.GreetingEndpoint()
        ..initialize(
          server,
          'greeting',
          null,
        ),
    };
    connectors['academic'] = _i1.EndpointConnector(
      name: 'academic',
      endpoint: endpoints['academic']!,
      methodConnectors: {
        'getMyProgress': _i1.MethodConnector(
          name: 'getMyProgress',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['academic'] as _i2.AcademicEndpoint)
                  .getMyProgress(session),
        ),
      },
    );
    connectors['account'] = _i1.EndpointConnector(
      name: 'account',
      endpoint: endpoints['account']!,
      methodConnectors: {
        'me': _i1.MethodConnector(
          name: 'me',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['account'] as _i3.AccountEndpoint).me(session),
        ),
        'logoutAll': _i1.MethodConnector(
          name: 'logoutAll',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['account'] as _i3.AccountEndpoint)
                  .logoutAll(session),
        ),
      },
    );
    connectors['adminAccount'] = _i1.EndpointConnector(
      name: 'adminAccount',
      endpoint: endpoints['adminAccount']!,
      methodConnectors: {
        'checkAccess': _i1.MethodConnector(
          name: 'checkAccess',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['adminAccount'] as _i4.AdminAccountEndpoint)
                  .checkAccess(session),
        ),
        'setActive': _i1.MethodConnector(
          name: 'setActive',
          params: {
            'accountId': _i1.ParameterDescription(
              name: 'accountId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'active': _i1.ParameterDescription(
              name: 'active',
              type: _i1.getType<bool>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['adminAccount'] as _i4.AdminAccountEndpoint)
                  .setActive(
                    session,
                    params['accountId'],
                    params['active'],
                  ),
        ),
      },
    );
    connectors['chatbot'] = _i1.EndpointConnector(
      name: 'chatbot',
      endpoint: endpoints['chatbot']!,
      methodConnectors: {
        'sendMessage': _i1.MethodConnector(
          name: 'sendMessage',
          params: {
            'message': _i1.ParameterDescription(
              name: 'message',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['chatbot'] as _i5.ChatbotEndpoint).sendMessage(
                    session,
                    params['message'],
                  ),
        ),
      },
    );
    connectors['course'] = _i1.EndpointConnector(
      name: 'course',
      endpoint: endpoints['course']!,
      methodConnectors: {
        'getCoursesPage': _i1.MethodConnector(
          name: 'getCoursesPage',
          params: {
            'page': _i1.ParameterDescription(
              name: 'page',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'pageSize': _i1.ParameterDescription(
              name: 'pageSize',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['course'] as _i6.CourseEndpoint).getCoursesPage(
                    session,
                    params['page'],
                    params['pageSize'],
                  ),
        ),
        'createCourse': _i1.MethodConnector(
          name: 'createCourse',
          params: {
            'courseDto': _i1.ParameterDescription(
              name: 'courseDto',
              type: _i1.getType<_i11.CourseDto>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['course'] as _i6.CourseEndpoint).createCourse(
                    session,
                    params['courseDto'],
                  ),
        ),
        'updateCourse': _i1.MethodConnector(
          name: 'updateCourse',
          params: {
            'courseDto': _i1.ParameterDescription(
              name: 'courseDto',
              type: _i1.getType<_i11.CourseDto>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['course'] as _i6.CourseEndpoint).updateCourse(
                    session,
                    params['courseDto'],
                  ),
        ),
        'deleteCourse': _i1.MethodConnector(
          name: 'deleteCourse',
          params: {
            'courseId': _i1.ParameterDescription(
              name: 'courseId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['course'] as _i6.CourseEndpoint).deleteCourse(
                    session,
                    params['courseId'],
                  ),
        ),
        'searchCourses': _i1.MethodConnector(
          name: 'searchCourses',
          params: {
            'query': _i1.ParameterDescription(
              name: 'query',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'page': _i1.ParameterDescription(
              name: 'page',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'pageSize': _i1.ParameterDescription(
              name: 'pageSize',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['course'] as _i6.CourseEndpoint).searchCourses(
                    session,
                    params['query'],
                    params['page'],
                    params['pageSize'],
                  ),
        ),
        'getCourseById': _i1.MethodConnector(
          name: 'getCourseById',
          params: {
            'courseId': _i1.ParameterDescription(
              name: 'courseId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['course'] as _i6.CourseEndpoint).getCourseById(
                    session,
                    params['courseId'],
                  ),
        ),
      },
    );
    connectors['curriculumAdmin'] = _i1.EndpointConnector(
      name: 'curriculumAdmin',
      endpoint: endpoints['curriculumAdmin']!,
      methodConnectors: {
        'listCurriculums': _i1.MethodConnector(
          name: 'listCurriculums',
          params: {
            'query': _i1.ParameterDescription(
              name: 'query',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['curriculumAdmin'] as _i7.CurriculumAdminEndpoint)
                      .listCurriculums(
                        session,
                        params['query'],
                      ),
        ),
        'createCurriculum': _i1.MethodConnector(
          name: 'createCurriculum',
          params: {
            'code': _i1.ParameterDescription(
              name: 'code',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'majorCode': _i1.ParameterDescription(
              name: 'majorCode',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['curriculumAdmin'] as _i7.CurriculumAdminEndpoint)
                      .createCurriculum(
                        session,
                        params['code'],
                        params['name'],
                        params['majorCode'],
                      ),
        ),
        'createDraftVersion': _i1.MethodConnector(
          name: 'createDraftVersion',
          params: {
            'curriculumId': _i1.ParameterDescription(
              name: 'curriculumId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'versionCode': _i1.ParameterDescription(
              name: 'versionCode',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'effectiveYear': _i1.ParameterDescription(
              name: 'effectiveYear',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'copyFromVersionId': _i1.ParameterDescription(
              name: 'copyFromVersionId',
              type: _i1.getType<int?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['curriculumAdmin'] as _i7.CurriculumAdminEndpoint)
                      .createDraftVersion(
                        session,
                        params['curriculumId'],
                        params['versionCode'],
                        params['effectiveYear'],
                        params['copyFromVersionId'],
                      ),
        ),
        'getVersion': _i1.MethodConnector(
          name: 'getVersion',
          params: {
            'versionId': _i1.ParameterDescription(
              name: 'versionId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['curriculumAdmin'] as _i7.CurriculumAdminEndpoint)
                      .getVersion(
                        session,
                        params['versionId'],
                      ),
        ),
        'saveDraftVersion': _i1.MethodConnector(
          name: 'saveDraftVersion',
          params: {
            'input': _i1.ParameterDescription(
              name: 'input',
              type: _i1.getType<_i12.CurriculumDraftInput>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['curriculumAdmin'] as _i7.CurriculumAdminEndpoint)
                      .saveDraftVersion(
                        session,
                        params['input'],
                      ),
        ),
        'publishVersion': _i1.MethodConnector(
          name: 'publishVersion',
          params: {
            'versionId': _i1.ParameterDescription(
              name: 'versionId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'expectedRevision': _i1.ParameterDescription(
              name: 'expectedRevision',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['curriculumAdmin'] as _i7.CurriculumAdminEndpoint)
                      .publishVersion(
                        session,
                        params['versionId'],
                        params['expectedRevision'],
                      ),
        ),
        'archiveVersion': _i1.MethodConnector(
          name: 'archiveVersion',
          params: {
            'versionId': _i1.ParameterDescription(
              name: 'versionId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['curriculumAdmin'] as _i7.CurriculumAdminEndpoint)
                      .archiveVersion(
                        session,
                        params['versionId'],
                      ),
        ),
        'deleteDraftVersion': _i1.MethodConnector(
          name: 'deleteDraftVersion',
          params: {
            'versionId': _i1.ParameterDescription(
              name: 'versionId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['curriculumAdmin'] as _i7.CurriculumAdminEndpoint)
                      .deleteDraftVersion(
                        session,
                        params['versionId'],
                      ),
        ),
        'previewVersionForAdmission': _i1.MethodConnector(
          name: 'previewVersionForAdmission',
          params: {
            'curriculumCode': _i1.ParameterDescription(
              name: 'curriculumCode',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'admissionYear': _i1.ParameterDescription(
              name: 'admissionYear',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['curriculumAdmin'] as _i7.CurriculumAdminEndpoint)
                      .previewVersionForAdmission(
                        session,
                        params['curriculumCode'],
                        params['admissionYear'],
                      ),
        ),
        'getStudentAssignment': _i1.MethodConnector(
          name: 'getStudentAssignment',
          params: {
            'studentCode': _i1.ParameterDescription(
              name: 'studentCode',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['curriculumAdmin'] as _i7.CurriculumAdminEndpoint)
                      .getStudentAssignment(
                        session,
                        params['studentCode'],
                      ),
        ),
        'changeStudentVersion': _i1.MethodConnector(
          name: 'changeStudentVersion',
          params: {
            'studentCode': _i1.ParameterDescription(
              name: 'studentCode',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'versionId': _i1.ParameterDescription(
              name: 'versionId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'reason': _i1.ParameterDescription(
              name: 'reason',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['curriculumAdmin'] as _i7.CurriculumAdminEndpoint)
                      .changeStudentVersion(
                        session,
                        params['studentCode'],
                        params['versionId'],
                        params['reason'],
                      ),
        ),
        'setStudentAdmissionYear': _i1.MethodConnector(
          name: 'setStudentAdmissionYear',
          params: {
            'studentCode': _i1.ParameterDescription(
              name: 'studentCode',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'admissionYear': _i1.ParameterDescription(
              name: 'admissionYear',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['curriculumAdmin'] as _i7.CurriculumAdminEndpoint)
                      .setStudentAdmissionYear(
                        session,
                        params['studentCode'],
                        params['admissionYear'],
                      ),
        ),
      },
    );
    connectors['emailIdp'] = _i1.EndpointConnector(
      name: 'emailIdp',
      endpoint: endpoints['emailIdp']!,
      methodConnectors: {
        'login': _i1.MethodConnector(
          name: 'login',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'password': _i1.ParameterDescription(
              name: 'password',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i8.EmailIdpEndpoint).login(
                session,
                email: params['email'],
                password: params['password'],
              ),
        ),
        'startRegistration': _i1.MethodConnector(
          name: 'startRegistration',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i8.EmailIdpEndpoint)
                  .startRegistration(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyRegistrationCode': _i1.MethodConnector(
          name: 'verifyRegistrationCode',
          params: {
            'accountRequestId': _i1.ParameterDescription(
              name: 'accountRequestId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _i1.ParameterDescription(
              name: 'verificationCode',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i8.EmailIdpEndpoint)
                  .verifyRegistrationCode(
                    session,
                    accountRequestId: params['accountRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishRegistration': _i1.MethodConnector(
          name: 'finishRegistration',
          params: {
            'registrationToken': _i1.ParameterDescription(
              name: 'registrationToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'password': _i1.ParameterDescription(
              name: 'password',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i8.EmailIdpEndpoint)
                  .finishRegistration(
                    session,
                    registrationToken: params['registrationToken'],
                    password: params['password'],
                  ),
        ),
        'startPasswordReset': _i1.MethodConnector(
          name: 'startPasswordReset',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i8.EmailIdpEndpoint)
                  .startPasswordReset(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyPasswordResetCode': _i1.MethodConnector(
          name: 'verifyPasswordResetCode',
          params: {
            'passwordResetRequestId': _i1.ParameterDescription(
              name: 'passwordResetRequestId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _i1.ParameterDescription(
              name: 'verificationCode',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i8.EmailIdpEndpoint)
                  .verifyPasswordResetCode(
                    session,
                    passwordResetRequestId: params['passwordResetRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishPasswordReset': _i1.MethodConnector(
          name: 'finishPasswordReset',
          params: {
            'finishPasswordResetToken': _i1.ParameterDescription(
              name: 'finishPasswordResetToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'newPassword': _i1.ParameterDescription(
              name: 'newPassword',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i8.EmailIdpEndpoint)
                  .finishPasswordReset(
                    session,
                    finishPasswordResetToken:
                        params['finishPasswordResetToken'],
                    newPassword: params['newPassword'],
                  ),
        ),
        'hasAccount': _i1.MethodConnector(
          name: 'hasAccount',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i8.EmailIdpEndpoint)
                  .hasAccount(session),
        ),
      },
    );
    connectors['student'] = _i1.EndpointConnector(
      name: 'student',
      endpoint: endpoints['student']!,
      methodConnectors: {
        'getMyCurriculum': _i1.MethodConnector(
          name: 'getMyCurriculum',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['student'] as _i9.StudentEndpoint)
                  .getMyCurriculum(session),
        ),
      },
    );
    connectors['greeting'] = _i1.EndpointConnector(
      name: 'greeting',
      endpoint: endpoints['greeting']!,
      methodConnectors: {
        'hello': _i1.MethodConnector(
          name: 'hello',
          params: {
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['greeting'] as _i10.GreetingEndpoint).hello(
                session,
                params['name'],
              ),
        ),
      },
    );
    modules['serverpod_auth_idp'] = _i13.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_auth_core'] = _i14.Endpoints()
      ..initializeEndpoints(server);
  }
}
