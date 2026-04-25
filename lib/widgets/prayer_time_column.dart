import 'package:flutter/material.dart';
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
            TimeAndDate(
              hijriDate: hijriDate,
              date: date,
              day: day,
              fullTime: fullTime,
            ),
            Spacer(), // مواقيت الصلاة
            const Text(
              'مواقيت الصلاة',
              style: TextStyle(
                color: Color(0xffeee8aa),
                fontWeight: FontWeight.bold,
                fontFamily: 'Tajawal',

                fontSize: 25,
                height: 1,
              ),
            ),
            const Line(height: 0.7),
            const SizedBox(height: 15),
            const PrayerTimes(),
            const SizedBox(height: 10),
            NextPray(
              nextPray: nextPrayName,
              hours: hours,
              min: minutes,
              sec: seconds,
              appState: appState,
              iqamaCountdown: iqamaTime,
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
  const TimeAndDate({
    super.key,
    required this.hijriDate,
    required this.date,
    required this.day,
    required this.fullTime,
  });

  final String hijriDate;
  final String date;
  final String day;
  final String fullTime;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0, left: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Date(hijriDate: hijriDate, date: date, day: day),
          DayAndTime(day: day, fullTime: fullTime),
        ],
      ),
    );
  }
}

class Date extends StatelessWidget {
  const Date({
    super.key,
    required this.hijriDate,
    required this.date,
    required this.day,
  });

  final String hijriDate;
  final String date;
  final String day;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            day,
            style: const TextStyle(
              color: Color(0xffeee8aa),
              fontWeight: FontWeight.w900,
              fontSize: 16,
              height: 1,
            ),
          ),
          Text(
            hijriDate,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              color: Color(0xffeee8aa),
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          //date
          Text(
            '$dateم',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: Color(0xffeee8aa),
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
  const DayAndTime({super.key, required this.day, required this.fullTime});

  final String day;
  final String fullTime;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // day
          // Text(
          //   day,
          //   style: const TextStyle(
          //     color: Color(0xffeee8aa),
          //     fontWeight: FontWeight.w900,
          //     fontSize: 16,
          //     height: 1,
          //   ),
          // ),

          //time
          RichText(
            textDirection: TextDirection.rtl,
            text: TextSpan(
              children: [
                TextSpan(
                  text: fullTime.split(' ')[0], // الوقت نفسه
                  style: const TextStyle(
                    color: Color(0xffeee8aa),
                    fontWeight: FontWeight.w900,
                    fontSize: 37,
                    height: 1,
                  ),
                ),
                TextSpan(
                  text: ' ${fullTime.split(' ')[1]}', // ص أو م
                  style: const TextStyle(
                    color: Color(0xffeee8aa),
                    fontWeight: FontWeight.w900,
                    fontSize: 28,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          // Text(
          //   fullTime,
          //   textDirection: TextDirection.rtl,
          //   style: const TextStyle(
          //     color: Color(0xffeee8aa),
          //     fontWeight: FontWeight.w900,
          //     fontSize: 35,
          //     height: 1,
          //   ),
          // ),
        
        ],
      ),
    );
  }
}
