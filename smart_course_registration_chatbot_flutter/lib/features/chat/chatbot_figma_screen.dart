import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/shared_app_header.dart';
import 'chatbot_repository_scope.dart';
import 'data/chatbot_repository.dart';
import 'domain/chatbot_message.dart';
import 'domain/chatbot_related_course.dart';
import 'presentation/chatbot_controller.dart';
import 'presentation/chatbot_state.dart';

/// Các trạng thái CHỈ để kiểm tra UI tuần 5.
/// Không phản ánh kết nối mạng hoặc phản hồi AI thực tế.
enum ChatbotPreviewState {
  initial,
  loading,
  sourcedSample,
  noEvidence,
  timeout,
  offline,
}

/// Giao diện Figma 390×844, giữ nguyên bản xem trước khi không được inject.
/// Khi nhận Controller/Repository/Scope, hiển thị dữ liệu hội thoại động.
/// Không đăng ký học phần, không tự suy đoán dữ liệu học vụ.
class ChatbotFigmaScreen extends StatefulWidget {
  const ChatbotFigmaScreen({
    super.key,
    this.controller,
    this.repository,
    this.initialConversationId,
    this.isSimulatedSource = true,
  });

  final ChatbotController? controller;
  final ChatbotRepository? repository;
  final String? initialConversationId;

  /// Chỉ đặt false khi nguồn Backend chính thức đã được tích hợp và kiểm chứng.
  final bool isSimulatedSource;

  @override
  State<ChatbotFigmaScreen> createState() => _ChatbotFigmaScreenState();
}

class _ChatbotFigmaScreenState extends State<ChatbotFigmaScreen> {
  static const _pageBackground = Color(0xFFF4F6FA);
  static const _purple = Color(0xFF6938CE);
  static const _purpleSoft = Color(0xFFF4F0FF);
  static const _purpleBorder = Color(0xFFD9CDFF);
  static const _darkText = Color(0xFF243143);
  static const _muted = Color(0xFF7B8798);
  static const _green = Color(0xFF07986C);

  final TextEditingController _questionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  ChatbotPreviewState _previewState = ChatbotPreviewState.initial;
  String? _lastQuestion;

  ChatbotController? _controller;
  bool _ownsController = false;
  String? _lastVisibleMessageId;
  String? _lastVisibleConversationId;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _attachController(widget.controller!, ownsController: false);
    } else if (widget.repository != null) {
      _attachController(
        ChatbotController(
          repository: widget.repository!,
          initialConversationId: widget.initialConversationId,
        ),
        ownsController: true,
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller != null ||
        widget.controller != null ||
        widget.repository != null) {
      return;
    }
    final repository = ChatbotRepositoryScope.maybeOf(context);
    if (repository != null) {
      _attachController(
        ChatbotController(
          repository: repository,
          initialConversationId: widget.initialConversationId,
        ),
        ownsController: true,
      );
    }
  }

  void _attachController(
    ChatbotController controller, {
    required bool ownsController,
  }) {
    _controller = controller;
    _ownsController = ownsController;
    controller.addListener(_onControllerUpdated);
    // Controller có thể notify đồng bộ. Không initialize trong build/dependencies.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && identical(_controller, controller)) {
        controller.initialize();
      }
    });
  }

  void _onControllerUpdated() {
    final state = _controller?.state;
    if (state == null) return;
    final conversationId = state.activeConversationId;
    final lastId = state.messages.isEmpty ? null : state.messages.last.id;
    final shouldScroll = lastId != null &&
        (lastId != _lastVisibleMessageId ||
            conversationId != _lastVisibleConversationId) &&
        !state.isLoadingOlderMessages;
    _lastVisibleMessageId = lastId;
    _lastVisibleConversationId = conversationId;
    if (shouldScroll) _scrollToBottomAfterFrame();
  }

  void _scrollToBottomAfterFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _controller?.removeListener(_onControllerUpdated);
    if (_ownsController) _controller?.dispose();
    _questionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _selectSuggestion(String question) {
    _questionController.text = question;
    _questionController.selection = TextSelection.collapsed(
      offset: question.length,
    );
    setState(() {});
  }

  void _sendQuestion() {
    final question = _questionController.text.trim();
    if (question.isEmpty) return;
    final controller = _controller;
    if (controller != null) {
      if (controller.state.isSending ||
          controller.state.messagesStatus == ChatbotRequestStatus.loading) {
        return;
      }
      _questionController.clear();
      controller.sendMessage(question);
      _scrollToBottomAfterFrame();
      return;
    }

    // Chế độ Preview Figma tuần 5: giữ nguyên hành vi 11 widget tests cũ.
    setState(() {
      _lastQuestion = question;
      _previewState = ChatbotPreviewState.noEvidence;
      _questionController.clear();
    });
    _scrollToBottomAfterFrame();
  }

  void _showNonOperationalNotice(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller != null) {
      return AnimatedBuilder(
        animation: controller,
        builder: (context, _) => _buildConnectedScaffold(controller),
      );
    }
    return Scaffold(
      backgroundColor: _pageBackground,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                key: const Key('chatbot_conversation_list'),
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(8, 14, 20, 20),
                children: [
                  _buildDateLabel(),
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.only(left: 36, bottom: 8),
                    child: Text(
                      'NỘI DUNG MINH HỌA · CHƯA KẾT NỐI AI',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: _muted,
                      ),
                    ),
                  ),
                  _assistantBubble(
                    child: const Text(
                      'Chào Nguyên! Mình có thể giúp gì cho bạn trong quá trình đăng ký học phần học kỳ này?',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.45,
                        color: _darkText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildSuggestion(
                    icon: Icons.auto_awesome,
                    text: 'Gợi ý môn chuyên ngành cho mình',
                  ),
                  const SizedBox(height: 8),
                  _buildSuggestion(
                    icon: Icons.help_outline_rounded,
                    text: 'Tại sao mình không đăng ký được AI?',
                  ),
                  const SizedBox(height: 14),
                  _buildUserSampleMessage(),
                  const SizedBox(height: 14),
                  _assistantBubble(child: _buildSampleRecommendation()),
                  const SizedBox(height: 10),
                  _buildClassCard(),
                  const SizedBox(height: 14),
                  _buildPaginationDots(),
                  if (_lastQuestion != null) ...[
                    const SizedBox(height: 16),
                    _buildUserMessage(_lastQuestion!),
                  ],
                  if (_previewState != ChatbotPreviewState.initial) ...[
                    const SizedBox(height: 12),
                    _assistantBubble(child: _buildStateContent()),
                  ],
                ],
              ),
            ),
            _buildComposer(),
          ],
        ),
      ),
    );
  }


  Widget _buildConnectedScaffold(ChatbotController controller) {
    final state = controller.state;
    return Scaffold(
      backgroundColor: _pageBackground,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            _buildConnectedHeader(controller),
            Expanded(child: _buildConnectedConversation(state, controller)),
            _buildComposer(),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectedHeader(ChatbotController controller) {
    return SharedAppHeader.assistant(
      title: 'Trợ lý AI Đăng ký',
      status: widget.isSimulatedSource
          ? 'Mô phỏng · Chưa kết nối Backend AI'
          : 'Trợ lý học vụ',
      avatar: const _StarAvatar(size: 44),
      leadingKey: const Key('chatbot_back_button'),
      onLeading: () {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          _showNonOperationalNotice('Không có màn hình trước để quay lại.');
        }
      },
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            key: const Key('chatbot_new_conversation_button'),
            tooltip: 'Tạo hội thoại mới',
            visualDensity: VisualDensity.compact,
            onPressed: () {
              controller.createNewConversation();
              _questionController.clear();
              _scrollToBottomAfterFrame();
            },
            icon: const Icon(Icons.add_comment_outlined, color: _darkText),
          ),
          IconButton(
            key: const Key('chatbot_conversations_button'),
            tooltip: 'Lịch sử hội thoại',
            visualDensity: VisualDensity.compact,
            onPressed: () => _showConversationSheet(controller),
            icon: const Icon(Icons.history_rounded, color: _darkText),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectedConversation(
    ChatbotState state,
    ChatbotController controller,
  ) {
    return ListView(
      key: const Key('chatbot_conversation_list'),
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(8, 14, 20, 20),
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE9EDF3),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Text(
              'Hội thoại',
              style: TextStyle(
                color: _muted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (widget.isSimulatedSource) ...[
          const Padding(
            padding: EdgeInsets.only(left: 36, bottom: 12),
            child: Text(
              'DỮ LIỆU HỘI THOẠI MÔ PHỎNG · KHÔNG PHẢI TƯ VẤN HỌC VỤ CHÍNH THỨC',
              key: Key('chatbot_simulation_banner'),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
                color: _muted,
              ),
            ),
          ),
        ],
        if (state.messagesStatus == ChatbotRequestStatus.loading) ...[
          const Center(
            key: Key('chatbot_messages_loading'),
            child: Padding(
              padding: EdgeInsets.all(18),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ],
        if (state.messagesStatus == ChatbotRequestStatus.error) ...[
          _buildInlineError(
            key: const Key('chatbot_messages_error'),
            message: state.messagesError?.message ??
                'Không thể tải lịch sử hội thoại.',
            retryKey: const Key('chatbot_messages_retry_button'),
            onRetry: controller.retryMessages,
          ),
          const SizedBox(height: 14),
        ],
        if (state.messagesStatus != ChatbotRequestStatus.loading &&
            state.messages.isEmpty) ...[
          _buildEmptyConnectedState(),
        ],
        if (state.isLoadingOlderMessages) ...[
          const Center(
            key: Key('chatbot_older_messages_loading'),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ] else if (state.olderMessagesError != null) ...[
          _buildInlineError(
            message: state.olderMessagesError!.message,
            retryKey: const Key('chatbot_older_messages_retry_button'),
            onRetry: controller.retryOlderMessages,
          ),
        ] else if (state.canLoadOlderMessages) ...[
          Center(
            child: OutlinedButton.icon(
              key: const Key('chatbot_load_older_messages_button'),
              onPressed: controller.loadOlderMessages,
              icon: const Icon(Icons.expand_less_rounded),
              label: const Text('Tải tin nhắn cũ hơn'),
            ),
          ),
          const SizedBox(height: 12),
        ],
        for (final message in state.messages) ...[
          _buildConnectedMessage(message),
          const SizedBox(height: 12),
        ],
        if (state.isSending) ...[
          _assistantBubble(
            child: const Row(
              key: Key('chatbot_sending_indicator'),
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 10),
                Flexible(child: Text('Đang phản hồi...')),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (state.sendError != null) ...[
          _buildInlineError(
            key: const Key('chatbot_send_error'),
            message: state.sendError!.message,
            failedMessage: state.failedMessage,
            retryKey: state.sendError!.isRetryable
                ? const Key('chatbot_retry_send_button')
                : null,
            onRetry: state.sendError!.isRetryable
                ? controller.retrySendMessage
                : null,
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyConnectedState() {
    return Column(
      key: const Key('chatbot_empty_state'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _assistantBubble(
          child: const Text(
            'Xin chào! Bạn có thể đặt câu hỏi về học phần. '
            'Thông tin cần được xác minh với dữ liệu học vụ chính thức.',
            style: TextStyle(fontSize: 14, height: 1.45, color: _darkText),
          ),
        ),
        const SizedBox(height: 10),
        _buildSuggestion(
          icon: Icons.auto_awesome,
          text: 'Gợi ý môn chuyên ngành cho mình',
        ),
        const SizedBox(height: 8),
        _buildSuggestion(
          icon: Icons.help_outline_rounded,
          text: 'Tại sao mình không đăng ký được AI?',
        ),
      ],
    );
  }

  Widget _buildConnectedMessage(ChatbotMessage message) {
    if (message.isFromUser) {
      return _buildUserMessage(message.content);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _assistantBubble(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.content,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: _darkText,
                ),
              ),
              if (message.evidenceStatus == ChatbotEvidenceStatus.none) ...[
                const SizedBox(height: 9),
                const Text(
                  'Chưa có căn cứ học vụ xác thực',
                  style: TextStyle(fontSize: 12, color: _muted),
                ),
              ],
              if (message.evidenceStatus == ChatbotEvidenceStatus.partial) ...[
                const SizedBox(height: 9),
                const Text(
                  'Căn cứ một phần · Cần kiểm tra lại',
                  style: TextStyle(fontSize: 12, color: _muted),
                ),
              ],
              if (message.sources.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  key: Key('chatbot_message_sources_${message.id}'),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDF5FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nguồn tham khảo',
                        style: TextStyle(
                          color: Color(0xFF075C9E),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      for (final source in message.sources) ...[
                        const SizedBox(height: 5),
                        Text(source.title),
                        if (source.reference != null)
                          Text(
                            source.reference!,
                            style: const TextStyle(fontSize: 12, color: _muted),
                          ),
                        if (source.excerpt != null)
                          Text(
                            source.excerpt!,
                            style: const TextStyle(fontSize: 12, color: _muted),
                          ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        for (final course in message.relatedCourses) ...[
          const SizedBox(height: 9),
          _buildRelatedCourseCard(course),
        ],
      ],
    );
  }

  Widget _buildRelatedCourseCard(ChatbotRelatedCourse course) {
    return Padding(
      padding: const EdgeInsets.only(left: 36),
      child: Container(
        key: Key('chatbot_related_course_${course.courseCode}'),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFFE0E6EF)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: const Color(0xFFEDF5FF),
              padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      course.courseName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: Color(0xFF075C9E),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${course.credits} TC',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF075C9E),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mã học phần: ${course.courseCode}',
                    style: const TextStyle(fontSize: 13, color: _darkText),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    course.reason,
                    style: const TextStyle(fontSize: 13, color: _muted),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Tra cứu thông tin chi tiết tại màn hình F03. '
                    'Chatbot không thực hiện đăng ký học phần.',
                    style: TextStyle(fontSize: 12, color: _muted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInlineError({
    Key? key,
    required String message,
    String? failedMessage,
    Key? retryKey,
    Future<void> Function()? onRetry,
  }) {
    return Container(
      key: key,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2F1),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message, style: const TextStyle(color: Color(0xFF922D27))),
          if (failedMessage != null) ...[
            const SizedBox(height: 6),
            Text('Câu hỏi chưa gửi: $failedMessage'),
          ],
          if (onRetry != null) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              key: retryKey,
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Thử lại'),
            ),
          ],
        ],
      ),
    );
  }

  void _showConversationSheet(ChatbotController controller) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: SizedBox(
          key: const Key('chatbot_conversations_sheet'),
          height: MediaQuery.sizeOf(sheetContext).height * 0.68,
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, _) => _buildConversationSheetContent(
              sheetContext,
              controller,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConversationSheetContent(
    BuildContext sheetContext,
    ChatbotController controller,
  ) {
    final state = controller.state;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 4, 8, 12),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Lịch sử hội thoại',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ),
              IconButton(
                tooltip: 'Làm mới hội thoại',
                onPressed: controller.retryConversations,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
        ),
        if (state.conversationsStatus == ChatbotRequestStatus.loading) ...[
          const Center(
            key: Key('chatbot_conversations_loading'),
            child: Padding(
              padding: EdgeInsets.all(18),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ] else if (state.conversationsStatus == ChatbotRequestStatus.error) ...[
          _buildInlineError(
            message: state.conversationsError?.message ??
                'Không thể tải lịch sử hội thoại.',
            retryKey: const Key('chatbot_conversations_retry_button'),
            onRetry: controller.retryConversations,
          ),
        ] else if (state.isConversationListEmpty) ...[
          const Center(
            key: Key('chatbot_conversations_empty'),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('Chưa có lịch sử hội thoại.'),
            ),
          ),
        ],
        if (state.deleteError != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              state.deleteError!.message,
              style: const TextStyle(color: Color(0xFF922D27)),
            ),
          ),
        Expanded(
          child: ListView(
            children: [
              for (final conversation in state.conversations)
                ListTile(
                  key: Key('chatbot_conversation_item_${conversation.id}'),
                  selected: state.activeConversationId == conversation.id,
                  title: Text(
                    conversation.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: conversation.lastMessagePreview == null
                      ? null
                      : Text(
                          conversation.lastMessagePreview!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    controller.selectConversation(conversation.id);
                    _questionController.clear();
                  },
                  trailing: state.deletingConversationIds
                          .contains(conversation.id)
                      ? const SizedBox(
                          width: 19,
                          height: 19,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : IconButton(
                          key: Key('chatbot_delete_conversation_${conversation.id}'),
                          tooltip: 'Xóa hội thoại',
                          onPressed: () =>
                              controller.deleteConversation(conversation.id),
                          icon: const Icon(Icons.delete_outline_rounded),
                        ),
                ),
              if (state.isLoadingMoreConversations)
                const Center(child: CircularProgressIndicator(strokeWidth: 2))
              else if (state.canLoadMoreConversations)
                Center(
                  child: OutlinedButton(
                    key: const Key('chatbot_load_more_conversations_button'),
                    onPressed: controller.loadMoreConversations,
                    child: const Text('Tải thêm hội thoại'),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SharedAppHeader.assistant(
      title: 'Trợ lý AI Đăng ký',
      status: 'Bản mẫu · Chưa kết nối AI',
      avatar: const _StarAvatar(size: 44),
      leadingKey: const Key('chatbot_back_button'),
      onLeading: () {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          _showNonOperationalNotice('Đây là bản xem trước màn hình.');
        }
      },
      trailing: PopupMenuButton<ChatbotPreviewState>(
        key: const Key('chatbot_state_menu'),
        tooltip: 'Xem trạng thái kiểm thử',
        icon: const Icon(Icons.more_vert_rounded, color: _muted),
        onSelected: (value) {
          setState(() => _previewState = value);
        },
        itemBuilder: (_) => const [
          PopupMenuItem(
            value: ChatbotPreviewState.initial,
            child: Text('Trở về màn hình mẫu'),
          ),
          PopupMenuItem(
            value: ChatbotPreviewState.loading,
            child: Text('Đang tải'),
          ),
          PopupMenuItem(
            value: ChatbotPreviewState.sourcedSample,
            child: Text('Có nguồn minh họa'),
          ),
          PopupMenuItem(
            value: ChatbotPreviewState.noEvidence,
            child: Text('Thiếu căn cứ'),
          ),
          PopupMenuItem(
            value: ChatbotPreviewState.timeout,
            child: Text('Hết thời gian chờ'),
          ),
          PopupMenuItem(
            value: ChatbotPreviewState.offline,
            child: Text('Mất mạng'),
          ),
        ],
      ),
    );
  }

  Widget _buildDateLabel() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFE9EDF3),
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Text(
          'Hôm nay, 14:30',
          style: TextStyle(
            color: _muted,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _assistantBubble({required Widget child}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 8),
          child: _StarAvatar(size: 28),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: child,
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestion({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.only(left: 36),
      child: Align(
        alignment: Alignment.centerLeft,
        child: OutlinedButton.icon(
          onPressed: () => _selectSuggestion(text),
          icon: Icon(icon, size: 17, color: _purple),
          label: Text(text, maxLines: 2),
          style: OutlinedButton.styleFrom(
            foregroundColor: _purple,
            backgroundColor: _purpleSoft,
            side: const BorderSide(color: _purpleBorder),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            textStyle: const TextStyle(fontSize: 13.5),
          ),
        ),
      ),
    );
  }

  Widget _buildUserSampleMessage() => _buildUserMessage(
    'Gợi ý môn học chuyên ngành phù hợp với định hướng làm Mobile App.',
  );

  Widget _buildUserMessage(String message) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 292),
        child: Container(
          padding: const EdgeInsets.fromLTRB(15, 12, 15, 14),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.45,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSampleRecommendation() {
    return const Text.rich(
      TextSpan(
        style: TextStyle(fontSize: 14, height: 1.48, color: _darkText),
        children: [
          TextSpan(
            text:
                'Bạn đạt 9.0 môn Lập trình Hướng đối tượng. '
                'Với định hướng Mobile App, mình gợi ý môn ',
          ),
          TextSpan(
            text: 'Lập trình Di động',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          TextSpan(
            text: ' cho học kỳ này.',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildClassCard() {
    return Padding(
      padding: const EdgeInsets.only(left: 36),
      child: Container(
        key: const Key('sample_course_card'),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFFE0E6EF)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: const Color(0xFFEDF5FF),
              padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Lập trình Di động',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF075C9E),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCCE8FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '3 TC',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: Color(0xFF075C9E),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mã lớp: PRTE230324_01CLC',
                    style: TextStyle(fontSize: 13, color: Color(0xFF52647E)),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Thứ 3 · Tiết 1–3 · Phòng A1.104',
                    style: TextStyle(fontSize: 13, color: Color(0xFF68788D)),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCF8ED),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: const Text(
                      '●  45/60 · Còn 15 chỗ',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: _green,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 1, color: Color(0xFFE0E6EF)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Kiểm tra điều kiện khi đăng ký',
                          style: TextStyle(fontSize: 12, color: _muted),
                        ),
                      ),
                      const SizedBox(width: 6),
                      SizedBox(
                        height: 35,
                        child: FilledButton(
                          key: const Key('sample_register_button'),
                          onPressed: () => _showNonOperationalNotice(
                            'Dữ liệu minh họa. Chatbot không đăng ký học phần; '
                            'hãy dùng màn hình Đăng ký học phần chính thức.',
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF16A34A),
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Đăng ký',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaginationDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        _PagerDot(active: true),
        SizedBox(width: 5),
        _PagerDot(active: false),
        SizedBox(width: 5),
        _PagerDot(active: false),
      ],
    );
  }

  Widget _buildStateContent() {
    switch (_previewState) {
      case ChatbotPreviewState.initial:
        return const SizedBox.shrink();
      case ChatbotPreviewState.loading:
        return const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 17,
              height: 17,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 10),
            Flexible(child: Text('Đang tải (mô phỏng giao diện)…')),
          ],
        );
      case ChatbotPreviewState.sourcedSample:
        return const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ví dụ cách hiển thị câu trả lời đi kèm nguồn. '
              'Chưa có dữ liệu học vụ chính thức được xác minh.',
              key: Key('sourced_sample_answer'),
            ),
            SizedBox(height: 8),
            Text(
              'Nguồn mẫu · CHƯA XÁC THỰC',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF075C9E),
              ),
            ),
          ],
        );
      case ChatbotPreviewState.noEvidence:
        return const Text(
          'Chưa đủ căn cứ để trả lời. Ứng dụng đang ở chế độ '
          'mô phỏng và chưa kết nối nguồn học vụ đã được duyệt.',
          key: Key('no_evidence_message'),
        );
      case ChatbotPreviewState.timeout:
        return const Text(
          'Hết thời gian chờ (tình huống kiểm thử mô phỏng). '
          'Vui lòng thử lại khi dịch vụ hoạt động.',
          key: Key('timeout_message'),
        );
      case ChatbotPreviewState.offline:
        return const Text(
          'Mất kết nối mạng (tình huống kiểm thử mô phỏng). '
          'Hãy kiểm tra kết nối rồi thử lại.',
          key: Key('offline_message'),
        );
    }
  }

  Widget _buildComposer() {
    final state = _controller?.state;
    final isBusy = state?.isSending == true ||
        state?.messagesStatus == ChatbotRequestStatus.loading;
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 12, 18, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE0E6EF))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              key: const Key('chatbot_question_input'),
              controller: _questionController,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendQuestion(),
              decoration: InputDecoration(
                filled: true,
                fillColor: _pageBackground,
                hintText: 'Nhập câu hỏi cho AI...',
                hintStyle: const TextStyle(color: Color(0xFF9AA8BA)),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32),
                  borderSide: const BorderSide(color: Color(0xFFE0E6EF)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
                suffixIcon: IconButton(
                  tooltip: 'Đính kèm (chưa hỗ trợ)',
                  onPressed: () => _showNonOperationalNotice(
                    'Chức năng đính kèm chưa được triển khai.',
                  ),
                  icon: const Icon(Icons.attach_file_rounded, color: _muted),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 46,
            height: 46,
            child: IconButton.filled(
              key: const Key('chatbot_send_button'),
              tooltip: 'Gửi câu hỏi',
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: isBusy ? null : _sendQuestion,
              icon: state?.isSending == true
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.arrow_forward_rounded, size: 26),
            ),
          ),
        ],
      ),
    );
  }
}

class _PagerDot extends StatelessWidget {
  const _PagerDot({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF929CAD) : const Color(0xFFD0D6DF),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _StarAvatar extends StatelessWidget {
  const _StarAvatar({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
        ),
      ),
      child: Center(
        child: Icon(Icons.auto_awesome, color: Colors.white, size: size * 0.58),
      ),
    );
  }
}
