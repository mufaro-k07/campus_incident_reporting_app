import 'package:intl/intl.dart';

String formatDateTime(DateTime date) {
  return DateFormat('d MMM y, HH:mm').format(date);
}

String formatDate(DateTime date) {
  return DateFormat('d MMM y').format(date);
}
