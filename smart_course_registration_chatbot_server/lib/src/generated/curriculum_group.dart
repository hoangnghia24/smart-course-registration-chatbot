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

abstract class CurriculumGroup
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  CurriculumGroup._({
    this.id,
    required this.curriculumVersionId,
    required this.groupCode,
    required this.groupName,
    required this.groupOrder,
  });

  factory CurriculumGroup({
    int? id,
    required int curriculumVersionId,
    required String groupCode,
    required String groupName,
    required int groupOrder,
  }) = _CurriculumGroupImpl;

  factory CurriculumGroup.fromJson(Map<String, dynamic> jsonSerialization) {
    return CurriculumGroup(
      id: jsonSerialization['id'] as int?,
      curriculumVersionId: jsonSerialization['curriculumVersionId'] as int,
      groupCode: jsonSerialization['groupCode'] as String,
      groupName: jsonSerialization['groupName'] as String,
      groupOrder: jsonSerialization['groupOrder'] as int,
    );
  }

  static final t = CurriculumGroupTable();

  static const db = CurriculumGroupRepository._();

  @override
  int? id;

  int curriculumVersionId;

  String groupCode;

  String groupName;

  int groupOrder;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [CurriculumGroup]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CurriculumGroup copyWith({
    int? id,
    int? curriculumVersionId,
    String? groupCode,
    String? groupName,
    int? groupOrder,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CurriculumGroup',
      if (id != null) 'id': id,
      'curriculumVersionId': curriculumVersionId,
      'groupCode': groupCode,
      'groupName': groupName,
      'groupOrder': groupOrder,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CurriculumGroup',
      if (id != null) 'id': id,
      'curriculumVersionId': curriculumVersionId,
      'groupCode': groupCode,
      'groupName': groupName,
      'groupOrder': groupOrder,
    };
  }

  static CurriculumGroupInclude include() {
    return CurriculumGroupInclude._();
  }

  static CurriculumGroupIncludeList includeList({
    _i1.WhereExpressionBuilder<CurriculumGroupTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CurriculumGroupTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CurriculumGroupTable>? orderByList,
    CurriculumGroupInclude? include,
  }) {
    return CurriculumGroupIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CurriculumGroup.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(CurriculumGroup.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CurriculumGroupImpl extends CurriculumGroup {
  _CurriculumGroupImpl({
    int? id,
    required int curriculumVersionId,
    required String groupCode,
    required String groupName,
    required int groupOrder,
  }) : super._(
         id: id,
         curriculumVersionId: curriculumVersionId,
         groupCode: groupCode,
         groupName: groupName,
         groupOrder: groupOrder,
       );

  /// Returns a shallow copy of this [CurriculumGroup]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CurriculumGroup copyWith({
    Object? id = _Undefined,
    int? curriculumVersionId,
    String? groupCode,
    String? groupName,
    int? groupOrder,
  }) {
    return CurriculumGroup(
      id: id is int? ? id : this.id,
      curriculumVersionId: curriculumVersionId ?? this.curriculumVersionId,
      groupCode: groupCode ?? this.groupCode,
      groupName: groupName ?? this.groupName,
      groupOrder: groupOrder ?? this.groupOrder,
    );
  }
}

class CurriculumGroupUpdateTable extends _i1.UpdateTable<CurriculumGroupTable> {
  CurriculumGroupUpdateTable(super.table);

  _i1.ColumnValue<int, int> curriculumVersionId(int value) => _i1.ColumnValue(
    table.curriculumVersionId,
    value,
  );

  _i1.ColumnValue<String, String> groupCode(String value) => _i1.ColumnValue(
    table.groupCode,
    value,
  );

  _i1.ColumnValue<String, String> groupName(String value) => _i1.ColumnValue(
    table.groupName,
    value,
  );

  _i1.ColumnValue<int, int> groupOrder(int value) => _i1.ColumnValue(
    table.groupOrder,
    value,
  );
}

class CurriculumGroupTable extends _i1.Table<int?> {
  CurriculumGroupTable({super.tableRelation})
    : super(tableName: 'app_curriculum_group') {
    updateTable = CurriculumGroupUpdateTable(this);
    curriculumVersionId = _i1.ColumnInt(
      'curriculumVersionId',
      this,
    );
    groupCode = _i1.ColumnString(
      'groupCode',
      this,
    );
    groupName = _i1.ColumnString(
      'groupName',
      this,
    );
    groupOrder = _i1.ColumnInt(
      'groupOrder',
      this,
    );
  }

  late final CurriculumGroupUpdateTable updateTable;

  late final _i1.ColumnInt curriculumVersionId;

  late final _i1.ColumnString groupCode;

  late final _i1.ColumnString groupName;

  late final _i1.ColumnInt groupOrder;

  @override
  List<_i1.Column> get columns => [
    id,
    curriculumVersionId,
    groupCode,
    groupName,
    groupOrder,
  ];
}

class CurriculumGroupInclude extends _i1.IncludeObject {
  CurriculumGroupInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => CurriculumGroup.t;
}

class CurriculumGroupIncludeList extends _i1.IncludeList {
  CurriculumGroupIncludeList._({
    _i1.WhereExpressionBuilder<CurriculumGroupTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CurriculumGroup.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => CurriculumGroup.t;
}

class CurriculumGroupRepository {
  const CurriculumGroupRepository._();

  /// Returns a list of [CurriculumGroup]s matching the given query parameters.
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
  Future<List<CurriculumGroup>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<CurriculumGroupTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CurriculumGroupTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CurriculumGroupTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CurriculumGroup>(
      where: where?.call(CurriculumGroup.t),
      orderBy: orderBy?.call(CurriculumGroup.t),
      orderByList: orderByList?.call(CurriculumGroup.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CurriculumGroup] matching the given query parameters.
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
  Future<CurriculumGroup?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<CurriculumGroupTable>? where,
    int? offset,
    _i1.OrderByBuilder<CurriculumGroupTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CurriculumGroupTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CurriculumGroup>(
      where: where?.call(CurriculumGroup.t),
      orderBy: orderBy?.call(CurriculumGroup.t),
      orderByList: orderByList?.call(CurriculumGroup.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CurriculumGroup] by its [id] or null if no such row exists.
  Future<CurriculumGroup?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CurriculumGroup>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CurriculumGroup]s in the list and returns the inserted rows.
  ///
  /// The returned [CurriculumGroup]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<CurriculumGroup>> insert(
    _i1.DatabaseSession session,
    List<CurriculumGroup> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<CurriculumGroup>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [CurriculumGroup] and returns the inserted row.
  ///
  /// The returned [CurriculumGroup] will have its `id` field set.
  Future<CurriculumGroup> insertRow(
    _i1.DatabaseSession session,
    CurriculumGroup row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<CurriculumGroup>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [CurriculumGroup]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<CurriculumGroup>> update(
    _i1.DatabaseSession session,
    List<CurriculumGroup> rows, {
    _i1.ColumnSelections<CurriculumGroupTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<CurriculumGroup>(
      rows,
      columns: columns?.call(CurriculumGroup.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CurriculumGroup]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CurriculumGroup> updateRow(
    _i1.DatabaseSession session,
    CurriculumGroup row, {
    _i1.ColumnSelections<CurriculumGroupTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<CurriculumGroup>(
      row,
      columns: columns?.call(CurriculumGroup.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CurriculumGroup] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CurriculumGroup?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<CurriculumGroupUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<CurriculumGroup>(
      id,
      columnValues: columnValues(CurriculumGroup.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CurriculumGroup]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<CurriculumGroup>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<CurriculumGroupUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<CurriculumGroupTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CurriculumGroupTable>? orderBy,
    _i1.OrderByListBuilder<CurriculumGroupTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<CurriculumGroup>(
      columnValues: columnValues(CurriculumGroup.t.updateTable),
      where: where(CurriculumGroup.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CurriculumGroup.t),
      orderByList: orderByList?.call(CurriculumGroup.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [CurriculumGroup]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<CurriculumGroup>> delete(
    _i1.DatabaseSession session,
    List<CurriculumGroup> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<CurriculumGroup>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [CurriculumGroup].
  Future<CurriculumGroup> deleteRow(
    _i1.DatabaseSession session,
    CurriculumGroup row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CurriculumGroup>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<CurriculumGroup>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<CurriculumGroupTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<CurriculumGroup>(
      where: where(CurriculumGroup.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<CurriculumGroupTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<CurriculumGroup>(
      where: where?.call(CurriculumGroup.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CurriculumGroup] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<CurriculumGroupTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CurriculumGroup>(
      where: where(CurriculumGroup.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
