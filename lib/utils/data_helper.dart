import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart' as intl;

class DateHelper {
  // 👇 تقدر تغيّرها من SharedPreferences بعد كده
  static int hijriOffset = -1; // -1 أو +1 حسب الرؤية

  static String formatDate(DateTime now) {
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return "${now.day.toString().padLeft(2, '0')} ${months[now.month - 1]} ${now.year}";
  }

  static String formatTime(DateTime now) {
    int hour = now.hour;
    int minute = now.minute;
    bool isPM = hour >= 12;

    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;

    String period = isPM ? 'م' : 'ص';

    return "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period";
  }

  static String formatDay(DateTime now) {
    return intl.DateFormat('EEEE', 'ar').format(now);
  }

  static String formatHijriDate(DateTime now) {
    const hijriMonths = [
      "محرم",
      "صفر",
      "ربيع الأول",
      "ربيع الآخر",
      "جمادى الأولى",
      "جمادى الآخرة",
      "رجب",
      "شعبان",
      "رمضان",
      "شوال",
      "ذو القعدة",
      "ذو الحجة",
    ];

    final hijri = HijriCalendar.fromDate(now);

    int day = hijri.hDay + hijriOffset;
    int month = hijri.hMonth;
    int year = hijri.hYear;

    // 👇 معالجة لو اليوم أقل من 1
    if (day <= 0) {
      month -= 1;

      if (month <= 0) {
        month = 12;
        year -= 1;
      }

      day = 30; // تقدير (كويس عمليًا)
    }

    // 👇 معالجة لو اليوم عدى 30
    if (day > 30) {
      day = 1;
      month += 1;

      if (month > 12) {
        month = 1;
        year += 1;
      }
    }

    return "$day ${hijriMonths[month - 1]} $yearهـ";
  }
}

// import 'package:hijri/hijri_calendar.dart';
// import 'package:intl/intl.dart' as intl;

// class DateHelper {
//   static String formatDate(DateTime now) {
//     const months = [
//       'يناير',
//       'فبراير',
//       'مارس',
//       'أبريل',
//       'مايو',
//       'يونيو',
//       'يوليو',
//       'أغسطس',
//       'سبتمبر',
//       'أكتوبر',
//       'نوفمبر',
//       'ديسمبر',
//     ];
//     return "${now.day.toString().padLeft(2, '0')} ${months[now.month - 1]} ${now.year}";
//   }

//   static String formatTime(DateTime now) {
//     int hour = now.hour;
//     int minute = now.minute;
//     bool isPM = hour >= 12;
//     if (hour > 12) hour -= 12;
//     if (hour == 0) hour = 12;
//     String period = isPM ? 'م' : 'ص';
//     return "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period";
//   }

//   static String formatDay(DateTime now) {
//     return intl.DateFormat('EEEE', 'ar').format(now);
//   }

//   static String formatHijriDate(DateTime now) {
//     const hijriMonths = [
//       "محرم",
//       "صفر",
//       "ربيع الأول",
//       "ربيع الآخر",
//       "جمادى الأولى",
//       "جمادى الآخرة",
//       "رجب",
//       "شعبان",
//       "رمضان",
//       "شوال",
//       "ذو القعدة",
//       "ذو الحجة",
//     ];

//     final hijri = HijriCalendar.fromDate(now);

//     hijri.adjustments = {
//       hijri.hMonth: -1, // 👈 التعديل هنا
//     };

//     return "${hijri.hDay} ${hijriMonths[hijri.hMonth - 1]} ${hijri.hYear}هـ";
//   }
// }
