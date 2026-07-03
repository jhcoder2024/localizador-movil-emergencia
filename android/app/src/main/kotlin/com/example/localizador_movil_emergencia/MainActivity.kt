package com.example.localizador_movil_emergencia

import android.Manifest
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.ContentValues
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.provider.Telephony
import android.telephony.SmsManager
import androidx.core.app.ActivityCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.localizador_movil_emergencia/sms"
    private var smsEventSink: EventChannel.EventSink? = null

    private val internalSmsReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            val action = intent.action
            if (action == "SMS_RECEIVED_INTERNAL") {
                val smsData = intent.getSerializableExtra("sms_data") as? Map<String, Any>
                if (smsData != null) {
                    smsEventSink?.success(smsData)
                }
            }
        }
    }

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
                "solicitarSerSmsDefault" -> {
                    solicitarSerSmsDefault(result)
                }
                "abrirAppSms" -> {
                    val telefono = call.argument<String>("telefono") ?: ""
                    val mensaje = call.argument<String>("mensaje") ?: ""
                    abrirAppSms(telefono, mensaje)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example.localizador_movil_emergencia/sms_sync").setMethodCallHandler { call, result ->
            when (call.method) {
                "getAllSms" -> {
                    getAllSms(result)
                }
                "getNewSms" -> {
                    val sinceTimestamp = call.argument<Long>("sinceTimestamp") ?: 0L
                    getNewSms(sinceTimestamp, result)
                }
                "markAsReadInSystem" -> {
                    val conversationId = call.argument<String>("conversationId") ?: ""
                    markAsReadInSystem(conversationId, result)
                }
                else -> result.notImplemented()
            }
        }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example.localizador_movil_emergencia/sms_events").setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                    smsEventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    smsEventSink = null
                }
            }
        )
    }

    private fun esAppSmsDefault(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            Telephony.Sms.getDefaultSmsPackage(this) == packageName
        } else {
            true
        }
    }

    private fun solicitarSerSmsDefault(result: MethodChannel.Result) {
        if (esAppSmsDefault()) {
            result.success(true)
            return
        }

        try {
            // Abrir directamente la página de configuración de apps predeterminadas
            // Este método funciona en TODOS los Android sin excepción
            val intent = Intent(Settings.ACTION_MANAGE_DEFAULT_APPS_SETTINGS).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
            }
            startActivity(intent)
            android.util.Log.i("[SmsRepository]", "Ajustes de apps predeterminadas abiertos")
            result.success(true)
        } catch (e: Exception) {
            android.util.Log.e("[SmsRepository]", "Error abriendo ajustes", e)
            // Último recurso: abrir ajustes generales
            try {
                val intent = Intent(Settings.ACTION_SETTINGS).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                startActivity(intent)
                result.success(true)
            } catch (e2: Exception) {
                android.util.Log.e("[SmsRepository]", "Error fatal", e2)
                result.success(false)
            }
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

    override fun onResume() {
        super.onResume()
        val filter = IntentFilter("SMS_RECEIVED_INTERNAL")
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(internalSmsReceiver, filter, Context.RECEIVER_EXPORTED)
        } else {
            @Suppress("DEPRECATION")
            registerReceiver(internalSmsReceiver, filter)
        }
    }

    override fun onPause() {
        super.onPause()
        try {
            unregisterReceiver(internalSmsReceiver)
        } catch (e: Exception) {}
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

    private fun getAllSms(result: MethodChannel.Result) {
        try {
            if (ActivityCompat.checkSelfPermission(this, Manifest.permission.READ_SMS)
                != PackageManager.PERMISSION_GRANTED
            ) {
                result.success(emptyList<Any>())
                return
            }

            val smsList = mutableListOf<Map<String, Any?>>()
            val cursor = contentResolver.query(
                Telephony.Sms.CONTENT_URI,
                null, null, null,
                "date ASC"
            )

            cursor?.use {
                while (it.moveToNext()) {
                    val sms = mapOf(
                        "id" to it.getLong(it.getColumnIndexOrThrow("_id")),
                        "address" to (it.getString(it.getColumnIndexOrThrow("address")) ?: ""),
                        "body" to (it.getString(it.getColumnIndexOrThrow("body")) ?: ""),
                        "date" to it.getLong(it.getColumnIndexOrThrow("date")),
                        "type" to it.getInt(it.getColumnIndexOrThrow("type")),
                        "read" to it.getInt(it.getColumnIndexOrThrow("read")),
                        "threadId" to it.getLong(it.getColumnIndexOrThrow("thread_id"))
                    )
                    smsList.add(sms)
                }
            }

            result.success(smsList)
        } catch (e: Exception) {
            android.util.Log.e("[SmsSync]", "Error getAllSms", e)
            result.success(emptyList<Any>())
        }
    }

    private fun getNewSms(sinceTimestamp: Long, result: MethodChannel.Result) {
        try {
            if (ActivityCompat.checkSelfPermission(this, Manifest.permission.READ_SMS)
                != PackageManager.PERMISSION_GRANTED
            ) {
                result.success(emptyList<Any>())
                return
            }

            val smsList = mutableListOf<Map<String, Any?>>()
            val cursor = contentResolver.query(
                Telephony.Sms.CONTENT_URI,
                null,
                "date > ?",
                arrayOf(sinceTimestamp.toString()),
                "date ASC"
            )

            cursor?.use {
                while (it.moveToNext()) {
                    val sms = mapOf(
                        "id" to it.getLong(it.getColumnIndexOrThrow("_id")),
                        "address" to (it.getString(it.getColumnIndexOrThrow("address")) ?: ""),
                        "body" to (it.getString(it.getColumnIndexOrThrow("body")) ?: ""),
                        "date" to it.getLong(it.getColumnIndexOrThrow("date")),
                        "type" to it.getInt(it.getColumnIndexOrThrow("type")),
                        "read" to it.getInt(it.getColumnIndexOrThrow("read")),
                        "threadId" to it.getLong(it.getColumnIndexOrThrow("thread_id"))
                    )
                    smsList.add(sms)
                }
            }

            result.success(smsList)
        } catch (e: Exception) {
            android.util.Log.e("[SmsSync]", "Error getNewSms", e)
            result.success(emptyList<Any>())
        }
    }

    private fun markAsReadInSystem(conversationId: String, result: MethodChannel.Result) {
        try {
            if (ActivityCompat.checkSelfPermission(this, Manifest.permission.READ_SMS)
                != PackageManager.PERMISSION_GRANTED
            ) {
                result.success(false)
                return
            }

            // Buscar SMS de ese número y marcarlos como leídos
            val values = ContentValues().apply {
                put(Telephony.Sms.READ, 1)
            }
            val updated = contentResolver.update(
                Telephony.Sms.CONTENT_URI,
                values,
                "address = ? AND read = 0",
                arrayOf(conversationId)
            )
            android.util.Log.i("[SmsSync]", "Marcados $updated SMS como leídos para $conversationId")
            result.success(true)
        } catch (e: Exception) {
            android.util.Log.e("[SmsSync]", "Error markAsReadInSystem", e)
            result.success(false)
        }
    }
}
