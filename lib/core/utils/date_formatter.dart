import 'package:intl/intl.dart';

/// Helper for standardizing date and time strings to Western Indonesia Time (WIB / GMT+7).
class DateFormatter {
  DateFormatter._();

  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _dateFormat = DateFormat('d MMM yyyy', 'id_ID');
  static final DateFormat _fullDateTimeFormat = DateFormat('d MMMM yyyy, HH:mm', 'id_ID');

  /// Formats DateTime to "08:00 WIB"
  static String formatTime(DateTime dateTime) {
    return '${_timeFormat.format(dateTime)} WIB';
  }

  /// Formats time range "07:00 - 08:00 WIB"
  static String formatTimeRange(DateTime start, DateTime end) {
    return '${_timeFormat.format(start)} - ${_timeFormat.format(end)} WIB';
  }

  /// Formats date to Indonesian readable date "11 Okt 2026"
  static String formatDate(DateTime dateTime) {
    try {
      return _dateFormat.format(dateTime);
    } catch (_) {
      // Fallback if locale is not loaded yet
      return '${dateTime.day} ${_monthShort(dateTime.month)} ${dateTime.year}';
    }
  }

  /// Formats full date time "11 Oktober 2026, 08:00 WIB"
  static String formatFull(DateTime dateTime) {
    try {
      return '${_fullDateTimeFormat.format(dateTime)} WIB';
    } catch (_) {
      return '${dateTime.day} ${_monthFull(dateTime.month)} ${dateTime.year}, ${_timeFormat.format(dateTime)} WIB';
    }
  }

  static String _monthShort(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return (month >= 1 && month <= 12) ? months[month - 1] : '';
  }

  static String _monthFull(int month) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return (month >= 1 && month <= 12) ? months[month - 1] : '';
  }
}
