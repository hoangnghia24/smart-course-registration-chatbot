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

import 'package:serverpod_client/serverpod_client.dart' as _i1;

abstract class AcademicTerm implements _i1.SerializableModel {
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

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String academicYear;

  String termName;

  String status;

  double maxCreditsPerTerm;

  /// thời gian bắt đầu và kết thúc học kỳ
  DateTime startAt;

  DateTime endAt;

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
