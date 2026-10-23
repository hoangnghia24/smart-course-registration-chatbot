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
import 'account_role.dart' as _i2;
import 'account_status.dart' as _i3;

abstract class UserAccount
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  UserAccount._({
    this.id,
    required this.authUserId,
    required this.schoolEmail,
    required this.role,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.statusChangedAt,
  });

  factory UserAccount({
    int? id,
    required String authUserId,
    required String schoolEmail,
    required _i2.AccountRole role,
    required _i3.AccountStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? statusChangedAt,
  }) = _UserAccountImpl;

  factory UserAccount.fromJson(Map<String, dynamic> jsonSerialization) {
    return UserAccount(
      id: jsonSerialization['id'] as int?,
      authUserId: jsonSerialization['authUserId'] as String,
      schoolEmail: jsonSerialization['schoolEmail'] as String,
      role: _i2.AccountRole.fromJson((jsonSerialization['role'] as String)),
      status: _i3.AccountStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
      statusChangedAt: jsonSerialization['statusChangedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['statusChangedAt'],
            ),
    );
  }

  static final t = UserAccountTable();

  static const db = UserAccountRepository._();

  @override
  int? id;

  String authUserId;

  String schoolEmail;

  _i2.AccountRole role;

  _i3.AccountStatus status;

  DateTime createdAt;

  DateTime updatedAt;

  DateTime? statusChangedAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [UserAccount]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  UserAccount copyWith({
    int? id,
    String? authUserId,
    String? schoolEmail,
    _i2.AccountRole? role,
    _i3.AccountStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? statusChangedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'UserAccount',
      if (id != null) 'id': id,
      'authUserId': authUserId,
      'schoolEmail': schoolEmail,
      'role': role.toJson(),
      'status': status.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (statusChangedAt != null) 'statusChangedAt': statusChangedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static UserAccountInclude include() {
    return UserAccountInclude._();
  }

  static UserAccountIncludeList includeList({
    _i1.WhereExpressionBuilder<UserAccountTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<UserAccountTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<UserAccountTable>? orderByList,
    UserAccountInclude? include,
  }) {
    return UserAccountIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(UserAccount.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(UserAccount.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UserAccountImpl extends UserAccount {
  _UserAccountImpl({
    int? id,
    required String authUserId,
    required String schoolEmail,
    required _i2.AccountRole role,
    required _i3.AccountStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? statusChangedAt,
  }) : super._(
         id: id,
         authUserId: authUserId,
         schoolEmail: schoolEmail,
         role: role,
         status: status,
         createdAt: createdAt,
         updatedAt: updatedAt,
         statusChangedAt: statusChangedAt,
       );

  /// Returns a shallow copy of this [UserAccount]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  UserAccount copyWith({
    Object? id = _Undefined,
    String? authUserId,
    String? schoolEmail,
    _i2.AccountRole? role,
    _i3.AccountStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? statusChangedAt = _Undefined,
  }) {
    return UserAccount(
      id: id is int? ? id : this.id,
      authUserId: authUserId ?? this.authUserId,
      schoolEmail: schoolEmail ?? this.schoolEmail,
      role: role ?? this.role,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      statusChangedAt: statusChangedAt is DateTime?
          ? statusChangedAt
          : this.statusChangedAt,
    );
  }
}

class UserAccountUpdateTable extends _i1.UpdateTable<UserAccountTable> {
  UserAccountUpdateTable(super.table);

  _i1.ColumnValue<String, String> authUserId(String value) => _i1.ColumnValue(
    table.authUserId,
    value,
  );

  _i1.ColumnValue<String, String> schoolEmail(String value) => _i1.ColumnValue(
    table.schoolEmail,
    value,
  );

  _i1.ColumnValue<_i2.AccountRole, _i2.AccountRole> role(
    _i2.AccountRole value,
  ) => _i1.ColumnValue(
    table.role,
    value,
  );

  _i1.ColumnValue<_i3.AccountStatus, _i3.AccountStatus> status(
    _i3.AccountStatus value,
  ) => _i1.ColumnValue(
    table.status,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _i1.ColumnValue(
        table.updatedAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> statusChangedAt(DateTime? value) =>
      _i1.ColumnValue(
        table.statusChangedAt,
        value,
      );
}

class UserAccountTable extends _i1.Table<int?> {
  UserAccountTable({super.tableRelation})
    : super(tableName: 'app_user_account') {
    updateTable = UserAccountUpdateTable(this);
    authUserId = _i1.ColumnString(
      'authUserId',
      this,
    );
    schoolEmail = _i1.ColumnString(
      'schoolEmail',
      this,
    );
    role = _i1.ColumnEnum(
      'role',
      this,
      _i1.EnumSerialization.byName,
    );
    status = _i1.ColumnEnum(
      'status',
      this,
      _i1.EnumSerialization.byName,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
    updatedAt = _i1.ColumnDateTime(
      'updatedAt',
      this,
    );
    statusChangedAt = _i1.ColumnDateTime(
      'statusChangedAt',
      this,
    );
  }

  late final UserAccountUpdateTable updateTable;

  late final _i1.ColumnString authUserId;

  late final _i1.ColumnString schoolEmail;

  late final _i1.ColumnEnum<_i2.AccountRole> role;

  late final _i1.ColumnEnum<_i3.AccountStatus> status;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  late final _i1.ColumnDateTime statusChangedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    authUserId,
    schoolEmail,
    role,
    status,
    createdAt,
    updatedAt,
    statusChangedAt,
  ];
}

class UserAccountInclude extends _i1.IncludeObject {
  UserAccountInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => UserAccount.t;
}

class UserAccountIncludeList extends _i1.IncludeList {
  UserAccountIncludeList._({
    _i1.WhereExpressionBuilder<UserAccountTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(UserAccount.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => UserAccount.t;
}

class UserAccountRepository {
  const UserAccountRepository._();

  /// Returns a list of [UserAccount]s matching the given query parameters.
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
  Future<List<UserAccount>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<UserAccountTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<UserAccountTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<UserAccountTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<UserAccount>(
      where: where?.call(UserAccount.t),
      orderBy: orderBy?.call(UserAccount.t),
      orderByList: orderByList?.call(UserAccount.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [UserAccount] matching the given query parameters.
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
  Future<UserAccount?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<UserAccountTable>? where,
    int? offset,
    _i1.OrderByBuilder<UserAccountTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<UserAccountTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<UserAccount>(
      where: where?.call(UserAccount.t),
      orderBy: orderBy?.call(UserAccount.t),
      orderByList: orderByList?.call(UserAccount.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [UserAccount] by its [id] or null if no such row exists.
  Future<UserAccount?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<UserAccount>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [UserAccount]s in the list and returns the inserted rows.
  ///
  /// The returned [UserAccount]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<UserAccount>> insert(
    _i1.DatabaseSession session,
    List<UserAccount> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<UserAccount>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [UserAccount] and returns the inserted row.
  ///
  /// The returned [UserAccount] will have its `id` field set.
  Future<UserAccount> insertRow(
    _i1.DatabaseSession session,
    UserAccount row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<UserAccount>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [UserAccount]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<UserAccount>> update(
    _i1.DatabaseSession session,
    List<UserAccount> rows, {
    _i1.ColumnSelections<UserAccountTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<UserAccount>(
      rows,
      columns: columns?.call(UserAccount.t),
      transaction: transaction,
    );
  }

  /// Updates a single [UserAccount]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<UserAccount> updateRow(
    _i1.DatabaseSession session,
    UserAccount row, {
    _i1.ColumnSelections<UserAccountTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<UserAccount>(
      row,
      columns: columns?.call(UserAccount.t),
      transaction: transaction,
    );
  }

  /// Updates a single [UserAccount] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<UserAccount?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<UserAccountUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<UserAccount>(
      id,
      columnValues: columnValues(UserAccount.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [UserAccount]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<UserAccount>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<UserAccountUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<UserAccountTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<UserAccountTable>? orderBy,
    _i1.OrderByListBuilder<UserAccountTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<UserAccount>(
      columnValues: columnValues(UserAccount.t.updateTable),
      where: where(UserAccount.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(UserAccount.t),
      orderByList: orderByList?.call(UserAccount.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [UserAccount]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<UserAccount>> delete(
    _i1.DatabaseSession session,
    List<UserAccount> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<UserAccount>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [UserAccount].
  Future<UserAccount> deleteRow(
    _i1.DatabaseSession session,
    UserAccount row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<UserAccount>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<UserAccount>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<UserAccountTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<UserAccount>(
      where: where(UserAccount.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<UserAccountTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<UserAccount>(
      where: where?.call(UserAccount.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [UserAccount] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<UserAccountTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<UserAccount>(
      where: where(UserAccount.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
