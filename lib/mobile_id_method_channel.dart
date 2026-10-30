import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import 'mobile_id.dart';
import 'mobile_id_platform_interface.dart';

/// An implementation of [MobileIdPlatform] that uses method channels.
class MethodChannelMobileId extends MobileIdPlatform {
  static const MethodChannel _channel = MethodChannel('mobile_id');

  @override
  Future<String?> getPlatformVersion() async {
    return _channel.invokeMethod<String>('getPlatformVersion');
  }

  @override
  Future<void> setAuthorizationServiceConfiguration(String fileName) async {
    await _channel.invokeMethod('setConfiguration', {'config_file_name': fileName});
  }

  @override
  Future<String?> getConfigurationByName(String configName) async {
    return _channel.invokeMethod<String>('getConfiguration', {'config_name': configName});
  }

  @override
  Future<void> configure(String configUrl, Map<String, String>? headers) async {
    await _channel.invokeMethod('configure', {
      'configUrl': configUrl,
      'headers': headers ?? <String, String>{},
    });
  }

  @override
  Future<void> setEnv(Environment env) async {
    await _channel.invokeMethod<String>(
      'setEnv',
      {'value': env == Environment.production ? 'production' : 'sandbox'},
    );
  }

  @override
  Future<void> setClientId(String clientId) async {
    await _channel.invokeMethod('setClientId', {'value': clientId});
  }

  @override
  Future<void> setRedirectUri(String redirectUri) async {
    await _channel.invokeMethod('setRedirectUri', {'value': redirectUri});
  }

  @override
  Future<void> setAuthorizationUrl(String authUrl) async {
    await _channel.invokeMethod('setAuthorizationUrl', {'value': authUrl});
  }

  @override
  Future<void> setCheckCoverageUrl(String checkCoverageUrl) async {
    await _channel.invokeMethod('setCheckCoverageUrl', {'value': checkCoverageUrl});
  }

  @override
  Future<String?> getClientId() async {
    return _channel.invokeMethod<String>('getClientId');
  }

  @override
  Future<String?> getRedirectUri() async {
    return _channel.invokeMethod<String>('getRedirectUri');
  }

  @override
  Future<String> generateState() async {
    final result = await _channel.invokeMethod<String>('generateState');
    return result ?? _generateRandomString(100);
  }

  String _generateRandomString(int length) {
    final random = Random.secure();
    final values = List<int>.generate(length, (i) => random.nextInt(255));
    return base64UrlEncode(values);
  }

  @override
  Future<void> addQueryParam(String key, String value) async {
    await _channel.invokeMethod('addQueryParam', {'key': key, 'value': value});
  }

  @override
  Future<CheckCoverageResponse> checkCoverage() async {
    final resultJson = await _channel.invokeMethod<String>('checkCoverage');
    return CheckCoverageResponse.fromJson(resultJson);
  }

  @override
  Future<CheckCoverageResponse> checkCoverageWithPhoneNumber(String phoneNumber) async {
    final resultJson = await _channel.invokeMethod<String>(
      'checkCoverageWithPhoneNumber',
      {'phone_number': phoneNumber},
    );
    return CheckCoverageResponse.fromJson(resultJson);
  }

  @override
  Future<void> setScopes(List<String> scopes) async {
    await _channel.invokeMethod<void>('setScopes', {'scopes': scopes});
  }

  @override
  Future<AuthenticationResponse> doAuthentication(String loginHint, [List<String>? scopes, String? state]) async {
    final resultJson = await _channel.invokeMethod('doAuthentication', {
      'login_hint': loginHint,
      if (scopes != null) 'scopes': scopes,
      if (state != null) 'state': state,
    });
    return AuthenticationResponse.fromUri(resultJson);
  }

  @override
  Future<void> enableLog() async {
    await _channel.invokeMethod<String>('enableLog');
  }

  @override
  Future<String> getLog() async {
    final result = await _channel.invokeMethod<String>('getLog');
    return result ?? '';
  }

  @override
  Future<void> setState(String value) async {
    await _channel.invokeMethod('setState', {'value': value});
  }

  @override
  Future<void> showNotification(
      String title, String message, String notificationFolder, String notificationIcon) async {
    await _channel.invokeMethod<String>('showNotification', {
      'title': title,
      'message': message,
      'notificationFolder': notificationFolder,
      'notificationIcon': notificationIcon,
    });
  }

  @override
  Future<void> unregisterNetwork() async {
    await _channel.invokeMethod('unregisterNetwork');
  }
}
