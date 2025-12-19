# Hướng dẫn nhanh - Chạy trên iOS

## ⚠️ Lưu ý quan trọng

**iOS development CHỈ chạy được trên macOS!**
- Không thể chạy trên Windows hoặc Linux
- Cần Mac (MacBook, iMac, Mac mini, Mac Studio, Mac Pro)

## Yêu cầu

1. ✅ macOS (bất kỳ phiên bản nào hỗ trợ Xcode mới nhất)
2. ✅ Xcode (cài từ App Store, ~12GB)
3. ✅ iPhone/iPad với iOS 12.0+
4. ✅ Apple ID (miễn phí)

## Các bước nhanh

### 1. Cài đặt Xcode

```bash
# Mở App Store và tìm "Xcode"
# Cài đặt (mất khoảng 30-60 phút)
```

Sau khi cài xong:
```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -license accept
```

### 2. Cài đặt CocoaPods

```bash
sudo gem install cocoapods
```

### 3. Cài đặt iOS dependencies

```bash
cd ios
pod install
cd ..
```

Hoặc chạy script tự động:
```bash
chmod +x setup-ios.sh
./setup-ios.sh
```

### 4. Kết nối iPhone

1. Dùng cáp USB kết nối iPhone với Mac
2. Trên iPhone: Chọn **Trust This Computer** và nhập passcode

### 5. Cấu hình Signing trong Xcode

```bash
open ios/Runner.xcworkspace
```

Trong Xcode:
1. Chọn **Runner** (bên trái)
2. Chọn tab **Signing & Capabilities**
3. Chọn **Team** (đăng nhập Apple ID nếu cần)
4. Xcode sẽ tự động tạo provisioning profile

### 6. Bật Developer Mode (iOS 16+)

Trên iPhone:
1. **Settings** > **Privacy & Security**
2. Bật **Developer Mode**
3. Khởi động lại iPhone
4. Chọn **Turn On** khi được hỏi

### 7. Chạy ứng dụng

```bash
flutter run
```

Hoặc dùng script:
```bash
chmod +x run-on-ios.sh
./run-on-ios.sh
```

## Chạy trên Simulator (không cần iPhone thật)

```bash
# Mở Simulator
open -a Simulator

# Chạy app
flutter run
```

## Troubleshooting nhanh

### "No devices found"
- Đảm bảo iPhone đã unlock và trust computer
- Kiểm tra cáp USB
- Mở Xcode > Window > Devices and Simulators

### "No code signing identities"
- Mở `ios/Runner.xcworkspace` trong Xcode
- Chọn Team trong Signing & Capabilities

### "Developer Mode is disabled"
- Settings > Privacy & Security > Developer Mode > ON
- Khởi động lại iPhone

### "CocoaPods not installed"
```bash
sudo gem install cocoapods
cd ios && pod install && cd ..
```

## Xem hướng dẫn chi tiết

Xem file `RUN_ON_PHONE.md` để biết thêm chi tiết và cách xử lý các lỗi khác.

