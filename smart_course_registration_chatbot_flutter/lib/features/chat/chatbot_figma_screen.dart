import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/shared_app_header.dart';
import 'chatbot_repository_scope.dart';
import 'chatbot_session_scope.dart';
import 'data/chatbot_repository.dart';
import 'domain/chatbot_faq.dart';
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
    this.singleConversationMode = false,
  });

  final ChatbotController? controller;
  final ChatbotRepository? repository;
  final String? initialConversationId;

  /// Chỉ đặt false khi nguồn Backend chính thức đã được tích hợp và kiểm chứng.
  final bool isSimulatedSource;

  /// Chế độ chỉ duy trì một cuộc hội thoại trong RAM của phiên đăng nhập hiện tại.
  /// Khi bật (hoặc khi lấy controller từ [ChatbotSessionScope]), các nút quản lý
  /// đa hội thoại (danh sách lịch sử, xóa hội thoại, tải tin cũ) sẽ được ẩn,
  /// và nút làm mới chỉ đặt lại hội thoại trong RAM.
  final bool singleConversationMode;

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
  bool _fromSessionScope = false;
  bool? _sessionIsSimulatedSource;
  bool _isInlineFaqExpanded = false;
  String? _lastVisibleMessageId;
  String? _lastVisibleConversationId;

  bool get _isSingleConversationMode =>
      widget.singleConversationMode || _fromSessionScope;

  bool get _effectiveIsSimulatedSource =>
      _fromSessionScope && _sessionIsSimulatedSource != null
          ? _sessionIsSimulatedSource!
          : widget.isSimulatedSource;

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
    if (widget.controller != null || widget.repository != null) {
      return;
    }

    final sessionController = ChatbotSessionScope.maybeControllerOf(context);
    if (sessionController != null) {
      _sessionIsSimulatedSource =
          ChatbotSessionScope.maybeIsSimulatedSourceOf(context);
      if (!identical(_controller, sessionController)) {
        _detachController();
        _fromSessionScope = true;
        _attachController(sessionController, ownsController: false);
      }
      return;
    }

    if (_fromSessionScope && sessionController == null) {
      _detachController();
      _fromSessionScope = false;
      _sessionIsSimulatedSource = null;
    }

    if (_controller != null) {
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

  void _detachController() {
    _controller?.removeListener(_onControllerUpdated);
    if (_ownsController) {
      _controller?.dispose();
    }
    _controller = null;
    _ownsController = false;
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

  void _selectFaq(ChatbotController controller, ChatbotFaqItem faq) {
    final added = controller.selectFaqById(faq.id);
    if (!added) return;
    if (_isInlineFaqExpanded) {
      setState(() {
        _isInlineFaqExpanded = false;
      });
    }
    _scrollToBottomAfterFrame();
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

  /// Khoảng thụt đầu dòng bên trái của nội dung trợ lý (36 px ở màn hình thường,
  /// tự động thu về 0 khi chiều rộng khả dụng của danh sách bị bóp hẹp để
  /// tránh `BoxConstraints` còn ~1.6 px gây RenderFlex overflow).
  double _adaptiveAssistantIndent(double availableWidth) {
    if (availableWidth < 220) return 0;
    return 36;
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
        child: LayoutBuilder(
          builder: (context, viewportConstraints) {
            final showFixedChrome = viewportConstraints.maxHeight >= 220 &&
                viewportConstraints.maxWidth >= 200;
            final horizontalPad = viewportConstraints.maxWidth < 180 ? 4.0 : 8.0;
            final rightPad = viewportConstraints.maxWidth < 180 ? 4.0 : 20.0;
            return Column(
              children: [
                if (showFixedChrome) _buildHeader(context),
                Expanded(
                  child: ListView(
                    key: const Key('chatbot_conversation_list'),
                    controller: _scrollController,
                    padding: EdgeInsets.fromLTRB(
                      horizontalPad,
                      14,
                      rightPad,
                      20,
                    ),
                    children: [
                      _buildDateLabel(),
                      const SizedBox(height: 16),
                      Padding(
                        padding: EdgeInsets.only(
                          left: _adaptiveAssistantIndent(
                            viewportConstraints.maxWidth,
                          ),
                          bottom: 8,
                        ),
                        child: const Text(
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
                if (viewportConstraints.maxHeight >= 110) _buildComposer(),
              ],
            );
          },
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
        child: LayoutBuilder(
          builder: (context, viewportConstraints) {
            final showHeader = viewportConstraints.maxHeight >= 220 &&
                viewportConstraints.maxWidth >= 200;
            return Column(
              children: [
                if (showHeader) _buildConnectedHeader(controller),
                Expanded(
                  child: _buildConnectedConversation(
                    state,
                    controller,
                    viewportWidth: viewportConstraints.maxWidth,
                  ),
                ),
                if (viewportConstraints.maxHeight >= 110) _buildComposer(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildConnectedHeader(ChatbotController controller) {
    final isSingleMode = _isSingleConversationMode;
    return SharedAppHeader.assistant(
      title: 'Trợ lý AI Đăng ký',
      status: _effectiveIsSimulatedSource
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
            tooltip: isSingleMode
                ? 'Đặt lại đoạn hội thoại trên màn hình'
                : 'Tạo hội thoại mới',
            visualDensity: VisualDensity.compact,
            onPressed: () {
              if (isSingleMode) {
                controller.resetConversationInMemory();
                _showNonOperationalNotice(
                  'Đã đặt lại đoạn hội thoại trên màn hình hiện tại.',
                );
              } else {
                controller.createNewConversation();
              }
              if (_isInlineFaqExpanded) {
                setState(() {
                  _isInlineFaqExpanded = false;
                });
              }
              _questionController.clear();
              _scrollToBottomAfterFrame();
            },
            icon: const Icon(Icons.add_comment_outlined, color: _darkText),
          ),
          if (!isSingleMode)
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
    ChatbotController controller, {
    double viewportWidth = 390,
  }) {
    final isSingleMode = _isSingleConversationMode;
    final leftPad = viewportWidth < 180 ? 4.0 : 8.0;
    final rightPad = viewportWidth < 180 ? 4.0 : 20.0;
    final assistantIndent = _adaptiveAssistantIndent(viewportWidth);
    return ListView(
      key: const Key('chatbot_conversation_list'),
      controller: _scrollController,
      padding: EdgeInsets.fromLTRB(leftPad, 14, rightPad, 20),
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _muted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_effectiveIsSimulatedSource) ...[
          Padding(
            padding: EdgeInsets.only(left: assistantIndent, bottom: 12),
            child: const Text(
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
        if (state.isSending && state.messages.isEmpty) ...[
          _assistantBubble(
            child: _buildSendingIndicatorRow(),
          ),
          const SizedBox(height: 12),
        ],
        if (state.messagesStatus != ChatbotRequestStatus.loading &&
            state.messages.isEmpty) ...[
          _buildEmptyConnectedState(controller),
        ],
        if (!isSingleMode) ...[
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
              child: OutlinedButton(
                key: const Key('chatbot_load_older_messages_button'),
                onPressed: controller.loadOlderMessages,
                style: OutlinedButton.styleFrom(
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.expand_less_rounded, size: 18),
                    SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Tải tin nhắn cũ hơn',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
        for (final message in state.messages) ...[
          _buildConnectedMessage(message),
          const SizedBox(height: 12),
        ],
        if (state.isSending && state.messages.isNotEmpty) ...[
          _assistantBubble(
            child: _buildSendingIndicatorRow(),
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
          const SizedBox(height: 12),
        ],
        if (state.messages.isNotEmpty) ...[
          _buildCollapsibleFaqSection(controller),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildSendingIndicatorRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final showSpinner = constraints.maxWidth >= 28;
        return Row(
          key: const Key('chatbot_sending_indicator'),
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showSpinner) ...[
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 10),
            ],
            const Flexible(
              child: Text('Đang phản hồi · Trợ lý AI đang xử lý câu hỏi...'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyConnectedState(ChatbotController controller) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final indent = _adaptiveAssistantIndent(constraints.maxWidth);
        return Column(
          key: const Key('chatbot_empty_state'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _assistantBubble(
              child: const Text(
                'Xin chào! Bạn có thể chọn câu hỏi thường gặp bên dưới để xem hướng dẫn ngay, hoặc nhập câu hỏi riêng về học phần trong chương trình đào tạo.',
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
            const SizedBox(height: 12),
            Padding(
              padding: EdgeInsets.only(left: indent, bottom: 8),
              child: const Text(
                'CÂU HỎI THƯỜNG GẶP · TRẢ LỜI NHANH',
                key: Key('chatbot_faq_section_header'),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                  color: _purple,
                ),
              ),
            ),
            _buildFaqChipsList(controller),
          ],
        );
      },
    );
  }

  Widget _buildCollapsibleFaqSection(ChatbotController controller) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final indent = _adaptiveAssistantIndent(constraints.maxWidth);
        final showIcon = constraints.maxWidth >= 100;
        final panelPad = constraints.maxWidth < 120 ? 4.0 : 10.0;
        return Padding(
          padding: EdgeInsets.only(left: indent),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton(
                  key: const Key('chatbot_toggle_faq_button'),
                  onPressed: () {
                    setState(() {
                      _isInlineFaqExpanded = !_isInlineFaqExpanded;
                    });
                    if (_isInlineFaqExpanded) {
                      _scrollToBottomAfterFrame();
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _purple,
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: _purpleBorder),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: EdgeInsets.symmetric(
                      horizontal: constraints.maxWidth < 120 ? 6 : 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (showIcon) ...[
                        Icon(
                          _isInlineFaqExpanded
                              ? Icons.expand_less_rounded
                              : Icons.quiz_outlined,
                          size: 17,
                          color: _purple,
                        ),
                        const SizedBox(width: 6),
                      ],
                      Flexible(
                        child: Text(
                          _isInlineFaqExpanded
                              ? 'Thu gọn câu hỏi thường gặp'
                              : 'Xem câu hỏi thường gặp (FAQ)',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_isInlineFaqExpanded) ...[
                const SizedBox(height: 8),
                Container(
                  key: const Key('chatbot_inline_faq_panel'),
                  padding: EdgeInsets.all(panelPad),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _purpleBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Chọn câu hỏi để nhận câu trả lời hướng dẫn ngay:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _muted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildFaqChipsList(controller, compactPadding: true),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildFaqChipsList(
    ChatbotController controller, {
    bool compactPadding = false,
  }) {
    final faqs = controller.faqs;
    return LayoutBuilder(
      builder: (context, constraints) {
        final leftIndent = compactPadding
            ? 0.0
            : _adaptiveAssistantIndent(constraints.maxWidth);
        return Padding(
          padding: EdgeInsets.only(left: leftIndent),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var index = 0; index < faqs.length; index++) ...[
                if (index > 0) const SizedBox(height: 7),
                _buildFaqChip(
                  controller: controller,
                  faq: faqs[index],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildFaqChip({
    required ChatbotController controller,
    required ChatbotFaqItem faq,
  }) {
    final icon = switch (faq.category) {
      ChatbotFaqCategory.overview => Icons.info_outline_rounded,
      ChatbotFaqCategory.lookup => Icons.menu_book_outlined,
      ChatbotFaqCategory.recommendation => Icons.route_outlined,
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        final showIcon = constraints.maxWidth >= 90;
        final horizontalPad = constraints.maxWidth < 90 ? 4.0 : 12.0;
        return Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth),
            child: OutlinedButton(
              key: Key('chatbot_faq_chip_${faq.id}'),
              onPressed: () => _selectFaq(controller, faq),
              style: OutlinedButton.styleFrom(
                foregroundColor: _purple,
                backgroundColor: _purpleSoft,
                side: const BorderSide(color: _purpleBorder),
                alignment: Alignment.centerLeft,
                minimumSize: Size.zero,
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPad,
                  vertical: 9,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showIcon) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Icon(icon, size: 16, color: _purple),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      faq.question,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final indent = _adaptiveAssistantIndent(constraints.maxWidth);
        return Padding(
          padding: EdgeInsets.only(left: indent),
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
                      Flexible(
                        child: Text(
                          '${course.credits} TC',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
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
      },
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
            TextButton(
              key: retryKey,
              onPressed: onRetry,
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh_rounded, size: 18),
                  SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Thử lại',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final showAvatar = constraints.maxWidth >= 140;
        final bubblePad = constraints.maxWidth < 80
            ? const EdgeInsets.all(6)
            : const EdgeInsets.fromLTRB(16, 12, 16, 14);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showAvatar) ...[
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: _StarAvatar(size: 28),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Container(
                padding: bubblePad,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: child,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSuggestion({required IconData icon, required String text}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final indent = _adaptiveAssistantIndent(constraints.maxWidth);
        final maxBtnWidth =
            (constraints.maxWidth - indent).clamp(0.0, double.infinity);
        final showIcon = maxBtnWidth >= 90;
        final horizontalPad = maxBtnWidth < 90 ? 4.0 : 12.0;
        return Padding(
          padding: EdgeInsets.only(left: indent),
          child: Align(
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxBtnWidth),
              child: OutlinedButton(
                onPressed: () => _selectSuggestion(text),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _purple,
                  backgroundColor: _purpleSoft,
                  side: const BorderSide(color: _purpleBorder),
                  alignment: Alignment.centerLeft,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPad,
                    vertical: 9,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  textStyle: const TextStyle(fontSize: 13.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showIcon) ...[
                      Icon(icon, size: 17, color: _purple),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        text,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final indent = _adaptiveAssistantIndent(constraints.maxWidth);
        return Padding(
          padding: EdgeInsets.only(left: indent),
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
                      Flexible(
                        child: Container(
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: Color(0xFF075C9E),
                            ),
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
                          Flexible(
                            child: SizedBox(
                              height: 35,
                              child: FilledButton(
                                key: const Key('sample_register_button'),
                                onPressed: () => _showNonOperationalNotice(
                                  'Dữ liệu minh họa. Chatbot không đăng ký học phần; '
                                  'hãy dùng màn hình Đăng ký học phần chính thức.',
                                ),
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF16A34A),
                                  minimumSize: Size.zero,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Đăng ký',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontWeight: FontWeight.w800),
                                ),
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
      },
    );
  }

  Widget _buildPaginationDots() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 5,
      children: const [
        _PagerDot(active: true),
        _PagerDot(active: false),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isUltraNarrow = constraints.maxWidth < 180;
        if (constraints.maxWidth < 70) {
          return const SizedBox.shrink();
        }
        return Container(
          padding: EdgeInsets.fromLTRB(
            isUltraNarrow ? 4 : 15,
            12,
            isUltraNarrow ? 4 : 18,
            12,
          ),
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
                    isDense: isUltraNarrow,
                    filled: true,
                    fillColor: _pageBackground,
                    hintText: 'Nhập câu hỏi cho AI...',
                    hintStyle: const TextStyle(color: Color(0xFF9AA8BA)),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: isUltraNarrow ? 8 : 16,
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
                    suffixIcon: isUltraNarrow
                        ? null
                        : IconButton(
                            tooltip: 'Đính kèm (chưa hỗ trợ)',
                            onPressed: () => _showNonOperationalNotice(
                              'Chức năng đính kèm chưa được triển khai.',
                            ),
                            icon: const Icon(
                              Icons.attach_file_rounded,
                              color: _muted,
                            ),
                          ),
                  ),
                ),
              ),
              SizedBox(width: isUltraNarrow ? 4 : 8),
              SizedBox(
                width: isUltraNarrow ? 36 : 46,
                height: isUltraNarrow ? 36 : 46,
                child: IconButton.filled(
                  key: const Key('chatbot_send_button'),
                  tooltip: 'Gửi câu hỏi',
                  padding: EdgeInsets.zero,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                      : Icon(
                          Icons.arrow_forward_rounded,
                          size: isUltraNarrow ? 18 : 26,
                        ),
                ),
              ),
            ],
          ),
        );
      },
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
