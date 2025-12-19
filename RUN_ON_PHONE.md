# Hướng dẫn chạy ứng dụng Flutter trên điện thoại

## Android

### Bước 1: Bật USB Debugging trên điện thoại

1. Vào **Settings** (Cài đặt)
2. Tìm **About phone** (Giới thiệu về điện thoại)
3. Nhấn 7 lần vào **Build number** (Số bản dựng) để bật Developer options
4. Quay lại Settings > **Developer options**
5. Bật **USB debugging**
6. (Tùy chọn) Bật **Install via USB** nếu có

### Bước 2: Kết nối điện thoại với máy tính

1. Dùng cáp USB để kết nối điện thoại với máy tính
2. Trên điện thoại, khi có thông báo, chọn **Allow USB debugging** và tích **Always allow from this computer**
3. Chọn **Allow** hoặc **Cho phép**

### Bước 3: Kiểm tra thiết bị

```bash
flutter devices
```

Bạn sẽ thấy thiết bị Android của mình trong danh sách, ví dụ:
```
sdk gphone64 arm64 (mobile) • emulator-5554 • android-arm64 • Android 13 (API 33)
```

### Bước 4: Chạy ứng dụng

```bash
flutter run
```

Hoặc chạy trên thiết bị cụ thể:
```bash
flutter run -d <device-id>
```

## iOS (chỉ trên macOS)

### Yêu cầu hệ thống

- **macOS** (không thể chạy trên Windows/Linux)
- **Xcode** đã được cài đặt từ App Store
- **CocoaPods** (sẽ được cài tự động hoặc cài thủ công)
- **iPhone/iPad** với iOS 12.0 trở lên
- **Apple Developer Account** (miễn phí hoặc có phí)

### Bước 1: Cài đặt Xcode

1. Mở **App Store** trên Mac
2. Tìm và cài đặt **Xcode** (khoảng 12GB, mất thời gian)
3. Sau khi cài xong, mở Xcode một lần để chấp nhận license
4. Cài đặt Command Line Tools:
   ```bash
   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
   sudo xcodebuild -license accept
   ```

### Bước 2: Cài đặt CocoaPods (nếu chưa có)

```bash
sudo gem install cocoapods
```

Kiểm tra:
```bash
pod --version
```

### Bước 3: Cấu hình iOS project

1. Di chuyển vào thư mục iOS:
   ```bash
   cd ios
   ```

2. Cài đặt pods:
   ```bash
   pod install
   ```

3. Quay lại thư mục gốc:
   ```bash
   cd ..
   ```

### Bước 4: Kết nối iPhone với Mac

1. Dùng cáp USB (hoặc Lightning/USB-C) để kết nối iPhone với Mac
2. Trên iPhone, khi có thông báo:
   - Chọn **Trust This Computer** (Tin cậy máy tính này)
   - Nhập passcode của iPhone
3. Mở **Xcode** > **Window** > **Devices and Simulators**
4. Kiểm tra iPhone đã xuất hiện trong danh sách

### Bước 5: Cấu hình Signing & Capabilities

1. Mở file `ios/Runner.xcworkspace` trong Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. Chọn **Runner** trong Project Navigator (bên trái)

3. Chọn tab **Signing & Capabilities**

4. Chọn **Team**:
   - Nếu có Apple Developer Account: Chọn team của bạn
   - Nếu không có: Chọn **Add Account...** và đăng nhập với Apple ID

5. Xcode sẽ tự động tạo **Provisioning Profile**

6. Đảm bảo **Bundle Identifier** là duy nhất (ví dụ: `com.yourname.hotelapp`)

### Bước 6: Chọn iPhone làm thiết bị chạy

1. Trong Xcode, ở thanh toolbar phía trên, chọn iPhone của bạn từ dropdown
2. Hoặc chạy lệnh để xem danh sách:
   ```bash
   flutter devices
   ```

Bạn sẽ thấy iPhone của mình, ví dụ:
```
iPhone 14 Pro (mobile) • 00008110-001234567890ABCD • ios • com.apple.CoreSimulator.SimRuntime.iOS-16-2 (simulator)
```

### Bước 7: Chạy ứng dụng

```bash
flutter run
```

Hoặc chạy trên thiết bị cụ thể:
```bash
flutter run -d <device-id>
```

### Bước 8: Cho phép Developer Mode (iOS 16+)

Nếu gặp lỗi về Developer Mode:

1. Trên iPhone, vào **Settings** (Cài đặt)
2. Tìm **Privacy & Security** (Quyền riêng tư & Bảo mật)
3. Cuộn xuống tìm **Developer Mode**
4. Bật **Developer Mode**
5. Khởi động lại iPhone
6. Khi khởi động lại, chọn **Turn On** khi được hỏi

### Chạy trên iOS Simulator (không cần iPhone thật)

1. Mở Xcode
2. **Xcode** > **Open Developer Tool** > **Simulator**
3. Chọn thiết bị simulator từ menu **Device**
4. Chạy:
   ```bash
   flutter run
   ```

Hoặc tạo và chạy simulator từ command line:
```bash
# Xem danh sách simulators
xcrun simctl list devices

# Khởi động simulator
open -a Simulator

# Chạy app
flutter run
```

## Troubleshooting iOS

### Không thấy thiết bị trong `flutter devices`

1. Đảm bảo iPhone đã được unlock
2. Chấp nhận "Trust This Computer" trên iPhone
3. Kiểm tra cáp USB (thử cáp khác)
4. Mở Xcode > Window > Devices and Simulators để kiểm tra
5. Restart iPhone và Mac

### Lỗi "No code signing identities found"

1. Mở `ios/Runner.xcworkspace` trong Xcode
2. Chọn **Runner** > **Signing & Capabilities**
3. Chọn **Team** (đăng nhập Apple ID nếu cần)
4. Xcode sẽ tự động tạo provisioning profile

### Lỗi "Developer Mode is disabled" (iOS 16+)

1. Trên iPhone: **Settings** > **Privacy & Security**
2. Bật **Developer Mode**
3. Khởi động lại iPhone
4. Chọn **Turn On** khi được hỏi

### Lỗi "Could not find a valid iOS Simulator"

```bash
# Mở Simulator
open -a Simulator

# Hoặc tạo simulator mới trong Xcode
# Xcode > Window > Devices and Simulators > + (Add)
```

### Lỗi "CocoaPods not installed"

```bash
sudo gem install cocoapods
cd ios
pod install
cd ..
```

### Lỗi "Xcode license not accepted"

```bash
sudo xcodebuild -license accept
```

### Lỗi "Command Line Tools not configured"

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

## Troubleshooting Android

### Không thấy thiết bị trong `flutter devices`

**Android:**
1. Đảm bảo USB debugging đã được bật
2. Thử rút và cắm lại cáp USB
3. Thử cáp USB khác
4. Kiểm tra driver USB trên Windows:
   - Vào Device Manager
   - Tìm Android device
   - Nếu có dấu chấm than, cài lại driver
5. Chạy `adb devices` để kiểm tra:
   ```bash
   adb devices
   ```
   Nếu thấy "unauthorized", chấp nhận trên điện thoại

**iOS:**
1. Đảm bảo đang dùng macOS
2. Cài đặt Xcode từ App Store
3. Chạy `sudo xcode-select --switch /Applications/Xcode.app`
4. Chấp nhận license: `sudo xcodebuild -license accept`

### Lỗi "No devices found"

1. Kiểm tra cáp USB
2. Thử chế độ USB khác (File Transfer thay vì Charging only)
3. Restart adb server:
   ```bash
   adb kill-server
   adb start-server
   ```

### Lỗi "Waiting for another flutter command to release the startup lock"

```bash
flutter clean
flutter pub get
flutter run
```

## Chạy qua WiFi

### Android 11+

Sau khi đã kết nối qua USB lần đầu:

1. Kết nối điện thoại và máy tính cùng một WiFi
2. Chạy:
   ```bash
   adb tcpip 5555
   adb connect <phone-ip-address>:5555
   ```
3. Rút cáp USB
4. Chạy `flutter run` như bình thường

### iOS (không hỗ trợ WiFi debugging)

iOS không hỗ trợ WiFi debugging như Android. Bạn phải kết nối qua USB hoặc dùng Simulator.

Sau khi đã kết nối qua USB lần đầu:

1. Kết nối điện thoại và máy tính cùng một WiFi
2. Chạy:
   ```bash
   adb tcpip 5555
   adb connect <phone-ip-address>:5555
   ```
3. Rút cáp USB
4. Chạy `flutter run` như bình thường

## Scripts hỗ trợ

### Windows (Android)
- `check-device.bat` - Kiểm tra thiết bị đã kết nối
- `run-on-phone.bat` - Chạy ứng dụng trên điện thoại

### macOS (iOS)
- `setup-ios.sh` - Cài đặt môi trường iOS
- `run-on-ios.sh` - Chạy ứng dụng trên iPhone

Để chạy script trên macOS:
```bash
chmod +x setup-ios.sh
chmod +x run-on-ios.sh
./setup-ios.sh
./run-on-ios.sh
```

## Lưu ý

### Android
- Lần đầu chạy có thể mất thời gian để build
- Đảm bảo điện thoại đã được unlock
- Có thể cần cài đặt driver từ nhà sản xuất (Samsung, Xiaomi, etc.)
- USB debugging phải được bật

### iOS
- **Chỉ chạy được trên macOS** (không thể trên Windows/Linux)
- Cần Xcode đã được cài đặt
- Cần Apple ID (miễn phí) để sign app
- iOS 16+ cần bật Developer Mode
- Lần đầu build có thể mất 10-15 phút
- Đảm bảo iPhone đã được unlock và trust computer

