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

/// F07 - Phien ban CTDT
/// Vong doi: DRAFT -> PUBLISHED -> ARCHIVED.
/// Chi DRAFT duoc sua noi dung; PUBLISHED/ARCHIVED bi khoa.
/// Hoc che tin chi: sinh vien nhap hoc nam N dung phien ban PUBLISHED
/// co effectiveYear lon nhat <= N cua CTDT ma sinh vien theo hoc.
abstract class CurriculumVersion
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  CurriculumVersion._({
    this.id,
    required this.curriculumId,
    required this.versionCode,
    required this.effectiveYear,
    required this.status,
    this.totalCreditsRequired,
    int? revision,
    this.publishedAt,
  }) : revision = revision ?? 1;

  factory CurriculumVersion({
    int? id,
    required int curriculumId,
    required String versionCode,
    required int effectiveYear,
    required String status,
    int? totalCreditsRequired,
    int? revision,
    DateTime? publishedAt,
  }) = _CurriculumVersionImpl;

  factory CurriculumVersion.fromJson(Map<String, dynamic> jsonSerialization) {
    return CurriculumVersion(
      id: jsonSerialization['id'] as int?,
      curriculumId: jsonSerialization['curriculumId'] as int,
      versionCode: jsonSerialization['versionCode'] as String,
      effectiveYear: jsonSerialization['effectiveYear'] as int,
      status: jsonSerialization['status'] as String,
      totalCreditsRequired: jsonSerialization['totalCreditsRequired'] as int?,
      revision: jsonSerialization['revision'] as int?,
      publishedAt: jsonSerialization['publishedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['publishedAt'],
            ),
    );
  }

  static final t = CurriculumVersionTable();

  static const db = CurriculumVersionRepository._();

  @override
  int? id;

  int curriculumId;

  String versionCode;

  int effectiveYear;

  /// DRAFT, PUBLISHED, ARCHIVED
  String status;

  /// Tong tin chi toi thieu de tot nghiep; bat buoc khi cong bo
  int? totalCreditsRequired;

  /// Tang moi lan luu ban nhap; dung chong ghi de dong thoi
  int revision;

  /// Thoi diem cong bo chinh thuc
  DateTime? publishedAt;

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
    int? totalCreditsRequired,
    int? revision,
    DateTime? publishedAt,
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
      if (totalCreditsRequired != null)
        'totalCreditsRequired': totalCreditsRequired,
      'revision': revision,
      if (publishedAt != null) 'publishedAt': publishedAt?.toJson(),
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
    int? totalCreditsRequired,
    int? revision,
    DateTime? publishedAt,
  }) : super._(
         id: id,
         curriculumId: curriculumId,
         versionCode: versionCode,
         effectiveYear: effectiveYear,
         status: status,
         totalCreditsRequired: totalCreditsRequired,
         revision: revision,
         publishedAt: publishedAt,
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
    Object? totalCreditsRequired = _Undefined,
    int? revision,
    Object? publishedAt = _Undefined,
  }) {
    return CurriculumVersion(
      id: id is int? ? id : this.id,
      curriculumId: curriculumId ?? this.curriculumId,
      versionCode: versionCode ?? this.versionCode,
      effectiveYear: effectiveYear ?? this.effectiveYear,
      status: status ?? this.status,
      totalCreditsRequired: totalCreditsRequired is int?
          ? totalCreditsRequired
          : this.totalCreditsRequired,
      revision: revision ?? this.revision,
      publishedAt: publishedAt is DateTime? ? publishedAt : this.publishedAt,
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

  _i1.ColumnValue<int, int> totalCreditsRequired(int? value) => _i1.ColumnValue(
    table.totalCreditsRequired,
    value,
  );

  _i1.ColumnValue<int, int> revision(int value) => _i1.ColumnValue(
    table.revision,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> publishedAt(DateTime? value) =>
      _i1.ColumnValue(
        table.publishedAt,
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
    totalCreditsRequired = _i1.ColumnInt(
      'totalCreditsRequired',
      this,
    );
    revision = _i1.ColumnInt(
      'revision',
      this,
      hasDefault: true,
    );
    publishedAt = _i1.ColumnDateTime(
      'publishedAt',
      this,
    );
  }

  late final CurriculumVersionUpdateTable updateTable;

  late final _i1.ColumnInt curriculumId;

  late final _i1.ColumnString versionCode;

  late final _i1.ColumnInt effectiveYear;

  /// DRAFT, PUBLISHED, ARCHIVED
  late final _i1.ColumnString status;

  /// Tong tin chi toi thieu de tot nghiep; bat buoc khi cong bo
  late final _i1.ColumnInt totalCreditsRequired;

  /// Tang moi lan luu ban nhap; dung chong ghi de dong thoi
  late final _i1.ColumnInt revision;

  /// Thoi diem cong bo chinh thuc
  late final _i1.ColumnDateTime publishedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    curriculumId,
    versionCode,
    effectiveYear,
    status,
    totalCreditsRequired,
    revision,
    publishedAt,
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
