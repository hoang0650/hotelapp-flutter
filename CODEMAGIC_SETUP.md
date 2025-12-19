# Quick Setup - Codemagic

## ✅ Đã sửa lỗi

Lỗi "Skipping build for Android/iOS because runner does not exist" đã được sửa bằng cách:

1. ✅ Tạo thư mục `android/` và `ios/` bằng lệnh:
   ```bash
   flutter create --platforms=android,ios .
   ```

2. ✅ Tạo file `codemagic.yaml` với cấu hình CI/CD

3. ✅ Cập nhật package name thành `com.hotelapp.mobile`

## Các bước tiếp theo

### 1. Commit và push code

```bash
git add .
git commit -m "Add Codemagic CI/CD configuration"
git push
```

### 2. Đăng ký Codemagic

1. Truy cập https://codemagic.io/
2. Đăng ký/Đăng nhập với GitHub/GitLab/Bitbucket
3. Click **Add application**
4. Chọn repository của bạn
5. Codemagic sẽ tự động phát hiện `codemagic.yaml`

### 3. Cấu hình Code Signing

#### Android:
- Vào **App settings** > **Code signing** > **Android**
- Upload keystore file hoặc tạo mới

#### iOS:
- Vào **App settings** > **Code signing** > **iOS**  
- Upload certificate và provisioning profile

### 4. Chạy build đầu tiên

1. Vào **Builds** tab
2. Chọn workflow: `hotelapp-android` hoặc `hotelapp-ios`
3. Click **Start new build**

## Xem hướng dẫn chi tiết

Xem file `DEPLOY_CODEMAGIC.md` để biết hướng dẫn đầy đủ.

