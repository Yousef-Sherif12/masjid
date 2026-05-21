import 'package:flutter/material.dart';
import 'package:masjid/constants/colors.dart';
import 'package:masjid/enums/app_theme_enum.dart';
import 'package:masjid/models/day_prayer.dart';
import 'package:masjid/services/prayer_service.dart';
import 'package:masjid/widgets/Line.dart';

class PrayerTimes extends StatefulWidget {
  PrayerTimes({super.key, required this.currentTheme});
  AppThemeEnum currentTheme;
  @override
  State<PrayerTimes> createState() => _PrayerTimesState();
}

class _PrayerTimesState extends State<PrayerTimes> {
  late Future<DayPrayer?> _prayerFuture;
  @override
  void initState() {
    super.initState();
    // 3. نادي الدالة هنا (مرة واحدة فقط عند تشغيل التطبيق)
    _prayerFuture = PrayerService.getTodayPrayers();
  }

  // أضف ده فوق الـ build
  static Map<String, String> prayerIcons = const {
    'الفجر': 'assets/icons/01-fajr.png',
    'الشروق': 'assets/icons/02-shorouq.png',
    'الظهر': 'assets/icons/03-duhur.png',
    'العصر': 'assets/icons/04-asr.png',
    'المغرب': 'assets/icons/05-mghreb.png',
    'العشاء': 'assets/icons/06-ishaa.png',
  };
  Widget _buildPrayerRow(String name, String time) {
    // 1. تنظيف النص وتقسيمه (بافتراض الوقت جاي "3:20 AM")
    List<String> parts = time.trim().split(' ');
    String rawTimeNumbers = parts[0]; // هتاخد "3:20"
    String rawPeriod = parts.length > 1 ? parts[1].toUpperCase() : "";

    // 2. ضبط التنسيق ليكون خانتين دائماً (03:20)
    List<String> timeParts = rawTimeNumbers.split(':');
    String hours = timeParts[0].padLeft(2, '0'); // لو 3 تبقى 03
    String minutes = timeParts[1].padLeft(2, '0'); // لو كانت خانة واحدة تظبطها
    String timeNumbers = "$hours:$minutes";

    // 3. تحويل الرمز للعربي
    String arabicPeriod = (rawPeriod == "AM" || rawPeriod == "ص") ? "ص" : "م";
    return Padding(
      padding: EdgeInsets.only(
        right: 10,
        left: arabicPeriod == 'م' ? 13 : 10,
        top: 3,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // الوقت على اليسار
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (arabicPeriod == "م") const SizedBox(width: 6),

              Text(
                arabicPeriod,
                style: TextStyle(
                  color:
                      widget.currentTheme == AppThemeEnum.hajTheme ||
                          widget.currentTheme == AppThemeEnum.hajTheme2
                      ? hajTextColor
                      : Color(0xffeee8aa),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (arabicPeriod == "م") const SizedBox(width: 6),
              if (name == 'الظهر') const SizedBox(width: 6),
              Text(
                timeNumbers,
                style: TextStyle(
                  color:
                      widget.currentTheme == AppThemeEnum.hajTheme ||
                          widget.currentTheme == AppThemeEnum.hajTheme2
                      ? hajTextColor
                      : Color(0xffeee8aa),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          // الاسم + الأيقونة على اليمين
          Row(
            children: [
              Text(
                name,
                style: TextStyle(
                  color:
                      widget.currentTheme == AppThemeEnum.hajTheme ||
                          widget.currentTheme == AppThemeEnum.hajTheme2
                      ? hajTextColor
                      : Color(0xffeee8aa),
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 10),
              Image.asset(
                prayerIcons[name]!,
                height: 20,
                width: 20,
                color:
                    widget.currentTheme == AppThemeEnum.hajTheme ||
                        widget.currentTheme == AppThemeEnum.hajTheme2
                    ? hajTextColor
                    : Color(0xffeee8aa),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Future<DayPrayer?> getTodayPrayers() async {
  //   // 1. قراءة الملف
  //   final String response = await rootBundle.loadString(
  //     'assets/jsons/prayer_times_.json',
  //   );
  //   final List<dynamic> data = json.decode(response);

  //   // 2. الحصول على تاريخ النهاردة بنفس تنسيق الجيسون (مثلاً: 2026-04-10)
  //   String todayDate = intl.DateFormat(
  //     'yyyy-MM-dd',
  //     'en',
  //   ).format(DateTime.now());
  //   // 3. البحث عن بيانات النهاردة
  //   try {
  //     final todayData = data.firstWhere(
  //       (element) => element['date'] == todayDate,
  //     );
  //     return DayPrayer.fromJson(todayData);
  //   } catch (e) {
  //     return null; // لو ملاقاش التاريخ
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DayPrayer?>(
      future: _prayerFuture, // الدالة اللي بتبحث في الجيسون عن تاريخ اليوم
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text("مواقيت الصلاة غير متوفرة"));
        }

        // استخراج البيانات منsnapshot
        final todayData = snapshot.data!;
        final prayerNames = todayData.times.keys
            .toList(); // أسماء الصلوات من الجيسون
        final prayerTimes = todayData.times.values
            .toList(); // أوقات الصلوات من الجيسون

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: [
                widget.currentTheme == AppThemeEnum.hajTheme ||
                        widget.currentTheme == AppThemeEnum.hajTheme2
                    ? hajBackGroundColor1
                    : Color(0xff38391a),
                Colors.transparent,
              ],
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(prayerNames.length, (index) {
              bool isLastPrayer = index == prayerNames.length - 1;
              return Column(
                children: [
                  _buildPrayerRow(prayerNames[index], prayerTimes[index]),

                  !isLastPrayer ? const PrayerLine() : const SizedBox(),
                  SizedBox(height: !isLastPrayer ? 5 : 0),
                ],
              );
            }),
          ),
        );
      },
    );
  }
}
