# Sửa lỗi "No artifacts were found" trên Codemagic

## Vấn đề

Sau khi build trên Codemagic, gặp lỗi:
```
== Gathering artifacts ==
No artifacts were found
```

## Nguyên nhân

1. **Đường dẫn artifacts không đúng** - Codemagic không tìm thấy file build
2. **Build thất bại** - Build không tạo ra file artifacts
3. **Pattern matching không khớp** - Pattern trong `artifacts:` không match với file thực tế

## Giải pháp

### ✅ Đã sửa trong codemagic.yaml

Đã cập nhật đường dẫn artifacts từ:
```yaml
artifacts:
  - build/**/outputs/**/*.apk  # Pattern quá rộng
```

Thành:
```yaml
artifacts:
  - build/app/outputs/flutter-apk/*.apk  # Đường dẫn cụ thể
  - build/app/outputs/bundle/release/*.aab
  - build/ios/ipa/*.ipa
```

### Thêm debug scripts

Đã thêm các lệnh `ls -la` để kiểm tra file sau khi build:
- Kiểm tra APK: `ls -la build/app/outputs/flutter-apk/`
- Kiểm tra AAB: `ls -la build/app/outputs/bundle/release/`
- Kiểm tra IPA: `ls -la build/ios/ipa/`

## Các bước kiểm tra

### 1. Kiểm tra build logs

Trong Codemagic dashboard:
1. Vào **Builds** > Chọn build của bạn
2. Xem logs của step "Build Android APK" hoặc "Build iOS"
3. Tìm dòng "APK build completed" hoặc "IPA build completed"
4. Kiểm tra output của `ls -la` để xem file có được tạo không

### 2. Kiểm tra đường dẫn file

Sau khi build, file sẽ ở:
- **Android APK**: `build/app/outputs/flutter-apk/app-release.apk`
- **Android AAB**: `build/app/outputs/bundle/release/app-release.aab`
- **iOS IPA**: `build/ios/ipa/Runner.ipa`

### 3. Nếu vẫn không thấy artifacts

#### Kiểm tra build có thành công không:

Trong logs, tìm:
- ✅ `Built build/app/outputs/flutter-apk/app-release.apk` (Android)
- ✅ `Built build/ios/ipa/Runner.ipa` (iOS)
- ❌ Nếu thấy lỗi, build đã thất bại

#### Kiểm tra code signing:

**Android:**
- Nếu build release, cần keystore
- Nếu chưa có keystore, build sẽ thất bại
- Thử build debug trước: `flutter build apk --debug`

**iOS:**
- Cần certificate và provisioning profile
- Nếu chưa cấu hình, build sẽ thất bại

## Giải pháp tạm thời - Build debug

Nếu chưa có code signing, có thể build debug version:

```yaml
- name: Build Android APK (Debug)
  script: |
    flutter build apk --debug
```

Artifacts cho debug:
```yaml
artifacts:
  - build/app/outputs/flutter-apk/app-debug.apk
```

## Cấu hình đầy đủ

### Android Release với Keystore

1. Tạo keystore:
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. Upload keystore lên Codemagic:
   - Vào **App settings** > **Code signing** > **Android**
   - Upload file `.jks`
   - Nhập passwords

3. Cập nhật `android/app/build.gradle.kts`:
```kotlin
signingConfigs {
    create("release") {
        storeFile = file(System.getenv("CM_KEYSTORE_PATH") ?: "upload-keystore.jks")
        storePassword = System.getenv("CM_KEYSTORE_PASSWORD")
        keyAlias = System.getenv("CM_KEY_ALIAS")
        keyPassword = System.getenv("CM_KEY_PASSWORD")
    }
}
buildTypes {
    getByName("release") {
        signingConfig = signingConfigs.getByName("release")
    }
}
```

### iOS Release với Certificate

1. Tạo certificate trong Apple Developer Portal
2. Upload lên Codemagic:
   - Vào **App settings** > **Code signing** > **iOS**
   - Upload `.p12` certificate
   - Upload `.mobileprovision` file

## Troubleshooting

### Lỗi "Build failed"

1. Kiểm tra logs để xem lỗi cụ thể
2. Thường gặp:
   - Code signing errors
   - Missing dependencies
   - Compilation errors

### Lỗi "Artifacts not found" nhưng build thành công

1. Kiểm tra đường dẫn trong `artifacts:` có đúng không
2. Thử dùng pattern rộng hơn:
   ```yaml
   artifacts:
     - build/**/*.apk
     - build/**/*.aab
     - build/**/*.ipa
   ```

### Build chậm hoặc timeout

Tăng `max_build_duration`:
```yaml
max_build_duration: 180  # 3 phút
```

## Checklist

- [ ] Build logs cho thấy "Built ..." thành công
- [ ] File artifacts tồn tại (kiểm tra bằng `ls -la`)
- [ ] Đường dẫn trong `artifacts:` khớp với file thực tế
- [ ] Code signing đã được cấu hình (cho release build)
- [ ] Đã commit và push `codemagic.yaml` mới

## Xem thêm

- [Codemagic Artifacts Documentation](https://docs.codemagic.io/publishing/artifacts/)
- [Flutter Build Guide](https://docs.flutter.dev/deployment/android)
- [iOS Build Guide](https://docs.flutter.dev/deployment/ios)

