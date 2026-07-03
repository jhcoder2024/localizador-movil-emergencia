package com.example.localizador_movil_emergencia

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.provider.Telephony
import android.telephony.SmsMessage
import android.util.Log

class SmsBroadcastReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            "android.provider.Telephony.SMS_DELIVERED",
            "android.provider.Telephony.SMS_RECEIVED" -> {
                val messages = parseSmsMessages(intent)
                for (msg in messages) {
                    Log.i("[SmsReceiver]", "SMS recibido de: ${msg.displayOriginatingAddress}, cuerpo: ${msg.messageBody?.take(50)}")
                    
                    // Enviar a Flutter vía EventChannel
                    // Necesitamos acceder a la Activity para obtener el EventChannel
                    // Como BroadcastReceiver es estático, usamos una referencia débil
                    val smsData = mapOf(
                        "address" to (msg.displayOriginatingAddress ?: ""),
                        "body" to (msg.messageBody ?: ""),
                        "date" to System.currentTimeMillis(),
                        "type" to 1, // received
                        "read" to 0
                    )
                    
                    // Enviar broadcast local para que MainActivity lo procese
                    val localIntent = Intent("SMS_RECEIVED_INTERNAL").apply {
                        putExtra("sms_data", HashMap(smsData))
                    }
                    context.sendBroadcast(localIntent)
                }
            }
            "SMS_SENT" -> {
                val smsId = intent.getIntExtra("sms_id", -1)
                val resultado = when (resultCode) {
                    android.app.Activity.RESULT_OK -> "sent"
                    else -> "failed"
                }
                Log.i("[SmsRepository]", "SMS $smsId: $resultado")

                // Enviar resultado a Flutter
                val resultData = mapOf(
                    "type" to "sms_sent_result",
                    "smsId" to smsId,
                    "estado" to resultado
                )
                val localIntent = Intent("SMS_RECEIVED_INTERNAL").apply {
                    putExtra("sms_data", HashMap(resultData))
                }
                context.sendBroadcast(localIntent)
            }
            "SMS_DELIVERED" -> {
                when (resultCode) {
                    android.app.Activity.RESULT_OK ->
                        Log.i("[SmsRepository]", "SMS: Entregado al destinatario")
                    android.app.Activity.RESULT_CANCELED ->
                        Log.w("[SmsRepository]", "SMS: No entregado al destinatario")
                }
            }
            "SMS_RECEIVED_INTERNAL" -> {
                // Este broadcast es enviado por nosotros mismos para comunicar al EventChannel
                val smsData = intent.getSerializableExtra("sms_data") as? Map<String, Any>
                if (smsData != null) {
                    // Enviar al EventChannel de Flutter
                    // Nota: El EventChannel se maneja desde MainActivity
                }
            }
        }
    }

    private fun parseSmsMessages(intent: Intent): Array<out SmsMessage> {
        val pdus = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            intent.getParcelableArrayExtra("pdus", android.telephony.SmsMessage::class.java)
        } else {
            @Suppress("DEPRECATION")
            intent.getParcelableArrayExtra("pdus")
        }
        
        if (pdus == null || pdus.isEmpty()) return emptyArray()
        
        val messages = mutableListOf<SmsMessage>()
        for (pdu in pdus) {
            val message = SmsMessage.createFromPdu(pdu as ByteArray)
            messages.add(message)
        }
        return messages.toTypedArray()
    }
}
