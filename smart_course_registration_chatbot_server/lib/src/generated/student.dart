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

abstract class Student
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  Student._({
    this.id,
    required this.userAccountId,
    required this.studentCode,
    required this.curriculumVersionId,
    required this.academicStatus,
  });

  factory Student({
    int? id,
    required int userAccountId,
    required String studentCode,
    required int curriculumVersionId,
    required String academicStatus,
  }) = _StudentImpl;

  factory Student.fromJson(Map<String, dynamic> jsonSerialization) {
    return Student(
      id: jsonSerialization['id'] as int?,
      userAccountId: jsonSerialization['userAccountId'] as int,
      studentCode: jsonSerialization['studentCode'] as String,
      curriculumVersionId: jsonSerialization['curriculumVersionId'] as int,
      academicStatus: jsonSerialization['academicStatus'] as String,
    );
  }

  static final t = StudentTable();

  static const db = StudentRepository._();

  @override
  int? id;

  int userAccountId;

  String studentCode;

  int curriculumVersionId;

  String academicStatus;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [Student]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Student copyWith({
    int? id,
    int? userAccountId,
    String? studentCode,
    int? curriculumVersionId,
    String? academicStatus,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Student',
      if (id != null) 'id': id,
      'userAccountId': userAccountId,
      'studentCode': studentCode,
      'curriculumVersionId': curriculumVersionId,
      'academicStatus': academicStatus,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static StudentInclude include() {
    return StudentInclude._();
  }

  static StudentIncludeList includeList({
    _i1.WhereExpressionBuilder<StudentTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<StudentTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<StudentTable>? orderByList,
    StudentInclude? include,
  }) {
    return StudentIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Student.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Student.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _StudentImpl extends Student {
  _StudentImpl({
    int? id,
    required int userAccountId,
    required String studentCode,
    required int curriculumVersionId,
    required String academicStatus,
  }) : super._(
         id: id,
         userAccountId: userAccountId,
         studentCode: studentCode,
         curriculumVersionId: curriculumVersionId,
         academicStatus: academicStatus,
       );

  /// Returns a shallow copy of this [Student]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Student copyWith({
    Object? id = _Undefined,
    int? userAccountId,
    String? studentCode,
    int? curriculumVersionId,
    String? academicStatus,
  }) {
    return Student(
      id: id is int? ? id : this.id,
      userAccountId: userAccountId ?? this.userAccountId,
      studentCode: studentCode ?? this.studentCode,
      curriculumVersionId: curriculumVersionId ?? this.curriculumVersionId,
      academicStatus: academicStatus ?? this.academicStatus,
    );
  }
}

class StudentUpdateTable extends _i1.UpdateTable<StudentTable> {
  StudentUpdateTable(super.table);

  _i1.ColumnValue<int, int> userAccountId(int value) => _i1.ColumnValue(
    table.userAccountId,
    value,
  );

  _i1.ColumnValue<String, String> studentCode(String value) => _i1.ColumnValue(
    table.studentCode,
    value,
  );

  _i1.ColumnValue<int, int> curriculumVersionId(int value) => _i1.ColumnValue(
    table.curriculumVersionId,
    value,
  );

  _i1.ColumnValue<String, String> academicStatus(String value) =>
      _i1.ColumnValue(
        table.academicStatus,
        value,
      );
}

class StudentTable extends _i1.Table<int?> {
  StudentTable({super.tableRelation}) : super(tableName: 'app_student') {
    updateTable = StudentUpdateTable(this);
    userAccountId = _i1.ColumnInt(
      'userAccountId',
      this,
    );
    studentCode = _i1.ColumnString(
      'studentCode',
      this,
    );
    curriculumVersionId = _i1.ColumnInt(
      'curriculumVersionId',
      this,
    );
    academicStatus = _i1.ColumnString(
      'academicStatus',
      this,
    );
  }

  late final StudentUpdateTable updateTable;

  late final _i1.ColumnInt userAccountId;

  late final _i1.ColumnString studentCode;

  late final _i1.ColumnInt curriculumVersionId;

  late final _i1.ColumnString academicStatus;

  @override
  List<_i1.Column> get columns => [
    id,
    userAccountId,
    studentCode,
    curriculumVersionId,
    academicStatus,
  ];
}

class StudentInclude extends _i1.IncludeObject {
  StudentInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => Student.t;
}

class StudentIncludeList extends _i1.IncludeList {
  StudentIncludeList._({
    _i1.WhereExpressionBuilder<StudentTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Student.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => Student.t;
}

class StudentRepository {
  const StudentRepository._();

  /// Returns a list of [Student]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<Student>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<StudentTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<StudentTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<StudentTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Student>(
      where: where?.call(Student.t),
      orderBy: orderBy?.call(Student.t),
      orderByList: orderByList?.call(Student.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Student] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<Student?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<StudentTable>? where,
    int? offset,
    _i1.OrderByBuilder<StudentTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<StudentTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Student>(
      where: where?.call(Student.t),
      orderBy: orderBy?.call(Student.t),
      orderByList: orderByList?.call(Student.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Student] by its [id] or null if no such row exists.
  Future<Student?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Student>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Student]s in the list and returns the inserted rows.
  ///
  /// The returned [Student]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<Student>> insert(
    _i1.DatabaseSession session,
    List<Student> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<Student>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [Student] and returns the inserted row.
  ///
  /// The returned [Student] will have its `id` field set.
  Future<Student> insertRow(
    _i1.DatabaseSession session,
    Student row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<Student>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [Student]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<Student>> update(
    _i1.DatabaseSession session,
    List<Student> rows, {
    _i1.ColumnSelections<StudentTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<Student>(
      rows,
      columns: columns?.call(Student.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Student]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Student> updateRow(
    _i1.DatabaseSession session,
    Student row, {
    _i1.ColumnSelections<StudentTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<Student>(
      row,
      columns: columns?.call(Student.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Student] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Student?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<StudentUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<Student>(
      id,
      columnValues: columnValues(Student.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Student]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<Student>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<StudentUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<StudentTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<StudentTable>? orderBy,
    _i1.OrderByListBuilder<StudentTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<Student>(
      columnValues: columnValues(Student.t.updateTable),
      where: where(Student.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Student.t),
      orderByList: orderByList?.call(Student.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [Student]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<Student>> delete(
    _i1.DatabaseSession session,
    List<Student> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Student>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [Student].
  Future<Student> deleteRow(
    _i1.DatabaseSession session,
    Student row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Student>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<Student>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<StudentTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Student>(
      where: where(Student.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<StudentTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Student>(
      where: where?.call(Student.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Student] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<StudentTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Student>(
      where: where(Student.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
