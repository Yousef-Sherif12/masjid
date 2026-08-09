import 'package:flutter/material.dart';
import 'package:masjid/constants/colors.dart';
import 'package:masjid/enums/app_state_enum.dart';
import 'package:masjid/enums/app_theme_enum.dart';
import 'package:masjid/models/day_prayer.dart';
import 'package:masjid/widgets/Line.dart';
import 'package:masjid/widgets/next_pray.dart';
import 'package:masjid/widgets/prayer_times.dart';

// ignore: must_be_immutable
class PrayerTimesAndDateColunm extends StatelessWidget {
  PrayerTimesAndDateColunm({
    super.key,
    required this.hijriDate,
    required this.date,
    required this.day,
    required this.fullTime,
    required this.nextPrayName, // 👈 اسم الصلاة القادمة
    required this.hours, // 👈 الساعات المتبقية
    required this.minutes, // 👈 الدقائق
    required this.seconds, // 👈 الثواني
    required this.iqamaTime,
    required this.appState,
    required this.currentTheme,
    required this.prayerData,
  });

  final String hijriDate;
  final String date;
  final String day;
  final String fullTime;
  final String nextPrayName;
  final int hours, minutes, seconds;
  final String iqamaTime;
  final AppState appState;
  AppThemeEnum currentTheme;
  final DayPrayer? prayerData; // ✅ بياخدها من main.dart

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: Container(
        margin: const EdgeInsets.only(right: 0, top: 10, bottom: 42, left: 0),
        padding: EdgeInsets.only(left: 5, right: 5),
        decoration: BoxDecoration(
          color: currentTheme == AppThemeEnum.newDarkTheme
              ? Colors.black.withOpacity(0.3)
              : currentTheme == AppThemeEnum.newLightTheme
              ? Colors.white.withOpacity(0.06)
              : Colors.transparent,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            bottomLeft: Radius.circular(15),
          ),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // 👈 مهم
          // mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Line(height: 1, currentTheme: currentTheme),
            //التاريخ
            SizedBox(height: 2),
            TimeAndDate(
              hijriDate: hijriDate,
              date: date,
              day: day,
              fullTime: fullTime,
              currentTheme: currentTheme,
            ),
            // Spacer(), // مواقيت الصلاة
            SizedBox(height: 4),

            Text(
              'مواقيت الصلاة',
              style: TextStyle(
                color:
                    currentTheme == AppThemeEnum.hajTheme ||
                        currentTheme == AppThemeEnum.hajTheme2
                    ? hajTextColor
                    : currentTheme == AppThemeEnum.newLightTheme
                    ? whiteBgTextColor
                    : Color(0xffeee8aa),
                fontWeight: FontWeight.bold,
                fontFamily: 'Tajawal',

                fontSize: 25,
                height: 1,
              ),
            ),
            Line(height: 0.7, currentTheme: currentTheme),
            const SizedBox(height: 0),
            PrayerTimes(
              prayerData: prayerData, // ✅ من main

              currentTheme: currentTheme,
            ),
            const SizedBox(height: 3),
            NextPray(
              nextPray: nextPrayName,
              hours: hours,
              min: minutes,
              sec: seconds,
              appState: appState,
              iqamaCountdown: iqamaTime,
              currentTheme: currentTheme,
            ),
            // const SizedBox(height: 9),
            Line(height: 1, currentTheme: currentTheme),
          ],
        ),
      ),
    );
  }
}

class TimeAndDate extends StatelessWidget {
  TimeAndDate({
    super.key,
    required this.hijriDate,
    required this.date,
    required this.day,
    required this.fullTime,
    required this.currentTheme,
  });

  final String hijriDate;
  final String date;
  final String day;
  final String fullTime;
  AppThemeEnum currentTheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0, left: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Date(
            hijriDate: hijriDate,
            date: date,
            day: day,
            currentTheme: currentTheme,
          ),
          SizedBox(width: 4),
          DayAndTime(fullTime: fullTime, currentTheme: currentTheme),
        ],
      ),
    );
  }
}

class Date extends StatelessWidget {
  Date({
    super.key,
    required this.hijriDate,
    required this.date,
    required this.day,
    required this.currentTheme,
  });

  final String hijriDate;
  final String date;
  final String day;
  AppThemeEnum currentTheme;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            day,
            style: TextStyle(
              color:
                  currentTheme == AppThemeEnum.hajTheme ||
                      currentTheme == AppThemeEnum.hajTheme2
                  ? hajTextColor
                  : currentTheme == AppThemeEnum.newLightTheme
                  ? whiteBgTextColor
                  : Color(0xffeee8aa),
              fontWeight: FontWeight.w900,
              fontSize: 16,
              height: 1,
            ),
          ),
          Text(
            hijriDate,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color:
                  currentTheme == AppThemeEnum.hajTheme ||
                      currentTheme == AppThemeEnum.hajTheme2
                  ? hajTextColor
                  : currentTheme == AppThemeEnum.newLightTheme
                  ? whiteBgTextColor
                  : Color(0xffeee8aa),
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          //date
          Text(
            '$dateم',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color:
                  currentTheme == AppThemeEnum.hajTheme ||
                      currentTheme == AppThemeEnum.hajTheme2
                  ? hajTextColor
                  : currentTheme == AppThemeEnum.newLightTheme
                  ? whiteBgTextColor
                  : Color(0xffeee8aa),
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class DayAndTime extends StatelessWidget {
  DayAndTime({super.key, required this.fullTime, required this.currentTheme});

  final String fullTime;
  AppThemeEnum currentTheme;

  @override
  Widget build(BuildContext context) {
    // فصل الوقت عن (ص/م)
    final timeParts = fullTime.split(' ');
    final timeOnly = timeParts[0];

    return Expanded(
      flex: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            width: double.infinity,
            height: 70, // ارتفاع مناسب للساعة في الشاشة الـ 55 بوصة
            child: FittedBox(
              fit: BoxFit
                  .scaleDown, // يمنع النزول لسطر جديد ويصغر الخط عند الضرورة
              alignment: Alignment.centerRight, // المحاذاة لليسار في نظام RTL
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    timeOnly,
                    style: TextStyle(
                      color:
                          currentTheme == AppThemeEnum.hajTheme ||
                              currentTheme == AppThemeEnum.hajTheme2
                          ? hajTextColor
                          : currentTheme == AppThemeEnum.newLightTheme
                          ? whiteBgTextColor
                          : Color(0xffeee8aa),
                      fontWeight: FontWeight.w900,
                      fontSize: 60, // حجم افتراضي كبير جداً
                      fontFamily: 'Tajawal',
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
