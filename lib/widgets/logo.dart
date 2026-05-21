import 'package:flutter/material.dart';
import 'package:masjid/constants/colors.dart';
import 'package:masjid/enums/app_theme_enum.dart';

class Logo extends StatelessWidget {
  Logo({super.key, required this.currentTheme});

  AppThemeEnum currentTheme;
  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 15,
      top: 15,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
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
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Column(
                children: [
                  Text(
                    'المسجـــــــــــــــــــد',
                    style: TextStyle(
                      color:
                          currentTheme == AppThemeEnum.hajTheme ||
                              currentTheme == AppThemeEnum.hajTheme2
                          ? hajTextColor
                          : Color(0xffeee8aa),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'الأهليّ الكويتيّ',
                    style: TextStyle(
                      color:
                          currentTheme == AppThemeEnum.hajTheme ||
                              currentTheme == AppThemeEnum.hajTheme2
                          ? hajTextColor
                          : Color(0xffeee8aa),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.mosque,
                color:
                    currentTheme == AppThemeEnum.hajTheme ||
                        currentTheme == AppThemeEnum.hajTheme2
                    ? hajTextColor
                    : Color(0xffeee8aa),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
