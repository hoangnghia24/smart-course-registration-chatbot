import 'package:flutter_test/flutter_test.dart';
import 'package:smart_course_registration_chatbot_client/smart_course_registration_chatbot_client.dart';
import 'package:smart_course_registration_chatbot_flutter/features/admin/course_management/data/serverpod_course_management_repository.dart';
import 'package:smart_course_registration_chatbot_flutter/features/admin/course_management/domain/admin_course.dart';

CourseDto sampleDto({int? id = 7, String? description = 'Mô tả'}) => CourseDto(
  id: id,
  code: 'CS101',
  name: 'Lập trình cơ bản',
  credits: 3,
  description: description,
  isActive: true,
);

ServerpodCourseManagementRepository createTestRepository({
  Future<List<CourseDto>> Function(int, int)? page,
  Future<List<CourseDto>> Function(String, int, int)? search,
  Future<CourseDto> Function(int)? detail,
  Future<CourseDto> Function(CourseDto)? create,
  Future<CourseDto> Function(CourseDto)? update,
  Future<bool> Function(int)? deactivate,
}) => ServerpodCourseManagementRepository.fromRpc(
  getCoursesPage: page ?? (p, s) async => [sampleDto()],
  searchCourses: search ?? (q, p, s) async => [sampleDto()],
  getCourseById: detail ?? (id) async => sampleDto(id: id),
  createCourse: create ?? (dto) async => dto,
  updateCourse: update ?? (dto) async => dto,
  deleteCourse: deactivate ?? (id) async => true,
);

void main() {
  group('F06 Serverpod adapter', () {
    test('Lấy danh sách: truyền đúng pagination và map DTO', () async {
      int? page;
      int? pageSize;
      final repo = createTestRepository(
        page: (p, s) async {
          page = p;
          pageSize = s;
          return [sampleDto(description: null)];
        },
      );
      final items = await repo.getPage(page: 2);
      expect(page, 2);
      expect(pageSize, 20);
      expect(items, hasLength(1));
      expect(items.single.id, 7);
      expect(items.single.code, 'CS101');
      expect(items.single.description, isNull);
      expect(items.single.isActive, isTrue);
    });

    test('Search trim và truyền đúng tham số', () async {
      String? received;
      final repo = createTestRepository(
        search: (q, p, s) async {
          received = '$q/$p/$s';
          return [sampleDto()];
        },
      );
      final items = await repo.search(
        query: '  CS101  ',
        page: 3,
        pageSize: 10,
      );
      expect(received, 'CS101/3/10');
      expect(items.single.credits, 3);
    });

    test('Search rỗng trả về [] mà không gửi RPC', () async {
      var calls = 0;
      final repo = createTestRepository(
        search: (q, p, s) async {
          calls++;
          return [];
        },
      );
      expect(await repo.search(query: '   '), isEmpty);
      expect(calls, 0);
    });

    test('GetById forward courseId và trả domain model', () async {
      final repo = createTestRepository(
        detail: (id) async => sampleDto(id: id),
      );
      final item = await repo.getById(42);
      expect(item.id, 42);
      expect(item.name, 'Lập trình cơ bản');
    });

    test('Create không gửi ID của domain model', () async {
      CourseDto? sent;
      final repo = createTestRepository(
        create: (dto) async {
          sent = dto;
          return sampleDto(id: 99);
        },
      );
      final created = await repo.create(
        const AdminCourse(
          id: 25,
          code: 'CS101',
          name: 'Lập trình cơ bản',
          credits: 3,
        ),
      );
      expect(sent!.id, isNull);
      expect(created.id, 99);
    });

    test('Update bảo toàn ID, không tự normalize tên mã', () async {
      CourseDto? sent;
      final repo = createTestRepository(
        update: (dto) async {
          sent = dto;
          return dto;
        },
      );
      final edited = await repo.update(
        const AdminCourse(
          id: 8,
          code: 'CS101',
          name: 'Lập trình nâng cao',
          credits: 4,
        ),
      );
      expect(sent!.id, 8);
      expect(sent!.credits, 4);
      expect(edited.name, 'Lập trình nâng cao');
    });

    test('Update thiếu ID bị chặn trước RPC', () async {
      var called = false;
      final repo = createTestRepository(
        update: (dto) async {
          called = true;
          return dto;
        },
      );
      await expectLater(
        repo.update(const AdminCourse(code: 'CS1', name: 'Môn', credits: 2)),
        throwsArgumentError,
      );
      expect(called, isFalse);
    });

    test('Deactivate trả nguyên false từ BE', () async {
      int? sent;
      final repo = createTestRepository(
        deactivate: (id) async {
          sent = id;
          return false;
        },
      );
      expect(await repo.deactivate(5), isFalse);
      expect(sent, 5);
    });

    test('Forward lỗi RPC, không chuyển thành danh sách rỗng', () async {
      final repo = createTestRepository(
        page: (p, s) async {
          throw StateError('network failed');
        },
      );
      await expectLater(repo.getPage(page: 1), throwsStateError);
    });

    test('Validation phân trang và ID trước RPC', () async {
      final repo = createTestRepository();
      await expectLater(repo.getPage(page: 0), throwsArgumentError);
      await expectLater(
        repo.getPage(page: 1, pageSize: 51),
        throwsArgumentError,
      );
      await expectLater(repo.getById(0), throwsArgumentError);
      await expectLater(repo.deactivate(-1), throwsArgumentError);
    });
  });
}
