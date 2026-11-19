package ch.knabberfuchs.app

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import androidx.activity.enableEdgeToEdge
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// FlutterFragmentActivity (not FlutterActivity) is required by the health
// package so Health Connect's permission flow can use the Activity Result APIs.
class MainActivity : FlutterFragmentActivity() {
    /// Text shared in (ACTION_SEND text/plain) that Dart hasn't taken yet.
    /// Dart pulls it with `takeSharedText` — on start, and whenever we signal
    /// `shareReady` — so a share that arrives before Flutter is up isn't lost.
    private var pendingShare: String? = null
    private var channel: MethodChannel? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        // Edge-to-edge on every Android version, not only 15+ (where SDK 35
        // forces it) — Flutter already pads for the insets via SafeArea.
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)
        // Only a fresh launch carries a new share; a recreated activity
        // (rotation, process restore) must not import the same text again.
        if (savedInstanceState == null) captureShare(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        // singleTop: a share while the app is running lands here.
        if (captureShare(intent)) channel?.invokeMethod("shareReady", null)
    }

    private fun captureShare(intent: Intent?): Boolean {
        if (intent?.action != Intent.ACTION_SEND || intent.type != "text/plain") {
            return false
        }
        val text = intent.getStringExtra(Intent.EXTRA_TEXT)
        if (text.isNullOrBlank()) return false
        pendingShare = text
        return true
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, INTENT_CHANNEL)
        channel!!.setMethodCallHandler { call, result ->
            when (call.method) {
                // Open an external URL in a NEW TASK. url_launcher launches from
                // this activity without FLAG_ACTIVITY_NEW_TASK, so a handing-off
                // app (e.g. Open Food Facts) stacks onto *our* task — reopening
                // Knabberfuchs then resurfaces the other app. NEW_TASK gives it
                // its own task instead.
                "openExternal" -> {
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
                }
                // Hand over (and forget) text shared in from another app.
                "takeSharedText" -> {
                    result.success(pendingShare)
                    pendingShare = null
                }
                else -> result.notImplemented()
            }
        }
    }

    companion object {
        private const val INTENT_CHANNEL = "ch.knabberfuchs.app/intent"
    }
}
