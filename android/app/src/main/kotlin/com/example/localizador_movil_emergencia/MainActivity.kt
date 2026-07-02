package com.example.localizador_movil_emergencia

import android.Manifest
import android.app.PendingIntent
import android.content.ContentValues
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.provider.Telephony
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
                "esAppSmsDefault" -> {
                    result.success(esAppSmsDefault())
                }
                "abrirAjustesSmsDefault" -> {
                    abrirAjustesSmsDefault()
                    result.success(true)
                }
                "abrirAppSms" -> {
                    val telefono = call.argument<String>("telefono") ?: ""
                    val mensaje = call.argument<String>("mensaje") ?: ""
                    abrirAppSms(telefono, mensaje)
                    result.success(true)
                }
                "traerAlFrente" -> {
                    traerAlFrente()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun esAppSmsDefault(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            Telephony.Sms.getDefaultSmsPackage(this) == packageName
        } else {
            false
        }
    }

    private fun abrirAjustesSmsDefault() {
        try {
            // Abrir ajustes de apps predeterminadas del sistema
            val intent = Intent(Settings.ACTION_MANAGE_DEFAULT_APPS_SETTINGS).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
            }
            startActivity(intent)
            android.util.Log.i("[SmsRepository]", "Abriendo ajustes de apps predeterminadas")
        } catch (e: Exception) {
            android.util.Log.e("[SmsRepository]", "Error abriendo ajustes", e)
        }
    }

    private fun traerAlFrente() {
        try {
            val intent = packageManager.getLaunchIntentForPackage(packageName)?.apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
                addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT)
                putExtra("reintentar_envio", true)
            }
            if (intent != null) {
                startActivity(intent)
                android.util.Log.i("[SmsRepository]", "App traída al frente")
            }
        } catch (e: Exception) {
            android.util.Log.e("[SmsRepository]", "Error trayendo app al frente", e)
        }
    }

    private fun abrirAppSms(telefono: String, mensaje: String) {
        try {
            val intent = Intent(Intent.ACTION_VIEW).apply {
                data = Uri.parse("sms:$telefono")
                putExtra("sms_body", mensaje)
                putExtra(Intent.EXTRA_TEXT, mensaje)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
            }
            startActivity(intent)
            android.util.Log.i("[SmsRepository]", "App de SMS abierta para $telefono")
        } catch (e: Exception) {
            android.util.Log.e("[SmsRepository]", "Error abriendo app SMS", e)
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

            // Método 1: SmsManager directo
            try {
                val smsManager = SmsManager.getDefault()
                val sentIntent = PendingIntent.getBroadcast(
                    this,
                    System.currentTimeMillis().toInt(),
                    Intent("SMS_SENT"),
                    PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
                )
                smsManager.sendTextMessage(telefono, null, mensaje, sentIntent, null)
                android.util.Log.i("[SmsRepository]", "SMS enviado por SmsManager a $telefono")
                result.success(true)
                return
            } catch (e: Exception) {
                android.util.Log.w("[SmsRepository]", "SmsManager falló: ${e.message}")
            }

            // Método 2: Insertar en bandeja de salida
            try {
                val values = ContentValues().apply {
                    put(Telephony.Sms.ADDRESS, telefono)
                    put(Telephony.Sms.BODY, mensaje)
                    put(Telephony.Sms.TYPE, Telephony.Sms.MESSAGE_TYPE_OUTBOX)
                    put(Telephony.Sms.STATUS, Telephony.Sms.STATUS_PENDING)
                    put(Telephony.Sms.DATE, System.currentTimeMillis())
                    put(Telephony.Sms.READ, 0)
                    put(Telephony.Sms.SEEN, 0)
                }
                contentResolver.insert(Telephony.Sms.CONTENT_URI, values)
                android.util.Log.i("[SmsRepository]", "SMS insertado en bandeja de salida para $telefono")
                result.success(true)
                return
            } catch (e: Exception) {
                android.util.Log.w("[SmsRepository]", "Inserción en bandeja falló: ${e.message}")
            }

            android.util.Log.e("[SmsRepository]", "Todos los métodos de envío fallaron")
            result.success(false)
        } catch (e: Exception) {
            android.util.Log.e("[SmsRepository]", "Error general", e)
            result.success(false)
        }
    }
}
