import 'package:flutter/material.dart';

class AdhanScreen extends StatefulWidget {
  final String prayerName;
  const AdhanScreen({super.key, required this.prayerName});

  @override
  State<AdhanScreen> createState() => _AdhanScreenState();
}

class _AdhanScreenState extends State<AdhanScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
           Text(
            "حان الآن موعد أذان ${widget.prayerName}",
            style: TextStyle(
              color: Color(0xffeee8aa),
              fontSize: 60,
              fontWeight: FontWeight.bold,
            ),
          ),
          // ✅ النص بيومض بسلاسة
          FadeTransition(
            opacity: _animation,
            child:  const Text(
              "يُرفع الآن الأذان",
              style:  TextStyle(
                color: Color(0xffeee8aa),
                fontSize: 60,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// import 'package:flutter/material.dart';

// class AdhanScreen extends StatelessWidget {
//   final String prayerName;
//   const AdhanScreen({super.key, required this.prayerName});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Text(
//             'يرفع الآن أذان',
//             style: TextStyle(
//               color: Color(0xffeee8aa),
//               fontSize: 90,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 10),
//           Text(
//             'الفجر',
//             style: const TextStyle(
//               color: Color(0xffeee8aa),
//               fontSize: 90,
//               fontWeight: FontWeight.w900,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
