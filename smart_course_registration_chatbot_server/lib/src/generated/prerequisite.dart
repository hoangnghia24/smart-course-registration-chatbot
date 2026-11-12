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

abstract class Prerequisite
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  Prerequisite._({
    this.id,
    required this.courseId,
    required this.prerequisiteCourseId,
  });

  factory Prerequisite({
    int? id,
    required int courseId,
    required int prerequisiteCourseId,
  }) = _PrerequisiteImpl;

  factory Prerequisite.fromJson(Map<String, dynamic> jsonSerialization) {
    return Prerequisite(
      id: jsonSerialization['id'] as int?,
      courseId: jsonSerialization['courseId'] as int,
      prerequisiteCourseId: jsonSerialization['prerequisiteCourseId'] as int,
    );
  }

  static final t = PrerequisiteTable();

  static const db = PrerequisiteRepository._();

  @override
  int? id;

  /// môn học đang xét kiểm tra điều kiện tiên quyết
  int courseId;

  /// môn học tiên quyết
  int prerequisiteCourseId;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [Prerequisite]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Prerequisite copyWith({
    int? id,
    int? courseId,
    int? prerequisiteCourseId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Prerequisite',
      if (id != null) 'id': id,
      'courseId': courseId,
      'prerequisiteCourseId': prerequisiteCourseId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static PrerequisiteInclude include() {
    return PrerequisiteInclude._();
  }

  static PrerequisiteIncludeList includeList({
    _i1.WhereExpressionBuilder<PrerequisiteTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PrerequisiteTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PrerequisiteTable>? orderByList,
    PrerequisiteInclude? include,
  }) {
    return PrerequisiteIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Prerequisite.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Prerequisite.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PrerequisiteImpl extends Prerequisite {
  _PrerequisiteImpl({
    int? id,
    required int courseId,
    required int prerequisiteCourseId,
  }) : super._(
         id: id,
         courseId: courseId,
         prerequisiteCourseId: prerequisiteCourseId,
       );

  /// Returns a shallow copy of this [Prerequisite]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Prerequisite copyWith({
    Object? id = _Undefined,
    int? courseId,
    int? prerequisiteCourseId,
  }) {
    return Prerequisite(
      id: id is int? ? id : this.id,
      courseId: courseId ?? this.courseId,
      prerequisiteCourseId: prerequisiteCourseId ?? this.prerequisiteCourseId,
    );
  }
}

class PrerequisiteUpdateTable extends _i1.UpdateTable<PrerequisiteTable> {
  PrerequisiteUpdateTable(super.table);

  _i1.ColumnValue<int, int> courseId(int value) => _i1.ColumnValue(
    table.courseId,
    value,
  );

  _i1.ColumnValue<int, int> prerequisiteCourseId(int value) => _i1.ColumnValue(
    table.prerequisiteCourseId,
    value,
  );
}

class PrerequisiteTable extends _i1.Table<int?> {
  PrerequisiteTable({super.tableRelation})
    : super(tableName: 'app_prerequisite') {
    updateTable = PrerequisiteUpdateTable(this);
    courseId = _i1.ColumnInt(
      'courseId',
      this,
    );
    prerequisiteCourseId = _i1.ColumnInt(
      'prerequisiteCourseId',
      this,
    );
  }

  late final PrerequisiteUpdateTable updateTable;

  /// môn học đang xét kiểm tra điều kiện tiên quyết
  late final _i1.ColumnInt courseId;

  /// môn học tiên quyết
  late final _i1.ColumnInt prerequisiteCourseId;

  @override
  List<_i1.Column> get columns => [
    id,
    courseId,
    prerequisiteCourseId,
  ];
}

class PrerequisiteInclude extends _i1.IncludeObject {
  PrerequisiteInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => Prerequisite.t;
}

class PrerequisiteIncludeList extends _i1.IncludeList {
  PrerequisiteIncludeList._({
    _i1.WhereExpressionBuilder<PrerequisiteTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Prerequisite.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => Prerequisite.t;
}

class PrerequisiteRepository {
  const PrerequisiteRepository._();

  /// Returns a list of [Prerequisite]s matching the given query parameters.
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
  Future<List<Prerequisite>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<PrerequisiteTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PrerequisiteTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PrerequisiteTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Prerequisite>(
      where: where?.call(Prerequisite.t),
      orderBy: orderBy?.call(Prerequisite.t),
      orderByList: orderByList?.call(Prerequisite.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Prerequisite] matching the given query parameters.
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
  Future<Prerequisite?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<PrerequisiteTable>? where,
    int? offset,
    _i1.OrderByBuilder<PrerequisiteTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PrerequisiteTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Prerequisite>(
      where: where?.call(Prerequisite.t),
      orderBy: orderBy?.call(Prerequisite.t),
      orderByList: orderByList?.call(Prerequisite.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Prerequisite] by its [id] or null if no such row exists.
  Future<Prerequisite?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Prerequisite>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Prerequisite]s in the list and returns the inserted rows.
  ///
  /// The returned [Prerequisite]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<Prerequisite>> insert(
    _i1.DatabaseSession session,
    List<Prerequisite> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<Prerequisite>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [Prerequisite] and returns the inserted row.
  ///
  /// The returned [Prerequisite] will have its `id` field set.
  Future<Prerequisite> insertRow(
    _i1.DatabaseSession session,
    Prerequisite row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<Prerequisite>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [Prerequisite]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<Prerequisite>> update(
    _i1.DatabaseSession session,
    List<Prerequisite> rows, {
    _i1.ColumnSelections<PrerequisiteTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<Prerequisite>(
      rows,
      columns: columns?.call(Prerequisite.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Prerequisite]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Prerequisite> updateRow(
    _i1.DatabaseSession session,
    Prerequisite row, {
    _i1.ColumnSelections<PrerequisiteTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<Prerequisite>(
      row,
      columns: columns?.call(Prerequisite.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Prerequisite] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Prerequisite?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<PrerequisiteUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<Prerequisite>(
      id,
      columnValues: columnValues(Prerequisite.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Prerequisite]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<Prerequisite>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<PrerequisiteUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<PrerequisiteTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PrerequisiteTable>? orderBy,
    _i1.OrderByListBuilder<PrerequisiteTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<Prerequisite>(
      columnValues: columnValues(Prerequisite.t.updateTable),
      where: where(Prerequisite.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Prerequisite.t),
      orderByList: orderByList?.call(Prerequisite.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [Prerequisite]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<Prerequisite>> delete(
    _i1.DatabaseSession session,
    List<Prerequisite> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Prerequisite>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [Prerequisite].
  Future<Prerequisite> deleteRow(
    _i1.DatabaseSession session,
    Prerequisite row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Prerequisite>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<Prerequisite>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<PrerequisiteTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Prerequisite>(
      where: where(Prerequisite.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<PrerequisiteTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Prerequisite>(
      where: where?.call(Prerequisite.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Prerequisite] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<PrerequisiteTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Prerequisite>(
      where: where(Prerequisite.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
