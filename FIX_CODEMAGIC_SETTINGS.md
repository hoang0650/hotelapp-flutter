# Sửa lỗi Codemagic Settings - Shorebird Token

## Vấn đề

Trên trang Settings của Codemagic, gặp lỗi:
- "Could not save changes. Please fix 3 errors below"
- "Shorebird token is required"

## Nguyên nhân

Bạn đang cố gắng cấu hình **Shorebird** (OTA Updates), nhưng:
- Shorebird là tính năng **tùy chọn**, không bắt buộc
- Shorebird cần token riêng để sử dụng
- Bạn không cần Shorebird để build app thông thường

## Giải pháp

### Cách 1: Bỏ qua Shorebird (Khuyến nghị)

1. **Không cần cấu hình Shorebird**
   - Shorebird chỉ cần khi bạn muốn OTA updates (cập nhật app không qua store)
   - Để build và deploy bình thường, không cần Shorebird

2. **Sử dụng workflow từ codemagic.yaml**
   - Codemagic sẽ tự động đọc file `codemagic.yaml` trong repo
   - Không cần cấu hình qua UI

3. **Chạy build từ tab "Builds"**
   - Vào tab **Builds** (không phải Settings)
   - Chọn workflow từ `codemagic.yaml`
   - Click **Start new build**

### Cách 2: Xóa cấu hình Shorebird

1. Trong trang Settings:
   - Tìm phần **Shorebird [release]**
   - Bỏ chọn hoặc xóa cấu hình này
   - Click **Discard** để hủy thay đổi

2. Hoặc:
   - Không điền "Shorebird token"
   - Bỏ qua phần này hoàn toàn

### Cách 3: Sử dụng workflow thông thường

1. Vào tab **Builds** (không phải Settings)
2. Chọn workflow:
   - `hotelapp-android-debug` - Build Android debug (không cần signing)
   - `hotelapp-android` - Build Android release
   - `hotelapp-ios` - Build iOS
3. Click **Start new build**

## Hướng dẫn chi tiết

### Bước 1: Bỏ qua Settings page

1. **Không cần** vào Settings để cấu hình
2. File `codemagic.yaml` đã có đầy đủ cấu hình
3. Codemagic sẽ tự động đọc file này

### Bước 2: Chạy build từ Builds tab

1. Vào Codemagic dashboard
2. Click tab **Builds** (bên trái)
3. Bạn sẽ thấy các workflows từ `codemagic.yaml`:
   - `hotelapp-android-debug`
   - `hotelapp-android-ios`
   - `hotelapp-android`
   - `hotelapp-ios`

4. Chọn workflow muốn chạy
5. Click **Start new build**

### Bước 3: Chọn branch

1. Chọn branch (thường là `main` hoặc `master`)
2. Click **Start build**

## Lưu ý quan trọng

### ✅ Không cần Shorebird

- Shorebird chỉ dùng cho OTA updates
- Để build và deploy bình thường, **không cần** Shorebird
- Bỏ qua phần cấu hình Shorebird

### ✅ Sử dụng codemagic.yaml

- File `codemagic.yaml` đã có đầy đủ cấu hình
- Codemagic tự động đọc file này
- Không cần cấu hình qua UI

### ✅ Chạy build từ Builds tab

- Vào tab **Builds**, không phải Settings
- Chọn workflow từ danh sách
- Click **Start new build**

## Nếu vẫn muốn dùng Shorebird (Tùy chọn)

1. Đăng ký tài khoản Shorebird tại https://shorebird.dev/
2. Lấy token từ Shorebird dashboard
3. Điền token vào Codemagic Settings
4. Cấu hình Shorebird workflow

**Lưu ý**: Shorebird là dịch vụ trả phí, không miễn phí.

## Troubleshooting

### Lỗi "Could not save changes"

**Giải pháp**: 
- Click **Discard** để hủy thay đổi
- Không cần lưu Settings nếu không dùng Shorebird
- Chạy build từ tab **Builds** thay vì Settings

### Không thấy workflows

**Kiểm tra**:
1. File `codemagic.yaml` đã được commit và push chưa?
2. Codemagic đã kết nối với repo chưa?
3. Refresh trang Codemagic

### Build không chạy

**Kiểm tra**:
1. Đã chọn đúng workflow chưa?
2. Branch đã có code chưa?
3. Xem logs để biết lỗi cụ thể

## Tóm tắt

1. ✅ **Bỏ qua** phần Shorebird trong Settings
2. ✅ **Sử dụng** workflow từ `codemagic.yaml`
3. ✅ **Chạy build** từ tab **Builds**, không phải Settings
4. ✅ **Không cần** cấu hình gì thêm nếu đã có `codemagic.yaml`

## Next Steps

1. Click **Discard** trong Settings để hủy thay đổi
2. Vào tab **Builds**
3. Chọn workflow `hotelapp-android-debug`
4. Click **Start new build**
5. Build sẽ chạy thành công!

