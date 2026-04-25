import 'package:flutter/material.dart';

class IqamaScreen extends StatelessWidget {
  final String prayerName;
  const IqamaScreen({super.key, required this.prayerName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        // عشان الـ Positioned يشتغل صح، لازم الـ Stack يملأ الشاشة
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage("assets/images/BG.png"),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3),
              BlendMode.darken,
            ),
          ),
        ),
        child: const Stack(
          alignment: Alignment.center, // ده بيسنتر أي حاجة مش Positioned
          children: [
            // 1. الأيقونة: تقدر تتحكم في التوب براحتك من هنا
            Positioned(
              top: 90, // 👈 غير الرقم ده زي ما أنت عايز تنزلها أو تطلعها
              left: 0,
              right:
                  0, // وضع left و right بـ 0 بيخلي الـ Positioned ياخد عرض الشاشة كله
              child: Center(child: Text('📵', style: TextStyle(fontSize: 90))),
            ),

            // 2. النصوص: في نص الشاشة بالظبط
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 80),
                Text(
                  'يُرجى وضع الهاتف على الصامت',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 50,
                    color: Color(0xffeee8aa),
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Tajawal',
                  ),
                ),
                Text(
                  'النظر في الصلاة موضع السجود',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 50,
                    color: Color(0xffeee8aa),
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
// import 'package:flutter/material.dart';

// class IqamaScreen extends StatelessWidget {
//   final String prayerName;
//   const IqamaScreen({super.key, required this.prayerName});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Container(
//         decoration: BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage("assets/images/BG.png"),
//             fit: BoxFit.cover,
//             // 👇 السطر ده بيضيف طبقة سوداء فوق الصورة بشفافية 60%
//             colorFilter: ColorFilter.mode(
//               Colors.black.withOpacity(0.25), // 0.0 شفاف جداً ، 1.0 أسود تماماً
//               BlendMode.darken, // نمط التغميق
//             ),
//           ),
//         ),
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             spacing: 10,
//             children: [
//               Text('📵', style: TextStyle(fontSize: 80)),
//               Text(
//                 'يُرجى وضع الهاتف على الصامت',
//                 style: TextStyle(
//                   fontSize: 50,
//                   color: Color(0xffeee8aa),
//                   fontWeight: FontWeight.bold,

//                 ),
//               ),
//               Text(
//                 'النظر في الصلاة موضع السجود',
//                 style: TextStyle(
//                   fontSize: 50,
//                   color: Color(0xffeee8aa),
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
