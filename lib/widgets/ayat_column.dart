import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:masjid/constants/colors.dart';
import 'package:masjid/enums/app_state_enum.dart';
import 'package:masjid/enums/app_theme_enum.dart';
import 'package:masjid/models/message_model.dart';
import 'package:masjid/widgets/Line.dart';

// ignore: must_be_immutable
class AyatColumn extends StatelessWidget {
  AyatColumn({
    super.key,
    required this.currentMessage,
    required this.appState,
    required this.adhkarMessages,
    required this.adhkarIndex,
    required this.currentTheme,
    required this.collectionLabel, // ✅
  });
  final String collectionLabel; // ✅

  final Message? currentMessage;
  final AppState appState;
  final List<Message> adhkarMessages;
  final int adhkarIndex;
  AppThemeEnum currentTheme;

  @override
  Widget build(BuildContext context) {
    // 1. تحدي
    //د الرسالة الحالية (أذكار أو محتوى عام)
    final isAdhkarMode = appState == AppState.adhkar;
    final Message? displayMessage = isAdhkarMode
        ? (adhkarIndex < adhkarMessages.length
              ? adhkarMessages[adhkarIndex]
              : null)
        : currentMessage;
    List<TextSpan> parseText(String text) {
      final List<TextSpan> spans = [];
      String buffer = '';

      for (int i = 0; i < text.length; i++) {
        final char = text[i];

        if (char == '۝') {
          if (buffer.isNotEmpty) {
            spans.add(TextSpan(text: buffer)); // 👈 ياخد Roboto من الأب
            buffer = '';
          }

          spans.add(
            const TextSpan(
              text: '۝',
              style: TextStyle(fontFamily: 'AmiriQuran'),
            ),
          );
        } else {
          buffer += char;
        }
      }

      if (buffer.isNotEmpty) {
        spans.add(TextSpan(text: buffer));
      }

      return spans;
    }

    return Expanded(
      flex: 7,
      child: Container(
        margin: const EdgeInsets.only(right: 0, left: 0, top: 10, bottom: 42),
        decoration: BoxDecoration(
          color: currentTheme == AppThemeEnum.newDarkTheme
              ? Colors.black.withOpacity(0.3)
              : currentTheme == AppThemeEnum.newLightTheme
              ? Colors.white.withOpacity(0.06)
              : Colors.transparent,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              Line(height: 1, currentTheme: currentTheme,),
              const SizedBox(height: 50),

              // ✅ العنوان وعداد الإقامة (ثابتين)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isAdhkarMode
                        ? displayMessage?.title ?? "أذكار"
                        : collectionLabel.isNotEmpty
                        ? collectionLabel
                        : displayMessage?.title ?? '',
                    style: TextStyle(
                      color:
                          currentTheme == AppThemeEnum.hajTheme ||
                              currentTheme == AppThemeEnum.hajTheme2
                          ? hajTextColor
                          : currentTheme == AppThemeEnum.newLightTheme
                          ? whiteBgTextColor
                          : Color(0xffeee8aa),
                      fontWeight: FontWeight.bold,
                      fontSize: 35,
                    ),
                  ),
                ],
              ),

              Line(currentTheme: currentTheme,),

              // ✅ قسم المحتوى المتحرك (كتلة واحدة من الشمال لليمين)
              Expanded(
                child: ClipRect(
                  // لمنع خروج الأنميشن عن الحدود
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 2000),
                    // الـ LayoutBuilder هنا عشان الـ Stack يخلي القديم يخرج والجديد يدخل بسلاسة
                    layoutBuilder:
                        (Widget? currentChild, List<Widget> previousChildren) {
                          return Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              ...previousChildren,
                              if (currentChild != null) currentChild,
                            ],
                          );
                        },
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      // تحديد لو الوجت هو اللي "داخل" دلوقتي عشان اتجاه السلايد
                      final bool isInAnimation =
                          child.key == ValueKey(displayMessage?.text ?? '');

                      // من الشمال (-1.0) لليمين
                      final begin = isInAnimation
                          ? const Offset(-1.0, 0.0)
                          : const Offset(1.0, 0.0);
                      const end = Offset.zero;

                      return SlideTransition(
                        position: Tween<Offset>(begin: begin, end: end).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeInOutQuart,
                          ),
                        ),
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                    child: displayMessage == null
                        ? const SizedBox(key: ValueKey('empty'))
                        : LayoutBuilder(
                            // الـ Key هنا على الـ Container لضمان تحريك العمود كاملاً ككتلة
                            key: ValueKey(displayMessage.text),
                            builder: (context, constraints) {
                              // حساب المساحة التقريبية للعناصر الإضافية لخصمها من النص الأساسي
                              // double extraSpace = 0;
                              // if (displayMessage.fadl != null) extraSpace += 75;
                              // if (displayMessage.subText != null) {
                              //   extraSpace += 55;
                              // }

                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                child: Center(
                                  child: Column(
                                    // mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,

                                    children: [
                                      // 1. النص الأساسي (بياخد المساحة المتاحة ويصغر نفسه إجبارياً)
                                      Flexible(
                                        child: AutoSizeText.rich(
                                          TextSpan(
                                            children: parseText(
                                              displayMessage.text,
                                            ),
                                            style: TextStyle(
                                              color:
                                                  currentTheme ==
                                                          AppThemeEnum
                                                              .hajTheme ||
                                                      currentTheme ==
                                                          AppThemeEnum.hajTheme2
                                                  ? hajTextColor
                                                  : currentTheme ==
                                                        AppThemeEnum
                                                            .newLightTheme
                                                  ? whiteBgTextColor
                                                  : Color(0xffeee8aa),
                                              fontFamily: 'Roboto',
                                              height: 1.4,
                                              fontWeight: FontWeight.bold,
                                              fontSize: displayMessage
                                                  .calculateFontSize,
                                            ),
                                          ),
                                          textAlign: TextAlign.center,
                                          textDirection: TextDirection.rtl,
                                          maxFontSize:
                                              displayMessage.calculateFontSize,
                                          minFontSize: 5,
                                          stepGranularity: 1,
                                          maxLines: 15,
                                        ),
                                      ),

                                      // 2. الفضل
                                      if (displayMessage.fadl != null &&
                                          displayMessage.fadl!.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 4,
                                          ),
                                          child: Text(
                                            displayMessage.fadl!,
                                            textAlign: TextAlign.center,
                                            textDirection: TextDirection.rtl,
                                            maxLines: 5,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color:
                                                  currentTheme ==
                                                          AppThemeEnum
                                                              .hajTheme ||
                                                      currentTheme ==
                                                          AppThemeEnum.hajTheme2
                                                  ? hajTextColor
                                                  : currentTheme ==
                                                        AppThemeEnum
                                                            .newLightTheme
                                                  ? whiteBgTextColor
                                                  : Color(0xffeee8aa),
                                              fontWeight: FontWeight.w500,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),

                                      // 3. المعلومات الفرعية (الراوي / المصدر)
                                      if (displayMessage.subText != null &&
                                          displayMessage.subText!.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 4,
                                          ),
                                          child: Text(
                                            displayMessage.subText!,
                                            textAlign: TextAlign.center,
                                            textDirection: TextDirection.rtl,
                                            style: TextStyle(
                                              color:
                                                  currentTheme ==
                                                          AppThemeEnum
                                                              .hajTheme ||
                                                      currentTheme ==
                                                          AppThemeEnum.hajTheme2
                                                  ? hajTextColor
                                                  : currentTheme ==
                                                        AppThemeEnum
                                                            .newLightTheme
                                                  ? whiteBgTextColor
                                                  : Color(0xffeee8aa),
                                              fontWeight: FontWeight.w400,
                                              fontSize: 24,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ),

              Line(height: 1, currentTheme: currentTheme,),
            ],
          ),
        ),
      ),
    );
  }
}
