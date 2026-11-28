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

abstract class ChatbotConversation
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  ChatbotConversation._({
    this.id,
    required this.studentId,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatbotConversation({
    int? id,
    required int studentId,
    required String title,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _ChatbotConversationImpl;

  factory ChatbotConversation.fromJson(Map<String, dynamic> jsonSerialization) {
    return ChatbotConversation(
      id: jsonSerialization['id'] as int?,
      studentId: jsonSerialization['studentId'] as int,
      title: jsonSerialization['title'] as String,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = ChatbotConversationTable();

  static const db = ChatbotConversationRepository._();

  @override
  int? id;

  int studentId;

  String title;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [ChatbotConversation]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ChatbotConversation copyWith({
    int? id,
    int? studentId,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ChatbotConversation',
      if (id != null) 'id': id,
      'studentId': studentId,
      'title': title,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static ChatbotConversationInclude include() {
    return ChatbotConversationInclude._();
  }

  static ChatbotConversationIncludeList includeList({
    _i1.WhereExpressionBuilder<ChatbotConversationTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ChatbotConversationTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ChatbotConversationTable>? orderByList,
    ChatbotConversationInclude? include,
  }) {
    return ChatbotConversationIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ChatbotConversation.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(ChatbotConversation.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ChatbotConversationImpl extends ChatbotConversation {
  _ChatbotConversationImpl({
    int? id,
    required int studentId,
    required String title,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         studentId: studentId,
         title: title,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [ChatbotConversation]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ChatbotConversation copyWith({
    Object? id = _Undefined,
    int? studentId,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatbotConversation(
      id: id is int? ? id : this.id,
      studentId: studentId ?? this.studentId,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ChatbotConversationUpdateTable
    extends _i1.UpdateTable<ChatbotConversationTable> {
  ChatbotConversationUpdateTable(super.table);

  _i1.ColumnValue<int, int> studentId(int value) => _i1.ColumnValue(
    table.studentId,
    value,
  );

  _i1.ColumnValue<String, String> title(String value) => _i1.ColumnValue(
    table.title,
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
}

class ChatbotConversationTable extends _i1.Table<int?> {
  ChatbotConversationTable({super.tableRelation})
    : super(tableName: 'app_chatbot_conversation') {
    updateTable = ChatbotConversationUpdateTable(this);
    studentId = _i1.ColumnInt(
      'studentId',
      this,
    );
    title = _i1.ColumnString(
      'title',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
    updatedAt = _i1.ColumnDateTime(
      'updatedAt',
      this,
    );
  }

  late final ChatbotConversationUpdateTable updateTable;

  late final _i1.ColumnInt studentId;

  late final _i1.ColumnString title;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    studentId,
    title,
    createdAt,
    updatedAt,
  ];
}

class ChatbotConversationInclude extends _i1.IncludeObject {
  ChatbotConversationInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => ChatbotConversation.t;
}

class ChatbotConversationIncludeList extends _i1.IncludeList {
  ChatbotConversationIncludeList._({
    _i1.WhereExpressionBuilder<ChatbotConversationTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ChatbotConversation.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => ChatbotConversation.t;
}

class ChatbotConversationRepository {
  const ChatbotConversationRepository._();

  /// Returns a list of [ChatbotConversation]s matching the given query parameters.
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
  Future<List<ChatbotConversation>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ChatbotConversationTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ChatbotConversationTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ChatbotConversationTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ChatbotConversation>(
      where: where?.call(ChatbotConversation.t),
      orderBy: orderBy?.call(ChatbotConversation.t),
      orderByList: orderByList?.call(ChatbotConversation.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [ChatbotConversation] matching the given query parameters.
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
  Future<ChatbotConversation?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ChatbotConversationTable>? where,
    int? offset,
    _i1.OrderByBuilder<ChatbotConversationTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ChatbotConversationTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ChatbotConversation>(
      where: where?.call(ChatbotConversation.t),
      orderBy: orderBy?.call(ChatbotConversation.t),
      orderByList: orderByList?.call(ChatbotConversation.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ChatbotConversation] by its [id] or null if no such row exists.
  Future<ChatbotConversation?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ChatbotConversation>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ChatbotConversation]s in the list and returns the inserted rows.
  ///
  /// The returned [ChatbotConversation]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<ChatbotConversation>> insert(
    _i1.DatabaseSession session,
    List<ChatbotConversation> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<ChatbotConversation>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [ChatbotConversation] and returns the inserted row.
  ///
  /// The returned [ChatbotConversation] will have its `id` field set.
  Future<ChatbotConversation> insertRow(
    _i1.DatabaseSession session,
    ChatbotConversation row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<ChatbotConversation>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [ChatbotConversation]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<ChatbotConversation>> update(
    _i1.DatabaseSession session,
    List<ChatbotConversation> rows, {
    _i1.ColumnSelections<ChatbotConversationTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<ChatbotConversation>(
      rows,
      columns: columns?.call(ChatbotConversation.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ChatbotConversation]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ChatbotConversation> updateRow(
    _i1.DatabaseSession session,
    ChatbotConversation row, {
    _i1.ColumnSelections<ChatbotConversationTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<ChatbotConversation>(
      row,
      columns: columns?.call(ChatbotConversation.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ChatbotConversation] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ChatbotConversation?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<ChatbotConversationUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<ChatbotConversation>(
      id,
      columnValues: columnValues(ChatbotConversation.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ChatbotConversation]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<ChatbotConversation>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<ChatbotConversationUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<ChatbotConversationTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ChatbotConversationTable>? orderBy,
    _i1.OrderByListBuilder<ChatbotConversationTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<ChatbotConversation>(
      columnValues: columnValues(ChatbotConversation.t.updateTable),
      where: where(ChatbotConversation.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ChatbotConversation.t),
      orderByList: orderByList?.call(ChatbotConversation.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [ChatbotConversation]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<ChatbotConversation>> delete(
    _i1.DatabaseSession session,
    List<ChatbotConversation> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<ChatbotConversation>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [ChatbotConversation].
  Future<ChatbotConversation> deleteRow(
    _i1.DatabaseSession session,
    ChatbotConversation row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ChatbotConversation>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<ChatbotConversation>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<ChatbotConversationTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<ChatbotConversation>(
      where: where(ChatbotConversation.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ChatbotConversationTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<ChatbotConversation>(
      where: where?.call(ChatbotConversation.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ChatbotConversation] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<ChatbotConversationTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ChatbotConversation>(
      where: where(ChatbotConversation.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
