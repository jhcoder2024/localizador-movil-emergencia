import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  PermissionUtils._();

  static Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  static Future<bool> requestSmsPermission() async {
    final status = await Permission.sms.request();
    return status.isGranted;
  }

  static Future<bool> requestContactsPermission() async {
    final status = await Permission.contacts.request();
    return status.isGranted;
  }

  static Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  static Future<bool> requestPhonePermission() async {
    final status = await Permission.phone.request();
    return status.isGranted;
  }

  static Future<bool> checkLocationPermission() async {
    return await Permission.location.isGranted;
  }

  static Future<bool> checkSmsPermission() async {
    return await Permission.sms.isGranted;
  }

  static Future<bool> checkContactsPermission() async {
    return await Permission.contacts.isGranted;
  }

  static Future<bool> checkNotificationPermission() async {
    return await Permission.notification.isGranted;
  }

  static Future<bool> requestAllEmergencyPermissions() async {
    final location = await requestLocationPermission();
    final sms = await requestSmsPermission();
    final contacts = await requestContactsPermission();
    final notification = await requestNotificationPermission();
    return location && sms && contacts && notification;
  }

  static Future<bool> hasAllEmergencyPermissions() async {
    final location = await checkLocationPermission();
    final sms = await checkSmsPermission();
    final contacts = await checkContactsPermission();
    final notification = await checkNotificationPermission();
    return location && sms && contacts && notification;
  }

  static Future<bool> openSettings() async {
    return await openAppSettings();
  }
}
