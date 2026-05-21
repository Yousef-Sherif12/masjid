import 'package:flutter/material.dart';
import 'package:masjid/constants/colors.dart';
import 'package:masjid/enums/app_state_enum.dart';
import 'package:masjid/enums/app_theme_enum.dart';

class NextPray extends StatelessWidget {
  NextPray({
    super.key,
    required this.nextPray,
    required this.hours,
    required this.min,
    required this.sec,
    required this.appState, // مرر حالة التطبيق
    required this.iqamaCountdown, // مرر نص عداد الإقامة 00:00
    required this.currentTheme,
  });

  final String nextPray;
  final int hours, min, sec;
  final AppState appState;
  final String iqamaCountdown;
  AppThemeEnum currentTheme;

  // دالة تنسيق الوقت بالعربية
  String formatArabicTime(int value, String type) {
    if (value <= 0) return "";

    if (type == "ثانية") {
      if (value == 1) return "ثانية";
      if (value == 2) return "ثانيتين";
      if (value >= 3 && value <= 10) return "$value ثوانٍ";
      return "$value ثانية";
    }

    if (type == "دقيقة") {
      if (value == 1) return "دقيقة";
      if (value == 2) return "دقيقتين";
      if (value >= 3 && value <= 10) return "$value دقائق";
      return "$value دقيقة";
    }

    if (type == "ساعة") {
      if (value == 1) return "ساعة";
      if (value == 2) return "ساعتين";
      if (value >= 3 && value <= 10) return "$value ساعات";
      return "$value ساعة";
    }

    return "$value $type";
  }

  TextStyle _timerStyle() {
    return TextStyle(
      color:
          currentTheme == AppThemeEnum.hajTheme ||
              currentTheme == AppThemeEnum.hajTheme2
          ? hajTextColor
          : Color(0xffeee8aa),
      fontWeight: FontWeight.w900,
      fontSize: 17,
    );
  }

  String parcePrayerName(String name) {
    if (name == 'الشروق') {
      return 'الضحى';
    } else {
      return name;
    }
  }

  @override
  Widget build(BuildContext context) {
    // تحديد ما إذا كنا في وضع عد التنازلي للإقامة
    bool isIqamaMode = appState == AppState.iqamaCount;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [
            currentTheme == AppThemeEnum.hajTheme ||
                    currentTheme == AppThemeEnum.hajTheme2
                ? hajBackGroundColor1
                : Color(0xff38391a),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: isIqamaMode ? _buildIqamaView() : _buildNextPrayView(),
    );
  }

  // 1. واجهة عداد الإقامة (00:00 على اليسار والنص على اليمين)
  Widget _buildIqamaView() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // عداد الإقامة الكبير
          Text(
            iqamaCountdown,
            // '30:59',
            style: TextStyle(
              color: currentTheme == AppThemeEnum.hajTheme||
              currentTheme == AppThemeEnum.hajTheme2
                  ? hajTextColor
                  : Color(0xffeee8aa),
              fontWeight: FontWeight.bold,
              fontSize: 50, // حجم كبير للعداد
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          // نصوص الإقامة
          Text(
            'الباقي على\nالإقامة',
            textAlign: TextAlign.center,

            style: TextStyle(
              color: currentTheme == AppThemeEnum.hajTheme||
              currentTheme == AppThemeEnum.hajTheme2
                  ? hajTextColor
                  : Color(0xffeee8aa),
              fontWeight: FontWeight.w900,
              fontSize: 22,
            ),
          ),
        ],
      ),
    );
  }

  // 2. واجهة الصلاة القادمة (الشكل القديم المعتاد)
  Widget _buildNextPrayView() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'الصلاة القادمة: ${parcePrayerName(nextPray)}',
            style: TextStyle(
              color: currentTheme == AppThemeEnum.hajTheme||
              currentTheme == AppThemeEnum.hajTheme2
                  ? hajTextColor
                  : Color(0xffeee8aa),
              fontWeight: FontWeight.w900,
              fontSize: 19,
              height: 1,
            ),
          ),
          Text(
            ':يحين موعدها بإذن الله تعالى بعد',
            style: TextStyle(
              color: currentTheme == AppThemeEnum.hajTheme||
              currentTheme == AppThemeEnum.hajTheme2
                  ? hajTextColor
                  : Color(0xffeee8aa),
              fontWeight: FontWeight.w300,
              fontSize: 16,
              height: 1.2,
            ),
          ),

          Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // عرض الساعات
                if (hours > 0)
                  Text(
                    formatArabicTime(hours, "ساعة") +
                        (min > 0 || sec > 0 ? " و " : ""),
                    style: _timerStyle(),
                  ),

                // عرض الدقائق
                if (min > 0)
                  Text(
                    formatArabicTime(min, "دقيقة") + (sec > 0 ? " و " : ""),
                    style: _timerStyle(),
                  ),

                // عرض الثواني
                if (sec > 0 ||
                    (hours == 0 &&
                        min == 0)) // بنعرض الثواني لو موجودة أو لو كله أصفار
                  Text(formatArabicTime(sec, "ثانية"), style: _timerStyle()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
