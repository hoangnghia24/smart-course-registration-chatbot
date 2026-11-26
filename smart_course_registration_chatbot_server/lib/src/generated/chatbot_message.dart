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
import 'chatbot_message_role.dart' as _i2;

abstract class ChatbotMessage
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  ChatbotMessage._({
    this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  factory ChatbotMessage({
    int? id,
    required int conversationId,
    required _i2.ChatbotMessageRole role,
    required String content,
    required DateTime createdAt,
  }) = _ChatbotMessageImpl;

  factory ChatbotMessage.fromJson(Map<String, dynamic> jsonSerialization) {
    return ChatbotMessage(
      id: jsonSerialization['id'] as int?,
      conversationId: jsonSerialization['conversationId'] as int,
      role: _i2.ChatbotMessageRole.fromJson(
        (jsonSerialization['role'] as String),
      ),
      content: jsonSerialization['content'] as String,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = ChatbotMessageTable();

  static const db = ChatbotMessageRepository._();

  @override
  int? id;

  int conversationId;

  _i2.ChatbotMessageRole role;

  String content;

  DateTime createdAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [ChatbotMessage]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ChatbotMessage copyWith({
    int? id,
    int? conversationId,
    _i2.ChatbotMessageRole? role,
    String? content,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ChatbotMessage',
      if (id != null) 'id': id,
      'conversationId': conversationId,
      'role': role.toJson(),
      'content': content,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static ChatbotMessageInclude include() {
    return ChatbotMessageInclude._();
  }

  static ChatbotMessageIncludeList includeList({
    _i1.WhereExpressionBuilder<ChatbotMessageTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ChatbotMessageTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ChatbotMessageTable>? orderByList,
    ChatbotMessageInclude? include,
  }) {
    return ChatbotMessageIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ChatbotMessage.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(ChatbotMessage.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ChatbotMessageImpl extends ChatbotMessage {
  _ChatbotMessageImpl({
    int? id,
    required int conversationId,
    required _i2.ChatbotMessageRole role,
    required String content,
    required DateTime createdAt,
  }) : super._(
         id: id,
         conversationId: conversationId,
         role: role,
         content: content,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [ChatbotMessage]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ChatbotMessage copyWith({
    Object? id = _Undefined,
    int? conversationId,
    _i2.ChatbotMessageRole? role,
    String? content,
    DateTime? createdAt,
  }) {
    return ChatbotMessage(
      id: id is int? ? id : this.id,
      conversationId: conversationId ?? this.conversationId,
      role: role ?? this.role,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ChatbotMessageUpdateTable extends _i1.UpdateTable<ChatbotMessageTable> {
  ChatbotMessageUpdateTable(super.table);

  _i1.ColumnValue<int, int> conversationId(int value) => _i1.ColumnValue(
    table.conversationId,
    value,
  );

  _i1.ColumnValue<_i2.ChatbotMessageRole, _i2.ChatbotMessageRole> role(
    _i2.ChatbotMessageRole value,
  ) => _i1.ColumnValue(
    table.role,
    value,
  );

  _i1.ColumnValue<String, String> content(String value) => _i1.ColumnValue(
    table.content,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );
}

class ChatbotMessageTable extends _i1.Table<int?> {
  ChatbotMessageTable({super.tableRelation})
    : super(tableName: 'app_chatbot_message') {
    updateTable = ChatbotMessageUpdateTable(this);
    conversationId = _i1.ColumnInt(
      'conversationId',
      this,
    );
    role = _i1.ColumnEnum(
      'role',
      this,
      _i1.EnumSerialization.byName,
    );
    content = _i1.ColumnString(
      'content',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final ChatbotMessageUpdateTable updateTable;

  late final _i1.ColumnInt conversationId;

  late final _i1.ColumnEnum<_i2.ChatbotMessageRole> role;

  late final _i1.ColumnString content;

  late final _i1.ColumnDateTime createdAt;

  @override
  List<_i1.Column> get columns => [
    id,
    conversationId,
    role,
    content,
    createdAt,
  ];
}

class ChatbotMessageInclude extends _i1.IncludeObject {
  ChatbotMessageInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => ChatbotMessage.t;
}

class ChatbotMessageIncludeList extends _i1.IncludeList {
  ChatbotMessageIncludeList._({
    _i1.WhereExpressionBuilder<ChatbotMessageTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ChatbotMessage.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => ChatbotMessage.t;
}

class ChatbotMessageRepository {
  const ChatbotMessageRepository._();

  /// Returns a list of [ChatbotMessage]s matching the given query parameters.
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
  Future<List<ChatbotMessage>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ChatbotMessageTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ChatbotMessageTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ChatbotMessageTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ChatbotMessage>(
      where: where?.call(ChatbotMessage.t),
      orderBy: orderBy?.call(ChatbotMessage.t),
      orderByList: orderByList?.call(ChatbotMessage.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [ChatbotMessage] matching the given query parameters.
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
  Future<ChatbotMessage?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ChatbotMessageTable>? where,
    int? offset,
    _i1.OrderByBuilder<ChatbotMessageTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ChatbotMessageTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ChatbotMessage>(
      where: where?.call(ChatbotMessage.t),
      orderBy: orderBy?.call(ChatbotMessage.t),
      orderByList: orderByList?.call(ChatbotMessage.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ChatbotMessage] by its [id] or null if no such row exists.
  Future<ChatbotMessage?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ChatbotMessage>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ChatbotMessage]s in the list and returns the inserted rows.
  ///
  /// The returned [ChatbotMessage]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<ChatbotMessage>> insert(
    _i1.DatabaseSession session,
    List<ChatbotMessage> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<ChatbotMessage>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [ChatbotMessage] and returns the inserted row.
  ///
  /// The returned [ChatbotMessage] will have its `id` field set.
  Future<ChatbotMessage> insertRow(
    _i1.DatabaseSession session,
    ChatbotMessage row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<ChatbotMessage>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [ChatbotMessage]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<ChatbotMessage>> update(
    _i1.DatabaseSession session,
    List<ChatbotMessage> rows, {
    _i1.ColumnSelections<ChatbotMessageTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<ChatbotMessage>(
      rows,
      columns: columns?.call(ChatbotMessage.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ChatbotMessage]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ChatbotMessage> updateRow(
    _i1.DatabaseSession session,
    ChatbotMessage row, {
    _i1.ColumnSelections<ChatbotMessageTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<ChatbotMessage>(
      row,
      columns: columns?.call(ChatbotMessage.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ChatbotMessage] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ChatbotMessage?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<ChatbotMessageUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<ChatbotMessage>(
      id,
      columnValues: columnValues(ChatbotMessage.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ChatbotMessage]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<ChatbotMessage>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<ChatbotMessageUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<ChatbotMessageTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ChatbotMessageTable>? orderBy,
    _i1.OrderByListBuilder<ChatbotMessageTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<ChatbotMessage>(
      columnValues: columnValues(ChatbotMessage.t.updateTable),
      where: where(ChatbotMessage.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ChatbotMessage.t),
      orderByList: orderByList?.call(ChatbotMessage.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [ChatbotMessage]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<ChatbotMessage>> delete(
    _i1.DatabaseSession session,
    List<ChatbotMessage> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<ChatbotMessage>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [ChatbotMessage].
  Future<ChatbotMessage> deleteRow(
    _i1.DatabaseSession session,
    ChatbotMessage row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ChatbotMessage>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<ChatbotMessage>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<ChatbotMessageTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<ChatbotMessage>(
      where: where(ChatbotMessage.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ChatbotMessageTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<ChatbotMessage>(
      where: where?.call(ChatbotMessage.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ChatbotMessage] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<ChatbotMessageTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ChatbotMessage>(
      where: where(ChatbotMessage.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
