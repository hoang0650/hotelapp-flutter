# Hotel App Flutter

Ứng dụng quản lý khách sạn được xây dựng bằng Flutter, chuyển đổi từ dự án React Native (Expo).

## Tính năng

- ✅ Đăng nhập/Đăng ký
- ✅ Quản lý phòng (Check-in/Check-out)
- ✅ Quản lý khách sạn
- ✅ Quản lý doanh nghiệp
- ✅ Quản lý nhân viên
- ✅ Quản lý khách hàng
- ✅ Quản lý dịch vụ
- ✅ Quản lý công nợ
- ✅ Giao ca
- ✅ Lịch
- ✅ Biểu đồ doanh thu
- ✅ Báo cáo tài chính
- ✅ Cài đặt và Profile

## Yêu cầu hệ thống

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android Studio / VS Code với Flutter extension
- Android SDK (cho Android)
- Xcode (cho iOS - chỉ trên macOS)

## Cài đặt

### 1. Cài đặt Flutter

Nếu chưa có Flutter, làm theo hướng dẫn tại: https://flutter.dev/docs/get-started/install

Kiểm tra cài đặt:
```bash
flutter doctor
```

### 2. Clone hoặc tải dự án

```bash
cd hotelapp-flutter
```

### 3. Cài đặt dependencies

```bash
flutter pub get
```

### 4. Chạy ứng dụng

#### Trên Android:
```bash
flutter run
```

#### Trên iOS (chỉ macOS):
```bash
flutter run
```

#### Chọn thiết bị cụ thể:
```bash
# Xem danh sách thiết bị
flutter devices

# Chạy trên thiết bị cụ thể
flutter run -d <device-id>
```

## Cấu trúc dự án

```
hotelapp-flutter/
├── lib/
│   ├── config/           # Cấu hình (constants, theme, router)
│   ├── models/           # Data models
│   ├── providers/        # State management (Provider)
│   ├── screens/          # Các màn hình
│   │   ├── auth/         # Màn hình xác thực
│   │   ├── admin/        # Màn hình quản trị
│   │   ├── home/         # Màn hình chính
│   │   ├── profile/      # Màn hình hồ sơ
│   │   └── settings/     # Màn hình cài đặt
│   ├── services/         # API services
│   └── main.dart         # Entry point
├── assets/               # Hình ảnh, icons
├── pubspec.yaml          # Dependencies
└── README.md
```

## Các lệnh hữu ích

### Chạy ứng dụng
```bash
flutter run
```

### Build APK (Android)
```bash
flutter build apk
```

### Build App Bundle (Android - cho Play Store)
```bash
flutter build appbundle
```

### Build iOS (chỉ trên macOS)
```bash
flutter build ios
```

### Xóa cache và rebuild
```bash
flutter clean
flutter pub get
flutter run
```

### Phân tích code
```bash
flutter analyze
```

### Format code
```bash
flutter format .
```

## Cấu hình API

API URL được cấu hình trong `lib/config/constants.dart`:

```dart
static const String apiUrl = 'https://nest-production-8106.up.railway.app/api';
```

Nếu cần thay đổi, chỉnh sửa file này.

## Dependencies chính

- **go_router**: Navigation và routing
- **provider**: State management
- **dio**: HTTP client
- **shared_preferences**: Local storage
- **jwt_decoder**: JWT token decoding
- **fl_chart**: Biểu đồ
- **table_calendar**: Lịch
- **image_picker**: Chọn ảnh
- **qr_code_scanner**: Quét QR code
- **camera**: Camera

## Phát triển tiếp

### Thêm màn hình mới

1. Tạo file trong `lib/screens/`
2. Thêm route vào `lib/config/router.dart`
3. Thêm navigation từ màn hình khác

### Thêm service mới

1. Tạo file trong `lib/services/`
2. Sử dụng `ApiService` để gọi API
3. Thêm endpoint vào `lib/config/constants.dart`

### Thêm model mới

1. Tạo file trong `lib/models/`
2. Implement `fromJson` và `toJson`

## Troubleshooting

### Lỗi "No devices found"
- Đảm bảo thiết bị/emulator đã được kết nối
- Chạy `flutter devices` để kiểm tra

### Lỗi "Package not found"
- Chạy `flutter pub get` để cài đặt lại dependencies

### Lỗi build
- Chạy `flutter clean` và `flutter pub get`
- Kiểm tra `flutter doctor` để đảm bảo môi trường đúng

## Liên hệ

Nếu có vấn đề, vui lòng tạo issue hoặc liên hệ team phát triển.

