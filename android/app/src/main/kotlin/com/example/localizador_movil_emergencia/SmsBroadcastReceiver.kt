package com.example.localizador_movil_emergencia

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class SmsBroadcastReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            "android.provider.Telephony.SMS_DELIVERED" -> {
                // SMS entregado al dispositivo (requerido para ser app SMS default)
                Log.i("[SmsRepository]", "SMS_DELIVERED: SMS recibido por el sistema")
            }
            "android.provider.Telephony.SMS_RECEIVED" -> {
                // SMS recibido (requerido para ser app SMS default)
                Log.i("[SmsRepository]", "SMS_RECEIVED: SMS recibido")
            }
            "SMS_SENT" -> {
                when (resultCode) {
                    android.app.Activity.RESULT_OK ->
                        Log.i("[SmsRepository]", "SMS: Enviado correctamente")
                    else ->
                        Log.w("[SmsRepository]", "SMS: Error al enviar (código: $resultCode)")
                }
            }
            "SMS_DELIVERED" -> {
                when (resultCode) {
                    android.app.Activity.RESULT_OK ->
                        Log.i("[SmsRepository]", "SMS: Entregado al destinatario")
                    android.app.Activity.RESULT_CANCELED ->
                        Log.w("[SmsRepository]", "SMS: No entregado al destinatario")
                }
            }
        }
    }
}
