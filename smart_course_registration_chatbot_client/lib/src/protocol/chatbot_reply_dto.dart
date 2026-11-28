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

abstract class ChatbotReplyDto implements _i1.SerializableModel {
  ChatbotReplyDto._({
    required this.conversationId,
    required this.answer,
  });

  factory ChatbotReplyDto({
    required int conversationId,
    required String answer,
  }) = _ChatbotReplyDtoImpl;

  factory ChatbotReplyDto.fromJson(Map<String, dynamic> jsonSerialization) {
    return ChatbotReplyDto(
      conversationId: jsonSerialization['conversationId'] as int,
      answer: jsonSerialization['answer'] as String,
    );
  }

  int conversationId;

  String answer;

  /// Returns a shallow copy of this [ChatbotReplyDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ChatbotReplyDto copyWith({
    int? conversationId,
    String? answer,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ChatbotReplyDto',
      'conversationId': conversationId,
      'answer': answer,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _ChatbotReplyDtoImpl extends ChatbotReplyDto {
  _ChatbotReplyDtoImpl({
    required int conversationId,
    required String answer,
  }) : super._(
         conversationId: conversationId,
         answer: answer,
       );

  /// Returns a shallow copy of this [ChatbotReplyDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ChatbotReplyDto copyWith({
    int? conversationId,
    String? answer,
  }) {
    return ChatbotReplyDto(
      conversationId: conversationId ?? this.conversationId,
      answer: answer ?? this.answer,
    );
  }
}
