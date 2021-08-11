import 'package:intl/intl.dart';

class DateFormatter {

  static final DateFormat dateFormat = DateFormat("dd-MM-yyyy hh:mm aa");

  static DateTime format(String dateTime) {

    return DateTime.parse(dateFormat.format(DateTime.parse(dateTime)));
  }
}