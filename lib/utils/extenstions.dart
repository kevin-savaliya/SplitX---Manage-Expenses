import 'package:intl/intl.dart';

extension DoubleExtensions on double {
  String formatAmount() {
    if (this % 1 == 0) {
      return toStringAsFixed(0);
    } else {
      return toStringAsFixed(2).replaceAll(RegExp(r"([.]*0)(?!.*\d)"), "");
    }
  }
}

extension DateTimeExtensions on DateTime {
  // Convert current DateTime to UTC
  DateTime get toUtcDateTime {
    return toUtc();
  }

  // Convert current DateTime to local time
  DateTime get toLocalDateTime {
    return toLocal();
  }

  String format(String pattern) {
    final DateFormat formatter = DateFormat(pattern);
    return formatter.format(this);
  }
}
