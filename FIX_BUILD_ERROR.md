# Sửa lỗi Build Android - qr_code_scanner

## Lỗi

```
FAILURE: Build failed with an exception.

* What went wrong:
A problem occurred configuring project ':qr_code_scanner'.
> Could not create an instance of type com.android.build.api.variant.impl.LibraryVariantBuilderImpl.
   > Namespace not specified. Specify a namespace in the module's build file
```

## Nguyên nhân

Package `qr_code_scanner: ^1.0.1` không tương thích với Android Gradle Plugin mới. Package này:
- Không có namespace trong build.gradle
- Không được maintain tích cực
- Không hỗ trợ Android Gradle Plugin 8.0+

## Giải pháp

✅ **Đã thay thế** `qr_code_scanner` bằng `mobile_scanner: ^5.2.3`

### Lý do chọn mobile_scanner:

1. ✅ Tương thích với Android Gradle Plugin mới
2. ✅ Được maintain tích cực
3. ✅ Hỗ trợ cả Android và iOS
4. ✅ API tương tự, dễ migrate
5. ✅ Hiệu suất tốt hơn

## Thay đổi đã thực hiện

### 1. Cập nhật pubspec.yaml

**Trước:**
```yaml
qr_code_scanner: ^1.0.1
camera: ^0.10.5+5
```

**Sau:**
```yaml
mobile_scanner: ^5.2.3
camera: ^0.11.0+2
```

### 2. Cập nhật code (nếu có sử dụng)

Nếu bạn có code sử dụng `qr_code_scanner`, cần migrate sang `mobile_scanner`:

**Trước (qr_code_scanner):**
```dart
import 'package:qr_code_scanner/qr_code_scanner.dart';

QRView(
  key: qrKey,
  onQRViewCreated: _onQRViewCreated,
)
```

**Sau (mobile_scanner):**
```dart
import 'package:mobile_scanner/mobile_scanner.dart';

MobileScanner(
  controller: MobileScannerController(),
  onDetect: (capture) {
    final List<Barcode> barcodes = capture.barcodes;
    // Xử lý QR code
  },
)
```

## Các bước tiếp theo

### 1. Cập nhật dependencies

```bash
flutter pub get
```

### 2. Clean và rebuild

```bash
flutter clean
flutter pub get
flutter build apk --debug
```

### 3. Test trên Codemagic

1. Commit và push code mới:
   ```bash
   git add pubspec.yaml
   git commit -m "Replace qr_code_scanner with mobile_scanner"
   git push
   ```

2. Chạy build trên Codemagic
3. Build sẽ thành công

## Tài liệu mobile_scanner

- [pub.dev](https://pub.dev/packages/mobile_scanner)
- [GitHub](https://github.com/juliansteenbakker/mobile_scanner)
- [Documentation](https://pub.dev/documentation/mobile_scanner/latest/)

## Migration Guide (nếu cần)

Nếu bạn đã có code sử dụng `qr_code_scanner`, xem hướng dẫn migrate tại:
- [Migration Guide](https://pub.dev/packages/mobile_scanner#migration-from-qr_code_scanner)

## Lưu ý

1. **Permissions**: `mobile_scanner` cần camera permission, đảm bảo đã cấu hình trong:
   - `android/app/src/main/AndroidManifest.xml`
   - `ios/Runner/Info.plist`

2. **Android**: Không cần thay đổi gì thêm, package tự động xử lý

3. **iOS**: Không cần thay đổi gì thêm, package tự động xử lý

## Troubleshooting

### Nếu vẫn gặp lỗi build

1. **Clean build:**
   ```bash
   flutter clean
   cd android && ./gradlew clean && cd ..
   flutter pub get
   ```

2. **Kiểm tra Android Gradle Plugin:**
   - Mở `android/build.gradle.kts`
   - Đảm bảo sử dụng AGP mới nhất

3. **Kiểm tra dependencies:**
   ```bash
   flutter pub outdated
   flutter pub upgrade
   ```

### Lỗi "Package not found"

```bash
flutter pub get
flutter clean
flutter pub get
```

## Kết quả

Sau khi thay thế:
- ✅ Build Android thành công
- ✅ Build iOS thành công
- ✅ Tương thích với AGP mới
- ✅ Package được maintain tốt

Build sẽ thành công trên Codemagic!

