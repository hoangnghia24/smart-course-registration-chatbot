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

/// F07 - Phien ban CTDT ap dung cho (nganh, khoa tuyen sinh).
/// Mot phien ban co the ap dung cho nhieu khoa;
/// moi (nganh, khoa) chi co dung mot phien ban.
abstract class CurriculumCohort
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  CurriculumCohort._({
    this.id,
    required this.curriculumVersionId,
    required this.majorCode,
    required this.admissionYear,
  });

  factory CurriculumCohort({
    int? id,
    required int curriculumVersionId,
    required String majorCode,
    required int admissionYear,
  }) = _CurriculumCohortImpl;

  factory CurriculumCohort.fromJson(Map<String, dynamic> jsonSerialization) {
    return CurriculumCohort(
      id: jsonSerialization['id'] as int?,
      curriculumVersionId: jsonSerialization['curriculumVersionId'] as int,
      majorCode: jsonSerialization['majorCode'] as String,
      admissionYear: jsonSerialization['admissionYear'] as int,
    );
  }

  static final t = CurriculumCohortTable();

  static const db = CurriculumCohortRepository._();

  @override
  int? id;

  int curriculumVersionId;

  /// Trung voi Curriculum.majorCode cua phien ban (service kiem tra)
  String majorCode;

  /// Nam nhap hoc / khoa tuyen sinh, vi du 2024
  int admissionYear;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [CurriculumCohort]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CurriculumCohort copyWith({
    int? id,
    int? curriculumVersionId,
    String? majorCode,
    int? admissionYear,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CurriculumCohort',
      if (id != null) 'id': id,
      'curriculumVersionId': curriculumVersionId,
      'majorCode': majorCode,
      'admissionYear': admissionYear,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static CurriculumCohortInclude include() {
    return CurriculumCohortInclude._();
  }

  static CurriculumCohortIncludeList includeList({
    _i1.WhereExpressionBuilder<CurriculumCohortTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CurriculumCohortTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CurriculumCohortTable>? orderByList,
    CurriculumCohortInclude? include,
  }) {
    return CurriculumCohortIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CurriculumCohort.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(CurriculumCohort.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CurriculumCohortImpl extends CurriculumCohort {
  _CurriculumCohortImpl({
    int? id,
    required int curriculumVersionId,
    required String majorCode,
    required int admissionYear,
  }) : super._(
         id: id,
         curriculumVersionId: curriculumVersionId,
         majorCode: majorCode,
         admissionYear: admissionYear,
       );

  /// Returns a shallow copy of this [CurriculumCohort]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CurriculumCohort copyWith({
    Object? id = _Undefined,
    int? curriculumVersionId,
    String? majorCode,
    int? admissionYear,
  }) {
    return CurriculumCohort(
      id: id is int? ? id : this.id,
      curriculumVersionId: curriculumVersionId ?? this.curriculumVersionId,
      majorCode: majorCode ?? this.majorCode,
      admissionYear: admissionYear ?? this.admissionYear,
    );
  }
}

class CurriculumCohortUpdateTable
    extends _i1.UpdateTable<CurriculumCohortTable> {
  CurriculumCohortUpdateTable(super.table);

  _i1.ColumnValue<int, int> curriculumVersionId(int value) => _i1.ColumnValue(
    table.curriculumVersionId,
    value,
  );

  _i1.ColumnValue<String, String> majorCode(String value) => _i1.ColumnValue(
    table.majorCode,
    value,
  );

  _i1.ColumnValue<int, int> admissionYear(int value) => _i1.ColumnValue(
    table.admissionYear,
    value,
  );
}

class CurriculumCohortTable extends _i1.Table<int?> {
  CurriculumCohortTable({super.tableRelation})
    : super(tableName: 'app_curriculum_cohort') {
    updateTable = CurriculumCohortUpdateTable(this);
    curriculumVersionId = _i1.ColumnInt(
      'curriculumVersionId',
      this,
    );
    majorCode = _i1.ColumnString(
      'majorCode',
      this,
    );
    admissionYear = _i1.ColumnInt(
      'admissionYear',
      this,
    );
  }

  late final CurriculumCohortUpdateTable updateTable;

  late final _i1.ColumnInt curriculumVersionId;

  /// Trung voi Curriculum.majorCode cua phien ban (service kiem tra)
  late final _i1.ColumnString majorCode;

  /// Nam nhap hoc / khoa tuyen sinh, vi du 2024
  late final _i1.ColumnInt admissionYear;

  @override
  List<_i1.Column> get columns => [
    id,
    curriculumVersionId,
    majorCode,
    admissionYear,
  ];
}

class CurriculumCohortInclude extends _i1.IncludeObject {
  CurriculumCohortInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => CurriculumCohort.t;
}

class CurriculumCohortIncludeList extends _i1.IncludeList {
  CurriculumCohortIncludeList._({
    _i1.WhereExpressionBuilder<CurriculumCohortTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CurriculumCohort.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => CurriculumCohort.t;
}

class CurriculumCohortRepository {
  const CurriculumCohortRepository._();

  /// Returns a list of [CurriculumCohort]s matching the given query parameters.
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
  Future<List<CurriculumCohort>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<CurriculumCohortTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CurriculumCohortTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CurriculumCohortTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CurriculumCohort>(
      where: where?.call(CurriculumCohort.t),
      orderBy: orderBy?.call(CurriculumCohort.t),
      orderByList: orderByList?.call(CurriculumCohort.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CurriculumCohort] matching the given query parameters.
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
  Future<CurriculumCohort?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<CurriculumCohortTable>? where,
    int? offset,
    _i1.OrderByBuilder<CurriculumCohortTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CurriculumCohortTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CurriculumCohort>(
      where: where?.call(CurriculumCohort.t),
      orderBy: orderBy?.call(CurriculumCohort.t),
      orderByList: orderByList?.call(CurriculumCohort.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CurriculumCohort] by its [id] or null if no such row exists.
  Future<CurriculumCohort?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CurriculumCohort>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CurriculumCohort]s in the list and returns the inserted rows.
  ///
  /// The returned [CurriculumCohort]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<CurriculumCohort>> insert(
    _i1.DatabaseSession session,
    List<CurriculumCohort> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<CurriculumCohort>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [CurriculumCohort] and returns the inserted row.
  ///
  /// The returned [CurriculumCohort] will have its `id` field set.
  Future<CurriculumCohort> insertRow(
    _i1.DatabaseSession session,
    CurriculumCohort row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<CurriculumCohort>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [CurriculumCohort]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<CurriculumCohort>> update(
    _i1.DatabaseSession session,
    List<CurriculumCohort> rows, {
    _i1.ColumnSelections<CurriculumCohortTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<CurriculumCohort>(
      rows,
      columns: columns?.call(CurriculumCohort.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CurriculumCohort]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CurriculumCohort> updateRow(
    _i1.DatabaseSession session,
    CurriculumCohort row, {
    _i1.ColumnSelections<CurriculumCohortTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<CurriculumCohort>(
      row,
      columns: columns?.call(CurriculumCohort.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CurriculumCohort] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CurriculumCohort?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<CurriculumCohortUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<CurriculumCohort>(
      id,
      columnValues: columnValues(CurriculumCohort.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CurriculumCohort]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<CurriculumCohort>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<CurriculumCohortUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<CurriculumCohortTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CurriculumCohortTable>? orderBy,
    _i1.OrderByListBuilder<CurriculumCohortTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<CurriculumCohort>(
      columnValues: columnValues(CurriculumCohort.t.updateTable),
      where: where(CurriculumCohort.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CurriculumCohort.t),
      orderByList: orderByList?.call(CurriculumCohort.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [CurriculumCohort]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<CurriculumCohort>> delete(
    _i1.DatabaseSession session,
    List<CurriculumCohort> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<CurriculumCohort>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [CurriculumCohort].
  Future<CurriculumCohort> deleteRow(
    _i1.DatabaseSession session,
    CurriculumCohort row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CurriculumCohort>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<CurriculumCohort>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<CurriculumCohortTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<CurriculumCohort>(
      where: where(CurriculumCohort.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<CurriculumCohortTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<CurriculumCohort>(
      where: where?.call(CurriculumCohort.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CurriculumCohort] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<CurriculumCohortTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CurriculumCohort>(
      where: where(CurriculumCohort.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
