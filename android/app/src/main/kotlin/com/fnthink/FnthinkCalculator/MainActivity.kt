package com.fnthink.FnthinkCalculator

import android.os.Bundle
import android.speech.tts.TextToSpeech
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Locale

class MainActivity : FlutterActivity() {
    private var tts: TextToSpeech? = null
    private var ready = false
    private var chinese = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        tts = TextToSpeech(this) { status ->
            if (status == TextToSpeech.SUCCESS) {
                val result = tts?.setLanguage(Locale.SIMPLIFIED_CHINESE)
                chinese = result == TextToSpeech.LANG_COUNTRY_AVAILABLE ||
                    result == TextToSpeech.LANG_AVAILABLE ||
                    result == TextToSpeech.LANG_COUNTRY_VAR_AVAILABLE
                tts?.setSpeechRate(0.9f)
                ready = true
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.fnthink.FnthinkCalculator/tts",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "isAvailable" -> result.success(ready && chinese)
                "speak" -> {
                    val text = call.argument<String>("text") ?: ""
                    val ok = ready && chinese && text.isNotEmpty()
                    if (ok) {
                        tts?.speak(text, TextToSpeech.QUEUE_FLUSH, null, "calc-voice")
                    }
                    result.success(ok)
                }
                "stop" -> {
                    tts?.stop()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        tts?.stop()
        tts?.shutdown()
        tts = null
        super.onDestroy()
    }
}
