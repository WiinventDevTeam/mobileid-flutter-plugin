package vn.mobileid.mobileid.plugin

import android.app.Activity
import android.os.Build
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.concurrent.atomic.AtomicBoolean
import vn.mobileid.mobileid.AuthListener
import vn.mobileid.mobileid.MobileIdEnvironment
import vn.mobileid.mobileid.MobileIdError
import vn.mobileid.mobileid.MobileIdScope
import vn.mobileid.mobileid.MobileIdSdk

class MobileIdPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private companion object {
        const val CHANNEL_NAME = "mobile_id"

        fun mapScopeKey(key: String): MobileIdScope? = when (key.lowercase()) {
            "phone_verify" -> MobileIdScope.PHONE_VERIFY
            "phone" -> MobileIdScope.PHONE
            "mobile_id" -> MobileIdScope.MOBILE_ID
            "profile" -> MobileIdScope.PROFILE
            else -> null
        }
    }

    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var sdk: MobileIdSdk? = null
    private val authInProgress = AtomicBoolean(false)

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        sdk = MobileIdSdk(binding.activity)
    }

    override fun onDetachedFromActivity() {
        activity = null
        sdk = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }

    private fun authListener(result: Result) = object : AuthListener {
        override fun onSuccess(result_: String) {
            if (authInProgress.compareAndSet(true, false)) {
                activity?.runOnUiThread { result.success(result_) }
            }
        }

        override fun onFail(result_: MobileIdError) {
            if (authInProgress.compareAndSet(true, false)) {
                activity?.runOnUiThread {
                    result.error(result_.errorCode.code, result_.errorMessage, result_.rawResponse)
                }
            }
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        val sdk = this.sdk
        if (sdk == null) {
            result.error("NO_ACTIVITY", "Activity not available", null)
            return
        }

        when (call.method) {
            "getPlatformVersion" -> result.success("Android ${Build.VERSION.RELEASE}")
            "setEnv" -> {
                val env = call.argument<String>("value")
                sdk.setEnv(if (env == "production") MobileIdEnvironment.PRODUCTION else MobileIdEnvironment.SANDBOX)
                result.success(null)
            }
            "configure" -> {
                val configUrl = call.argument<String>("configUrl") ?: ""
                val headers = call.argument<Map<String, String>>("headers") ?: emptyMap()
                sdk.configure(
                    configUrl,
                    headers,
                    onSuccess = { ->
                        activity?.runOnUiThread { result.success(true) }
                    },
                    onError = { err: MobileIdError ->
                        activity?.runOnUiThread { result.error(err.errorCode.code, err.errorMessage, err.rawResponse) }
                    }
                )
            }
            "setClientId" -> {
                sdk.setClientId(call.argument<String>("value") ?: "")
                result.success(null)
            }
            "setRedirectUri" -> {
                sdk.setRedirectUri(call.argument<String>("value") ?: "")
                result.success(null)
            }
            "setCheckCoverageUrl" -> {
                sdk.setCheckCoverageUrl(call.argument<String>("value") ?: "")
                result.success(null)
            }
            "setAuthorizationUrl" -> {
                sdk.setAuthorizationUrl(call.argument<String>("value") ?: "")
                result.success(null)
            }
            "getClientId" -> result.success(sdk.getClientId())
            "getRedirectUri" -> result.success(sdk.getRedirectUri())
            "generateState" -> result.success(sdk.generateState())
            "setState" -> {
                sdk.setState(call.argument<String>("value") ?: "")
                result.success(null)
            }
            "addQueryParam" -> {
                sdk.addQueryParam(
                    call.argument<String>("key") ?: "",
                    call.argument<String>("value") ?: ""
                )
                result.success(null)
            }
            "enableLog" -> {
                sdk.enableLog()
                result.success(null)
            }
            "getLog" -> result.success(sdk.getLog())
            "unregisterNetwork" -> {
                sdk.unregisterNetwork()
                result.success(null)
            }
            "checkCoverage" -> {
                if (authInProgress.getAndSet(true)) return
                sdk.checkCoverage(
                    { res -> if (authInProgress.compareAndSet(true, false)) activity?.runOnUiThread { result.success(res) } },
                    { err -> if (authInProgress.compareAndSet(true, false)) activity?.runOnUiThread { result.error(err.errorCode.code, err.errorMessage, err.rawResponse) } }
                )
            }
            "checkCoverageWithPhoneNumber" -> {
                val phone = call.argument<String>("phone_number")
                if (phone.isNullOrEmpty()) {
                    result.error("invalid_parameter", "phoneNumber cannot be empty", null)
                    return
                }
                if (authInProgress.getAndSet(true)) return
                sdk.checkCoverageWithPhoneNumber(
                    phone,
                    { res -> if (authInProgress.compareAndSet(true, false)) activity?.runOnUiThread { result.success(res) } },
                    { err -> if (authInProgress.compareAndSet(true, false)) activity?.runOnUiThread { result.error(err.errorCode.code, err.errorMessage, err.rawResponse) } }
                )
            }
            "setScopes" -> {
                val scopesList = call.argument<List<String>>("scopes") ?: emptyList()
                val mappedScopes = scopesList.mapNotNull { mapScopeKey(it) }
                sdk.setScopes(mappedScopes)
                result.success(null)
            }
            "doAuthentication" -> {
                if (authInProgress.getAndSet(true)) return
                val loginHint = call.argument<String>("login_hint") ?: ""
                val scopesList = call.argument<List<String>>("scopes")
                val scopes = scopesList?.mapNotNull { mapScopeKey(it) } ?: listOf(MobileIdScope.PHONE_VERIFY)
                val state = call.argument<String>("state")
                sdk.doAuthentication(loginHint, scopes, state, authListener(result))
            }
            else -> result.notImplemented()
        }
    }
}
