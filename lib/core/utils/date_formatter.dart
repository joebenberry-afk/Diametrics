class DateFormatter {
  static String formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final dateNow = DateTime(now.year, now.month, now.day);
    final dateDt = DateTime(dt.year, dt.month, dt.day);
    final diffDays = dateNow.difference(dateDt).inDays;

    if (diffDays == 0) return 'Today ${_timeStr(dt)}';
    if (diffDays == 1) return 'Yesterday ${_timeStr(dt)}';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${_timeStr(dt)}';
  }

  static String _timeStr(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
