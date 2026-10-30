import 'authentication_response.dart';
import 'coverage_response.dart';
import 'mobile_id_platform_interface.dart';

export 'authentication_response.dart';
export 'coverage_response.dart';
export 'error_codes.dart';

/// Target authentication environment.
enum Environment { sandbox, production }

/// Các phạm vi xác thực được hỗ trợ bởi MobileID.
enum MobileIdScope {
  phoneVerify,
  phone,
  mobileId,
  profile,
}

extension MobileIdScopeExtension on MobileIdScope {
  String get key {
    switch (this) {
      case MobileIdScope.phoneVerify:
        return 'phone_verify';
      case MobileIdScope.phone:
        return 'phone';
      case MobileIdScope.mobileId:
        return 'mobile_id';
      case MobileIdScope.profile:
        return 'profile';
    }
  }
}

/// MobileID authentication plugin.
class MobileId {
  Future<String?> getPlatformVersion() {
    return MobileIdPlatform.instance.getPlatformVersion();
  }

  Future<void> setAuthorizationServiceConfiguration(String fileName) {
    return MobileIdPlatform.instance.setAuthorizationServiceConfiguration(fileName);
  }

  Future<String?> getConfigurationByName(String configName) {
    return MobileIdPlatform.instance.getConfigurationByName(configName);
  }

  /// Resolve cấu hình SDK (IP client_id + redirect_uri + environment) từ backend
  /// tenant lúc runtime rồi tự áp dụng. Khách cung cấp [configUrl] — URL đầy đủ
  /// tới endpoint cấu hình của họ; SDK GET thẳng URL đó (không tự thêm path).
  /// Endpoint phải trả về { success, data: { payload } } — payload là blob mã hoá
  /// (AES-256-GCM) chứa ipClientId/ipRedirectUri/environment; native SDK tự giải mã.
  ///
  /// [headers] (tùy chọn) — header gắn vào request GET, ví dụ auth cho endpoint
  /// của khách: { "Authorization": "Bearer <token>" }. Không truyền → GET trần.
  Future<void> configure({
    required String configUrl,
    Map<String, String>? headers,
  }) {
    return MobileIdPlatform.instance.configure(configUrl, headers);
  }

  Future<void> setEnv(Environment env) {
    return MobileIdPlatform.instance.setEnv(env);
  }

  Future<void> setClientId(String clientId) {
    return MobileIdPlatform.instance.setClientId(clientId);
  }

  Future<void> setState({required String value}) {
    return MobileIdPlatform.instance.setState(value);
  }

  Future<void> setRedirectUri(String redirectUri) {
    return MobileIdPlatform.instance.setRedirectUri(redirectUri);
  }

  Future<void> setAuthorizationUrl(String authUrl) {
    return MobileIdPlatform.instance.setAuthorizationUrl(authUrl);
  }

  Future<String?> getClientId() {
    return MobileIdPlatform.instance.getClientId();
  }

  Future<String?> getRedirectUri() {
    return MobileIdPlatform.instance.getRedirectUri();
  }

  Future<String> generateState() {
    return MobileIdPlatform.instance.generateState();
  }

  Future<void> unregisterNetwork() {
    return MobileIdPlatform.instance.unregisterNetwork();
  }

  Future<void> addQueryParam({required String key, required String value}) {
    return MobileIdPlatform.instance.addQueryParam(key, value);
  }

  Future<void> setCheckCoverageUrl(String checkCoverageUrl) {
    return MobileIdPlatform.instance.setCheckCoverageUrl(checkCoverageUrl);
  }

  Future<CheckCoverageResponse> checkCoverage() {
    return MobileIdPlatform.instance.checkCoverage();
  }

  Future<CheckCoverageResponse> checkCoverageWithPhoneNumber(String phoneNumber) {
    return MobileIdPlatform.instance.checkCoverageWithPhoneNumber(phoneNumber);
  }

  /// Cấu hình single scope trước khi gọi xác thực (Mặc định: phoneVerify).
  Future<void> setScope(MobileIdScope scope) {
    return setScopes([scope]);
  }

  /// Cấu hình kết hợp nhiều scope trước khi gọi xác thực (vd: [phoneVerify, mobileId]).
  Future<void> setScopes(List<MobileIdScope> scopes) {
    final keys = scopes.map((s) => s.key).toList();
    return MobileIdPlatform.instance.setScopes(keys);
  }

  /// Xác thực với MobileID.
  /// Hỗ trợ truyền [scope] đơn lẻ hoặc danh sách [scopes] kết hợp, và [state] tùy chọn cho phiên xác thực.
  /// Khi dùng scope `phone` (Silent Login) hoặc `mobileId`, [loginHint] có thể để trống.
  Future<AuthenticationResponse> doAuthentication({
    String loginHint = '',
    MobileIdScope scope = MobileIdScope.phoneVerify,
    List<MobileIdScope>? scopes,
    String? state,
  }) {
    final effectiveScopes = (scopes != null && scopes.isNotEmpty) ? scopes : [scope];
    final keys = effectiveScopes.map((s) => s.key).toList();
    return MobileIdPlatform.instance.doAuthentication(loginHint, keys, state);
  }

  Future<void> enableLog() {
    return MobileIdPlatform.instance.enableLog();
  }

  Future<String?> getLog() {
    return MobileIdPlatform.instance.getLog();
  }

  Future<void> showNotification(
      String title, String message, String notificationFolder, String notificationIcon) {
    return MobileIdPlatform.instance.showNotification(title, message, notificationFolder, notificationIcon);
  }
}
