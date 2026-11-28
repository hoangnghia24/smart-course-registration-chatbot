/// Phân nhóm câu hỏi thường gặp (FAQ) cho Chatbot tư vấn đăng ký học phần.
enum ChatbotFaqCategory {
  overview,
  lookup,
  recommendation,
}

/// Dữ liệu một câu hỏi thường gặp được xử lý cục bộ tại Flutter.
///
/// Khi người dùng chọn FAQ, hệ thống tra cứu theo [id], không so sánh chuỗi
/// văn bản và không gọi Backend/AI/RAG.
class ChatbotFaqItem {
  const ChatbotFaqItem({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
  });

  final String id;
  final String question;
  final String answer;
  final ChatbotFaqCategory category;
}

/// Danh sách 8 FAQ đã được duyệt cho FE-08.
///
/// Không chứa kết quả học tập cá nhân, GPA cụ thể, số tín chỉ tích lũy,
/// danh sách môn đủ điều kiện hay kết luận học vụ chưa được xác minh.
const List<ChatbotFaqItem> kApprovedChatbotFaqs = <ChatbotFaqItem>[
  ChatbotFaqItem(
    id: 'faq_assistant_scope',
    category: ChatbotFaqCategory.overview,
    question: 'Trợ lý học vụ AI có thể hỗ trợ những gì?',
    answer:
        'Mình hỗ trợ tư vấn học phần trong chương trình đào tạo, hướng dẫn quy tắc đăng ký và giải thích lý do nên chọn hoặc chưa đủ điều kiện chọn học phần. Mình không thực hiện đăng ký học phần thay bạn và không tư vấn định hướng nghề nghiệp ngoài chương trình đào tạo.',
  ),
  ChatbotFaqItem(
    id: 'faq_view_curriculum',
    category: ChatbotFaqCategory.lookup,
    question: 'Tôi xem chương trình đào tạo ở đâu?',
    answer:
        'Từ màn hình chính (Dashboard Sinh viên), bạn chọn mục "Chương trình đào tạo" tại phần Chức năng nhanh. Màn hình này hiển thị các học phần theo từng khối kiến thức, học kỳ dự kiến, số tín chỉ và phân loại bắt buộc hoặc tự chọn của phiên bản chương trình đào tạo được gán cho bạn.',
  ),
  ChatbotFaqItem(
    id: 'faq_check_progress',
    category: ChatbotFaqCategory.lookup,
    question: 'Làm sao để kiểm tra tiến độ và kết quả học tập?',
    answer:
        'Tại Dashboard Sinh viên, bạn chọn mục "Kết quả học tập". Màn hình này hiển thị bảng điểm theo dữ liệu học vụ mà hệ thống hiện có, bao gồm bộ lọc học kỳ theo chương trình đào tạo, tín chỉ tích lũy, tín chỉ còn thiếu, GPA và điểm hoặc trạng thái học phần (Đã đạt, Chưa đạt, Đang học, Chưa học) khi đã có dữ liệu. Nếu GPA, tổng tín chỉ hoặc điểm số chưa được công bố hay còn chờ quy chế, màn hình sẽ hiển thị ký hiệu "—" kèm ghi chú giải thích chứ không tự tính toán.',
  ),
  ChatbotFaqItem(
    id: 'faq_course_catalog',
    category: ChatbotFaqCategory.lookup,
    question: 'Tôi tra cứu danh sách và thông tin học phần bằng cách nào?',
    answer:
        'Tại Dashboard Sinh viên, bạn chọn mục "Tra cứu học phần" rồi nhập mã học phần hoặc tên môn học vào ô tìm kiếm. Bạn có thể nhấn vào từng học phần trong kết quả tra cứu để xem mã môn, tên môn, số tín chỉ và mô tả chi tiết.',
  ),
  ChatbotFaqItem(
    id: 'faq_prerequisites_info',
    category: ChatbotFaqCategory.lookup,
    question:
        'Làm sao để biết điều kiện tiên quyết hoặc môn học trước của một học phần?',
    answer:
        'Bạn có thể xem mô tả học phần tại mục "Tra cứu học phần", kiểm tra trạng thái điều kiện tại mục "Lộ trình học tập", hoặc nhập trực tiếp câu hỏi kèm mã/tên môn học vào ô chat bên dưới để mình tra cứu quy định trong chương trình đào tạo giúp bạn.',
  ),
  ChatbotFaqItem(
    id: 'faq_label_eligible',
    category: ChatbotFaqCategory.recommendation,
    question:
        'Nhãn "Đủ điều kiện", "Chưa đủ điều kiện" và "Chưa xác định" có ý nghĩa gì?',
    answer:
        'Trong mục "Lộ trình học tập", nhãn "Đủ điều kiện" chỉ hiển thị khi Backend đã có kết quả đánh giá chính thức xác nhận học phần thỏa điều kiện đăng ký. Nhãn "Chưa đủ điều kiện" cho biết kết quả đánh giá xác định học phần còn thiếu điều kiện học trước, tiên quyết hoặc quy định liên quan. Nếu hệ thống chưa có kết quả đánh giá chính thức từ Rule Engine, trạng thái điều kiện đăng ký sẽ là "Chưa xác định" (hoặc chỉ hiển thị học phần tham khảo trong chương trình đào tạo) và không được xem là đã đủ điều kiện đăng ký.',
  ),
  ChatbotFaqItem(
    id: 'faq_label_priority',
    category: ChatbotFaqCategory.recommendation,
    question: 'Nhãn "Nên ưu tiên" trong gợi ý học phần có ý nghĩa gì?',
    answer:
        'Nhãn "Nên ưu tiên" chỉ là khuyến nghị về thứ tự học tập khi hệ thống có kết quả xếp hạng ưu tiên từ Rule Engine. Nhãn này giúp bạn tham khảo môn nên cân nhắc trước trong kế hoạch học tập, hoàn toàn không đồng nghĩa với điều kiện tiên quyết bắt buộc và không đồng nghĩa học phần đó đã đủ điều kiện đăng ký.',
  ),
  ChatbotFaqItem(
    id: 'faq_use_recommendation',
    category: ChatbotFaqCategory.recommendation,
    question: 'Cách sử dụng chức năng Lộ trình học tập và gợi ý học phần?',
    answer:
        'Tại Dashboard Sinh viên, bạn mở mục "Lộ trình học tập". Khi Backend đã cung cấp kết quả đề xuất chính thức từ Rule Engine, màn hình hiển thị nhãn "Cá nhân hóa" cùng thứ tự bước học và danh sách gợi ý kỳ tiếp theo. Trường hợp chức năng gợi ý F24/F27 chưa kết nối Rule Engine chính thức, màn hình hiển thị trạng thái "Chờ đề xuất" (tham khảo dữ liệu chương trình đào tạo và tiến độ hiện có, không tự suy diễn thứ tự ưu tiên hay điều kiện đăng ký); còn các bản xem trước giao diện (DEMO/Preview) chỉ dùng dữ liệu minh họa và không phải kết luận học vụ thực tế.',
  ),
];

final Map<String, ChatbotFaqItem> _faqById = <String, ChatbotFaqItem>{
  for (final item in kApprovedChatbotFaqs) item.id: item,
};

/// Tra cứu FAQ theo [id]. Trả về `null` nếu không tìm thấy.
ChatbotFaqItem? findChatbotFaqById(String id) => _faqById[id.trim()];
