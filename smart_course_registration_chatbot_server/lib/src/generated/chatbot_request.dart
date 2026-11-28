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

abstract class ChatbotRequest
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  ChatbotRequest._({
    this.id,
    required this.studentId,
    required this.conversationId,
    required this.clientRequestId,
    this.requestedConversationId,
    required this.question,
    required this.answer,
    required this.createdAt,
  });

  factory ChatbotRequest({
    int? id,
    required int studentId,
    required int conversationId,
    required String clientRequestId,
    int? requestedConversationId,
    required String question,
    required String answer,
    required DateTime createdAt,
  }) = _ChatbotRequestImpl;

  factory ChatbotRequest.fromJson(Map<String, dynamic> jsonSerialization) {
    return ChatbotRequest(
      id: jsonSerialization['id'] as int?,
      studentId: jsonSerialization['studentId'] as int,
      conversationId: jsonSerialization['conversationId'] as int,
      clientRequestId: jsonSerialization['clientRequestId'] as String,
      requestedConversationId:
          jsonSerialization['requestedConversationId'] as int?,
      question: jsonSerialization['question'] as String,
      answer: jsonSerialization['answer'] as String,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = ChatbotRequestTable();

  static const db = ChatbotRequestRepository._();

  @override
  int? id;

  int studentId;

  int conversationId;

  String clientRequestId;

  int? requestedConversationId;

  String question;

  String answer;

  DateTime createdAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [ChatbotRequest]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ChatbotRequest copyWith({
    int? id,
    int? studentId,
    int? conversationId,
    String? clientRequestId,
    int? requestedConversationId,
    String? question,
    String? answer,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ChatbotRequest',
      if (id != null) 'id': id,
      'studentId': studentId,
      'conversationId': conversationId,
      'clientRequestId': clientRequestId,
      if (requestedConversationId != null)
        'requestedConversationId': requestedConversationId,
      'question': question,
      'answer': answer,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static ChatbotRequestInclude include() {
    return ChatbotRequestInclude._();
  }

  static ChatbotRequestIncludeList includeList({
    _i1.WhereExpressionBuilder<ChatbotRequestTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ChatbotRequestTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ChatbotRequestTable>? orderByList,
    ChatbotRequestInclude? include,
  }) {
    return ChatbotRequestIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ChatbotRequest.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(ChatbotRequest.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ChatbotRequestImpl extends ChatbotRequest {
  _ChatbotRequestImpl({
    int? id,
    required int studentId,
    required int conversationId,
    required String clientRequestId,
    int? requestedConversationId,
    required String question,
    required String answer,
    required DateTime createdAt,
  }) : super._(
         id: id,
         studentId: studentId,
         conversationId: conversationId,
         clientRequestId: clientRequestId,
         requestedConversationId: requestedConversationId,
         question: question,
         answer: answer,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [ChatbotRequest]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ChatbotRequest copyWith({
    Object? id = _Undefined,
    int? studentId,
    int? conversationId,
    String? clientRequestId,
    Object? requestedConversationId = _Undefined,
    String? question,
    String? answer,
    DateTime? createdAt,
  }) {
    return ChatbotRequest(
      id: id is int? ? id : this.id,
      studentId: studentId ?? this.studentId,
      conversationId: conversationId ?? this.conversationId,
      clientRequestId: clientRequestId ?? this.clientRequestId,
      requestedConversationId: requestedConversationId is int?
          ? requestedConversationId
          : this.requestedConversationId,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ChatbotRequestUpdateTable extends _i1.UpdateTable<ChatbotRequestTable> {
  ChatbotRequestUpdateTable(super.table);

  _i1.ColumnValue<int, int> studentId(int value) => _i1.ColumnValue(
    table.studentId,
    value,
  );

  _i1.ColumnValue<int, int> conversationId(int value) => _i1.ColumnValue(
    table.conversationId,
    value,
  );

  _i1.ColumnValue<String, String> clientRequestId(String value) =>
      _i1.ColumnValue(
        table.clientRequestId,
        value,
      );

  _i1.ColumnValue<int, int> requestedConversationId(int? value) =>
      _i1.ColumnValue(
        table.requestedConversationId,
        value,
      );

  _i1.ColumnValue<String, String> question(String value) => _i1.ColumnValue(
    table.question,
    value,
  );

  _i1.ColumnValue<String, String> answer(String value) => _i1.ColumnValue(
    table.answer,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );
}

class ChatbotRequestTable extends _i1.Table<int?> {
  ChatbotRequestTable({super.tableRelation})
    : super(tableName: 'app_chatbot_request') {
    updateTable = ChatbotRequestUpdateTable(this);
    studentId = _i1.ColumnInt(
      'studentId',
      this,
    );
    conversationId = _i1.ColumnInt(
      'conversationId',
      this,
    );
    clientRequestId = _i1.ColumnString(
      'clientRequestId',
      this,
    );
    requestedConversationId = _i1.ColumnInt(
      'requestedConversationId',
      this,
    );
    question = _i1.ColumnString(
      'question',
      this,
    );
    answer = _i1.ColumnString(
      'answer',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final ChatbotRequestUpdateTable updateTable;

  late final _i1.ColumnInt studentId;

  late final _i1.ColumnInt conversationId;

  late final _i1.ColumnString clientRequestId;

  late final _i1.ColumnInt requestedConversationId;

  late final _i1.ColumnString question;

  late final _i1.ColumnString answer;

  late final _i1.ColumnDateTime createdAt;

  @override
  List<_i1.Column> get columns => [
    id,
    studentId,
    conversationId,
    clientRequestId,
    requestedConversationId,
    question,
    answer,
    createdAt,
  ];
}

class ChatbotRequestInclude extends _i1.IncludeObject {
  ChatbotRequestInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => ChatbotRequest.t;
}

class ChatbotRequestIncludeList extends _i1.IncludeList {
  ChatbotRequestIncludeList._({
    _i1.WhereExpressionBuilder<ChatbotRequestTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ChatbotRequest.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => ChatbotRequest.t;
}

class ChatbotRequestRepository {
  const ChatbotRequestRepository._();

  /// Returns a list of [ChatbotRequest]s matching the given query parameters.
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
  Future<List<ChatbotRequest>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ChatbotRequestTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ChatbotRequestTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ChatbotRequestTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ChatbotRequest>(
      where: where?.call(ChatbotRequest.t),
      orderBy: orderBy?.call(ChatbotRequest.t),
      orderByList: orderByList?.call(ChatbotRequest.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [ChatbotRequest] matching the given query parameters.
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
  Future<ChatbotRequest?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ChatbotRequestTable>? where,
    int? offset,
    _i1.OrderByBuilder<ChatbotRequestTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ChatbotRequestTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ChatbotRequest>(
      where: where?.call(ChatbotRequest.t),
      orderBy: orderBy?.call(ChatbotRequest.t),
      orderByList: orderByList?.call(ChatbotRequest.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ChatbotRequest] by its [id] or null if no such row exists.
  Future<ChatbotRequest?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ChatbotRequest>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ChatbotRequest]s in the list and returns the inserted rows.
  ///
  /// The returned [ChatbotRequest]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<ChatbotRequest>> insert(
    _i1.DatabaseSession session,
    List<ChatbotRequest> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<ChatbotRequest>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [ChatbotRequest] and returns the inserted row.
  ///
  /// The returned [ChatbotRequest] will have its `id` field set.
  Future<ChatbotRequest> insertRow(
    _i1.DatabaseSession session,
    ChatbotRequest row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<ChatbotRequest>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [ChatbotRequest]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<ChatbotRequest>> update(
    _i1.DatabaseSession session,
    List<ChatbotRequest> rows, {
    _i1.ColumnSelections<ChatbotRequestTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<ChatbotRequest>(
      rows,
      columns: columns?.call(ChatbotRequest.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ChatbotRequest]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ChatbotRequest> updateRow(
    _i1.DatabaseSession session,
    ChatbotRequest row, {
    _i1.ColumnSelections<ChatbotRequestTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<ChatbotRequest>(
      row,
      columns: columns?.call(ChatbotRequest.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ChatbotRequest] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ChatbotRequest?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<ChatbotRequestUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<ChatbotRequest>(
      id,
      columnValues: columnValues(ChatbotRequest.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ChatbotRequest]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<ChatbotRequest>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<ChatbotRequestUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<ChatbotRequestTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ChatbotRequestTable>? orderBy,
    _i1.OrderByListBuilder<ChatbotRequestTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<ChatbotRequest>(
      columnValues: columnValues(ChatbotRequest.t.updateTable),
      where: where(ChatbotRequest.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ChatbotRequest.t),
      orderByList: orderByList?.call(ChatbotRequest.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [ChatbotRequest]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<ChatbotRequest>> delete(
    _i1.DatabaseSession session,
    List<ChatbotRequest> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<ChatbotRequest>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [ChatbotRequest].
  Future<ChatbotRequest> deleteRow(
    _i1.DatabaseSession session,
    ChatbotRequest row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ChatbotRequest>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<ChatbotRequest>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<ChatbotRequestTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<ChatbotRequest>(
      where: where(ChatbotRequest.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ChatbotRequestTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<ChatbotRequest>(
      where: where?.call(ChatbotRequest.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ChatbotRequest] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<ChatbotRequestTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ChatbotRequest>(
      where: where(ChatbotRequest.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
