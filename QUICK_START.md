# Hướng dẫn nhanh - Start dự án Flutter

## Bước 1: Kiểm tra Flutter đã được cài đặt

```bash
flutter doctor
```

Nếu chưa có Flutter, cài đặt tại: https://flutter.dev/docs/get-started/install

## Bước 2: Di chuyển vào thư mục dự án

```bash
cd hotelapp-flutter
```

## Bước 3: Cài đặt dependencies

```bash
flutter pub get
```

## Bước 4: Chạy ứng dụng

### Trên Android Emulator hoặc thiết bị Android:

```bash
flutter run
```

### Trên iOS Simulator (chỉ macOS):

```bash
flutter run
```

### Chọn thiết bị cụ thể:

```bash
# Xem danh sách thiết bị
flutter devices

# Chạy trên thiết bị cụ thể
flutter run -d <device-id>
```

## Bước 5: Build ứng dụng (tùy chọn)

### Build APK cho Android:

```bash
flutter build apk
```

File APK sẽ được tạo tại: `build/app/outputs/flutter-apk/app-release.apk`

### Build App Bundle cho Google Play Store:

```bash
flutter build appbundle
```

File AAB sẽ được tạo tại: `build/app/outputs/bundle/release/app-release.aab`

## Troubleshooting

### Lỗi "No devices found"

1. Đảm bảo emulator/thiết bị đã được khởi động
2. Chạy `flutter devices` để kiểm tra
3. Với Android: Mở Android Studio > AVD Manager > Start emulator
4. Với iOS: Mở Xcode > Window > Devices and Simulators > Start simulator

### Lỗi "Package not found"

```bash
flutter clean
flutter pub get
```

### Lỗi build

```bash
flutter clean
flutter pub get
flutter run
```

## Các lệnh hữu ích khác

### Format code:
```bash
flutter format .
```

### Phân tích code:
```bash
flutter analyze
```

### Xem logs:
```bash
flutter logs
```

## Cấu hình API

API URL được cấu hình trong `lib/config/constants.dart`. Nếu cần thay đổi, chỉnh sửa file này.

## Lưu ý

- Đảm bảo thiết bị/emulator đã được kết nối trước khi chạy
- Lần đầu chạy có thể mất thời gian để build
- Nếu gặp lỗi, chạy `flutter doctor` để kiểm tra môi trường

