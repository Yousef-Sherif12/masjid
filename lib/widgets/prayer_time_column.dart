import 'package:flutter/material.dart';
import 'package:masjid/constants/colors.dart';
import 'package:masjid/enums/app_state_enum.dart';
import 'package:masjid/enums/app_theme_enum.dart';
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
            const Line(height: 1),
            //التاريخ
            SizedBox(height: 10),
            TimeAndDate(
              hijriDate: hijriDate,
              date: date,
              day: day,
              fullTime: fullTime,
              currentTheme: currentTheme,
            ),
            Spacer(), // مواقيت الصلاة
            Text(
              'مواقيت الصلاة',
              style: TextStyle(
                color:
                    currentTheme == AppThemeEnum.hajTheme ||
                        currentTheme == AppThemeEnum.hajTheme2
                    ? hajTextColor
                    : Color(0xffeee8aa),
                fontWeight: FontWeight.bold,
                fontFamily: 'Tajawal',

                fontSize: 25,
                height: 1,
              ),
            ),
            const Line(height: 0.7),
            const SizedBox(height: 10),
            PrayerTimes(currentTheme: currentTheme),
            const SizedBox(height: 7),
            NextPray(
              nextPray: nextPrayName,
              hours: hours,
              min: minutes,
              sec: seconds,
              appState: appState,
              iqamaCountdown: iqamaTime,
              currentTheme: currentTheme,
            ),
            const SizedBox(height: 5),
            const Line(height: 1),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            day,
            style: TextStyle(
              color: currentTheme == AppThemeEnum.hajTheme||
              currentTheme == AppThemeEnum.hajTheme2
                  ? hajTextColor
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
              color: currentTheme == AppThemeEnum.hajTheme||
              currentTheme == AppThemeEnum.hajTheme2
                  ? hajTextColor
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
              color: currentTheme == AppThemeEnum.hajTheme||
              currentTheme == AppThemeEnum.hajTheme2
                  ? hajTextColor
                  : Color(0xffeee8aa),
              fontWeight: FontWeight.w700,
              fontSize: 18,
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
                      color: currentTheme == AppThemeEnum.hajTheme||
              currentTheme == AppThemeEnum.hajTheme2
                          ? hajTextColor
                          : Color(0xffeee8aa),
                      fontWeight: FontWeight.w900,
                      fontSize: 200, // حجم افتراضي كبير جداً
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
