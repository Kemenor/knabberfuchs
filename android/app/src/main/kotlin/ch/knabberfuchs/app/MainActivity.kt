package ch.knabberfuchs.app

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// FlutterFragmentActivity (not FlutterActivity) is required by the health
// package so Health Connect's permission flow can use the Activity Result APIs.
class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Open an external URL in a NEW TASK. url_launcher launches from this
        // activity without FLAG_ACTIVITY_NEW_TASK, so a handing-off app (e.g.
        // Open Food Facts) stacks onto *our* task — reopening Knabberfuchs then
        // resurfaces the other app. NEW_TASK gives it its own task instead.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, INTENT_CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "openExternal") {
                    val url = call.argument<String>("url")
                    if (url.isNullOrEmpty()) {
                        result.error("no_url", "url is required", null)
                        return@setMethodCallHandler
                    }
                    try {
                        startActivity(
                            Intent(Intent.ACTION_VIEW, Uri.parse(url))
                                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        )
                        result.success(true)
                    } catch (e: Exception) {
                        result.success(false)
                    }
                } else {
                    result.notImplemented()
                }
            }
    }

    companion object {
        private const val INTENT_CHANNEL = "ch.knabberfuchs.app/intent"
    }
}
