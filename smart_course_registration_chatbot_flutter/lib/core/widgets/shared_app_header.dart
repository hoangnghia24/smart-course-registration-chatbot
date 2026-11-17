import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// MỘT định nghĩa Header dùng chung cho toàn bộ các màn hình đã triển khai.
/// Mỗi kiểu hiển thị là cấu hình của cùng widget, không sao chép lại giao diện.
/// - academic: F03/F04/F23 và các màn hình học vụ sinh viên.
/// - dashboard: Dashboard sinh viên, giảng viên và quản trị.
/// - assistant: màn hình Chatbot (giao diện trắng theo Figma riêng).
/// - toolbar: Dashboard đơn giản/legacy dùng trong Scaffold.appBar.
enum SharedHeaderKind { academic, dashboard, assistant, toolbar }

class SharedAppHeader extends StatelessWidget implements PreferredSizeWidget {
  const SharedAppHeader.academic({
    super.key,
    required this.sectionTitle,
    required this.identityLine,
    this.detail,
    this.leadingIcon = Icons.arrow_back_rounded,
    this.onLeading,
    this.leadingKey,
    this.leadingTooltip = 'Quay lại',
    this.trailing,
  }) : kind = SharedHeaderKind.academic,
       title = 'HCM-UTE',
       role = null,
       avatarIcon = Icons.person_outline_rounded,
       onNotification = null,
       onSignOut = null,
       signOutKey = null,
       avatar = null,
       status = null,
       statusColor = null;

  const SharedAppHeader.dashboard({
    super.key,
    required this.role,
    required this.identityLine,
    required this.detail,
    required this.avatarIcon,
    this.onNotification,
    this.onSignOut,
    this.signOutKey,
  }) : kind = SharedHeaderKind.dashboard,
       sectionTitle = null,
       title = 'HCM-UTE',
       leadingIcon = null,
       onLeading = null,
       leadingKey = null,
       leadingTooltip = null,
       trailing = null,
       avatar = null,
       status = null,
       statusColor = null;

  const SharedAppHeader.assistant({
    super.key,
    required this.title,
    required this.status,
    this.statusColor = const Color(0xFF986B20),
    required this.avatar,
    this.onLeading,
    this.leadingKey,
    this.trailing,
  }) : kind = SharedHeaderKind.assistant,
       sectionTitle = null,
       identityLine = null,
       detail = null,
       role = null,
       avatarIcon = null,
       leadingIcon = Icons.arrow_back_ios_new_rounded,
       leadingTooltip = 'Quay lại',
       onNotification = null,
       onSignOut = null,
       signOutKey = null;

  const SharedAppHeader.toolbar({
    super.key,
    required this.title,
    this.trailing,
  }) : kind = SharedHeaderKind.toolbar,
       sectionTitle = null,
       identityLine = null,
       detail = null,
       role = null,
       avatarIcon = null,
       leadingIcon = null,
       onLeading = null,
       leadingKey = null,
       leadingTooltip = null,
       avatar = null,
       status = null,
       statusColor = null,
       onNotification = null,
       onSignOut = null,
       signOutKey = null;

  static const Color primary = AppColors.primary;
  static const Color subtle = Color(0xFFCFDFFF);

  final SharedHeaderKind kind;
  final String? sectionTitle;
  final String? title;
  final String? identityLine;
  final String? detail;
  final String? role;
  final String? status;
  final Color? statusColor;
  final IconData? leadingIcon;
  final VoidCallback? onLeading;
  final Key? leadingKey;
  final String? leadingTooltip;
  final Widget? trailing;
  final Widget? avatar;
  final IconData? avatarIcon;
  final VoidCallback? onNotification;
  final VoidCallback? onSignOut;
  final Key? signOutKey;

  @override
  Size get preferredSize => kind == SharedHeaderKind.toolbar
      ? const Size.fromHeight(kToolbarHeight)
      : Size.zero;

  @override
  Widget build(BuildContext context) {
    return switch (kind) {
      SharedHeaderKind.academic => _buildAcademic(),
      SharedHeaderKind.dashboard => _buildDashboard(),
      SharedHeaderKind.assistant => _buildAssistant(),
      SharedHeaderKind.toolbar => AppBar(
        title: Text(title ?? 'HCM-UTE'),
        actions: trailing == null ? null : [trailing!],
      ),
    };
  }

  Widget _textLine(
    String text, {
    Color color = Colors.white,
    double size = 12,
    FontWeight weight = FontWeight.w500,
  }) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(color: color, fontSize: size, fontWeight: weight),
    );
  }

  Widget _buildAcademic() {
    return Container(
      width: double.infinity,
      color: primary,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 106,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 5, 15, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: _textLine(
                    sectionTitle ?? '',
                    color: subtle,
                    size: 11,
                    weight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Row(
                    children: [
                      IconButton(
                        key: leadingKey,
                        onPressed: onLeading,
                        tooltip: leadingTooltip,
                        icon: Icon(leadingIcon, color: Colors.white, size: 25),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _textLine(
                              'HCM-UTE',
                              size: 18,
                              weight: FontWeight.w700,
                            ),
                            const SizedBox(height: 3),
                            _textLine(
                              identityLine ?? '',
                              size: 12,
                              weight: FontWeight.w600,
                            ),
                            if (detail != null &&
                                detail!.trim().isNotEmpty) ...[
                              const SizedBox(height: 3),
                              _textLine(detail!, color: subtle, size: 10),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      trailing ??
                          const CircleAvatar(
                            radius: 17,
                            backgroundColor: Color(0xFF3B78D1),
                            child: Icon(
                              Icons.person_outline_rounded,
                              color: Colors.white,
                            ),
                          ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    // DashboardScaffold đã đặt SafeArea bên ngoài nên không tạo SafeArea lồng nhau.
    return Container(
      height: 130,
      width: double.infinity,
      color: primary,
      padding: const EdgeInsets.fromLTRB(20, 20, 16, 18),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.white.withValues(alpha: 0.16),
            child: Icon(avatarIcon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _textLine(role ?? '', size: 20, weight: FontWeight.w700),
                const SizedBox(height: 4),
                _textLine(
                  identityLine ?? '',
                  color: Colors.white.withValues(alpha: .86),
                  size: 13,
                ),
                const SizedBox(height: 2),
                _textLine(
                  detail ?? '',
                  color: Colors.white.withValues(alpha: .68),
                  size: 11,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Thông báo',
            onPressed: onNotification,
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.white,
            ),
          ),
          if (onSignOut != null)
            IconButton(
              key: signOutKey,
              tooltip: 'Đăng xuất demo',
              onPressed: onSignOut,
              icon: const Icon(Icons.logout_rounded, color: Colors.white),
            ),
        ],
      ),
    );
  }

  Widget _buildAssistant() {
    // Chatbot có palette riêng theo Figma nhưng dùng cùng thành phần Header.
    const dark = Color(0xFF243143);
    const muted = Color(0xFF7B8798);
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
            key: leadingKey,
            tooltip: 'Quay lại',
            onPressed: onLeading,
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 21,
              color: dark,
            ),
          ),
          avatar ??
              const Icon(Icons.smart_toy_outlined, color: primary, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _textLine(
                  title ?? 'Trợ lý AI Đăng ký',
                  color: dark,
                  size: 19,
                  weight: FontWeight.w800,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.circle, color: statusColor ?? muted, size: 8),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _textLine(
                        status ?? '',
                        color: statusColor ?? muted,
                        size: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
