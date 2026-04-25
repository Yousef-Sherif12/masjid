
import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  const Logo({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 15,
      top: 15,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient:const LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            colors: [ Color(0xff38391a), Colors.transparent],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Column(
                children: [
                const  Text(
                    'المسجـــــــــــــــــــد',
                    style: TextStyle(
                      color: Color(0xffeee8aa),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                const  Text(
                    'الأهليّ الكويتيّ',
                    style: TextStyle(
                      color: Color(0xffeee8aa),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            const  SizedBox(width: 8),
            const  Icon(Icons.mosque, color: Color(0xffeee8aa)),
            ],
          ),
        ),
      ),
    );
  }
}
