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

abstract class CourseSection
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  CourseSection._({
    this.id,
    required this.courseId,
    required this.termId,
    required this.lecturerId,
    required this.sectionCode,
    required this.capacity,
    this.minimumEnrollment,
    required this.status,
    required this.createdAt,
  });

  factory CourseSection({
    int? id,
    required int courseId,
    required int termId,
    required int lecturerId,
    required String sectionCode,
    required int capacity,
    int? minimumEnrollment,
    required String status,
    required DateTime createdAt,
  }) = _CourseSectionImpl;

  factory CourseSection.fromJson(Map<String, dynamic> jsonSerialization) {
    return CourseSection(
      id: jsonSerialization['id'] as int?,
      courseId: jsonSerialization['courseId'] as int,
      termId: jsonSerialization['termId'] as int,
      lecturerId: jsonSerialization['lecturerId'] as int,
      sectionCode: jsonSerialization['sectionCode'] as String,
      capacity: jsonSerialization['capacity'] as int,
      minimumEnrollment: jsonSerialization['minimumEnrollment'] as int?,
      status: jsonSerialization['status'] as String,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = CourseSectionTable();

  static const db = CourseSectionRepository._();

  @override
  int? id;

  /// Mon hoc duoc mo lop
  int courseId;

  /// Hoc ky mo lop
  int termId;

  /// Giang vien duoc phan cong
  int lecturerId;

  /// Ma lop hoc phan
  String sectionCode;

  /// Si so toi da
  int capacity;

  /// Si so toi thieu de mo lop
  int? minimumEnrollment;

  /// Trang thai lop hoc phan
  /// DRAFT, OPEN, CLOSED, CANCELLED, COMPLETED
  String status;

  /// Thoi gian tao lop
  DateTime createdAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [CourseSection]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CourseSection copyWith({
    int? id,
    int? courseId,
    int? termId,
    int? lecturerId,
    String? sectionCode,
    int? capacity,
    int? minimumEnrollment,
    String? status,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CourseSection',
      if (id != null) 'id': id,
      'courseId': courseId,
      'termId': termId,
      'lecturerId': lecturerId,
      'sectionCode': sectionCode,
      'capacity': capacity,
      if (minimumEnrollment != null) 'minimumEnrollment': minimumEnrollment,
      'status': status,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CourseSection',
      if (id != null) 'id': id,
      'courseId': courseId,
      'termId': termId,
      'lecturerId': lecturerId,
      'sectionCode': sectionCode,
      'capacity': capacity,
      if (minimumEnrollment != null) 'minimumEnrollment': minimumEnrollment,
      'status': status,
      'createdAt': createdAt.toJson(),
    };
  }

  static CourseSectionInclude include() {
    return CourseSectionInclude._();
  }

  static CourseSectionIncludeList includeList({
    _i1.WhereExpressionBuilder<CourseSectionTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CourseSectionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CourseSectionTable>? orderByList,
    CourseSectionInclude? include,
  }) {
    return CourseSectionIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CourseSection.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(CourseSection.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CourseSectionImpl extends CourseSection {
  _CourseSectionImpl({
    int? id,
    required int courseId,
    required int termId,
    required int lecturerId,
    required String sectionCode,
    required int capacity,
    int? minimumEnrollment,
    required String status,
    required DateTime createdAt,
  }) : super._(
         id: id,
         courseId: courseId,
         termId: termId,
         lecturerId: lecturerId,
         sectionCode: sectionCode,
         capacity: capacity,
         minimumEnrollment: minimumEnrollment,
         status: status,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [CourseSection]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CourseSection copyWith({
    Object? id = _Undefined,
    int? courseId,
    int? termId,
    int? lecturerId,
    String? sectionCode,
    int? capacity,
    Object? minimumEnrollment = _Undefined,
    String? status,
    DateTime? createdAt,
  }) {
    return CourseSection(
      id: id is int? ? id : this.id,
      courseId: courseId ?? this.courseId,
      termId: termId ?? this.termId,
      lecturerId: lecturerId ?? this.lecturerId,
      sectionCode: sectionCode ?? this.sectionCode,
      capacity: capacity ?? this.capacity,
      minimumEnrollment: minimumEnrollment is int?
          ? minimumEnrollment
          : this.minimumEnrollment,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class CourseSectionUpdateTable extends _i1.UpdateTable<CourseSectionTable> {
  CourseSectionUpdateTable(super.table);

  _i1.ColumnValue<int, int> courseId(int value) => _i1.ColumnValue(
    table.courseId,
    value,
  );

  _i1.ColumnValue<int, int> termId(int value) => _i1.ColumnValue(
    table.termId,
    value,
  );

  _i1.ColumnValue<int, int> lecturerId(int value) => _i1.ColumnValue(
    table.lecturerId,
    value,
  );

  _i1.ColumnValue<String, String> sectionCode(String value) => _i1.ColumnValue(
    table.sectionCode,
    value,
  );

  _i1.ColumnValue<int, int> capacity(int value) => _i1.ColumnValue(
    table.capacity,
    value,
  );

  _i1.ColumnValue<int, int> minimumEnrollment(int? value) => _i1.ColumnValue(
    table.minimumEnrollment,
    value,
  );

  _i1.ColumnValue<String, String> status(String value) => _i1.ColumnValue(
    table.status,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );
}

class CourseSectionTable extends _i1.Table<int?> {
  CourseSectionTable({super.tableRelation})
    : super(tableName: 'app_course_section') {
    updateTable = CourseSectionUpdateTable(this);
    courseId = _i1.ColumnInt(
      'courseId',
      this,
    );
    termId = _i1.ColumnInt(
      'termId',
      this,
    );
    lecturerId = _i1.ColumnInt(
      'lecturerId',
      this,
    );
    sectionCode = _i1.ColumnString(
      'sectionCode',
      this,
    );
    capacity = _i1.ColumnInt(
      'capacity',
      this,
    );
    minimumEnrollment = _i1.ColumnInt(
      'minimumEnrollment',
      this,
    );
    status = _i1.ColumnString(
      'status',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final CourseSectionUpdateTable updateTable;

  /// Mon hoc duoc mo lop
  late final _i1.ColumnInt courseId;

  /// Hoc ky mo lop
  late final _i1.ColumnInt termId;

  /// Giang vien duoc phan cong
  late final _i1.ColumnInt lecturerId;

  /// Ma lop hoc phan
  late final _i1.ColumnString sectionCode;

  /// Si so toi da
  late final _i1.ColumnInt capacity;

  /// Si so toi thieu de mo lop
  late final _i1.ColumnInt minimumEnrollment;

  /// Trang thai lop hoc phan
  /// DRAFT, OPEN, CLOSED, CANCELLED, COMPLETED
  late final _i1.ColumnString status;

  /// Thoi gian tao lop
  late final _i1.ColumnDateTime createdAt;

  @override
  List<_i1.Column> get columns => [
    id,
    courseId,
    termId,
    lecturerId,
    sectionCode,
    capacity,
    minimumEnrollment,
    status,
    createdAt,
  ];
}

class CourseSectionInclude extends _i1.IncludeObject {
  CourseSectionInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => CourseSection.t;
}

class CourseSectionIncludeList extends _i1.IncludeList {
  CourseSectionIncludeList._({
    _i1.WhereExpressionBuilder<CourseSectionTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CourseSection.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => CourseSection.t;
}

class CourseSectionRepository {
  const CourseSectionRepository._();

  /// Returns a list of [CourseSection]s matching the given query parameters.
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
  Future<List<CourseSection>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<CourseSectionTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CourseSectionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CourseSectionTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CourseSection>(
      where: where?.call(CourseSection.t),
      orderBy: orderBy?.call(CourseSection.t),
      orderByList: orderByList?.call(CourseSection.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CourseSection] matching the given query parameters.
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
  Future<CourseSection?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<CourseSectionTable>? where,
    int? offset,
    _i1.OrderByBuilder<CourseSectionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CourseSectionTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CourseSection>(
      where: where?.call(CourseSection.t),
      orderBy: orderBy?.call(CourseSection.t),
      orderByList: orderByList?.call(CourseSection.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CourseSection] by its [id] or null if no such row exists.
  Future<CourseSection?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CourseSection>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CourseSection]s in the list and returns the inserted rows.
  ///
  /// The returned [CourseSection]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<CourseSection>> insert(
    _i1.DatabaseSession session,
    List<CourseSection> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<CourseSection>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [CourseSection] and returns the inserted row.
  ///
  /// The returned [CourseSection] will have its `id` field set.
  Future<CourseSection> insertRow(
    _i1.DatabaseSession session,
    CourseSection row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<CourseSection>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [CourseSection]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<CourseSection>> update(
    _i1.DatabaseSession session,
    List<CourseSection> rows, {
    _i1.ColumnSelections<CourseSectionTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<CourseSection>(
      rows,
      columns: columns?.call(CourseSection.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CourseSection]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CourseSection> updateRow(
    _i1.DatabaseSession session,
    CourseSection row, {
    _i1.ColumnSelections<CourseSectionTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<CourseSection>(
      row,
      columns: columns?.call(CourseSection.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CourseSection] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CourseSection?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<CourseSectionUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<CourseSection>(
      id,
      columnValues: columnValues(CourseSection.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CourseSection]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<CourseSection>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<CourseSectionUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<CourseSectionTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CourseSectionTable>? orderBy,
    _i1.OrderByListBuilder<CourseSectionTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<CourseSection>(
      columnValues: columnValues(CourseSection.t.updateTable),
      where: where(CourseSection.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CourseSection.t),
      orderByList: orderByList?.call(CourseSection.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [CourseSection]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<CourseSection>> delete(
    _i1.DatabaseSession session,
    List<CourseSection> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<CourseSection>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [CourseSection].
  Future<CourseSection> deleteRow(
    _i1.DatabaseSession session,
    CourseSection row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CourseSection>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<CourseSection>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<CourseSectionTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<CourseSection>(
      where: where(CourseSection.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<CourseSectionTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<CourseSection>(
      where: where?.call(CourseSection.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CourseSection] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<CourseSectionTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CourseSection>(
      where: where(CourseSection.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
