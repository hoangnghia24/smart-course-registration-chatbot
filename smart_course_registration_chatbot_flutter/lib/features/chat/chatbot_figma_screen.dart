import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

enum ChatbotPreviewState {
  initial,
  loading,
  sourcedSample,
  noEvidence,
  timeout,
  offline,
}

class ChatbotFigmaScreen extends StatefulWidget {
  const ChatbotFigmaScreen({super.key});

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

  @override
  void dispose() {
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
    setState(() {
      _lastQuestion = question;
      // Chưa có API AI: tuyệt đối không sinh câu trả lời học vụ giả.
      _previewState = ChatbotPreviewState.noEvidence;
      _questionController.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
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
    return Scaffold(
      backgroundColor: _pageBackground,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              // Prototype có ít tin nhắn tĩnh: dựng sẵn nội dung để các
              // trạng thái và thẻ môn học luôn tồn tại trong cây Widget,
              // kể cả khi nằm ngoài vùng màn hình. Vẫn cuộn dọc bình thường.
              child: SingleChildScrollView(
                key: const Key('chatbot_conversation_list'),
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(8, 14, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
            ),
            _buildComposer(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 110,
      padding: const EdgeInsets.fromLTRB(6, 18, 12, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE7EBF2))),
      ),
      child: Row(
        children: [
          IconButton(
            key: const Key('chatbot_back_button'),
            tooltip: 'Quay lại',
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                _showNonOperationalNotice('Đây là bản xem trước màn hình.');
              }
            },
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: _darkText,
              size: 21,
            ),
          ),
          const _StarAvatar(size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Trợ lý AI Đăng ký',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 19,
                    letterSpacing: -0.5,
                    color: _darkText,
                  ),
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.circle, color: Color(0xFFB57817), size: 8),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Bản mẫu · Chưa kết nối AI',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF986B20),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<ChatbotPreviewState>(
            key: const Key('chatbot_state_menu'),
            tooltip: 'Xem trạng thái kiểm thử',
            icon: const Icon(Icons.more_vert_rounded, color: _muted),
            onSelected: (value) {
              setState(() => _previewState = value);
              // Hiện trạng thái vừa chọn ở cuối hội thoại mà không cần kéo tay.
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted || !_scrollController.hasClients) return;
                _scrollController.jumpTo(
                  _scrollController.position.maxScrollExtent,
                );
              });
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
            text: 'Bạn đạt 9.0 môn Lập trình Hướng đối tượng. '
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
              onPressed: _sendQuestion,
              icon: const Icon(Icons.arrow_forward_rounded, size: 26),
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
