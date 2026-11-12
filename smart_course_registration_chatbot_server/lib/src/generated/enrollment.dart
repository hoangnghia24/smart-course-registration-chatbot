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
import 'registration_origin.dart' as _i2;

abstract class Enrollment
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  Enrollment._({
    this.id,
    required this.studentId,
    required this.sectionId,
    required this.enrollmentType,
    required this.status,
    required this.registrationOrigin,
    required this.registeredAt,
    this.cancelledAt,
    this.submittedAt,
    this.score,
    required this.gradeStatus,
    required this.resultStatus,
    this.publishedAt,
    this.enteredByLecturerId,
  });

  factory Enrollment({
    int? id,
    required int studentId,
    required int sectionId,
    required String enrollmentType,
    required String status,
    required _i2.RegistrationOrigin registrationOrigin,
    required DateTime registeredAt,
    DateTime? cancelledAt,
    DateTime? submittedAt,
    double? score,
    required String gradeStatus,
    required String resultStatus,
    DateTime? publishedAt,
    int? enteredByLecturerId,
  }) = _EnrollmentImpl;

  factory Enrollment.fromJson(Map<String, dynamic> jsonSerialization) {
    return Enrollment(
      id: jsonSerialization['id'] as int?,
      studentId: jsonSerialization['studentId'] as int,
      sectionId: jsonSerialization['sectionId'] as int,
      enrollmentType: jsonSerialization['enrollmentType'] as String,
      status: jsonSerialization['status'] as String,
      registrationOrigin: _i2.RegistrationOrigin.fromJson(
        (jsonSerialization['registrationOrigin'] as String),
      ),
      registeredAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['registeredAt'],
      ),
      cancelledAt: jsonSerialization['cancelledAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['cancelledAt'],
            ),
      submittedAt: jsonSerialization['submittedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['submittedAt'],
            ),
      score: (jsonSerialization['score'] as num?)?.toDouble(),
      gradeStatus: jsonSerialization['gradeStatus'] as String,
      resultStatus: jsonSerialization['resultStatus'] as String,
      publishedAt: jsonSerialization['publishedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['publishedAt'],
            ),
      enteredByLecturerId: jsonSerialization['enteredByLecturerId'] as int?,
    );
  }

  static final t = EnrollmentTable();

  static const db = EnrollmentRepository._();

  @override
  int? id;

  /// Sinh vien dang ky
  int studentId;

  /// Lop hoc phan duoc dang ky
  int sectionId;

  /// Loai dang ky
  /// REGULAR, IMPROVEMENT
  String enrollmentType;

  /// Trang thai dang ky
  /// ENROLLED, CANCELLED, SECTION_CANCELLED, COMPLETED
  String status;

  /// Thời điểm đăng ký
  _i2.RegistrationOrigin registrationOrigin;

  /// Thoi gian dang ky
  DateTime registeredAt;

  /// Thoi gian huy dang ky
  DateTime? cancelledAt;

  /// Thời gian giảng viên hoàn tất gửi điểm số
  DateTime? submittedAt;

  /// Diem so
  double? score;

  /// Trang thai cong bo diem
  /// NOT_ENTERED, DRAFT, FINALIZED, PUBLISHED
  String gradeStatus;

  /// Ket qua hoc tap
  /// PENDING, PASSED, FAILED
  String resultStatus;

  /// Thoi gian cong bo diem
  DateTime? publishedAt;

  /// Giang vien nhap diem
  int? enteredByLecturerId;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [Enrollment]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Enrollment copyWith({
    int? id,
    int? studentId,
    int? sectionId,
    String? enrollmentType,
    String? status,
    _i2.RegistrationOrigin? registrationOrigin,
    DateTime? registeredAt,
    DateTime? cancelledAt,
    DateTime? submittedAt,
    double? score,
    String? gradeStatus,
    String? resultStatus,
    DateTime? publishedAt,
    int? enteredByLecturerId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Enrollment',
      if (id != null) 'id': id,
      'studentId': studentId,
      'sectionId': sectionId,
      'enrollmentType': enrollmentType,
      'status': status,
      'registrationOrigin': registrationOrigin.toJson(),
      'registeredAt': registeredAt.toJson(),
      if (cancelledAt != null) 'cancelledAt': cancelledAt?.toJson(),
      if (submittedAt != null) 'submittedAt': submittedAt?.toJson(),
      if (score != null) 'score': score,
      'gradeStatus': gradeStatus,
      'resultStatus': resultStatus,
      if (publishedAt != null) 'publishedAt': publishedAt?.toJson(),
      if (enteredByLecturerId != null)
        'enteredByLecturerId': enteredByLecturerId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static EnrollmentInclude include() {
    return EnrollmentInclude._();
  }

  static EnrollmentIncludeList includeList({
    _i1.WhereExpressionBuilder<EnrollmentTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<EnrollmentTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<EnrollmentTable>? orderByList,
    EnrollmentInclude? include,
  }) {
    return EnrollmentIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Enrollment.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Enrollment.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _EnrollmentImpl extends Enrollment {
  _EnrollmentImpl({
    int? id,
    required int studentId,
    required int sectionId,
    required String enrollmentType,
    required String status,
    required _i2.RegistrationOrigin registrationOrigin,
    required DateTime registeredAt,
    DateTime? cancelledAt,
    DateTime? submittedAt,
    double? score,
    required String gradeStatus,
    required String resultStatus,
    DateTime? publishedAt,
    int? enteredByLecturerId,
  }) : super._(
         id: id,
         studentId: studentId,
         sectionId: sectionId,
         enrollmentType: enrollmentType,
         status: status,
         registrationOrigin: registrationOrigin,
         registeredAt: registeredAt,
         cancelledAt: cancelledAt,
         submittedAt: submittedAt,
         score: score,
         gradeStatus: gradeStatus,
         resultStatus: resultStatus,
         publishedAt: publishedAt,
         enteredByLecturerId: enteredByLecturerId,
       );

  /// Returns a shallow copy of this [Enrollment]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Enrollment copyWith({
    Object? id = _Undefined,
    int? studentId,
    int? sectionId,
    String? enrollmentType,
    String? status,
    _i2.RegistrationOrigin? registrationOrigin,
    DateTime? registeredAt,
    Object? cancelledAt = _Undefined,
    Object? submittedAt = _Undefined,
    Object? score = _Undefined,
    String? gradeStatus,
    String? resultStatus,
    Object? publishedAt = _Undefined,
    Object? enteredByLecturerId = _Undefined,
  }) {
    return Enrollment(
      id: id is int? ? id : this.id,
      studentId: studentId ?? this.studentId,
      sectionId: sectionId ?? this.sectionId,
      enrollmentType: enrollmentType ?? this.enrollmentType,
      status: status ?? this.status,
      registrationOrigin: registrationOrigin ?? this.registrationOrigin,
      registeredAt: registeredAt ?? this.registeredAt,
      cancelledAt: cancelledAt is DateTime? ? cancelledAt : this.cancelledAt,
      submittedAt: submittedAt is DateTime? ? submittedAt : this.submittedAt,
      score: score is double? ? score : this.score,
      gradeStatus: gradeStatus ?? this.gradeStatus,
      resultStatus: resultStatus ?? this.resultStatus,
      publishedAt: publishedAt is DateTime? ? publishedAt : this.publishedAt,
      enteredByLecturerId: enteredByLecturerId is int?
          ? enteredByLecturerId
          : this.enteredByLecturerId,
    );
  }
}

class EnrollmentUpdateTable extends _i1.UpdateTable<EnrollmentTable> {
  EnrollmentUpdateTable(super.table);

  _i1.ColumnValue<int, int> studentId(int value) => _i1.ColumnValue(
    table.studentId,
    value,
  );

  _i1.ColumnValue<int, int> sectionId(int value) => _i1.ColumnValue(
    table.sectionId,
    value,
  );

  _i1.ColumnValue<String, String> enrollmentType(String value) =>
      _i1.ColumnValue(
        table.enrollmentType,
        value,
      );

  _i1.ColumnValue<String, String> status(String value) => _i1.ColumnValue(
    table.status,
    value,
  );

  _i1.ColumnValue<_i2.RegistrationOrigin, _i2.RegistrationOrigin>
  registrationOrigin(_i2.RegistrationOrigin value) => _i1.ColumnValue(
    table.registrationOrigin,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> registeredAt(DateTime value) =>
      _i1.ColumnValue(
        table.registeredAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> cancelledAt(DateTime? value) =>
      _i1.ColumnValue(
        table.cancelledAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> submittedAt(DateTime? value) =>
      _i1.ColumnValue(
        table.submittedAt,
        value,
      );

  _i1.ColumnValue<double, double> score(double? value) => _i1.ColumnValue(
    table.score,
    value,
  );

  _i1.ColumnValue<String, String> gradeStatus(String value) => _i1.ColumnValue(
    table.gradeStatus,
    value,
  );

  _i1.ColumnValue<String, String> resultStatus(String value) => _i1.ColumnValue(
    table.resultStatus,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> publishedAt(DateTime? value) =>
      _i1.ColumnValue(
        table.publishedAt,
        value,
      );

  _i1.ColumnValue<int, int> enteredByLecturerId(int? value) => _i1.ColumnValue(
    table.enteredByLecturerId,
    value,
  );
}

class EnrollmentTable extends _i1.Table<int?> {
  EnrollmentTable({super.tableRelation}) : super(tableName: 'app_enrollment') {
    updateTable = EnrollmentUpdateTable(this);
    studentId = _i1.ColumnInt(
      'studentId',
      this,
    );
    sectionId = _i1.ColumnInt(
      'sectionId',
      this,
    );
    enrollmentType = _i1.ColumnString(
      'enrollmentType',
      this,
    );
    status = _i1.ColumnString(
      'status',
      this,
    );
    registrationOrigin = _i1.ColumnEnum(
      'registrationOrigin',
      this,
      _i1.EnumSerialization.byName,
    );
    registeredAt = _i1.ColumnDateTime(
      'registeredAt',
      this,
    );
    cancelledAt = _i1.ColumnDateTime(
      'cancelledAt',
      this,
    );
    submittedAt = _i1.ColumnDateTime(
      'submittedAt',
      this,
    );
    score = _i1.ColumnDouble(
      'score',
      this,
    );
    gradeStatus = _i1.ColumnString(
      'gradeStatus',
      this,
    );
    resultStatus = _i1.ColumnString(
      'resultStatus',
      this,
    );
    publishedAt = _i1.ColumnDateTime(
      'publishedAt',
      this,
    );
    enteredByLecturerId = _i1.ColumnInt(
      'enteredByLecturerId',
      this,
    );
  }

  late final EnrollmentUpdateTable updateTable;

  /// Sinh vien dang ky
  late final _i1.ColumnInt studentId;

  /// Lop hoc phan duoc dang ky
  late final _i1.ColumnInt sectionId;

  /// Loai dang ky
  /// REGULAR, IMPROVEMENT
  late final _i1.ColumnString enrollmentType;

  /// Trang thai dang ky
  /// ENROLLED, CANCELLED, SECTION_CANCELLED, COMPLETED
  late final _i1.ColumnString status;

  /// Thời điểm đăng ký
  late final _i1.ColumnEnum<_i2.RegistrationOrigin> registrationOrigin;

  /// Thoi gian dang ky
  late final _i1.ColumnDateTime registeredAt;

  /// Thoi gian huy dang ky
  late final _i1.ColumnDateTime cancelledAt;

  /// Thời gian giảng viên hoàn tất gửi điểm số
  late final _i1.ColumnDateTime submittedAt;

  /// Diem so
  late final _i1.ColumnDouble score;

  /// Trang thai cong bo diem
  /// NOT_ENTERED, DRAFT, FINALIZED, PUBLISHED
  late final _i1.ColumnString gradeStatus;

  /// Ket qua hoc tap
  /// PENDING, PASSED, FAILED
  late final _i1.ColumnString resultStatus;

  /// Thoi gian cong bo diem
  late final _i1.ColumnDateTime publishedAt;

  /// Giang vien nhap diem
  late final _i1.ColumnInt enteredByLecturerId;

  @override
  List<_i1.Column> get columns => [
    id,
    studentId,
    sectionId,
    enrollmentType,
    status,
    registrationOrigin,
    registeredAt,
    cancelledAt,
    submittedAt,
    score,
    gradeStatus,
    resultStatus,
    publishedAt,
    enteredByLecturerId,
  ];
}

class EnrollmentInclude extends _i1.IncludeObject {
  EnrollmentInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => Enrollment.t;
}

class EnrollmentIncludeList extends _i1.IncludeList {
  EnrollmentIncludeList._({
    _i1.WhereExpressionBuilder<EnrollmentTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Enrollment.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => Enrollment.t;
}

class EnrollmentRepository {
  const EnrollmentRepository._();

  /// Returns a list of [Enrollment]s matching the given query parameters.
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
  Future<List<Enrollment>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<EnrollmentTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<EnrollmentTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<EnrollmentTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Enrollment>(
      where: where?.call(Enrollment.t),
      orderBy: orderBy?.call(Enrollment.t),
      orderByList: orderByList?.call(Enrollment.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Enrollment] matching the given query parameters.
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
  Future<Enrollment?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<EnrollmentTable>? where,
    int? offset,
    _i1.OrderByBuilder<EnrollmentTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<EnrollmentTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Enrollment>(
      where: where?.call(Enrollment.t),
      orderBy: orderBy?.call(Enrollment.t),
      orderByList: orderByList?.call(Enrollment.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Enrollment] by its [id] or null if no such row exists.
  Future<Enrollment?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Enrollment>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Enrollment]s in the list and returns the inserted rows.
  ///
  /// The returned [Enrollment]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<Enrollment>> insert(
    _i1.DatabaseSession session,
    List<Enrollment> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<Enrollment>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [Enrollment] and returns the inserted row.
  ///
  /// The returned [Enrollment] will have its `id` field set.
  Future<Enrollment> insertRow(
    _i1.DatabaseSession session,
    Enrollment row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<Enrollment>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [Enrollment]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<Enrollment>> update(
    _i1.DatabaseSession session,
    List<Enrollment> rows, {
    _i1.ColumnSelections<EnrollmentTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<Enrollment>(
      rows,
      columns: columns?.call(Enrollment.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Enrollment]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Enrollment> updateRow(
    _i1.DatabaseSession session,
    Enrollment row, {
    _i1.ColumnSelections<EnrollmentTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<Enrollment>(
      row,
      columns: columns?.call(Enrollment.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Enrollment] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Enrollment?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<EnrollmentUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<Enrollment>(
      id,
      columnValues: columnValues(Enrollment.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Enrollment]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<Enrollment>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<EnrollmentUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<EnrollmentTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<EnrollmentTable>? orderBy,
    _i1.OrderByListBuilder<EnrollmentTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<Enrollment>(
      columnValues: columnValues(Enrollment.t.updateTable),
      where: where(Enrollment.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Enrollment.t),
      orderByList: orderByList?.call(Enrollment.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [Enrollment]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<Enrollment>> delete(
    _i1.DatabaseSession session,
    List<Enrollment> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Enrollment>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [Enrollment].
  Future<Enrollment> deleteRow(
    _i1.DatabaseSession session,
    Enrollment row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Enrollment>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<Enrollment>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<EnrollmentTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Enrollment>(
      where: where(Enrollment.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<EnrollmentTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Enrollment>(
      where: where?.call(Enrollment.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Enrollment] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<EnrollmentTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Enrollment>(
      where: where(Enrollment.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
