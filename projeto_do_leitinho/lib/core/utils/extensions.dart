import 'package:flutter/material.dart';

// String extensions
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String removeNonDigits() {
    return replaceAll(RegExp(r'[^\d]'), '');
  }

  bool get isCPF {
    final cleaned = removeNonDigits();
    return cleaned.length == 11;
  }

  bool get isCNPJ {
    final cleaned = removeNonDigits();
    return cleaned.length == 14;
  }
}

// DateTime extensions
extension DateTimeExtension on DateTime {
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  bool isToday() {
    return isSameDay(DateTime.now());
  }

  bool isYesterday() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(yesterday);
  }

  DateTime get startOfDay {
    return DateTime(year, month, day);
  }

  DateTime get endOfDay {
    return DateTime(year, month, day, 23, 59, 59, 999);
  }

  DateTime get startOfMonth {
    return DateTime(year, month, 1);
  }

  DateTime get endOfMonth {
    return DateTime(year, month + 1, 0, 23, 59, 59, 999);
  }
}

// BuildContext extensions
extension BuildContextExtension on BuildContext {
  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void showInfoSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  double get width => MediaQuery.of(this).size.width;
  double get height => MediaQuery.of(this).size.height;
  bool get isMobile => width < 600;
  bool get isTablet => width >= 600 && width < 1024;
  bool get isDesktop => width >= 1024;
}

// Double extensions
extension DoubleExtension on double {
  String toStringWithDecimals(int decimals) {
    return toStringAsFixed(decimals);
  }

  String toLiters() {
    return '${toStringAsFixed(1)}L';
  }

  String toTemperature() {
    return '${toStringAsFixed(1)}°C';
  }

  String toPercentage() {
    return '${toStringAsFixed(1)}%';
  }
}

// List extensions
extension ListExtension<T> on List<T> {
  T? get firstOrNull {
    if (isEmpty) return null;
    return first;
  }

  T? get lastOrNull {
    if (isEmpty) return null;
    return last;
  }

  List<T> sortedBy<K extends Comparable>(K Function(T) keyExtractor) {
    final list = List<T>.from(this);
    list.sort((a, b) => keyExtractor(a).compareTo(keyExtractor(b)));
    return list;
  }

  List<T> sortedByDescending<K extends Comparable>(K Function(T) keyExtractor) {
    final list = List<T>.from(this);
    list.sort((a, b) => keyExtractor(b).compareTo(keyExtractor(a)));
    return list;
  }
}
