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
import 'lecturer_status.dart' as _i2;

abstract class Lecturer
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  Lecturer._({
    this.id,
    required this.userAccountId,
    required this.lecturerCode,
    required this.teachingStatus,
  });

  factory Lecturer({
    int? id,
    required int userAccountId,
    required String lecturerCode,
    required _i2.LecturerStatus teachingStatus,
  }) = _LecturerImpl;

  factory Lecturer.fromJson(Map<String, dynamic> jsonSerialization) {
    return Lecturer(
      id: jsonSerialization['id'] as int?,
      userAccountId: jsonSerialization['userAccountId'] as int,
      lecturerCode: jsonSerialization['lecturerCode'] as String,
      teachingStatus: _i2.LecturerStatus.fromJson(
        (jsonSerialization['teachingStatus'] as String),
      ),
    );
  }

  static final t = LecturerTable();

  static const db = LecturerRepository._();

  @override
  int? id;

  int userAccountId;

  String lecturerCode;

  _i2.LecturerStatus teachingStatus;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [Lecturer]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Lecturer copyWith({
    int? id,
    int? userAccountId,
    String? lecturerCode,
    _i2.LecturerStatus? teachingStatus,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Lecturer',
      if (id != null) 'id': id,
      'userAccountId': userAccountId,
      'lecturerCode': lecturerCode,
      'teachingStatus': teachingStatus.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static LecturerInclude include() {
    return LecturerInclude._();
  }

  static LecturerIncludeList includeList({
    _i1.WhereExpressionBuilder<LecturerTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<LecturerTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<LecturerTable>? orderByList,
    LecturerInclude? include,
  }) {
    return LecturerIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Lecturer.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Lecturer.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _LecturerImpl extends Lecturer {
  _LecturerImpl({
    int? id,
    required int userAccountId,
    required String lecturerCode,
    required _i2.LecturerStatus teachingStatus,
  }) : super._(
         id: id,
         userAccountId: userAccountId,
         lecturerCode: lecturerCode,
         teachingStatus: teachingStatus,
       );

  /// Returns a shallow copy of this [Lecturer]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Lecturer copyWith({
    Object? id = _Undefined,
    int? userAccountId,
    String? lecturerCode,
    _i2.LecturerStatus? teachingStatus,
  }) {
    return Lecturer(
      id: id is int? ? id : this.id,
      userAccountId: userAccountId ?? this.userAccountId,
      lecturerCode: lecturerCode ?? this.lecturerCode,
      teachingStatus: teachingStatus ?? this.teachingStatus,
    );
  }
}

class LecturerUpdateTable extends _i1.UpdateTable<LecturerTable> {
  LecturerUpdateTable(super.table);

  _i1.ColumnValue<int, int> userAccountId(int value) => _i1.ColumnValue(
    table.userAccountId,
    value,
  );

  _i1.ColumnValue<String, String> lecturerCode(String value) => _i1.ColumnValue(
    table.lecturerCode,
    value,
  );

  _i1.ColumnValue<_i2.LecturerStatus, _i2.LecturerStatus> teachingStatus(
    _i2.LecturerStatus value,
  ) => _i1.ColumnValue(
    table.teachingStatus,
    value,
  );
}

class LecturerTable extends _i1.Table<int?> {
  LecturerTable({super.tableRelation}) : super(tableName: 'app_lecturer') {
    updateTable = LecturerUpdateTable(this);
    userAccountId = _i1.ColumnInt(
      'userAccountId',
      this,
    );
    lecturerCode = _i1.ColumnString(
      'lecturerCode',
      this,
    );
    teachingStatus = _i1.ColumnEnum(
      'teachingStatus',
      this,
      _i1.EnumSerialization.byName,
    );
  }

  late final LecturerUpdateTable updateTable;

  late final _i1.ColumnInt userAccountId;

  late final _i1.ColumnString lecturerCode;

  late final _i1.ColumnEnum<_i2.LecturerStatus> teachingStatus;

  @override
  List<_i1.Column> get columns => [
    id,
    userAccountId,
    lecturerCode,
    teachingStatus,
  ];
}

class LecturerInclude extends _i1.IncludeObject {
  LecturerInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => Lecturer.t;
}

class LecturerIncludeList extends _i1.IncludeList {
  LecturerIncludeList._({
    _i1.WhereExpressionBuilder<LecturerTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Lecturer.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => Lecturer.t;
}

class LecturerRepository {
  const LecturerRepository._();

  /// Returns a list of [Lecturer]s matching the given query parameters.
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
  Future<List<Lecturer>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<LecturerTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<LecturerTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<LecturerTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Lecturer>(
      where: where?.call(Lecturer.t),
      orderBy: orderBy?.call(Lecturer.t),
      orderByList: orderByList?.call(Lecturer.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Lecturer] matching the given query parameters.
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
  Future<Lecturer?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<LecturerTable>? where,
    int? offset,
    _i1.OrderByBuilder<LecturerTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<LecturerTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Lecturer>(
      where: where?.call(Lecturer.t),
      orderBy: orderBy?.call(Lecturer.t),
      orderByList: orderByList?.call(Lecturer.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Lecturer] by its [id] or null if no such row exists.
  Future<Lecturer?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Lecturer>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Lecturer]s in the list and returns the inserted rows.
  ///
  /// The returned [Lecturer]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<Lecturer>> insert(
    _i1.DatabaseSession session,
    List<Lecturer> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<Lecturer>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [Lecturer] and returns the inserted row.
  ///
  /// The returned [Lecturer] will have its `id` field set.
  Future<Lecturer> insertRow(
    _i1.DatabaseSession session,
    Lecturer row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<Lecturer>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [Lecturer]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<Lecturer>> update(
    _i1.DatabaseSession session,
    List<Lecturer> rows, {
    _i1.ColumnSelections<LecturerTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<Lecturer>(
      rows,
      columns: columns?.call(Lecturer.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Lecturer]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Lecturer> updateRow(
    _i1.DatabaseSession session,
    Lecturer row, {
    _i1.ColumnSelections<LecturerTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<Lecturer>(
      row,
      columns: columns?.call(Lecturer.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Lecturer] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Lecturer?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<LecturerUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<Lecturer>(
      id,
      columnValues: columnValues(Lecturer.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Lecturer]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<Lecturer>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<LecturerUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<LecturerTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<LecturerTable>? orderBy,
    _i1.OrderByListBuilder<LecturerTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<Lecturer>(
      columnValues: columnValues(Lecturer.t.updateTable),
      where: where(Lecturer.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Lecturer.t),
      orderByList: orderByList?.call(Lecturer.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [Lecturer]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<Lecturer>> delete(
    _i1.DatabaseSession session,
    List<Lecturer> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Lecturer>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [Lecturer].
  Future<Lecturer> deleteRow(
    _i1.DatabaseSession session,
    Lecturer row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Lecturer>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<Lecturer>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<LecturerTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Lecturer>(
      where: where(Lecturer.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<LecturerTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Lecturer>(
      where: where?.call(Lecturer.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Lecturer] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<LecturerTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Lecturer>(
      where: where(Lecturer.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
