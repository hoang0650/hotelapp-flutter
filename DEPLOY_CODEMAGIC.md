# Hướng dẫn Deploy lên Codemagic

[Codemagic](https://codemagic.io/) là nền tảng CI/CD chuyên dụng cho mobile apps, hỗ trợ Flutter, React Native, iOS và Android.

## Yêu cầu

1. ✅ Tài khoản Codemagic (đăng ký miễn phí tại https://codemagic.io/)
2. ✅ Repository trên GitHub, GitLab, Bitbucket hoặc Azure DevOps
3. ✅ File `codemagic.yaml` đã được tạo trong dự án

## Các bước deploy

### Bước 1: Đẩy code lên Git repository

```bash
git init
git add .
git commit -m "Initial commit - Flutter Hotel App"
git remote add origin <your-repo-url>
git push -u origin main
```

### Bước 2: Đăng ký/Đăng nhập Codemagic

1. Truy cập https://codemagic.io/
2. Click **Sign up** hoặc **Login**
3. Chọn phương thức đăng nhập (GitHub, GitLab, Bitbucket, etc.)

### Bước 3: Thêm ứng dụng vào Codemagic

1. Sau khi đăng nhập, click **Add application**
2. Chọn repository của bạn
3. Chọn **Flutter** làm project type
4. Codemagic sẽ tự động phát hiện file `codemagic.yaml`

### Bước 4: Cấu hình Code Signing

#### Android

1. Vào **App settings** > **Code signing**
2. Chọn **Android** tab
3. Upload **keystore file** hoặc tạo mới:
   ```bash
   keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
4. Nhập thông tin:
   - **Keystore password**
   - **Key alias**
   - **Key password**
5. Lưu credentials vào Codemagic

#### iOS

1. Vào **App settings** > **Code signing**
2. Chọn **iOS** tab
3. Upload **Certificate** (.p12 file)
4. Upload **Provisioning profile** (.mobileprovision)
5. Hoặc kết nối với **App Store Connect API** để tự động quản lý

### Bước 5: Cấu hình Environment Variables (nếu cần)

1. Vào **App settings** > **Environment variables**
2. Thêm các biến môi trường nếu cần:
   - `API_URL` - URL của backend API
   - Các keys khác nếu cần

### Bước 6: Chỉnh sửa codemagic.yaml (tùy chọn)

Mở file `codemagic.yaml` và cập nhật:

1. **Email recipients** - Thay `user@example.com` bằng email của bạn
2. **APP_ID** và **PACKAGE_NAME** - Đảm bảo khớp với cấu hình app
3. **Beta groups** - Cập nhật nếu dùng TestFlight

### Bước 7: Chạy build đầu tiên

1. Vào **Builds** tab
2. Chọn workflow muốn chạy:
   - `hotelapp-android-ios` - Build cả Android và iOS
   - `hotelapp-android` - Chỉ build Android
   - `hotelapp-ios` - Chỉ build iOS
3. Click **Start new build**
4. Chọn branch (thường là `main` hoặc `master`)
5. Click **Start build**

### Bước 8: Theo dõi build

- Xem logs real-time trong Codemagic dashboard
- Build Android thường mất 5-10 phút
- Build iOS thường mất 10-15 phút

## Cấu trúc codemagic.yaml

File `codemagic.yaml` đã được tạo với 3 workflows:

### 1. hotelapp-android-ios
- Build cả Android và iOS
- Dùng Mac M1 instance
- Phù hợp cho build đầy đủ

### 2. hotelapp-android
- Chỉ build Android
- Dùng Linux instance (rẻ hơn)
- Build APK và App Bundle

### 3. hotelapp-ios
- Chỉ build iOS
- Dùng Mac M1 instance
- Build IPA file

## Tự động hóa

### Build tự động khi push code

1. Vào **App settings** > **Build triggers**
2. Bật **Automatic builds**
3. Chọn branches muốn trigger build
4. Chọn workflow mặc định

### Tự động upload lên stores

#### Google Play Store

1. Cấu hình **Google Play credentials** trong Codemagic
2. Trong `codemagic.yaml`, bật `submit_as_draft: false` để tự động submit
3. Build sẽ tự động upload lên Google Play

#### Apple App Store / TestFlight

1. Cấu hình **App Store Connect API** trong Codemagic
2. Trong `codemagic.yaml`, bật `submit_to_testflight: true`
3. Build sẽ tự động upload lên TestFlight

## Troubleshooting

### Lỗi "Skipping build for Android because runner does not exist"

✅ **Đã sửa**: Đã chạy `flutter create --platforms=android,ios .` để tạo các thư mục platform.

### Lỗi "Code signing failed"

1. Kiểm tra keystore/certificate đã được upload đúng
2. Đảm bảo passwords đúng
3. Với iOS, kiểm tra provisioning profile khớp với bundle ID

### Lỗi "CocoaPods not found"

Script đã tự động cài CocoaPods:
```yaml
- name: Install CocoaPods dependencies
  script: |
    cd ios && pod install && cd ..
```

### Lỗi "Build timeout"

Tăng `max_build_duration` trong `codemagic.yaml`:
```yaml
max_build_duration: 180  # 3 phút
```

### Lỗi "No space left on device"

Chọn instance type lớn hơn:
```yaml
instance_type: mac_pro  # Thay vì mac_mini_m1
```

## Tài nguyên

- [Codemagic Documentation](https://docs.codemagic.io/)
- [Flutter CI/CD với Codemagic](https://docs.codemagic.io/getting-started/flutter/)
- [Code Signing Guide](https://docs.codemagic.io/code-signing/)

## Lưu ý

1. **Miễn phí**: Codemagic có gói miễn phí với 500 build minutes/tháng
2. **Pricing**: Xem chi tiết tại https://codemagic.io/pricing/
3. **Support**: Hỗ trợ qua email, chat hoặc Discord

## Checklist trước khi deploy

- [ ] Code đã được push lên Git repository
- [ ] File `codemagic.yaml` đã được commit
- [ ] Thư mục `android/` và `ios/` đã tồn tại
- [ ] Đã cấu hình code signing (Android keystore, iOS certificates)
- [ ] Đã cập nhật email trong `codemagic.yaml`
- [ ] Đã test build local thành công: `flutter build apk` và `flutter build ios`

Sau khi hoàn thành các bước trên, bạn có thể bắt đầu build trên Codemagic!

