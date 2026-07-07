package com.example.localizador_movil_emergencia

import android.app.Application

class EmergencyApplication : Application() {
    companion object {
        var widgetTriggered = false
    }
}
