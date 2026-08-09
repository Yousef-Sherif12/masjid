import 'package:flutter/material.dart';
import 'package:masjid/enums/app_theme_enum.dart';

class Line extends StatelessWidget {
  Line({
    super.key,
    this.height = 0.75,
    this.width = double.infinity,
    required this.currentTheme,
  });
  final double width;
  final double height;
  AppThemeEnum currentTheme;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: currentTheme != AppThemeEnum.newLightTheme
              ? [
                  Colors.transparent,
                  Color(0xffC8A84B), // اللون الذهبي
                  Color(0xffC8A84B),
                  Colors.transparent,
                ]
              : [
                  Colors.transparent,
                  Color.fromARGB(255, 97, 59, 5), // اللون الذهبي
                  Color.fromARGB(255, 97, 59, 5),
                  Colors.transparent,
                ],
          stops: [0.1, 0.3, 0.7, 1.0],
        ),
      ),
    );
  }
}

class PrayerLine extends StatelessWidget {
  PrayerLine({
    super.key,
    this.height = 1.5,
    this.width = double.infinity,
    required this.currentTheme,
  });
  final double width;
  final double height;
  AppThemeEnum currentTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          // يبدأ من اليمين للشمال
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: currentTheme != AppThemeEnum.newLightTheme
              ? [
                  Color(0xffC8A84B), // يبدأ ذهبي كامل من اليمين
                  Color(0xffC8A84B), // يفضل ذهبي لمسافة بسيطة
                  Colors.transparent, // ينتهي شفاف تماماً في الشمال
                ]
              : [
                  // يبدأ ذهبي كامل من اليمين
                  Color.fromARGB(255, 97, 59, 5), // يفضل ذهبي لمسافة بسيطة
                  Color.fromARGB(255, 97, 59, 5), // يفضل ذهبي لمسافة بسيطة
                  Colors.transparent, // ينتهي شفاف تماماً في الشمال
                ],
          // الـ stops هنا هي السر:
          // 0.0 يعني من أول نقطة عاليمين يكون ذهبي
          // 0.2 يفضل ذهبي ثابت لحد 20% من الخط
          // 1.0 يختفي تماماً عند نهاية الخط عالشمال
          stops: [0.0, 0.2, 1.0],
        ),
      ),
    );
  }
}
