import 'package:flutter/material.dart';

class Line extends StatelessWidget {
  const Line({super.key, this.height = 0.75, this.width = double.infinity});
  final double width;
  final double height;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration:const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Color(0xffC8A84B), // اللون الذهبي
            Color(0xffC8A84B),
            Colors.transparent,
          ],
          stops: [0.1, 0.3, 0.7, 1.0],
        ),
      ),
    );
  }
}

class PrayerLine extends StatelessWidget {
  const PrayerLine({
    super.key,
    this.height = 1.5,
    this.width = double.infinity,
  });
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration:const BoxDecoration(
        gradient: LinearGradient(
          // يبدأ من اليمين للشمال
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [
             Color(0xffC8A84B), // يبدأ ذهبي كامل من اليمين
             Color(0xffC8A84B), // يفضل ذهبي لمسافة بسيطة
            Colors.transparent, // ينتهي شفاف تماماً في الشمال
          ],
          // الـ stops هنا هي السر:
          // 0.0 يعني من أول نقطة عاليمين يكون ذهبي
          // 0.2 يفضل ذهبي ثابت لحد 20% من الخط
          // 1.0 يختفي تماماً عند نهاية الخط عالشمال
          stops:  [0.0, 0.2, 1.0],
        ),
      ),
    );
  }
}
