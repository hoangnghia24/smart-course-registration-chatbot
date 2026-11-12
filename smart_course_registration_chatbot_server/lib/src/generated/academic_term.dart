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

abstract class AcademicTerm
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  AcademicTerm._({
    this.id,
    required this.academicYear,
    required this.termName,
    required this.status,
    required this.maxCreditsPerTerm,
    required this.startAt,
    required this.endAt,
  });

  factory AcademicTerm({
    int? id,
    required String academicYear,
    required String termName,
    required String status,
    required double maxCreditsPerTerm,
    required DateTime startAt,
    required DateTime endAt,
  }) = _AcademicTermImpl;

  factory AcademicTerm.fromJson(Map<String, dynamic> jsonSerialization) {
    return AcademicTerm(
      id: jsonSerialization['id'] as int?,
      academicYear: jsonSerialization['academicYear'] as String,
      termName: jsonSerialization['termName'] as String,
      status: jsonSerialization['status'] as String,
      maxCreditsPerTerm: (jsonSerialization['maxCreditsPerTerm'] as num)
          .toDouble(),
      startAt: _i1.DateTimeJsonExtension.fromJson(jsonSerialization['startAt']),
      endAt: _i1.DateTimeJsonExtension.fromJson(jsonSerialization['endAt']),
    );
  }

  static final t = AcademicTermTable();

  static const db = AcademicTermRepository._();

  @override
  int? id;

  String academicYear;

  String termName;

  String status;

  double maxCreditsPerTerm;

  /// thời gian bắt đầu và kết thúc học kỳ
  DateTime startAt;

  DateTime endAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [AcademicTerm]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AcademicTerm copyWith({
    int? id,
    String? academicYear,
    String? termName,
    String? status,
    double? maxCreditsPerTerm,
    DateTime? startAt,
    DateTime? endAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AcademicTerm',
      if (id != null) 'id': id,
      'academicYear': academicYear,
      'termName': termName,
      'status': status,
      'maxCreditsPerTerm': maxCreditsPerTerm,
      'startAt': startAt.toJson(),
      'endAt': endAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AcademicTerm',
      if (id != null) 'id': id,
      'academicYear': academicYear,
      'termName': termName,
      'status': status,
      'maxCreditsPerTerm': maxCreditsPerTerm,
      'startAt': startAt.toJson(),
      'endAt': endAt.toJson(),
    };
  }

  static AcademicTermInclude include() {
    return AcademicTermInclude._();
  }

  static AcademicTermIncludeList includeList({
    _i1.WhereExpressionBuilder<AcademicTermTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AcademicTermTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AcademicTermTable>? orderByList,
    AcademicTermInclude? include,
  }) {
    return AcademicTermIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AcademicTerm.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(AcademicTerm.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AcademicTermImpl extends AcademicTerm {
  _AcademicTermImpl({
    int? id,
    required String academicYear,
    required String termName,
    required String status,
    required double maxCreditsPerTerm,
    required DateTime startAt,
    required DateTime endAt,
  }) : super._(
         id: id,
         academicYear: academicYear,
         termName: termName,
         status: status,
         maxCreditsPerTerm: maxCreditsPerTerm,
         startAt: startAt,
         endAt: endAt,
       );

  /// Returns a shallow copy of this [AcademicTerm]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AcademicTerm copyWith({
    Object? id = _Undefined,
    String? academicYear,
    String? termName,
    String? status,
    double? maxCreditsPerTerm,
    DateTime? startAt,
    DateTime? endAt,
  }) {
    return AcademicTerm(
      id: id is int? ? id : this.id,
      academicYear: academicYear ?? this.academicYear,
      termName: termName ?? this.termName,
      status: status ?? this.status,
      maxCreditsPerTerm: maxCreditsPerTerm ?? this.maxCreditsPerTerm,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
    );
  }
}

class AcademicTermUpdateTable extends _i1.UpdateTable<AcademicTermTable> {
  AcademicTermUpdateTable(super.table);

  _i1.ColumnValue<String, String> academicYear(String value) => _i1.ColumnValue(
    table.academicYear,
    value,
  );

  _i1.ColumnValue<String, String> termName(String value) => _i1.ColumnValue(
    table.termName,
    value,
  );

  _i1.ColumnValue<String, String> status(String value) => _i1.ColumnValue(
    table.status,
    value,
  );

  _i1.ColumnValue<double, double> maxCreditsPerTerm(double value) =>
      _i1.ColumnValue(
        table.maxCreditsPerTerm,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> startAt(DateTime value) =>
      _i1.ColumnValue(
        table.startAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> endAt(DateTime value) => _i1.ColumnValue(
    table.endAt,
    value,
  );
}

class AcademicTermTable extends _i1.Table<int?> {
  AcademicTermTable({super.tableRelation})
    : super(tableName: 'app_academic_term') {
    updateTable = AcademicTermUpdateTable(this);
    academicYear = _i1.ColumnString(
      'academicYear',
      this,
    );
    termName = _i1.ColumnString(
      'termName',
      this,
    );
    status = _i1.ColumnString(
      'status',
      this,
    );
    maxCreditsPerTerm = _i1.ColumnDouble(
      'maxCreditsPerTerm',
      this,
    );
    startAt = _i1.ColumnDateTime(
      'startAt',
      this,
    );
    endAt = _i1.ColumnDateTime(
      'endAt',
      this,
    );
  }

  late final AcademicTermUpdateTable updateTable;

  late final _i1.ColumnString academicYear;

  late final _i1.ColumnString termName;

  late final _i1.ColumnString status;

  late final _i1.ColumnDouble maxCreditsPerTerm;

  /// thời gian bắt đầu và kết thúc học kỳ
  late final _i1.ColumnDateTime startAt;

  late final _i1.ColumnDateTime endAt;

  @override
  List<_i1.Column> get columns => [
    id,
    academicYear,
    termName,
    status,
    maxCreditsPerTerm,
    startAt,
    endAt,
  ];
}

class AcademicTermInclude extends _i1.IncludeObject {
  AcademicTermInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => AcademicTerm.t;
}

class AcademicTermIncludeList extends _i1.IncludeList {
  AcademicTermIncludeList._({
    _i1.WhereExpressionBuilder<AcademicTermTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(AcademicTerm.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => AcademicTerm.t;
}

class AcademicTermRepository {
  const AcademicTermRepository._();

  /// Returns a list of [AcademicTerm]s matching the given query parameters.
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
  Future<List<AcademicTerm>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<AcademicTermTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AcademicTermTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AcademicTermTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<AcademicTerm>(
      where: where?.call(AcademicTerm.t),
      orderBy: orderBy?.call(AcademicTerm.t),
      orderByList: orderByList?.call(AcademicTerm.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [AcademicTerm] matching the given query parameters.
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
  Future<AcademicTerm?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<AcademicTermTable>? where,
    int? offset,
    _i1.OrderByBuilder<AcademicTermTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AcademicTermTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<AcademicTerm>(
      where: where?.call(AcademicTerm.t),
      orderBy: orderBy?.call(AcademicTerm.t),
      orderByList: orderByList?.call(AcademicTerm.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [AcademicTerm] by its [id] or null if no such row exists.
  Future<AcademicTerm?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<AcademicTerm>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [AcademicTerm]s in the list and returns the inserted rows.
  ///
  /// The returned [AcademicTerm]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<AcademicTerm>> insert(
    _i1.DatabaseSession session,
    List<AcademicTerm> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<AcademicTerm>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [AcademicTerm] and returns the inserted row.
  ///
  /// The returned [AcademicTerm] will have its `id` field set.
  Future<AcademicTerm> insertRow(
    _i1.DatabaseSession session,
    AcademicTerm row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<AcademicTerm>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [AcademicTerm]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<AcademicTerm>> update(
    _i1.DatabaseSession session,
    List<AcademicTerm> rows, {
    _i1.ColumnSelections<AcademicTermTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<AcademicTerm>(
      rows,
      columns: columns?.call(AcademicTerm.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AcademicTerm]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<AcademicTerm> updateRow(
    _i1.DatabaseSession session,
    AcademicTerm row, {
    _i1.ColumnSelections<AcademicTermTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<AcademicTerm>(
      row,
      columns: columns?.call(AcademicTerm.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AcademicTerm] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<AcademicTerm?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<AcademicTermUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<AcademicTerm>(
      id,
      columnValues: columnValues(AcademicTerm.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [AcademicTerm]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<AcademicTerm>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<AcademicTermUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<AcademicTermTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AcademicTermTable>? orderBy,
    _i1.OrderByListBuilder<AcademicTermTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<AcademicTerm>(
      columnValues: columnValues(AcademicTerm.t.updateTable),
      where: where(AcademicTerm.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AcademicTerm.t),
      orderByList: orderByList?.call(AcademicTerm.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [AcademicTerm]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<AcademicTerm>> delete(
    _i1.DatabaseSession session,
    List<AcademicTerm> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<AcademicTerm>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [AcademicTerm].
  Future<AcademicTerm> deleteRow(
    _i1.DatabaseSession session,
    AcademicTerm row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<AcademicTerm>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<AcademicTerm>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<AcademicTermTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<AcademicTerm>(
      where: where(AcademicTerm.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<AcademicTermTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<AcademicTerm>(
      where: where?.call(AcademicTerm.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [AcademicTerm] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<AcademicTermTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<AcademicTerm>(
      where: where(AcademicTerm.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
