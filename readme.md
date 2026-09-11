# Smart Course Registration Chatbot

Chatbot hỗ trợ hệ thống đăng ký môn học thông minh, được xây dựng bằng Flutter, Serverpod, PostgreSQL và Redis.

## Tech Stack

- Flutter / Dart
- Serverpod 3.4.13
- PostgreSQL 16 + pgvector
- Redis 6.2.6
- Docker / Docker Compose

## Project Structure

```text
smart_course_registration_chatbot/
├── smart_course_registration_chatbot_server/
├── smart_course_registration_chatbot_client/
├── smart_course_registration_chatbot_flutter/
├── pubspec.yaml
└── README.md
```

Trong đó:

- `smart_course_registration_chatbot_server`: Backend Serverpod.
- `smart_course_registration_chatbot_client`: Client code được Serverpod generate.
- `smart_course_registration_chatbot_flutter`: Ứng dụng Flutter.

## 1. Yêu cầu môi trường

Cài đặt trước:

- Git
- Flutter SDK
- Dart SDK
- Docker Desktop
- Serverpod CLI

Kiểm tra:

```bash
git --version
flutter --version
dart --version
docker --version
docker compose version
serverpod --version
```

Project hiện đang sử dụng:

```text
Serverpod: 3.4.13
Dart: 3.13.3
```

Có thể cài đúng Serverpod CLI bằng:

```bash
dart pub global activate serverpod_cli 3.4.13
```

## 2. Clone repository

```bash
git clone https://github.com/hoangnghia24/smart-course-registration-chatbot.git
cd smart-course-registration-chatbot
```

Cài dependencies cho workspace:

```bash
dart pub get
```

## 3. Cấu hình Serverpod

Serverpod sử dụng file:

```text
smart_course_registration_chatbot_server/config/passwords.yaml
```

File này chứa thông tin nhạy cảm và không được commit lên GitHub.

Nếu repository có file:

```text
smart_course_registration_chatbot_server/config/passwords.example.yaml
```

thì copy thành `passwords.yaml`.

### Windows PowerShell

```powershell
Copy-Item `
  smart_course_registration_chatbot_server\config\passwords.example.yaml `
  smart_course_registration_chatbot_server\config\passwords.yaml
```

### macOS / Linux

```bash
cp \
  smart_course_registration_chatbot_server/config/passwords.example.yaml \
  smart_course_registration_chatbot_server/config/passwords.yaml
```

Sau đó kiểm tra thông tin database trong `passwords.yaml` phải khớp với cấu hình local trong `docker-compose.yaml`.

> Không commit `passwords.yaml`, `.env`, API key hoặc production secrets lên GitHub.

## 4. Khởi động PostgreSQL và Redis bằng Docker

Đi vào backend:

```bash
cd smart_course_registration_chatbot_server
```

Khởi động các container:

```bash
docker compose up -d
```

Kiểm tra:

```bash
docker compose ps
```

Các service local hiện tại:

| Service | Local Port |
|---|---:|
| PostgreSQL Development | 8090 |
| Redis Development | 8091 |
| PostgreSQL Test | 9090 |
| Redis Test | 9091 |

Các container phải có trạng thái `Up`.

Nếu Docker chưa chạy, mở Docker Desktop trước rồi kiểm tra:

```bash
docker info
```

## 5. Chạy Serverpod Backend

Trong thư mục:

```text
smart_course_registration_chatbot_server
```

chạy:

```bash
dart run bin/main.dart --apply-migrations
```

Lệnh trên sẽ:

1. Kết nối PostgreSQL.
2. Kết nối Redis.
3. Apply database migrations.
4. Khởi động Serverpod backend.

Các cổng mặc định:

| Service | URL |
|---|---|
| Serverpod API | http://localhost:8080 |
| Serverpod Insights | http://localhost:8081 |
| Web Server | http://localhost:8082 |

Giữ terminal backend đang chạy trong quá trình phát triển.

## 6. Chạy Flutter

Mở terminal mới.

Từ root repository:

```bash
cd smart_course_registration_chatbot_flutter
```

Kiểm tra thiết bị:

```bash
flutter devices
```

Chạy ứng dụng:

```bash
flutter run
```

Chạy trên Chrome:

```bash
flutter run -d chrome
```

## 7. Luồng chạy local

```text
Flutter App
    |
    v
Serverpod Backend
    |
    +------------------+
    |                  |
    v                  v
PostgreSQL           Redis
localhost:8090       localhost:8091
```

Flutter không kết nối trực tiếp tới PostgreSQL hoặc Redis.

## 8. Khi thay đổi Serverpod Model hoặc Endpoint

Đi vào backend:

```bash
cd smart_course_registration_chatbot_server
```

Generate lại Serverpod code:

```bash
serverpod generate
```

Nếu có thay đổi database schema, tạo migration:

```bash
serverpod create-migration
```

Sau đó chạy:

```bash
dart run bin/main.dart --apply-migrations
```

Các file migration phải được commit lên GitHub để các thành viên dùng cùng database schema.

## 9. Dừng môi trường local

Dừng Serverpod:

```text
Ctrl + C
```

Dừng Docker:

```bash
cd smart_course_registration_chatbot_server
docker compose down
```

## 10. Reset Database Local

Nếu cần xóa hoàn toàn dữ liệu database local:

```bash
docker compose down -v
```

Sau đó tạo lại:

```bash
docker compose up -d
dart run bin/main.dart --apply-migrations
```

> Cảnh báo: `docker compose down -v` sẽ xóa toàn bộ dữ liệu PostgreSQL local.

## 11. Quy trình làm việc với Git

Trước khi bắt đầu công việc:

```bash
git checkout main
git pull origin main
```

Tạo branch mới:

```bash
git checkout -b feature/<feature-name>
```

Ví dụ:

```bash
git checkout -b feature/chatbot
```

Sau khi hoàn thành:

```bash
git add .
git commit -m "feat: implement chatbot"
git push -u origin feature/chatbot
```

Sau đó tạo Pull Request vào `main`.

## 12. Commit Convention

Sử dụng convention:

```text
feat:     thêm chức năng mới
fix:      sửa lỗi
refactor: refactor source code
docs:     cập nhật tài liệu
test:     thêm hoặc sửa test
chore:    cấu hình / maintenance
```

Ví dụ:

```text
feat: add conversation endpoint
fix: handle chatbot response error
docs: update setup guide
chore: update docker configuration
```

## Quick Start

Sau khi đã setup máy lần đầu:

### Terminal 1 - Backend

```bash
cd smart_course_registration_chatbot_server
docker compose up -d
dart run bin/main.dart --apply-migrations
```

### Terminal 2 - Flutter

```bash
cd smart_course_registration_chatbot_flutter
flutter run
```

## Security

Không commit:

```text
config/passwords.yaml
.env
API keys
production database credentials
private keys
```

AI API key sau này phải được cấu hình ở Serverpod backend, không đặt trực tiếp trong Flutter app.
