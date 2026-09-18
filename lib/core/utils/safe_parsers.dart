import 'package:cloud_firestore/cloud_firestore.dart';

/// Robust safe parsers to prevent any `TypeError: null: type 'Null' is not a subtype of type 'String'`
/// or other runtime type mismatch crashes across Firestore models and UI components.
class SafeParsers {
  SafeParsers._();

  /// Safely converts any value to non-null String
  static String string(dynamic val, [String fallback = '']) {
    if (val == null) return fallback;
    return val.toString();
  }

  /// Safely converts to nullable String (returns null if empty or null)
  static String? nullableString(dynamic val) {
    if (val == null) return null;
    final str = val.toString().trim();
    return str.isEmpty ? null : str;
  }

  /// Safely parses a double from num, String, or null
  static double doubleVal(dynamic val, [double fallback = 0.0]) {
    if (val == null) return fallback;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString()) ?? fallback;
  }

  /// Safely parses an int from num, String, or null
  static int intVal(dynamic val, [int fallback = 0]) {
    if (val == null) return fallback;
    if (val is num) return val.toInt();
    return int.tryParse(val.toString()) ?? fallback;
  }

  /// Safely parses a bool from bool, String, or null
  static bool boolVal(dynamic val, [bool fallback = false]) {
    if (val == null) return fallback;
    if (val is bool) return val;
    final s = val.toString().toLowerCase().trim();
    if (s == 'true' || s == '1') return true;
    if (s == 'false' || s == '0') return false;
    return fallback;
  }

  /// Safely converts any dynamic list to a clean `List<String>`, dropping nulls and converting items to String
  static List<String> stringList(dynamic val) {
    if (val == null) return [];
    if (val is Iterable) {
      return val
          .where((e) => e != null)
          .map((e) => e.toString())
          .where((s) => s.isNotEmpty)
          .toList();
    }
    return [];
  }

  /// Safely parses DateTime from Timestamp, DateTime, ISO-8601 String, or millis
  static DateTime dateTime(dynamic val, [DateTime? fallback]) {
    final defaultDate = fallback ?? DateTime.now();
    if (val == null) return defaultDate;
    if (val is DateTime) return val;
    if (val is Timestamp) return val.toDate();
    try {
      final dynamic dyn = val;
      if (dyn.toDate is Function) {
        return (dyn.toDate() as DateTime);
      }
    } catch (_) {}

    if (val is int) {
      return DateTime.fromMillisecondsSinceEpoch(val);
    }
    return DateTime.tryParse(val.toString()) ?? defaultDate;
  }

  /// Safely parses nullable DateTime
  static DateTime? nullableDateTime(dynamic val) {
    if (val == null) return null;
    if (val is DateTime) return val;
    if (val is Timestamp) return val.toDate();
    try {
      final dynamic dyn = val;
      if (dyn.toDate is Function) {
        return (dyn.toDate() as DateTime);
      }
    } catch (_) {}
    if (val is int) {
      return DateTime.fromMillisecondsSinceEpoch(val);
    }
    return DateTime.tryParse(val.toString());
  }

  /// Safely parses `Map<String, int>` from dynamic map
  static Map<String, int> stringIntMap(dynamic val) {
    if (val == null || val is! Map) return {};
    final result = <String, int>{};
    val.forEach((k, v) {
      if (k != null) {
        result[k.toString()] = intVal(v, 0);
      }
    });
    return result;
  }
}
