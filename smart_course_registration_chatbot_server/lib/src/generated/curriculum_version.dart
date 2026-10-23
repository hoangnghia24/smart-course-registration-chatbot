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

abstract class CurriculumVersion
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  CurriculumVersion._({
    this.id,
    required this.curriculumId,
    required this.versionCode,
    required this.effectiveYear,
    required this.status,
  });

  factory CurriculumVersion({
    int? id,
    required int curriculumId,
    required String versionCode,
    required int effectiveYear,
    required String status,
  }) = _CurriculumVersionImpl;

  factory CurriculumVersion.fromJson(Map<String, dynamic> jsonSerialization) {
    return CurriculumVersion(
      id: jsonSerialization['id'] as int?,
      curriculumId: jsonSerialization['curriculumId'] as int,
      versionCode: jsonSerialization['versionCode'] as String,
      effectiveYear: jsonSerialization['effectiveYear'] as int,
      status: jsonSerialization['status'] as String,
    );
  }

  static final t = CurriculumVersionTable();

  static const db = CurriculumVersionRepository._();

  @override
  int? id;

  int curriculumId;

  String versionCode;

  int effectiveYear;

  String status;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [CurriculumVersion]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CurriculumVersion copyWith({
    int? id,
    int? curriculumId,
    String? versionCode,
    int? effectiveYear,
    String? status,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CurriculumVersion',
      if (id != null) 'id': id,
      'curriculumId': curriculumId,
      'versionCode': versionCode,
      'effectiveYear': effectiveYear,
      'status': status,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static CurriculumVersionInclude include() {
    return CurriculumVersionInclude._();
  }

  static CurriculumVersionIncludeList includeList({
    _i1.WhereExpressionBuilder<CurriculumVersionTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CurriculumVersionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CurriculumVersionTable>? orderByList,
    CurriculumVersionInclude? include,
  }) {
    return CurriculumVersionIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CurriculumVersion.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(CurriculumVersion.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CurriculumVersionImpl extends CurriculumVersion {
  _CurriculumVersionImpl({
    int? id,
    required int curriculumId,
    required String versionCode,
    required int effectiveYear,
    required String status,
  }) : super._(
         id: id,
         curriculumId: curriculumId,
         versionCode: versionCode,
         effectiveYear: effectiveYear,
         status: status,
       );

  /// Returns a shallow copy of this [CurriculumVersion]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CurriculumVersion copyWith({
    Object? id = _Undefined,
    int? curriculumId,
    String? versionCode,
    int? effectiveYear,
    String? status,
  }) {
    return CurriculumVersion(
      id: id is int? ? id : this.id,
      curriculumId: curriculumId ?? this.curriculumId,
      versionCode: versionCode ?? this.versionCode,
      effectiveYear: effectiveYear ?? this.effectiveYear,
      status: status ?? this.status,
    );
  }
}

class CurriculumVersionUpdateTable
    extends _i1.UpdateTable<CurriculumVersionTable> {
  CurriculumVersionUpdateTable(super.table);

  _i1.ColumnValue<int, int> curriculumId(int value) => _i1.ColumnValue(
    table.curriculumId,
    value,
  );

  _i1.ColumnValue<String, String> versionCode(String value) => _i1.ColumnValue(
    table.versionCode,
    value,
  );

  _i1.ColumnValue<int, int> effectiveYear(int value) => _i1.ColumnValue(
    table.effectiveYear,
    value,
  );

  _i1.ColumnValue<String, String> status(String value) => _i1.ColumnValue(
    table.status,
    value,
  );
}

class CurriculumVersionTable extends _i1.Table<int?> {
  CurriculumVersionTable({super.tableRelation})
    : super(tableName: 'app_curriculum_version') {
    updateTable = CurriculumVersionUpdateTable(this);
    curriculumId = _i1.ColumnInt(
      'curriculumId',
      this,
    );
    versionCode = _i1.ColumnString(
      'versionCode',
      this,
    );
    effectiveYear = _i1.ColumnInt(
      'effectiveYear',
      this,
    );
    status = _i1.ColumnString(
      'status',
      this,
    );
  }

  late final CurriculumVersionUpdateTable updateTable;

  late final _i1.ColumnInt curriculumId;

  late final _i1.ColumnString versionCode;

  late final _i1.ColumnInt effectiveYear;

  late final _i1.ColumnString status;

  @override
  List<_i1.Column> get columns => [
    id,
    curriculumId,
    versionCode,
    effectiveYear,
    status,
  ];
}

class CurriculumVersionInclude extends _i1.IncludeObject {
  CurriculumVersionInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => CurriculumVersion.t;
}

class CurriculumVersionIncludeList extends _i1.IncludeList {
  CurriculumVersionIncludeList._({
    _i1.WhereExpressionBuilder<CurriculumVersionTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CurriculumVersion.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => CurriculumVersion.t;
}

class CurriculumVersionRepository {
  const CurriculumVersionRepository._();

  /// Returns a list of [CurriculumVersion]s matching the given query parameters.
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
  Future<List<CurriculumVersion>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<CurriculumVersionTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CurriculumVersionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CurriculumVersionTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CurriculumVersion>(
      where: where?.call(CurriculumVersion.t),
      orderBy: orderBy?.call(CurriculumVersion.t),
      orderByList: orderByList?.call(CurriculumVersion.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CurriculumVersion] matching the given query parameters.
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
  Future<CurriculumVersion?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<CurriculumVersionTable>? where,
    int? offset,
    _i1.OrderByBuilder<CurriculumVersionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CurriculumVersionTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CurriculumVersion>(
      where: where?.call(CurriculumVersion.t),
      orderBy: orderBy?.call(CurriculumVersion.t),
      orderByList: orderByList?.call(CurriculumVersion.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CurriculumVersion] by its [id] or null if no such row exists.
  Future<CurriculumVersion?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CurriculumVersion>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CurriculumVersion]s in the list and returns the inserted rows.
  ///
  /// The returned [CurriculumVersion]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<CurriculumVersion>> insert(
    _i1.DatabaseSession session,
    List<CurriculumVersion> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<CurriculumVersion>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [CurriculumVersion] and returns the inserted row.
  ///
  /// The returned [CurriculumVersion] will have its `id` field set.
  Future<CurriculumVersion> insertRow(
    _i1.DatabaseSession session,
    CurriculumVersion row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<CurriculumVersion>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [CurriculumVersion]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<CurriculumVersion>> update(
    _i1.DatabaseSession session,
    List<CurriculumVersion> rows, {
    _i1.ColumnSelections<CurriculumVersionTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<CurriculumVersion>(
      rows,
      columns: columns?.call(CurriculumVersion.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CurriculumVersion]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CurriculumVersion> updateRow(
    _i1.DatabaseSession session,
    CurriculumVersion row, {
    _i1.ColumnSelections<CurriculumVersionTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<CurriculumVersion>(
      row,
      columns: columns?.call(CurriculumVersion.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CurriculumVersion] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CurriculumVersion?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<CurriculumVersionUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<CurriculumVersion>(
      id,
      columnValues: columnValues(CurriculumVersion.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CurriculumVersion]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<CurriculumVersion>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<CurriculumVersionUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<CurriculumVersionTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CurriculumVersionTable>? orderBy,
    _i1.OrderByListBuilder<CurriculumVersionTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<CurriculumVersion>(
      columnValues: columnValues(CurriculumVersion.t.updateTable),
      where: where(CurriculumVersion.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CurriculumVersion.t),
      orderByList: orderByList?.call(CurriculumVersion.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [CurriculumVersion]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<CurriculumVersion>> delete(
    _i1.DatabaseSession session,
    List<CurriculumVersion> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<CurriculumVersion>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [CurriculumVersion].
  Future<CurriculumVersion> deleteRow(
    _i1.DatabaseSession session,
    CurriculumVersion row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CurriculumVersion>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<CurriculumVersion>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<CurriculumVersionTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<CurriculumVersion>(
      where: where(CurriculumVersion.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<CurriculumVersionTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<CurriculumVersion>(
      where: where?.call(CurriculumVersion.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CurriculumVersion] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<CurriculumVersionTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CurriculumVersion>(
      where: where(CurriculumVersion.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
