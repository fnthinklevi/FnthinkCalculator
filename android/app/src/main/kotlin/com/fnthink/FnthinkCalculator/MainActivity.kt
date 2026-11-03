package com.fnthink.FnthinkCalculator

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var shortcutChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        shortcutChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SHORTCUT_CHANNEL,
        ).also { channel ->
            channel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "getInitialShortcut" -> result.success(consumeShortcut())
                    else -> result.notImplemented()
                }
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        consumeShortcut()?.let { shortcut ->
            shortcutChannel?.invokeMethod("shortcut", shortcut)
        }
    }

    private fun consumeShortcut(): String? {
        val shortcut = intent?.getStringExtra(EXTRA_SHORTCUT_TYPE) ?: return null
        intent?.removeExtra(EXTRA_SHORTCUT_TYPE)
        return shortcut
    }

    companion object {
        private const val SHORTCUT_CHANNEL = "fnthink/app_shortcuts"
        private const val EXTRA_SHORTCUT_TYPE = "shortcut_type"
    }
}
