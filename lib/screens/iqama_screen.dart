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
              Colors.black.withOpacity(0.65),
              BlendMode.darken,
            ),
          ),
        ),

        // 2. النصوص: في نص الشاشة بالظبط
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('📵', style: TextStyle(fontSize: 90)),
            SizedBox(height: 0),
            Text(
              'يُرجى وضع الهاتف على الصامت',
              textAlign: TextAlign.center,
              style: TextStyle(height:1,
                fontSize: 50,
                color: Color(0xffeee8aa),
                fontWeight: FontWeight.bold,
                fontFamily: 'Tajawal',
              ),
            ),SizedBox(height: 5,),
            Text(
              'النظر موضع السجود في الصلاة',
              textAlign: TextAlign.center,
              style: TextStyle(height: 1,
                fontSize: 50,
                color: Color(0xffeee8aa),
                fontWeight: FontWeight.bold,
                fontFamily: 'Tajawal',
              ),
            ),SizedBox(height: 40,)
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
