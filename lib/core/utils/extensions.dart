extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  bool isValidPhone() {
    final regex = RegExp(r'^\+?[\d\s\-\(\)]{7,15}$');
    return regex.hasMatch(this);
  }

  bool isValidEmail() {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(this);
  }
}

extension DateTimeExtension on DateTime {
  String toFormattedString() {
    final day = this.day.toString().padLeft(2, '0');
    final month = this.month.toString().padLeft(2, '0');
    final hour = this.hour.toString().padLeft(2, '0');
    final minute = this.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }
}

extension DoubleExtension on double {
  String toLatLngString() {
    return toStringAsFixed(6);
  }
}
