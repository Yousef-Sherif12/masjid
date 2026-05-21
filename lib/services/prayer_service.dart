import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;
import 'package:masjid/models/day_prayer.dart';

class PrayerService {
  static Future<DayPrayer?> getTodayPrayers() async {
    final String response = await rootBundle.loadString(
      'assets/jsons/prayer_times_.json',
    );
    final List<dynamic> data = json.decode(response);

    // ✅ DateTime.now() هنا بيجيب التاريخ الحالي وقت الاستدعاء
    String todayDate = intl.DateFormat(
      'yyyy-MM-dd',
      'en',
    ).format(DateTime.now());

    try {
      final todayData = data.firstWhere(
        (element) => element['date'] == todayDate,
      );
      return DayPrayer.fromJson(todayData);
    } catch (e) {
      return null;
    }
  }

  static DateTime parseTime(String timeStr, DateTime date) {
    try {
      final clean = timeStr.trim().toUpperCase();
      final isPM = clean.contains("PM");
      final timePart = clean.replaceAll("AM", "").replaceAll("PM", "").trim();
      final parts = timePart.split(":");
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);
      if (isPM && hour != 12) hour += 12;
      if (!isPM && hour == 12) hour = 0;
      return DateTime(date.year, date.month, date.day, hour, minute);
    } catch (e) {
      return date;
    }
  }

  // في prayer_service.dart
  static Map<String, dynamic> calculateCountdown(DayPrayer? todayPrayerData) {
    if (todayPrayerData == null) return {"name": "-", "h": 0, "m": 0, "s": 0};

    final now = DateTime.now();
    const prayerOrder = [
      "الفجر",
      "الشروق",
      "الظهر",
      "العصر",
      "المغرب",
      "العشاء",
    ];

    for (final prayerName in prayerOrder) {
      final timeStr = todayPrayerData.times[prayerName];
      if (timeStr == null) continue;
      final prayerTime = parseTime(timeStr, now);

      // ✅ الفرق بالثواني بدل isAfter
      final diffSeconds = prayerTime.difference(now).inSeconds;
      if (diffSeconds > 0) {
        final diff = Duration(seconds: diffSeconds);
        return {
          "name": prayerName,
          "h": diff.inHours,
          "m": diff.inMinutes % 60,
          "s": diff.inSeconds % 60,
        };
      }
    }

    final fajrStr = todayPrayerData.times["الفجر"] ?? "4:00 AM";
    final tomorrow = now.add(const Duration(days: 1));
    final nextFajr = parseTime(fajrStr, tomorrow);
    final diff = nextFajr.difference(now);
    return {
      "name": "الفجر",
      "h": diff.inHours,
      "m": diff.inMinutes % 60,
      "s": diff.inSeconds % 60,
    };
  }
  // static Map<String, dynamic> calculateCountdown(DayPrayer? todayPrayerData) {
  //   if (todayPrayerData == null) return {"name": "-", "h": 0, "m": 0, "s": 0};

  //   final now = DateTime.now();
  //   const prayerOrder = [
  //     "الفجر",
  //     "الشروق",
  //     "الظهر",
  //     "العصر",
  //     "المغرب",
  //     "العشاء",
  //   ];

  //   for (final prayerName in prayerOrder) {
  //     final timeStr = todayPrayerData.times[prayerName];
  //     if (timeStr == null) continue;
  //     final prayerTime = parseTime(timeStr, now);
  //     if (prayerTime.isAfter(now)) {
  //       final diff = prayerTime.difference(now);
  //       return {
  //         "name": prayerName,
  //         "h": diff.inHours,
  //         "m": diff.inMinutes % 60,
  //         "s": diff.inSeconds % 60,
  //       };
  //     }
  //   }

  //   final fajrStr = todayPrayerData.times["الفجر"] ?? "4:00 AM";
  //   final tomorrow = now.add(const Duration(days: 1));
  //   final nextFajr = parseTime(fajrStr, tomorrow);
  //   final diff = nextFajr.difference(now);
  //   return {
  //     "name": "الفجر",
  //     "h": diff.inHours,
  //     "m": diff.inMinutes % 60,
  //     "s": diff.inSeconds % 60,
  //   };
  // }

  static String getCurrentPrayerName(DayPrayer? todayPrayerData) {
    if (todayPrayerData == null) return "";

    final now = DateTime.now();
    // ترتيب عكسي عشان نشوف آخر صلاة أذنت كانت إيه
    const prayerOrder = [
      "العشاء",
      "المغرب",
      "العصر",
      "الظهر",
      "الشروق",
      "الفجر",
    ];

    for (final prayerName in prayerOrder) {
      final timeStr = todayPrayerData.times[prayerName];
      if (timeStr == null) continue;
      final prayerTime = parseTime(timeStr, now);

      // أول صلاة تقابلنا وقتها "قبل" دلوقتي، يبقى هي دي الصلاة الحالية
      if (now.isAfter(prayerTime)) {
        return prayerName;
      }
    }
    return "العشاء"; // حالة احتياطية لو قبل الفجر
  }
}
