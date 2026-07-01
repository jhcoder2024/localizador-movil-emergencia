package com.example.localizador_movil_emergencia

import android.Manifest
import android.content.pm.PackageManager
import android.telephony.SmsManager
import androidx.core.app.ActivityCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.localizador_movil_emergencia/sms"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "sendSms" -> {
                    val telefono = call.argument<String>("telefono") ?: ""
                    val mensaje = call.argument<String>("mensaje") ?: ""
                    enviarSms(telefono, mensaje, result)
                }
                "estaDisponible" -> {
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun enviarSms(telefono: String, mensaje: String, result: MethodChannel.Result) {
        try {
            if (ActivityCompat.checkSelfPermission(this, Manifest.permission.SEND_SMS)
                != PackageManager.PERMISSION_GRANTED
            ) {
                android.util.Log.w("[SmsRepository]", "Permiso SEND_SMS no concedido")
                result.success(false)
                return
            }

            val smsManager = SmsManager.getDefault()
            smsManager.sendTextMessage(telefono, null, mensaje, null, null)
            android.util.Log.i("[SmsRepository]", "SMS enviado a $telefono")
            result.success(true)
        } catch (e: Exception) {
            android.util.Log.e("[SmsRepository]", "Error enviando SMS", e)
            result.success(false)
        }
    }
}
