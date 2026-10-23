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

abstract class Curriculum
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  Curriculum._({
    this.id,
    required this.code,
    required this.name,
    required this.majorCode,
    required this.status,
  });

  factory Curriculum({
    int? id,
    required String code,
    required String name,
    required String majorCode,
    required String status,
  }) = _CurriculumImpl;

  factory Curriculum.fromJson(Map<String, dynamic> jsonSerialization) {
    return Curriculum(
      id: jsonSerialization['id'] as int?,
      code: jsonSerialization['code'] as String,
      name: jsonSerialization['name'] as String,
      majorCode: jsonSerialization['majorCode'] as String,
      status: jsonSerialization['status'] as String,
    );
  }

  static final t = CurriculumTable();

  static const db = CurriculumRepository._();

  @override
  int? id;

  String code;

  String name;

  String majorCode;

  String status;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [Curriculum]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Curriculum copyWith({
    int? id,
    String? code,
    String? name,
    String? majorCode,
    String? status,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Curriculum',
      if (id != null) 'id': id,
      'code': code,
      'name': name,
      'majorCode': majorCode,
      'status': status,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static CurriculumInclude include() {
    return CurriculumInclude._();
  }

  static CurriculumIncludeList includeList({
    _i1.WhereExpressionBuilder<CurriculumTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CurriculumTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CurriculumTable>? orderByList,
    CurriculumInclude? include,
  }) {
    return CurriculumIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Curriculum.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Curriculum.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CurriculumImpl extends Curriculum {
  _CurriculumImpl({
    int? id,
    required String code,
    required String name,
    required String majorCode,
    required String status,
  }) : super._(
         id: id,
         code: code,
         name: name,
         majorCode: majorCode,
         status: status,
       );

  /// Returns a shallow copy of this [Curriculum]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Curriculum copyWith({
    Object? id = _Undefined,
    String? code,
    String? name,
    String? majorCode,
    String? status,
  }) {
    return Curriculum(
      id: id is int? ? id : this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      majorCode: majorCode ?? this.majorCode,
      status: status ?? this.status,
    );
  }
}

class CurriculumUpdateTable extends _i1.UpdateTable<CurriculumTable> {
  CurriculumUpdateTable(super.table);

  _i1.ColumnValue<String, String> code(String value) => _i1.ColumnValue(
    table.code,
    value,
  );

  _i1.ColumnValue<String, String> name(String value) => _i1.ColumnValue(
    table.name,
    value,
  );

  _i1.ColumnValue<String, String> majorCode(String value) => _i1.ColumnValue(
    table.majorCode,
    value,
  );

  _i1.ColumnValue<String, String> status(String value) => _i1.ColumnValue(
    table.status,
    value,
  );
}

class CurriculumTable extends _i1.Table<int?> {
  CurriculumTable({super.tableRelation}) : super(tableName: 'app_curriculum') {
    updateTable = CurriculumUpdateTable(this);
    code = _i1.ColumnString(
      'code',
      this,
    );
    name = _i1.ColumnString(
      'name',
      this,
    );
    majorCode = _i1.ColumnString(
      'majorCode',
      this,
    );
    status = _i1.ColumnString(
      'status',
      this,
    );
  }

  late final CurriculumUpdateTable updateTable;

  late final _i1.ColumnString code;

  late final _i1.ColumnString name;

  late final _i1.ColumnString majorCode;

  late final _i1.ColumnString status;

  @override
  List<_i1.Column> get columns => [
    id,
    code,
    name,
    majorCode,
    status,
  ];
}

class CurriculumInclude extends _i1.IncludeObject {
  CurriculumInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => Curriculum.t;
}

class CurriculumIncludeList extends _i1.IncludeList {
  CurriculumIncludeList._({
    _i1.WhereExpressionBuilder<CurriculumTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Curriculum.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => Curriculum.t;
}

class CurriculumRepository {
  const CurriculumRepository._();

  /// Returns a list of [Curriculum]s matching the given query parameters.
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
  Future<List<Curriculum>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<CurriculumTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CurriculumTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CurriculumTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Curriculum>(
      where: where?.call(Curriculum.t),
      orderBy: orderBy?.call(Curriculum.t),
      orderByList: orderByList?.call(Curriculum.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Curriculum] matching the given query parameters.
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
  Future<Curriculum?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<CurriculumTable>? where,
    int? offset,
    _i1.OrderByBuilder<CurriculumTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CurriculumTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Curriculum>(
      where: where?.call(Curriculum.t),
      orderBy: orderBy?.call(Curriculum.t),
      orderByList: orderByList?.call(Curriculum.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Curriculum] by its [id] or null if no such row exists.
  Future<Curriculum?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Curriculum>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Curriculum]s in the list and returns the inserted rows.
  ///
  /// The returned [Curriculum]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<Curriculum>> insert(
    _i1.DatabaseSession session,
    List<Curriculum> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<Curriculum>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [Curriculum] and returns the inserted row.
  ///
  /// The returned [Curriculum] will have its `id` field set.
  Future<Curriculum> insertRow(
    _i1.DatabaseSession session,
    Curriculum row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<Curriculum>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [Curriculum]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<Curriculum>> update(
    _i1.DatabaseSession session,
    List<Curriculum> rows, {
    _i1.ColumnSelections<CurriculumTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<Curriculum>(
      rows,
      columns: columns?.call(Curriculum.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Curriculum]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Curriculum> updateRow(
    _i1.DatabaseSession session,
    Curriculum row, {
    _i1.ColumnSelections<CurriculumTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<Curriculum>(
      row,
      columns: columns?.call(Curriculum.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Curriculum] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Curriculum?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<CurriculumUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<Curriculum>(
      id,
      columnValues: columnValues(Curriculum.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Curriculum]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<Curriculum>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<CurriculumUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<CurriculumTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CurriculumTable>? orderBy,
    _i1.OrderByListBuilder<CurriculumTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<Curriculum>(
      columnValues: columnValues(Curriculum.t.updateTable),
      where: where(Curriculum.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Curriculum.t),
      orderByList: orderByList?.call(Curriculum.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [Curriculum]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<Curriculum>> delete(
    _i1.DatabaseSession session,
    List<Curriculum> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Curriculum>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [Curriculum].
  Future<Curriculum> deleteRow(
    _i1.DatabaseSession session,
    Curriculum row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Curriculum>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<Curriculum>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<CurriculumTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Curriculum>(
      where: where(Curriculum.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<CurriculumTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Curriculum>(
      where: where?.call(Curriculum.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Curriculum] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<CurriculumTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Curriculum>(
      where: where(Curriculum.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
