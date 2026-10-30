import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'mobile_id.dart';
import 'mobile_id_method_channel.dart';

abstract class MobileIdPlatform extends PlatformInterface {
  MobileIdPlatform() : super(token: _token);

  static final Object _token = Object();

  static MobileIdPlatform _instance = MethodChannelMobileId();

  static MobileIdPlatform get instance => _instance;

  static set instance(MobileIdPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion();

  Future<void> setAuthorizationServiceConfiguration(String fileName);

  Future<String?> getConfigurationByName(String configName);

  Future<void> configure(String configUrl, Map<String, String>? headers);

  Future<void> setEnv(Environment env);

  Future<void> setClientId(String clientId);

  Future<void> setRedirectUri(String redirectUri);

  Future<void> setAuthorizationUrl(String authUrl);

  Future<void> setCheckCoverageUrl(String checkCoverageUrl);

  Future<String?> getClientId();

  Future<String?> getRedirectUri();

  Future<String> generateState();

  Future<void> addQueryParam(String key, String value);

  Future<void> setState(String value);

  Future<void> unregisterNetwork();

  Future<void> enableLog();

  Future<String> getLog();

  Future<void> showNotification(
      String title, String message, String notificationFolder, String notificationIcon);

  Future<CheckCoverageResponse> checkCoverage();

  Future<CheckCoverageResponse> checkCoverageWithPhoneNumber(String phoneNumber);

  Future<void> setScopes(List<String> scopes);

  Future<AuthenticationResponse> doAuthentication(String loginHint, [List<String>? scopes, String? state]);
}
