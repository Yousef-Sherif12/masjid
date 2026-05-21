import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:masjid/constants/colors.dart';
import 'package:masjid/enums/app_theme_enum.dart';
import 'package:masjid/models/ticker_message_model.dart';
import 'package:masjid/services/iqama_service.dart';
import 'package:masjid/widgets/Line.dart';

// ignore: must_be_immutable
class BottomTicker extends StatelessWidget {
  BottomTicker({super.key, required this.currentTheme});
  AppThemeEnum currentTheme;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: Column(
        children: [
          const Line(height: 1),
          const SizedBox(height: 4),
// ✅ استخدم StreamBuilder بدل FutureBuilder عشان يتحدث فوراً
Expanded(
  child: StreamBuilder<List<TickerMessage>>(
    stream: IqamaService.listenToTickerMessages(), // ✅ stream
    builder: (context, snapshot) {
      if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return const SizedBox();
      }

      final messages = snapshot.data!
          .where((e) => e.active) // ✅ فلتر المفعّلين بس
          .toList();

      if (messages.isEmpty) return const SizedBox();

      // ✅ المسافات والنقطة صح — قبل وبعد كل نص
      const separator = '            .            ';
      final text = messages
          .map((e) => e.text)
          .join(separator) + separator; // ✅ ضيف separator في الآخر

      return Marquee(
        key: ValueKey(text), // ✅ يعيد البناء لو النص اتغير
        text: text,
        style: TextStyle(
          color: currentTheme == AppThemeEnum.hajTheme ||
                  currentTheme == AppThemeEnum.hajTheme2
              ? hajTextColor
              : const Color(0xffeee8aa),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        scrollAxis: Axis.horizontal,
        textDirection: TextDirection.rtl,
        velocity: 45,
        accelerationCurve: Curves.linear,
        decelerationCurve: Curves.linear,
        pauseAfterRound: Duration.zero,
      );
    },
  ),
),
          // Expanded(
          //   child: Marquee(
          //     text:
          //         "اللهمّ تقبل منا طاعاتنا في رمضان 🤲🏻            .            يُرجى وضع الهاتف على الصامت 📵            .            يُرجى الحفاظ على نظافة المسجد 🕌            .            اللهمّ ارزقنا حجّ بيتِك الحرام 🕋            .            الله أكبر، الله أكبر، الله أكبر.. لا إله إلا الله            .            الله أكبر، الله أكبر، ولله الحمد            .            يُرجى عدم التدخل في إقامة الصلاة فهي مسئولية الإمام            .            ",
          //     // "اللهمّ تقبل منا طاعاتنا في رمضان 🤲🏻            .            يُرجى وضع الهاتف على الصامت 📵            .            أستغفر الله العظيم وأتوب إليه            .            يُرجى الحفاظ على نظافة المسجد 🕌            .            اللهمّ ارزقنا حجّ بيتِك الحرام 🕋            .            سبحان الله وبحمدِه .. سبحان الله العظيم            .            يُرجى عدم التدخل في إقامة الصلاة فهي مسئولية الإمام            .            ",
          //     style: TextStyle(
          //       color:
          //           currentTheme == AppThemeEnum.hajTheme ||
          //               currentTheme == AppThemeEnum.hajTheme2
          //           ? hajTextColor
          //           : Color(0xffeee8aa),
          //       fontSize: 16,
          //       fontWeight: FontWeight.bold,
          //     ),

          //     scrollAxis: Axis.horizontal,
          //     textDirection: TextDirection.rtl,

          //     velocity: 45, // 👈 السرعة (قللها لو عايز أبطأ)
          //     // blankSpace: 200,
          //     accelerationCurve: Curves.linear,
          //     decelerationCurve: Curves.linear,
          //     pauseAfterRound: Duration.zero,
          //   ),
          // ),

          const SizedBox(height: 4),
          const Line(height: 1),
        ],
      ),
    );
  }
}
