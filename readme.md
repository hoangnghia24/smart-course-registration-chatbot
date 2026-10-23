# Smart Course Registration Chatbot

Ứng dụng đăng ký môn học thông minh tích hợp chatbot.

Tài liệu dành cho **thành viên mới** chạy backend local trên Windows (PowerShell), với **Serverpod 3.4.13**, **Dart 3.13.x** và **PostgreSQL 16 qua Docker**.

> **Tên database thống nhất:** `smart-course-registration-chatbot` (dấu gạch ngang `-`, **không phải** `smart_course_registration_chatbot`). Tài liệu này hướng dẫn chạy backend và kiểm tra health check; chức năng Flutter/chatbot có thể có quy trình riêng.
>
> **Đường dẫn giả định:** file `docker-compose.yaml`, `.env.example`, thư mục `config/` và `bin/main.dart` nằm trong `smart_course_registration_chatbot_server/`. Nếu repository đang bố trí khác, chọn đúng thư mục chứa những file đó.

## 1. Công cụ cần cài

- Git, Docker Desktop (Docker Compose v2), Flutter SDK (kèm Dart), VS Code.
- Khởi động Docker Desktop trước khi chạy lệnh Docker.

```powershell
git --version
flutter --version
dart --version
docker compose version
```

Dự án dùng các gói Serverpod **3.4.13**. CLI cũng phải là phiên bản này:

```powershell
dart pub global activate serverpod_cli 3.4.13
serverpod --version
```

Nếu `serverpod --version` khác `3.4.13`, kiểm tra `Get-Command serverpod -All` để xử lý trường hợp có nhiều bản cài. **Không tự nâng lên Serverpod 4.x** khi chưa nâng đồng bộ dự án.

## 2. Tải dự án

```powershell
git clone https://github.com/hoangnghia24/smart-course-registration-chatbot.git
cd smart-course-registration-chatbot
cd smart_course_registration_chatbot_server
```

**Các lệnh sau chạy từ thư mục `smart_course_registration_chatbot_server`.**

## 3. Tạo `.env` cho Docker

```powershell
Copy-Item .env.example .env
code .env
```

Trong `.env`, kiểm tra tối thiểu các biến (giá trị mật khẩu phải thay bằng mật khẩu riêng, không dùng placeholder):

```dotenv
POSTGRES_DB=smart-course-registration-chatbot
POSTGRES_USER=postgres
POSTGRES_PASSWORD=CHANGE_ME_STRONG_LOCAL_PASSWORD
POSTGRES_PORT=8090
```

Nếu `.env.example` đã khai báo `SERVERPOD_PASSWORD_database` hoặc các `SERVERPOD_PASSWORD_*` khác, giữ chúng **đồng bộ** với `config/passwords.yaml` (xem bước 4). Docker Compose dùng `.env` để thay các biến `${...}`; **Dart/Serverpod không mặc định tự nạp file `.env`**.

> **Quan trọng:** Nếu Docker volume PostgreSQL đã được tạo từ trước, chỉnh `POSTGRES_DB` hoặc `POSTGRES_PASSWORD` trong `.env` **không tự đổi** tên database hay mật khẩu PostgreSQL hiện có.

## 4. Tạo `config/passwords.yaml` từ file mẫu

Serverpod đọc file thực tế **`config/passwords.yaml`**. Repository chỉ lưu file mẫu **`config/password.example.yaml`** để tránh lộ bí mật.

```powershell
Copy-Item .\config\password.example.yaml .\config\passwords.yaml
code .\config\passwords.yaml
```

Trong `config/passwords.yaml`:

1. Điền `development.database` **giống hệt `POSTGRES_PASSWORD` thực tế** trong PostgreSQL.
2. Thay toàn bộ `CHANGE_ME_...` bằng những khóa ngẫu nhiên, riêng biệt. Các khóa JWT/email/session chỉ cần khi các module tương ứng được bật, nhưng nếu giữ chúng trong mẫu thì vẫn phải thay trước khi sử dụng.
3. Không đưa mật khẩu, token hoặc secret thật vào Git.

Ví dụ tạo **một** chuỗi bí mật ngẫu nhiên 64 byte ở PowerShell (chạy lại từng lần để lấy các khóa khác nhau):

```powershell
$bytes = New-Object byte[] 64
$rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
try { $rng.GetBytes($bytes) } finally { $rng.Dispose() }
[Convert]::ToBase64String($bytes)
```

Nếu sử dụng script `scripts/load-env.ps1` để nạp `.env`, lưu ý các biến `SERVERPOD_PASSWORD_*` của phiên PowerShell có thể **ghi đè** các khóa tương ứng trong `passwords.yaml`. Đảm bảo chúng không mâu thuẫn. Với quy trình trong README này, **không bắt buộc dùng script** vì Serverpod có thể đọc trực tiếp `passwords.yaml`.

Đảm bảo `.gitignore` ở thư mục gốc có quy tắc:

```gitignore
**/.env
!**/.env.example
**/config/passwords.yaml
```

**Không bỏ qua** `config/password.example.yaml` vì đây là file mẫu cần commit. Nếu `passwords.yaml` đã từng được Git theo dõi, phải gỡ khỏi Git index và thay các bí mật đã lộ; chỉ thêm `.gitignore` chưa đủ.

## 5. Khởi động PostgreSQL

Đảm bảo `docker-compose.yaml` đang khai báo service `postgres`, ánh xạ cổng local `8090` tới cổng container `5432`, và sử dụng các biến `POSTGRES_*` trong `.env`.

```powershell
docker compose config -q
docker compose up -d postgres
docker compose ps
```

Xem danh sách database hiện có:

```powershell
docker compose exec postgres psql -U postgres -d postgres -c "SELECT datname FROM pg_database WHERE datistemplate = false ORDER BY datname;"
```

Nếu **chưa có** database `smart-course-registration-chatbot`, tạo đúng tên này **một lần** (không thay thế hoặc xóa database đã có):

```powershell
'CREATE DATABASE "smart-course-registration-chatbot";' |
  docker compose exec -T postgres psql -U postgres -d postgres
```

Tên có dấu `-` phải được đặt trong dấu nháy kép ở câu lệnh SQL. Kiểm tra đọc database:

```powershell
docker compose exec postgres psql -U postgres -d "smart-course-registration-chatbot" -c "SELECT current_database(), 1 AS connected;"
```

Kỳ vọng cột `connected` có giá trị `1`. Không dùng `docker compose down -v` để sửa lỗi thông thường vì tùy chọn `-v` có thể xóa volume dữ liệu.

## 6. Kiểm tra cấu hình Serverpod

Mở file `config/development.yaml`. Trong **phần `database` có sẵn**, phải có các giá trị sau; giữ lại những phần cấu hình khác của dự án:

```yaml
database:
  host: localhost
  port: 8090
  name: smart-course-registration-chatbot
  user: postgres
  requireSsl: false
```

Nếu chưa sử dụng Redis, có thể đặt `redis.enabled: false` theo cấu hình dự án. Web server phải được bật trên cổng `8082` nếu muốn kiểm tra route `/health` tùy chỉnh.

**Lưu ý:** File `config/password.example.yaml` chỉ chứa **bí mật**; tên database và cổng được khai báo ở `config/development.yaml`, không ở file mật khẩu.

## 7. Cài dependencies, migration và chạy backend

```powershell
dart pub get
serverpod generate
dart analyze
```

Không sửa tay các file dưới `lib/src/generated/`. Chỉ chạy `serverpod create-migration` khi schema thực sự thay đổi và cần tạo migration mới.

Áp dụng migrations đã có:

```powershell
dart run bin/main.dart --mode development --role maintenance --apply-migrations
```

Sau đó chạy backend:

```powershell
dart run bin/main.dart --mode development
```

Giữ Terminal này mở. Nếu hiện `database ... does not exist`, hãy đối chiếu lại **đúng tên có dấu `-`** giữa PostgreSQL và `config/development.yaml`.

## 8. Health check

Mở một cửa sổ PowerShell **khác**:

```powershell
curl.exe -i http://localhost:8080/
```

Nếu nhóm **đã tạo** `lib/src/web/app_health_route.dart` và đăng ký đường dẫn `/health` trong `lib/server.dart`, kiểm tra thêm:

```powershell
curl.exe -i http://localhost:8082/health
```

Kỳ vọng route kiểm tra cả database trả HTTP `200` và JSON có `"database":"connected"`. Nếu `404`, kiểm tra đăng ký route/cổng web; nếu `503`, kiểm tra PostgreSQL, migrations và cấu hình truy cập. Việc tạo file route **không tự động** làm route hoạt động nếu chưa đăng ký trong `server.dart`.

## 9. Git workflow cho thành viên mới

Nhóm nên phát triển trên nhánh chức năng và tạo Pull Request, không chỉnh trực tiếp `main`.

```powershell
git fetch origin
# Nếu repository đã có nhánh develop:
git switch develop
git pull origin develop
git switch -c feature/ten-chuc-nang
# Sau khi sửa và kiểm tra:
git status
git add <cac-file-ma-nguon-can-commit>
git commit -m "feat: mo ta thay doi"
git push -u origin feature/ten-chuc-nang
```

Thay `<cac-file-ma-nguon-can-commit>` bằng đường dẫn file thực tế. Trước khi push, xác nhận **không có** `.env` hoặc `config/passwords.yaml` trong commit. Nếu repository chưa có nhánh `develop`, hỏi nhóm về nhánh đích của Pull Request.

## 10. Các lỗi thường gặp

| Lỗi | Cách xử lý |
| --- | --- |
| `database "smart_course_registration_chatbot" does not exist` | Sửa `database.name` về `smart-course-registration-chatbot` hoặc kiểm tra DB thực tế. |
| `database "smart-course-registration-chatbot" does not exist` | Tạo DB bằng câu lệnh ở bước 5 nếu chưa có. |
| `password authentication failed` | Đối chiếu mật khẩu hiện có của PostgreSQL với `development.database`; thay `.env` không đổi mật khẩu trong volume cũ. |
| `PasswordNotFoundException` | Điền khóa yêu cầu vào `config/passwords.yaml` hoặc biến `SERVERPOD_PASSWORD_*` phù hợp. |
| `load-env.ps1 is not recognized` | Script không tồn tại. Với hướng dẫn này, dùng `config/passwords.yaml` nên không cần script để nạp secret Serverpod. |
| CLI `4.x`, packages `3.4.13` | Đồng bộ CLI về `3.4.13`; kiểm tra `Get-Command serverpod -All`. |
| `serverpod generate` lỗi SDK path | Kiểm tra `Get-Command dart -All`, `where.exe dart` và Dart SDK nằm trong Flutter. |
| `/health` trả `404` | Xác minh route đã được khai báo và web server dùng cổng `8082`. |

## 11. Checklist máy thành viên mới

- [ ] Clone repository thành công.
- [ ] Dart, Flutter, Docker hoạt động; Serverpod CLI `3.4.13`.
- [ ] Đã tạo `.env` từ `.env.example`.
- [ ] Đã tạo `config/passwords.yaml` từ `config/password.example.yaml` và thay tất cả secret mẫu.
- [ ] Tên DB **`smart-course-registration-chatbot`** đồng nhất trong `.env`, PostgreSQL và `config/development.yaml`.
- [ ] PostgreSQL chạy và câu lệnh `SELECT 1` thành công.
- [ ] Migration được áp dụng; Serverpod khởi động không lỗi.
- [ ] Kiểm tra API/health check thành công (nếu route tương ứng đã triển khai).
- [ ] Một thành viên khác làm theo README mà không cần chỉnh mã nguồn.
- [ ] Không có file chứa thông tin bí mật trong commit.

---

**Tài liệu tham khảo:** [Serverpod 3.4 — Configurations](https://docs.serverpod.dev/3.4.0/concepts/configuration), [Serverpod Authentication — Setup](https://docs.serverpod.dev/3.4.0/concepts/authentication/setup).

**Lưu ý:** README là mẫu đã thống nhất với thông tin người phát triển cung cấp; chưa được xác thực bằng thao tác clone/chạy thử repository hiện tại. Trước khi nghiệm thu, nhóm cần chạy thử từ đầu trên máy của một thành viên khác.
