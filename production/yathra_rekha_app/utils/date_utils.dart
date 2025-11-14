import 'package:intl/intl.dart';

class AppDateUtils {
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }
  
  static DateTime? parseDate(String dateString) {
    try {
      return _dateFormat.parse(dateString);
    } catch (e) {
      return null;
    }
  }
  
  static bool isExpiringSoon(DateTime date, {int days = 30}) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    return difference <= days && difference >= 0;
  }
  
  static bool isExpired(DateTime date) {
    return date.isBefore(DateTime.now());
  }
}