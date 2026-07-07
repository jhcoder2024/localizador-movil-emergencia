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
import android.os.Bundle
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

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example.localizador_movil_emergencia/widget").setMethodCallHandler { call, result ->
            when (call.method) {
                "shouldActivateEmergency" -> result.success(false)
                else -> result.notImplemented()
            }
        }

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
                "getAllMms" -> {
                    getAllMms(result)
                }
                "markAsReadInSystem" -> {
                    val conversationId = call.argument<String>("conversationId") ?: ""
                    markAsReadInSystem(conversationId, result)
                }
                "sendSmsFromInbox" -> {
                    val telefono = call.argument<String>("telefono") ?: ""
                    val mensaje = call.argument<String>("mensaje") ?: ""
                    val smsId = call.argument<Int>("smsId") ?: 0
                    sendSmsFromInbox(telefono, mensaje, smsId, result)
                }
                "sendMms" -> {
                    val telefono = call.argument<String>("telefono") ?: ""
                    val imagePath = call.argument<String>("imagePath") ?: ""
                    sendMms(telefono, imagePath, result)
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

    override fun onDestroy() {
        super.onDestroy()
        try {
            unregisterReceiver(internalSmsReceiver)
        } catch (e: Exception) {}
    }

    override fun onTrimMemory(level: Int) {
        super.onTrimMemory(level)
        if (level >= TRIM_MEMORY_UI_HIDDEN) {
            try {
                val serviceIntent = Intent(this, id.flutter.flutter_background_service.BackgroundService::class.java)
                stopService(serviceIntent)
            } catch (e: Exception) {}
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
            val sentIntent = PendingIntent.getBroadcast(
                this,
                System.currentTimeMillis().toInt(),
                Intent("SMS_SENT"),
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
            )
            smsManager.sendTextMessage(telefono, null, mensaje, sentIntent, null)

            // Insertar en ContentProvider para consistencia
            try {
                val values = ContentValues().apply {
                    put(Telephony.Sms.ADDRESS, telefono)
                    put(Telephony.Sms.BODY, mensaje)
                    put(Telephony.Sms.TYPE, Telephony.Sms.MESSAGE_TYPE_SENT)
                    put(Telephony.Sms.DATE, System.currentTimeMillis())
                    put(Telephony.Sms.READ, 1)
                }
                contentResolver.insert(Telephony.Sms.CONTENT_URI, values)
            } catch (e: Exception) {
                android.util.Log.w("[SmsRepository]", "Error insertando en ContentProvider: ${e.message}")
            }

            android.util.Log.i("[SmsRepository]", "SMS enviado a $telefono")
            result.success(true)
        } catch (e: Exception) {
            android.util.Log.e("[SmsRepository]", "Error enviando SMS", e)
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

    private fun sendSmsFromInbox(telefono: String, mensaje: String, smsId: Int, result: MethodChannel.Result) {
        try {
            if (ActivityCompat.checkSelfPermission(this, Manifest.permission.SEND_SMS)
                != PackageManager.PERMISSION_GRANTED
            ) {
                result.success(mapOf("exito" to false, "error" to "Permiso SEND_SMS no concedido"))
                return
            }

            val smsManager = SmsManager.getDefault()
            val sentIntent = PendingIntent.getBroadcast(
                this,
                smsId,
                Intent("SMS_SENT").apply { putExtra("sms_id", smsId) },
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
            )
            smsManager.sendTextMessage(telefono, null, mensaje, sentIntent, null)

            // Insertar en ContentProvider de Android para consistencia
            try {
                val values = ContentValues().apply {
                    put(Telephony.Sms.ADDRESS, telefono)
                    put(Telephony.Sms.BODY, mensaje)
                    put(Telephony.Sms.TYPE, Telephony.Sms.MESSAGE_TYPE_SENT)
                    put(Telephony.Sms.DATE, System.currentTimeMillis())
                    put(Telephony.Sms.READ, 1)
                }
                contentResolver.insert(Telephony.Sms.CONTENT_URI, values)
            } catch (e: Exception) {
                android.util.Log.w("[SmsInbox]", "Error insertando en ContentProvider: ${e.message}")
            }

            result.success(mapOf("exito" to true, "error" to null))
        } catch (e: Exception) {
            android.util.Log.e("[SmsInbox]", "Error sendSmsFromInbox", e)
            result.success(mapOf("exito" to false, "error" to e.message))
        }
    }

    private fun getAllMms(result: MethodChannel.Result) {
        try {
            if (ActivityCompat.checkSelfPermission(this, Manifest.permission.READ_SMS)
                != PackageManager.PERMISSION_GRANTED
            ) {
                result.success(emptyList<Any>())
                return
            }

            val mmsList = mutableListOf<Map<String, Any?>>()

            val mmsCursor = contentResolver.query(
                Uri.parse("content://mms"),
                arrayOf("_id", "date", "read", "sub", "msg_box"),
                null, null, null
            )

            mmsCursor?.use { cursor ->
                while (cursor.moveToNext()) {
                    val mmsId = cursor.getLong(cursor.getColumnIndexOrThrow("_id"))
                    val date = cursor.getLong(cursor.getColumnIndexOrThrow("date")) * 1000L
                    val read = cursor.getInt(cursor.getColumnIndexOrThrow("read"))
                    val sub = cursor.getString(cursor.getColumnIndexOrThrow("sub")) ?: ""
                    val msgBox = cursor.getInt(cursor.getColumnIndexOrThrow("msg_box"))

                    var address = ""
                    val addrCursor = contentResolver.query(
                        Uri.parse("content://mms/$mmsId/addr"),
                        null, null, null, null
                    )
                    addrCursor?.use { addr ->
                        while (addr.moveToNext()) {
                            if (addr.getString(addr.getColumnIndexOrThrow("type")) == "151") {
                                address = addr.getString(addr.getColumnIndexOrThrow("address")) ?: ""
                            }
                        }
                    }

                    val parts = mutableListOf<Map<String, Any?>>()
                    val partCursor = contentResolver.query(
                        Uri.parse("content://mms/part/$mmsId"),
                        null, null, null, null
                    )

                    partCursor?.use { partsCursor ->
                        while (partsCursor.moveToNext()) {
                            val partId = partsCursor.getLong(partsCursor.getColumnIndexOrThrow("_id"))
                            val contentType = partsCursor.getString(partsCursor.getColumnIndexOrThrow("ct")) ?: ""
                            val dataPath = partsCursor.getString(partsCursor.getColumnIndexOrThrow("_data"))
                            val text = partsCursor.getString(partsCursor.getColumnIndexOrThrow("text"))

                            if (contentType.startsWith("image/")) {
                                var imageBytes: ByteArray? = null
                                if (dataPath != null) {
                                    try {
                                        imageBytes = java.io.File(dataPath).readBytes()
                                    } catch (e: Exception) {}
                                }
                                if (imageBytes == null) {
                                    try {
                                        val uri = Uri.parse("content://mms/part/$partId")
                                        imageBytes = contentResolver.openInputStream(uri)?.readBytes()
                                    } catch (e: Exception) {}
                                }

                                if (imageBytes != null) {
                                    val base64Image = android.util.Base64.encodeToString(imageBytes, android.util.Base64.NO_WRAP)
                                    parts.add(mapOf(
                                        "type" to "image",
                                        "contentType" to contentType,
                                        "data" to base64Image
                                    ))
                                }
                            } else if (contentType.startsWith("text/") && text != null) {
                                parts.add(mapOf(
                                    "type" to "text",
                                    "contentType" to contentType,
                                    "text" to text
                                ))
                            }
                        }
                    }

                    if (address.isNotEmpty() && parts.isNotEmpty()) {
                        mmsList.add(mapOf(
                            "id" to mmsId,
                            "address" to address,
                            "date" to date,
                            "read" to read,
                            "sub" to sub,
                            "type" to if (msgBox == 1) 1 else 2,
                            "parts" to parts
                        ))
                    }
                }
            }

            result.success(mmsList)
        } catch (e: Exception) {
            android.util.Log.e("[MmsSync]", "Error getAllMms", e)
            result.success(emptyList<Any>())
        }
    }

    private fun sendMms(telefono: String, imagePath: String, result: MethodChannel.Result) {
        try {
            val imageUri = Uri.parse(imagePath)
            val intent = Intent(Intent.ACTION_SEND).apply {
                type = if (imagePath.endsWith(".png", true)) "image/png" else "image/jpeg"
                putExtra(Intent.EXTRA_STREAM, imageUri)
                putExtra("address", telefono)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }
            startActivity(Intent.createChooser(intent, "Enviar MMS"))
            result.success(true)
        } catch (e: Exception) {
            android.util.Log.e("[MmsSync]", "Error sendMms", e)
            result.success(false)
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
