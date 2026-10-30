# MobileID Flutter Plugin

Plugin Flutter cung cấp xác thực số điện thoại di động dưới thương hiệu **MobileID**. Bọc quanh hai SDK native `mobile-id-android` và `mobile-id-ios`.

## Tính năng

- **Xác thực qua mạng di động (cellular)**: xác minh số điện thoại trực tiếp qua 3G/4G/5G, không cần OTP.
- **Kiểm tra vùng phủ (coverage)**: kiểm tra thuê bao có hỗ trợ xác thực mạng di động hay không.

## Cài đặt

```yaml
dependencies:
  mobile_id:
    git:
      url: https://github.com/WiinventDevTeam/mobileid-flutter-plugin.git
      ref: 1.1.0
```

Plugin tự kéo SDK native MobileID về. Bạn chỉ cần thêm một cấu hình cho Android:

- **Android**: SDK native phân phối qua Maven repo của MobileID. Thêm repo vào `settings.gradle` của app:

  ```gradle
  dependencyResolutionManagement {
      repositories {
          google()
          mavenCentral()
          maven { url "https://raw.githubusercontent.com/WiinventDevTeam/mobileid-android-sdk/main/maven" }
      }
  }
  ```

- **iOS**: framework native đã đóng gói sẵn trong plugin — chỉ cần `pod install`, không phải sửa `Podfile`.

## Sử dụng nhanh

Cấu hình SDK được nạp từ backend lúc runtime qua `configure(configUrl:)` — app
không hardcode client_id/redirect_uri. Trỏ `configUrl` tới endpoint cấu hình của
backend bạn.

```dart
import 'package:mobile_id/mobile_id.dart';

final mobileId = MobileId();

// 1. Nạp cấu hình từ backend (client_id, redirect_uri, environment).
await mobileId.configure(configUrl: 'https://your-backend.com/api/sdk-config');

// 2. Kiểm tra nhà mạng có hỗ trợ không.
final coverage = await mobileId.checkCoverageWithPhoneNumber('84901234567');
if (coverage.isAvailable) {
  // 3. Xác thực qua mạng di động.
  final auth = await mobileId.doAuthentication(loginHint: '84901234567');

  // 4. Đổi auth.code lấy token qua backend của bạn.
}
```

`configure` nhận thêm tham số `headers` (tùy chọn) nếu endpoint của bạn yêu cầu
header auth riêng (vd `Authorization`).

Xem app minh họa đầy đủ trong [example/](example/).

> **Lưu ý**: Xác thực qua mạng di động yêu cầu thiết bị kết nối **dữ liệu di động thật (3G/4G/5G)**. Không hoạt động trên Wifi hoặc Simulator.
