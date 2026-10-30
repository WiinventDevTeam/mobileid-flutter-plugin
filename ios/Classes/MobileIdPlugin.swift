import Flutter
import UIKit
import MobileIdSdk

public class MobileIdPlugin: NSObject, FlutterPlugin {

  private let sdk = MobileID()

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "mobile_id", binaryMessenger: registrar.messenger())
    let instance = MobileIdPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as? [String: Any]

    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)

    case "checkCoverage":
      sdk.checkCoverage(success: { result($0) },
                        fail: { result(FlutterError(code: $0.code, message: $0.errorMessage, details: $0.rawResponse)) })

    case "checkCoverageWithPhoneNumber":
      guard let phoneNumber = args?["phone_number"] as? String, !phoneNumber.isEmpty else {
        result(FlutterError(code: "validation_failed", message: "phone_number cannot be empty", details: nil))
        return
      }
      sdk.checkCoverageWithPhoneNumber(phoneNumber,
                                       success: { result($0) },
                                       fail: { result(FlutterError(code: $0.code, message: $0.errorMessage, details: $0.rawResponse)) })

    case "setScopes":
      let scopesList = args?["scopes"] as? [String] ?? []
      let mapped = scopesList.compactMap { mapScopeKey($0) }
      sdk.setScopes(mapped)
      result(nil)

    case "doAuthentication":
      let loginHint = args?["login_hint"] as? String ?? ""
      let scopesList = args?["scopes"] as? [String]
      let scopes: [MobileIdScope] = scopesList?.compactMap { mapScopeKey($0) } ?? [.phoneVerify]
      let state = args?["state"] as? String
      sdk.doAuthentication(loginHint: loginHint,
                           scopes: scopes,
                           state: state,
                           success: { result($0) },
                           fail: { result(FlutterError(code: $0.code, message: $0.errorMessage, details: $0.rawResponse)) })

    case "addQueryParam":
      if let key = args?["key"] as? String, let value = args?["value"] as? String {
        sdk.addQueryParam(key: key, value: value)
      }
      result(nil)

    case "setState":
      sdk.setState(args?["value"] as? String ?? "")
      result(nil)

    case "getConfiguration":
      result(sdk.getConfigurationByName(args?["config_name"] as? String))

    case "getClientId":
      result(sdk.getClientId())

    case "getRedirectUri":
      result(sdk.getRedirectUri())

    case "setClientId":
      if let value = args?["value"] as? String { sdk.setClientId(value) }
      result(nil)

    case "setRedirectUri":
      if let value = args?["value"] as? String { sdk.setRedirectUri(value) }
      result(nil)

    case "setEnv":
      if let value = args?["value"] as? String {
        sdk.setEnv(value == "production" ? .production : .sandbox)
      }
      result(nil)

    case "configure":
      let configUrl = args?["configUrl"] as? String ?? ""
      let headers = args?["headers"] as? [String: String] ?? [:]
      sdk.configure(configUrl: configUrl,
                    headers: headers,
                    success: { result(nil) },
                    fail: { result(FlutterError(code: $0.code, message: $0.errorMessage, details: $0.rawResponse)) })

    case "setCheckCoverageUrl":
      if let value = args?["value"] as? String { sdk.setCheckCoverageUrl(value) }
      result(nil)

    case "setAuthorizationUrl":
      if let value = args?["value"] as? String { sdk.setAuthorizationUrl(value) }
      result(nil)

    case "generateState":
      result(sdk.generateState())

    case "showNotification":
      result(nil)

    case "unregisterNetwork":
      result(nil)

    case "enableLog":
      sdk.enableLog()
      result(nil)

    case "getLog":
      result(sdk.getLog())

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func mapScopeKey(_ key: String) -> MobileIdScope? {
    switch key.lowercased() {
    case "phone_verify": return .phoneVerify
    case "phone": return .phone
    case "mobile_id": return .mobileId
    case "profile": return .profile
    default: return nil
    }
  }
}
