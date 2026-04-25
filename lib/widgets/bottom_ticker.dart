import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:masjid/widgets/Line.dart';

class BottomTicker extends StatelessWidget {
  const BottomTicker({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: Column(
        children: [
          const Line(height: 1),
          const SizedBox(height: 4),

          Expanded(
            child: Marquee(
              text: "اللهمّ تقبل منا طاعاتنا في رمضان 🤲🏻            .            يُرجى وضع الهاتف على الصامت 📵            .            أستغفر الله العظيم وأتوب إليه            .            يُرجى الحفاظ على نظافة المسجد 🕌            .            سبحان الله وبحمدِه .. سبحان الله العظيم            .            يُرجى عدم التدخل في إقامة الصلاة فهي مسئولية الإمام            .            ",
              style: const TextStyle(
                color: Color(0xffeee8aa),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),

              scrollAxis: Axis.horizontal,
              textDirection: TextDirection.rtl,

              velocity: 45, // 👈 السرعة (قللها لو عايز أبطأ)

              // blankSpace: 200,
              accelerationCurve: Curves.linear,
              decelerationCurve: Curves.linear,
              pauseAfterRound: Duration.zero,
            ),
          ),

          const SizedBox(height: 4),
          const Line(height: 1),
        ],
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:marquee/marquee.dart';
// import 'package:masjid/widgets/Line.dart';

// class BottomTicker extends StatelessWidget {
//    const BottomTicker({super.key});

//    @override
//    Widget build(BuildContext context) {
//      return Container(
//        margin: const EdgeInsets.only(bottom: 10),
//        height: 28.5,
//        decoration: const BoxDecoration(color: Colors.transparent),
//        child: Column(
//          children: [
//            const Line(height: 1),
//            SizedBox(height: 3),
//            Expanded(
//              child: Marquee(
//                text:
// 'اللهمّ تقبل منا طاعاتنا في رمضان 🤲🏻        .        قال النبي ﷺ: "من صام رمضان ثم أتبعه ستة من شوال كان كصيام الدهر" .. فمازالت الفرصة أمامك ⏳        .        يُرجى وضع الهاتف على الصامت 📵        .        أستغفر الله العظيم وأتوب إليه        .        يُرجى الحفاظ على نظافة المسجد 🕌        .        سبحان الله وبحمدِه .. سبحان الله العظيم        .        يُرجى عدم التدخل في إقامة الصلاة فهي مسئولية الإمام        .         ',
//                accelerationCurve: Curves.linear,
//                decelerationCurve: Curves.linear,
//                textDirection: TextDirection.rtl,
//                style: const TextStyle(
//                  color: Color(0xffeee8aa),
//                  fontSize: 18,
//                  fontWeight: FontWeight.bold,
//                ),
//                scrollAxis: Axis.horizontal,
//                blankSpace: 150,
//                velocity: 50,
//                startPadding: 15,
//                pauseAfterRound: const Duration(seconds: 1),
//              ),
//            ),
//          ],
//        ),
//      );
//    }
//  }
//  import 'dart:async';
//  import 'package:flutter/material.dart';
//  import 'package:masjid/widgets/Line.dart';

//  class BottomTicker extends StatefulWidget {
//    const BottomTicker({super.key});

//    @override
//    State<BottomTicker> createState() => _BottomTickerState();
//  }

//  class _BottomTickerState extends State<BottomTicker> {
//    late ScrollController _scrollController;
//    Timer? _timer;

//    // النص المطلوب عرضه
//    final String tickerText =
//        'اللَّهُمَّ تَقَبَّلْ مِنَّا طَاعَاتِنَا 🤲🏻                  .                  قال النبي ﷺ: "مَنْ صَامَ رَمَضَانَ ثُمَّ أَتْبَعَهُ سِتًّا مِنْ شَوَّالٍ كَانَ كَصِيَامِ الدَّهْرِ" .. فَمَازَالَتِ الفُرْصَةُ أَمَامَكَ ⏳                  .                  يُرْجَى وَضْعُ الهَاتِفِ عَلَى الصَّامِتِ 📵                  .                  أَسْتَغْفِرُ اللَّهَ العَظِيمَ وَأَتُوبُ إِلَيْهِ                  .                  يُرْجَى الحِفَاظُ عَلَى نَظَافَةِ المَسْجِدِ 🕌                  .                  سُبْحَانَ اللَّهِ وَبِحَمْدِهِ .. سُبْحَانَ اللَّهِ العَظِيمِ                  .                  يُرْجَى عَدَمُ التَّدَخُّلِ فِي إِقَامَةِ الصَّلَاةِ فَهِيَ مَسْئُولِيَّةُ الإِمَامِ 🕌                  .                  النَّظَرُ فِي الصَّلَاةِ مَوْضِعَ السُّجُودِ 🕋';
//    @override
//    void initState() {
//      super.initState();
//      _scrollController = ScrollController();

//      // نبدأ التحريك بعد أول فريم
//      WidgetsBinding.instance.addPostFrameCallback((_) {
//        _startScrolling();
//      });
//    }

//    void _startScrolling() {
//      // التايمر بيتحرك كل 50 مللي ثانية لأداء ناعم
//      _timer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
//        if (_scrollController.hasClients) {
//          double maxScroll = _scrollController.position.maxScrollExtent;
//          double currentScroll = _scrollController.offset;

//          // لو وصلنا للنهاية ارجع للبداية فوراً
//          if (currentScroll >= maxScroll) {
//            _scrollController.jumpTo(0);
//          } else {
//            // تحريك بمقدار 1 بكسل (تقدر تسرع أو تبطئ من هنا)
//            _scrollController.jumpTo(currentScroll + 1);
//          }
//        }
//      });
//    }

//    @override
//    void dispose() {
//      _timer?.cancel();
//      _scrollController.dispose();
//      super.dispose();
//    }

//    @override
//    Widget build(BuildContext context) {
//      return Container(
//        margin: const EdgeInsets.only(bottom: 0),
//        height: 28.5, // ارتفاع مناسب لعدم قص الإيموجي
//        decoration: const BoxDecoration(color: Colors.transparent),
//        child: Column(
//          children: [
//            const Line(height: 1),
//            const SizedBox(height: 3),
//            Expanded(
//              child: RepaintBoundary(
//                // ✅ لعزل عملية الرسم وتحسين الأداء
//                child: ListView.builder(
//                  controller: _scrollController,
//                  scrollDirection: Axis.horizontal,
//                  reverse: true, // عشان يبدأ من اليمين لليسار (RTL)
//                  physics:
//                      const NeverScrollableScrollPhysics(), // منع التمرير اليدوي
//                  itemBuilder: (context, index) {
//                    return Padding(
//                      padding: const EdgeInsets.symmetric(horizontal: 0),
//                      child: Center(
//                        child: Text(
//                          tickerText,
//                          style: const TextStyle(
//                            color: Color(0xffeee8aa),
//                            fontSize: 16,
//                            fontWeight: FontWeight.bold,
//                          ),
//                        ),
//                      ),
//                    );
//                  },
//                ),
//              ),
//            ),
//            const SizedBox(height: 3),

//            const Line(height: 1),

//          ],
//        ),
//      );
//    }
//  }

//  import 'package:flutter/material.dart';
//  import 'package:masjid/widgets/Line.dart';

//  class BottomTicker extends StatefulWidget {
//    const BottomTicker({super.key});

//    @override
//    State<BottomTicker> createState() => _BottomTickerState();
//  }

//  class _BottomTickerState extends State<BottomTicker>
//      with SingleTickerProviderStateMixin {
//    late ScrollController _scrollController;

//    final String tickerText =
//        'اللَّهُمَّ تَقَبَّلْ مِنَّا طَاعَاتِنَا 🤲🏻                  .                  قال النبي ﷺ: "مَنْ صَامَ رَمَضَانَ ثُمَّ أَتْبَعَهُ سِتًّا مِنْ شَوَّالٍ كَانَ كَصِيَامِ الدَّهْرِ" .. فَمَازَالَتِ الفُرْصَةُ أَمَامَكَ ⏳                  .                  يُرْجَى وَضْعُ الهَاتِفِ عَلَى الصَّامِتِ 📵                  .                  أَسْتَغْفِرُ اللَّهَ العَظِيمَ وَأَتُوبُ إِلَيْهِ                  .                  يُرْجَى الحِفَاظُ عَلَى نَظَافَةِ المَسْجِدِ 🕌                  .                  سُبْحَانَ اللَّهِ وَبِحَمْدِهِ .. سُبْحَانَ اللَّهِ العَظِيمِ                  .                  يُرْجَى عَدَمُ التَّدَخُّلِ فِي إِقَامَةِ الصَّلَاةِ                  .                  النَّظَرُ فِي الصَّلَاةِ مَوْضِعَ السُّجُودِ 🕋';

//    @override
//    void initState() {
//      super.initState();
//      _scrollController = ScrollController();

//      WidgetsBinding.instance.addPostFrameCallback((_) {
//        _startScrolling();
//      });
//    }

//    Future<void> _startScrolling() async {
//      while (mounted) {
//        final maxScroll = _scrollController.position.maxScrollExtent;

//        await _scrollController.animateTo(
//          maxScroll,
//          duration: const Duration(seconds: 170), // 👈 السرعة (كبر = أبطأ)
//          curve: Curves.linear,
//        );

//        // 👇 أهم نقطة: رجوع بدون ما المستخدم يحس
//        _scrollController.jumpTo(0);
//      }
//    }

//    @override
//    void dispose() {
//      _scrollController.dispose();
//      super.dispose();
//    }

//    @override
//    Widget build(BuildContext context) {
//      return SizedBox(
//        height: 36,
//        // margin: const EdgeInsets.only(bottom: 3),
//        child: Column(
//          children: [
//            const Line(height: 1),
//            const SizedBox(height: 4),

//            Expanded(
//              child: ClipRect(
//                child: ListView(
//                  controller: _scrollController,
//                  scrollDirection: Axis.horizontal,
//                  reverse: true, // 👈 RTL
//                  physics: const NeverScrollableScrollPhysics(),
//                  children: [
//                    Row(crossAxisAlignment: CrossAxisAlignment.center,
//                      children: [
//                        _buildText(),
//                        const SizedBox(width: 80), // مسافة بين النسختين
//                        _buildText(), // 👈 نسخة تانية
//                      ],
//                    ),
//                  ],
//                ),
//              ),
//            ),

//            const SizedBox(height: 4),
//            const Line(height: 1),
//          ],
//        ),
//      );
//    }

//    Widget _buildText() {
//      return Text(
//        tickerText,
//        maxLines: 1,
//        softWrap: false,
//        style: const TextStyle(
//          color: Color(0xffeee8aa),
//          fontSize: 16,
//          fontWeight: FontWeight.bold,
//        ),
//      );
//    }
//  }
// import 'package:flutter/material.dart';
// import 'package:masjid/widgets/Line.dart';

// class BottomTicker extends StatefulWidget {
//   const BottomTicker({super.key});

//   @override
//   State<BottomTicker> createState() => _BottomTickerState();
// }

// class _BottomTickerState extends State<BottomTicker>
//     with SingleTickerProviderStateMixin {
//   late ScrollController _scrollController;
//   late AnimationController _animationController;

//   final String tickerText =
//       'اللَّهُمَّ تَقَبَّلْ مِنَّا طَاعَاتِنَا 🤲🏻                 .                 قال النبي ﷺ: "مَنْ صَامَ رَمَضَانَ ثُمَّ أَتْبَعَهُ سِتًّا مِنْ شَوَّالٍ كَانَ كَصِيَامِ الدَّهْرِ" .. فَمَازَالَتِ الفُرْصَةُ أَمَامَكَ ⏳                 .                 يُرْجَى وَضْعُ الهَاتِفِ عَلَى الصَّامِتِ 📵                 .                 أَسْتَغْفِرُ اللَّهَ العَظِيمَ وَأَتُوبُ إِلَيْهِ                 .                 يُرْجَى الحِفَاظُ عَلَى نَظَافَةِ المَسْجِدِ 🕌                 .                 سُبْحَانَ اللَّهِ وَبِحَمْدِهِ .. سُبْحَانَ اللَّهِ العَظِيمِ                 .                 يُرْجَى عَدَمُ التَّدَخُّلِ فِي إِقَامَةِ الصَّلَاةِ                 .                 النَّظَرُ فِي الصَّلَاةِ مَوْضِعَ السُّجُودِ 🕋';

//   @override
//   void initState() {
//     super.initState();
//     _scrollController = ScrollController();

//     // ✅ استخدام AnimationController للتحكم الكامل في النعومة
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 170), // السرعة الإجمالية
//     );

//     _animationController.addListener(() {
//       if (_scrollController.hasClients) {
//         final maxScroll = _scrollController.position.maxScrollExtent;
//         // تحريك السكرول بناءً على قيمة الأنيميشن من 0 لـ 1
//         _scrollController.jumpTo(_animationController.value * maxScroll);
//       }
//     });

//     _animationController.repeat(); // جعل الحركة مستمرة (Loop)
//   }

//   @override
//   void dispose() {
//     _animationController.dispose(); // مهم جداً
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 36,
//       color: Colors.transparent,
//       child: Column(
//         children: [
//           const Line(height: 1),
//           const SizedBox(height: 4),
//           Expanded(
//             child: RepaintBoundary( // ✅ مهم جداً لعزل التيكر عن باقي الشاشة وتحسين الأداء
//               child: ListView(
//                 controller: _scrollController,
//                 scrollDirection: Axis.horizontal,
//                 reverse: true, // RTL
//                 physics: const NeverScrollableScrollPhysics(),
//                 children: [
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       _buildText(),
//                       const SizedBox(width: 100), // مسافة الأمان
//                       _buildText(),
//                       const SizedBox(width: 20), // لضمان استمرارية اللوب
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 4),
//           const Line(height: 1),
//         ],
//       ),
//     );
//   }

//   Widget _buildText() {
//     return Text(
//       tickerText,
//       maxLines: 1,
//       softWrap: false,
//       style: const TextStyle(
//         color: Color(0xffeee8aa),
//         fontSize: 16,
//         fontWeight: FontWeight.bold,
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:masjid/widgets/Line.dart';

// class BottomTicker extends StatefulWidget {
//   const BottomTicker({super.key});

//   @override
//   State<BottomTicker> createState() => _BottomTickerState();
// }

// class _BottomTickerState extends State<BottomTicker>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   double textWidth = 0;
//    double gap = 150; // المسافة بين الجملتين

//   final String tickerText =
//       'اللهمّ تقبل منا طاعاتنا في رمضان 🤲🏻        .        قال النبي ﷺ: "من صام رمضان ثم أتبعه ستة من شوال كان كصيام الدهر" .. فمازالت الفرصة أمامك ⏳        .        يُرجى وضع الهاتف على الصامت 📵        .        أَسْتَغْفِرُ اللهَ العظيم وأتوب إليه        .        يُرجى الحفاظ على نظافة المسجد 🕌        .        سبحان الله وبحمدِه .. سبحان الله العظيم        .        يُرجى عدم التدخل في إقامة الصلاة فهي مسئولية الإمام.        ';

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 100),
//     )..repeat();

//     _calculateWidth();
//   }

//   void _calculateWidth() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final textPainter = TextPainter(
//         text: TextSpan(
//           text: tickerText,
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             fontFamily: 'Tajawal',
//           ),
//         ),
//         maxLines: 1,
//         textDirection: TextDirection.rtl,
//       )..layout();

//       setState(() {
//         textWidth = textPainter.width;
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (textWidth == 0) return const SizedBox.shrink();

//     return SizedBox(
//       height: 38,
//       child: Column(
//         children: [
//           const Line(height: 1),
//           const SizedBox(height: 4),
//           Expanded(
//             child: ClipRect(
//               child: AnimatedBuilder(
//                 animation: _controller,
//                 builder: (context, child) {
//                   // ✅ السر هنا: بنتحرك فقط عرض (النص + المسافة) 
//                   // فالعين بتشوف النسخة التانية جت مكان الأولى بالضبط في لحظة إعادة الأنيميشن
//                   final double loopStep = textWidth + gap;
//                   final dx = _controller.value * loopStep;

//                   return Transform.translate(
//                     offset: Offset(dx - loopStep, 0), // تحريك من اليسار لليمين
//                     child: child,
//                   );
//                 },
//                 child: OverflowBox(
//                   maxWidth: double.infinity,
//                   alignment: Alignment.centerLeft,
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       _buildText(),
//                        SizedBox(width: gap),
//                       _buildText(),
//                        SizedBox(width: gap), // نسخة تالتة لضمان عدم وجود فراغ في الشاشات العريضة
//                       _buildText(),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 4),
//           const Line(height: 1),
//         ],
//       ),
//     );
//   }

//   Widget _buildText() {
//     return Text(
//       tickerText,
//       maxLines: 1,
//       softWrap: false,
//       style: const TextStyle(
//         color: Color(0xffeee8aa),
//         fontSize: 16,
//         fontWeight: FontWeight.bold,
//         fontFamily: 'Tajawal',
//       ),
//     );
//   }
// }