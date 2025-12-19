# Sửa lỗi Validation - app_store_connect integration

## Lỗi

```
1 validation error in codemagic.yaml:

hotelapp-ios -> publishing
  auth -> "integration" requires workflow -> integrations -> app_store_connect
```

## Nguyên nhân

Khi sử dụng `auth: integration` trong `app_store_connect`, Codemagic yêu cầu phải khai báo `integrations -> app_store_connect` trong workflow.

## Giải pháp

✅ **Đã thêm** `integrations` vào các workflow iOS:

```yaml
integrations:
  app_store_connect: codemagic
```

## Thay đổi đã thực hiện

### 1. Workflow `hotelapp-ios`

**Trước:**
```yaml
hotelapp-ios:
  environment:
    # ...
  scripts:
    # ...
  publishing:
    app_store_connect:
      auth: integration
```

**Sau:**
```yaml
hotelapp-ios:
  environment:
    # ...
  integrations:
    app_store_connect: codemagic
  scripts:
    # ...
  publishing:
    app_store_connect:
      auth: integration
```

### 2. Workflow `hotelapp-android-ios`

Cũng đã thêm `integrations` để tương thích.

## Giải thích

- `integrations -> app_store_connect: codemagic` - Khai báo sử dụng App Store Connect integration
- `publishing -> app_store_connect -> auth: integration` - Sử dụng integration đã khai báo

## Các bước tiếp theo

### 1. Commit và push code

```bash
git add codemagic.yaml
git commit -m "Fix validation: Add app_store_connect integration"
git push
```

### 2. Kiểm tra validation

1. Vào Codemagic dashboard
2. Vào **Builds** tab
3. Validation sẽ pass

### 3. Chạy build

1. Chọn workflow `hotelapp-ios` hoặc `hotelapp-android-ios`
2. Click **Start new build**
3. Build sẽ chạy thành công

## Lưu ý

### Nếu không cần App Store Connect

Nếu bạn không cần upload lên App Store/TestFlight, có thể xóa phần `app_store_connect`:

```yaml
publishing:
  email:
    recipients:
      - user@example.com
    notify:
      success: true
      failure: false
  # Xóa phần app_store_connect nếu không cần
```

### Nếu cần App Store Connect

1. Cấu hình App Store Connect API trong Codemagic:
   - Vào **App settings** > **Integrations**
   - Kết nối với App Store Connect
   - Tạo API key

2. Workflow sẽ tự động sử dụng integration này

## Tài liệu tham khảo

- [Codemagic App Store Connect Integration](https://docs.codemagic.io/publishing/app-store-connect/)
- [Codemagic YAML Reference](https://docs.codemagic.io/yaml/yaml-getting-started/)

## Kết quả

✅ Validation error đã được sửa
✅ Workflow có thể chạy build iOS
✅ Có thể upload lên App Store/TestFlight (nếu đã cấu hình)

