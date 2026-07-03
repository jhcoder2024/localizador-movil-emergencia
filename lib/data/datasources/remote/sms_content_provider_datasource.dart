import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class SmsContentProviderDataSource {
  static const _syncChannel = MethodChannel('com.example.localizador_movil_emergencia/sms_sync');

  Future<List<Map<String, dynamic>>> getAllSms() async {
    try {
      final result = await _syncChannel.invokeMethod<List<dynamic>>('getAllSms');
      return result?.cast<Map<String, dynamic>>() ?? [];
    } catch (e) {
      debugPrint('[SmsContentProvider] Error getAllSms: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getNewSms(int sinceTimestamp) async {
    try {
      final result = await _syncChannel.invokeMethod<List<dynamic>>('getNewSms', {
        'sinceTimestamp': sinceTimestamp,
      });
      return result?.cast<Map<String, dynamic>>() ?? [];
    } catch (e) {
      debugPrint('[SmsContentProvider] Error getNewSms: $e');
      return [];
    }
  }

  Future<bool> markAsReadInSystem(String conversationId) async {
    try {
      final result = await _syncChannel.invokeMethod<bool>('markAsReadInSystem', {
        'conversationId': conversationId,
      });
      return result ?? false;
    } catch (e) {
      debugPrint('[SmsContentProvider] Error markAsReadInSystem: $e');
      return false;
    }
  }
}
