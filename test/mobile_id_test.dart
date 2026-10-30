import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_id/mobile_id.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('mobile_id');
  final List<MethodCall> log = <MethodCall>[];

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      log.add(methodCall);
      switch (methodCall.method) {
        case 'setScopes':
          return null;
        case 'doAuthentication':
          return 'https://example.com/callback?code=mock_code&state=mock_state';
        default:
          return null;
      }
    });
    log.clear();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('MobileIdScope enum has correct key values', () {
    expect(MobileIdScope.phoneVerify.key, 'phone_verify');
    expect(MobileIdScope.phone.key, 'phone');
    expect(MobileIdScope.mobileId.key, 'mobile_id');
    expect(MobileIdScope.profile.key, 'profile');
  });

  test('setScope invokes setScopes with single key', () async {
    final mobileId = MobileId();
    await mobileId.setScope(MobileIdScope.phone);

    expect(log, hasLength(1));
    expect(log.first.method, 'setScopes');
    expect(log.first.arguments, {'scopes': ['phone']});
  });

  test('setScopes invokes setScopes with multiple keys', () async {
    final mobileId = MobileId();
    await mobileId.setScopes([MobileIdScope.phoneVerify, MobileIdScope.mobileId]);

    expect(log, hasLength(1));
    expect(log.first.method, 'setScopes');
    expect(log.first.arguments, {'scopes': ['phone_verify', 'mobile_id']});
  });

  test('doAuthentication defaults to phoneVerify scope', () async {
    final mobileId = MobileId();
    final res = await mobileId.doAuthentication(loginHint: '84901234567');

    expect(res.code, 'mock_code');
    expect(res.state, 'mock_state');
    expect(log, hasLength(1));
    expect(log.first.method, 'doAuthentication');
    expect(log.first.arguments, {
      'login_hint': '84901234567',
      'scopes': ['phone_verify'],
    });
  });

  test('doAuthentication with explicit single scope and empty loginHint', () async {
    final mobileId = MobileId();
    final res = await mobileId.doAuthentication(scope: MobileIdScope.phone);

    expect(res.code, 'mock_code');
    expect(log, hasLength(1));
    expect(log.first.method, 'doAuthentication');
    expect(log.first.arguments, {
      'login_hint': '',
      'scopes': ['phone'],
    });
  });

  test('doAuthentication with multiple scopes', () async {
    final mobileId = MobileId();
    final res = await mobileId.doAuthentication(
      loginHint: '84901234567',
      scopes: [MobileIdScope.phoneVerify, MobileIdScope.mobileId],
    );

    expect(res.code, 'mock_code');
    expect(log, hasLength(1));
    expect(log.first.method, 'doAuthentication');
    expect(log.first.arguments, {
      'login_hint': '84901234567',
      'scopes': ['phone_verify', 'mobile_id'],
    });
  });

  test('enableLog, setState, addQueryParam complete Futures properly', () async {
    final mobileId = MobileId();
    await mobileId.enableLog();
    await mobileId.setState(value: 'custom_state');
    await mobileId.addQueryParam(key: 'k', value: 'v');

    expect(log.map((c) => c.method).toList(), [
      'enableLog',
      'setState',
      'addQueryParam',
    ]);
  });
}
