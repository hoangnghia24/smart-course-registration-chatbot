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
import 'package:serverpod/protocol.dart' as _i2;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _i3;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _i4;
import 'account_role.dart' as _i5;
import 'account_status.dart' as _i6;
import 'app_exception.dart' as _i7;
import 'audit_log.dart' as _i8;
import 'course.dart' as _i9;
import 'course_item_dto.dart' as _i10;
import 'current_user_dto.dart' as _i11;
import 'curriculum.dart' as _i12;
import 'curriculum_details_dto.dart' as _i13;
import 'curriculum_dto.dart' as _i14;
import 'curriculum_item.dart' as _i15;
import 'curriculum_item_detail_dto.dart' as _i16;
import 'curriculum_version.dart' as _i17;
import 'curriculum_version_dto.dart' as _i18;
import 'greetings/greeting.dart' as _i19;
import 'lecturer.dart' as _i20;
import 'lecturer_status.dart' as _i21;
import 'student.dart' as _i22;
import 'user_account.dart' as _i23;
export 'account_role.dart';
export 'account_status.dart';
export 'app_exception.dart';
export 'audit_log.dart';
export 'course.dart';
export 'course_item_dto.dart';
export 'current_user_dto.dart';
export 'curriculum.dart';
export 'curriculum_details_dto.dart';
export 'curriculum_dto.dart';
export 'curriculum_item.dart';
export 'curriculum_item_detail_dto.dart';
export 'curriculum_version.dart';
export 'curriculum_version_dto.dart';
export 'greetings/greeting.dart';
export 'lecturer.dart';
export 'lecturer_status.dart';
export 'student.dart';
export 'user_account.dart';

class Protocol extends _i1.SerializationManagerServer {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static final List<_i2.TableDefinition> targetTableDefinitions = [
    _i2.TableDefinition(
      name: 'app_audit_log',
      dartName: 'AuditLog',
      schema: 'public',
      module: 'smart_course_registration_chatbot',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'app_audit_log_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'actorUserAccountId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'targetUserAccountId',
          columnType: _i2.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _i2.ColumnDefinition(
          name: 'action',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _i2.ColumnDefinition(
          name: 'details',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'app_audit_log_fk_0',
          columns: ['actorUserAccountId'],
          referenceTable: 'app_user_account',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _i2.ForeignKeyDefinition(
          constraintName: 'app_audit_log_fk_1',
          columns: ['targetUserAccountId'],
          referenceTable: 'app_user_account',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'app_audit_log_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'app_course',
      dartName: 'Course',
      schema: 'public',
      module: 'smart_course_registration_chatbot',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'app_course_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'code',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'name',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'credits',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'description',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'isActive',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'app_course_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'app_course_code_unique',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'code',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'app_curriculum',
      dartName: 'Curriculum',
      schema: 'public',
      module: 'smart_course_registration_chatbot',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'app_curriculum_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'code',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'name',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'majorCode',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'status',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'app_curriculum_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'app_curriculum_code_unique',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'code',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'app_curriculum_item',
      dartName: 'CurriculumItem',
      schema: 'public',
      module: 'smart_course_registration_chatbot',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'app_curriculum_item_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'curriculumVersionId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'courseId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'semester',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'isRequired',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'app_curriculum_item_fk_0',
          columns: ['curriculumVersionId'],
          referenceTable: 'app_curriculum_version',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _i2.ForeignKeyDefinition(
          constraintName: 'app_curriculum_item_fk_1',
          columns: ['courseId'],
          referenceTable: 'app_course',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'app_curriculum_item_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'app_curriculum_item_unique',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'curriculumVersionId',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'courseId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'app_curriculum_version',
      dartName: 'CurriculumVersion',
      schema: 'public',
      module: 'smart_course_registration_chatbot',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'app_curriculum_version_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'curriculumId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'versionCode',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'effectiveYear',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'status',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'app_curriculum_version_fk_0',
          columns: ['curriculumId'],
          referenceTable: 'app_curriculum',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'app_curriculum_version_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'app_curriculum_version_unique',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'curriculumId',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'versionCode',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'app_lecturer',
      dartName: 'Lecturer',
      schema: 'public',
      module: 'smart_course_registration_chatbot',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'app_lecturer_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'userAccountId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'lecturerCode',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'teachingStatus',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:LecturerStatus',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'app_lecturer_fk_0',
          columns: ['userAccountId'],
          referenceTable: 'app_user_account',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'app_lecturer_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'app_lecturer_account_unique',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'userAccountId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'app_lecturer_code_unique',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'lecturerCode',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'app_student',
      dartName: 'Student',
      schema: 'public',
      module: 'smart_course_registration_chatbot',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'app_student_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'userAccountId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'studentCode',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'curriculumVersionId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'academicStatus',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'app_student_fk_0',
          columns: ['userAccountId'],
          referenceTable: 'app_user_account',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _i2.ForeignKeyDefinition(
          constraintName: 'app_student_fk_1',
          columns: ['curriculumVersionId'],
          referenceTable: 'app_curriculum_version',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'app_student_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'app_student_account_unique',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'userAccountId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'app_student_code_unique',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'studentCode',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'app_user_account',
      dartName: 'UserAccount',
      schema: 'public',
      module: 'smart_course_registration_chatbot',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'app_user_account_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'authUserId',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'schoolEmail',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'role',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:AccountRole',
        ),
        _i2.ColumnDefinition(
          name: 'status',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:AccountStatus',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _i2.ColumnDefinition(
          name: 'updatedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _i2.ColumnDefinition(
          name: 'statusChangedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'app_user_account_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'app_user_account_auth_user_unique',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'authUserId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'app_user_account_email_unique',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'schoolEmail',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    ..._i3.Protocol.targetTableDefinitions,
    ..._i4.Protocol.targetTableDefinitions,
    ..._i2.Protocol.targetTableDefinitions,
  ];

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

    if (t == _i5.AccountRole) {
      return _i5.AccountRole.fromJson(data) as T;
    }
    if (t == _i6.AccountStatus) {
      return _i6.AccountStatus.fromJson(data) as T;
    }
    if (t == _i7.AppException) {
      return _i7.AppException.fromJson(data) as T;
    }
    if (t == _i8.AuditLog) {
      return _i8.AuditLog.fromJson(data) as T;
    }
    if (t == _i9.Course) {
      return _i9.Course.fromJson(data) as T;
    }
    if (t == _i10.CourseItemDto) {
      return _i10.CourseItemDto.fromJson(data) as T;
    }
    if (t == _i11.CurrentUserDto) {
      return _i11.CurrentUserDto.fromJson(data) as T;
    }
    if (t == _i12.Curriculum) {
      return _i12.Curriculum.fromJson(data) as T;
    }
    if (t == _i13.CurriculumDetailsDto) {
      return _i13.CurriculumDetailsDto.fromJson(data) as T;
    }
    if (t == _i14.CurriculumDto) {
      return _i14.CurriculumDto.fromJson(data) as T;
    }
    if (t == _i15.CurriculumItem) {
      return _i15.CurriculumItem.fromJson(data) as T;
    }
    if (t == _i16.CurriculumItemDetailDto) {
      return _i16.CurriculumItemDetailDto.fromJson(data) as T;
    }
    if (t == _i17.CurriculumVersion) {
      return _i17.CurriculumVersion.fromJson(data) as T;
    }
    if (t == _i18.CurriculumVersionDto) {
      return _i18.CurriculumVersionDto.fromJson(data) as T;
    }
    if (t == _i19.Greeting) {
      return _i19.Greeting.fromJson(data) as T;
    }
    if (t == _i20.Lecturer) {
      return _i20.Lecturer.fromJson(data) as T;
    }
    if (t == _i21.LecturerStatus) {
      return _i21.LecturerStatus.fromJson(data) as T;
    }
    if (t == _i22.Student) {
      return _i22.Student.fromJson(data) as T;
    }
    if (t == _i23.UserAccount) {
      return _i23.UserAccount.fromJson(data) as T;
    }
    if (t == _i1.getType<_i5.AccountRole?>()) {
      return (data != null ? _i5.AccountRole.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.AccountStatus?>()) {
      return (data != null ? _i6.AccountStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.AppException?>()) {
      return (data != null ? _i7.AppException.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.AuditLog?>()) {
      return (data != null ? _i8.AuditLog.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.Course?>()) {
      return (data != null ? _i9.Course.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.CourseItemDto?>()) {
      return (data != null ? _i10.CourseItemDto.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.CurrentUserDto?>()) {
      return (data != null ? _i11.CurrentUserDto.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.Curriculum?>()) {
      return (data != null ? _i12.Curriculum.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i13.CurriculumDetailsDto?>()) {
      return (data != null ? _i13.CurriculumDetailsDto.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i14.CurriculumDto?>()) {
      return (data != null ? _i14.CurriculumDto.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i15.CurriculumItem?>()) {
      return (data != null ? _i15.CurriculumItem.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i16.CurriculumItemDetailDto?>()) {
      return (data != null ? _i16.CurriculumItemDetailDto.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i17.CurriculumVersion?>()) {
      return (data != null ? _i17.CurriculumVersion.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i18.CurriculumVersionDto?>()) {
      return (data != null ? _i18.CurriculumVersionDto.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i19.Greeting?>()) {
      return (data != null ? _i19.Greeting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i20.Lecturer?>()) {
      return (data != null ? _i20.Lecturer.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i21.LecturerStatus?>()) {
      return (data != null ? _i21.LecturerStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i22.Student?>()) {
      return (data != null ? _i22.Student.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i23.UserAccount?>()) {
      return (data != null ? _i23.UserAccount.fromJson(data) : null) as T;
    }
    if (t == List<_i16.CurriculumItemDetailDto>) {
      return (data as List)
              .map((e) => deserialize<_i16.CurriculumItemDetailDto>(e))
              .toList()
          as T;
    }
    try {
      return _i3.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i4.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i2.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i5.AccountRole => 'AccountRole',
      _i6.AccountStatus => 'AccountStatus',
      _i7.AppException => 'AppException',
      _i8.AuditLog => 'AuditLog',
      _i9.Course => 'Course',
      _i10.CourseItemDto => 'CourseItemDto',
      _i11.CurrentUserDto => 'CurrentUserDto',
      _i12.Curriculum => 'Curriculum',
      _i13.CurriculumDetailsDto => 'CurriculumDetailsDto',
      _i14.CurriculumDto => 'CurriculumDto',
      _i15.CurriculumItem => 'CurriculumItem',
      _i16.CurriculumItemDetailDto => 'CurriculumItemDetailDto',
      _i17.CurriculumVersion => 'CurriculumVersion',
      _i18.CurriculumVersionDto => 'CurriculumVersionDto',
      _i19.Greeting => 'Greeting',
      _i20.Lecturer => 'Lecturer',
      _i21.LecturerStatus => 'LecturerStatus',
      _i22.Student => 'Student',
      _i23.UserAccount => 'UserAccount',
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
      case _i5.AccountRole():
        return 'AccountRole';
      case _i6.AccountStatus():
        return 'AccountStatus';
      case _i7.AppException():
        return 'AppException';
      case _i8.AuditLog():
        return 'AuditLog';
      case _i9.Course():
        return 'Course';
      case _i10.CourseItemDto():
        return 'CourseItemDto';
      case _i11.CurrentUserDto():
        return 'CurrentUserDto';
      case _i12.Curriculum():
        return 'Curriculum';
      case _i13.CurriculumDetailsDto():
        return 'CurriculumDetailsDto';
      case _i14.CurriculumDto():
        return 'CurriculumDto';
      case _i15.CurriculumItem():
        return 'CurriculumItem';
      case _i16.CurriculumItemDetailDto():
        return 'CurriculumItemDetailDto';
      case _i17.CurriculumVersion():
        return 'CurriculumVersion';
      case _i18.CurriculumVersionDto():
        return 'CurriculumVersionDto';
      case _i19.Greeting():
        return 'Greeting';
      case _i20.Lecturer():
        return 'Lecturer';
      case _i21.LecturerStatus():
        return 'LecturerStatus';
      case _i22.Student():
        return 'Student';
      case _i23.UserAccount():
        return 'UserAccount';
    }
    className = _i2.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod.$className';
    }
    className = _i3.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    className = _i4.Protocol().getClassNameForObject(data);
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
      return deserialize<_i5.AccountRole>(data['data']);
    }
    if (dataClassName == 'AccountStatus') {
      return deserialize<_i6.AccountStatus>(data['data']);
    }
    if (dataClassName == 'AppException') {
      return deserialize<_i7.AppException>(data['data']);
    }
    if (dataClassName == 'AuditLog') {
      return deserialize<_i8.AuditLog>(data['data']);
    }
    if (dataClassName == 'Course') {
      return deserialize<_i9.Course>(data['data']);
    }
    if (dataClassName == 'CourseItemDto') {
      return deserialize<_i10.CourseItemDto>(data['data']);
    }
    if (dataClassName == 'CurrentUserDto') {
      return deserialize<_i11.CurrentUserDto>(data['data']);
    }
    if (dataClassName == 'Curriculum') {
      return deserialize<_i12.Curriculum>(data['data']);
    }
    if (dataClassName == 'CurriculumDetailsDto') {
      return deserialize<_i13.CurriculumDetailsDto>(data['data']);
    }
    if (dataClassName == 'CurriculumDto') {
      return deserialize<_i14.CurriculumDto>(data['data']);
    }
    if (dataClassName == 'CurriculumItem') {
      return deserialize<_i15.CurriculumItem>(data['data']);
    }
    if (dataClassName == 'CurriculumItemDetailDto') {
      return deserialize<_i16.CurriculumItemDetailDto>(data['data']);
    }
    if (dataClassName == 'CurriculumVersion') {
      return deserialize<_i17.CurriculumVersion>(data['data']);
    }
    if (dataClassName == 'CurriculumVersionDto') {
      return deserialize<_i18.CurriculumVersionDto>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_i19.Greeting>(data['data']);
    }
    if (dataClassName == 'Lecturer') {
      return deserialize<_i20.Lecturer>(data['data']);
    }
    if (dataClassName == 'LecturerStatus') {
      return deserialize<_i21.LecturerStatus>(data['data']);
    }
    if (dataClassName == 'Student') {
      return deserialize<_i22.Student>(data['data']);
    }
    if (dataClassName == 'UserAccount') {
      return deserialize<_i23.UserAccount>(data['data']);
    }
    if (dataClassName.startsWith('serverpod.')) {
      data['className'] = dataClassName.substring(10);
      return _i2.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i3.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i4.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  @override
  _i1.Table? getTableForType(Type t) {
    {
      var table = _i3.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _i4.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _i2.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _i8.AuditLog:
        return _i8.AuditLog.t;
      case _i9.Course:
        return _i9.Course.t;
      case _i12.Curriculum:
        return _i12.Curriculum.t;
      case _i15.CurriculumItem:
        return _i15.CurriculumItem.t;
      case _i17.CurriculumVersion:
        return _i17.CurriculumVersion.t;
      case _i20.Lecturer:
        return _i20.Lecturer.t;
      case _i22.Student:
        return _i22.Student.t;
      case _i23.UserAccount:
        return _i23.UserAccount.t;
    }
    return null;
  }

  @override
  List<_i2.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

  @override
  String getModuleName() => 'smart_course_registration_chatbot';

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
      return _i3.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i4.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
