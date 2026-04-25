import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:masjid/enums/adhkar_type_enum.dart';
import 'package:masjid/enums/app_state_enum.dart';
import 'package:masjid/enums/app_theme_enum.dart';
import 'package:masjid/screens/Adhan_Screen.dart';
import 'package:masjid/screens/iqama_screen.dart';
import 'package:masjid/services/iqama_service.dart';
import 'package:masjid/utils/data_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:masjid/models/day_prayer.dart';
import 'package:masjid/models/message_model.dart' show Message;
import 'package:masjid/services/prayer_service.dart';
import 'package:masjid/widgets/ayat_column.dart';
import 'package:masjid/widgets/bottom_ticker.dart';
import 'package:masjid/widgets/logo.dart';
import 'package:masjid/widgets/prayer_time_column.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ar', null);
  WakelockPlus.enable();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Tajawal', textTheme: TextTheme()),
      locale: const Locale('en'),
      supportedLocales: const [Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      home: const Scaffold(body: VideoBackground()),
    );
  }
}

class VideoBackground extends StatefulWidget {
  const VideoBackground({super.key});

  @override
  State<VideoBackground> createState() => _VideoBackgroundState();
}

class _VideoBackgroundState extends State<VideoBackground> {
  VideoPlayerController? _controller;
  final AudioPlayer _audioPlayer = AudioPlayer();
  AppThemeEnum currentTheme = AppThemeEnum.newLightTheme;

  DayPrayer? todayPrayerData;
  Map<String, int> iqamaTimes = {};

  AppState appState = AppState.normal;
  String currentPrayerName = '';
  String _iqamaCountdown = '';
  String? _lastTriggeredPrayer;

  Timer? timer;
  Timer? _clockTimer;
  Timer? _adhkarTimer;

  List<Message> quranMessages = [];
  List<Message> hadithMessages = [];
  List<Message> faniMessages = [];
  List<Message> prayerFromQuranMessages = [];
  List<Message> thaqilMessages = [];

  List<Message> adhkarMessages = [];
  List<Message> adhkarSalahMessages = [];
  List<Message> adhkarSabahMessages = [];
  List<Message> adhkarMasaMessages = [];

  int adhkarIndex = 0;
  int quranIndex = 0;
  int thaqilIndex = 0;
  int hadithIndex = 0;
  int faniIndex = 0;
  int contentTypeIndex = 0;
  int prayerFromQuranIndex = 0;

  DateTime _now = DateTime.now();

  // ✅ cached countdown - مش بيتحسب في كل build
  Map<String, dynamic> _cachedCountdown = {"name": "-", "h": 0, "m": 0, "s": 0};

  Message? get currentMainMessage {
    switch (contentTypeIndex) {
      case 0:
        return quranMessages.isNotEmpty ? quranMessages[quranIndex] : null;
      case 1:
        return hadithMessages.isNotEmpty ? hadithMessages[hadithIndex] : null;
      case 2:
        return prayerFromQuranMessages.isNotEmpty
            ? prayerFromQuranMessages[prayerFromQuranIndex]
            : null;
      case 3:
        return thaqilMessages.isNotEmpty ? thaqilMessages[thaqilIndex] : null;
      default:
        return null;
    }
  }

  void _nextContent() {
    switch (contentTypeIndex) {
      case 0:
        quranIndex = (quranIndex + 1) % quranMessages.length;
        break;
      case 1:
        hadithIndex = (hadithIndex + 1) % hadithMessages.length;
        break;
      case 2:
        prayerFromQuranIndex =
            (prayerFromQuranIndex + 1) % prayerFromQuranMessages.length;
        break; // ✅
      case 3:
        thaqilIndex = (thaqilIndex + 1) % thaqilMessages.length;
        break;
    }
    contentTypeIndex = (contentTypeIndex + 1) % 4; // ✅ 4 محتويات
  }

  void startTimer() {
    timer?.cancel();
    final current = currentMainMessage;
    if (current == null) {
      // ✅ skip ومتوقفش
      _nextContent();
      startTimer();
      return;
    }
    timer = Timer(current.duration, () {
      if (!mounted) return;
      setState(() => _nextContent());
      startTimer();
    });
  }

  AdhkarType currentAdhkarType = AdhkarType.salah;
  bool isManualAdhkar = false;
  List<Message> _getAdhkarByType() {
    switch (currentAdhkarType) {
      case AdhkarType.sabah:
        return [...adhkarSabahMessages];

      case AdhkarType.masa:
        return [...adhkarMasaMessages];

      case AdhkarType.salah:
        return [...adhkarSalahMessages];
    }
  }

  List<Message> _getAdhkarForPrayer(String prayerName) {
    if (prayerName == "الفجر") {
      return [
        ...adhkarSalahMessages,
        ...adhkarSabahMessages,
        ...adhkarSabahMessages,
      ];
    } else if (prayerName == "العصر") {
      return [...adhkarSalahMessages, ...adhkarMasaMessages];
    } else {
      return [...adhkarSalahMessages];
    }
  }

  void _startAdhkarTimer() {
    adhkarIndex = 0;

    if (isManualAdhkar) {
      // 👈 تشغيل من زرار
      adhkarMessages = _getAdhkarByType();
    } else {
      // 👈 تشغيل تلقائي حسب الصلاة
      adhkarMessages = _getAdhkarForPrayer(currentPrayerName);
    }

    _runNextZikr();
  }

  void _runNextZikr() {
    _adhkarTimer?.cancel();
    if (adhkarIndex >= adhkarMessages.length) {
      _controller?.play();
      setState(() {
        appState = AppState.normal;
        _lastTriggeredPrayer = null;
        isManualAdhkar = false; // 👈 رجّع للوضع التلقائي
      });
      return;
    }
    final duration = adhkarMessages[adhkarIndex].duration;
    _adhkarTimer = Timer(duration, () {
      if (!mounted) return;
      setState(() => adhkarIndex++);
      _runNextZikr();
    });
  }

  void _showSabahAdhkar() {
    _adhkarTimer?.cancel();

    isManualAdhkar = true; // 👈 أهم سطر

    adhkarIndex = 0;
    currentAdhkarType = AdhkarType.sabah;
    adhkarMessages = _getAdhkarByType();

    setState(() {
      appState = AppState.adhkar;
    });

    _runNextZikr();
  }

  void _showMasaAdhkar() {
    _adhkarTimer?.cancel();

    isManualAdhkar = true;

    adhkarIndex = 0;
    currentAdhkarType = AdhkarType.masa;
    adhkarMessages = _getAdhkarByType();

    setState(() {
      appState = AppState.adhkar;
    });

    _runNextZikr();
  }

  void _triggerAdhan(String prayerName) {
    if (_lastTriggeredPrayer == prayerName) return;
    _lastTriggeredPrayer = prayerName;
    currentPrayerName = prayerName;
    setState(() => appState = AppState.adhan);
    try {
      _audioPlayer.play(AssetSource('audios/adhan.mp3'));
      // ignore: empty_catches
    } catch (e) {}
    final int delay;
    if (currentPrayerName == 'الشروق') {
      delay = 3;
    } else {
      delay = 60*3;
    }
    Future.delayed( Duration(seconds: delay), () {
      if (!mounted) return;
      _audioPlayer.stop();
      _controller?.play();
      setState(() => appState = AppState.iqamaCount);
    });
  }

  void _checkPrayerTime() {
    if (todayPrayerData == null) return;
    if (appState == AppState.adhan) return;
    final now = DateTime.now();
    const prayerOrder = [
      "الفجر",
      "الشروق",
      "الظهر",
      "العصر",
      "المغرب",
      "العشاء",
    ];
    for (final prayerName in prayerOrder) {
      final timeStr = todayPrayerData!.times[prayerName];
      if (timeStr == null) continue;
      final prayerTime = PrayerService.parseTime(timeStr, now);
      if (now.hour == prayerTime.hour && now.minute == prayerTime.minute) {
        _triggerAdhan(prayerName);
        return;
      }
    }
  }

  String _getIqamaCountdown() {
    if (todayPrayerData == null) return '';
    final now = DateTime.now();
    final timeStr = todayPrayerData!.times[currentPrayerName];
    if (timeStr == null) return '';
    final prayerTime = PrayerService.parseTime(timeStr, now);
    final iqamaMinutes = iqamaTimes[currentPrayerName] ?? 10;
    final iqamaTime = prayerTime.add(Duration(minutes: iqamaMinutes));
    final diff = iqamaTime.difference(now);
    if (diff.isNegative) return '00:00';
    final m = diff.inMinutes.toString().padLeft(2, '0');
    final s = (diff.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _switchToIqama() => setState(() => appState = AppState.iqama);
  void _switchToAdhkar() {
    _adhkarTimer?.cancel();

    adhkarIndex = 0;
    isManualAdhkar = true; // تفعيل الوضع اليدوي لضمان عدم تداخل الأوقات

    // تحديد النوع صراحةً كأذكار صلاة مفروضة
    currentAdhkarType = AdhkarType.salah;
    adhkarMessages = _getAdhkarByType();

    setState(() {
      appState = AppState.adhkar;
    });

    _runNextZikr();
  }

  void _switchToNormal() {
    _controller?.play(); // ✅
    setState(() => appState = AppState.normal);
  } // void _switchToAdhan() => setState(() => appState = AppState.adhan);

  final FocusNode _focusNode = FocusNode();

  bool _onGlobalKey(KeyEvent event) {
    if (event is KeyDownEvent) {
      final key = event.logicalKey;
      if (key == LogicalKeyboardKey.colorF0Red ||
          key == LogicalKeyboardKey.keyA) {
        _switchToIqama();
        return true;
      }
      if (key == LogicalKeyboardKey.colorF1Green ||
          key == LogicalKeyboardKey.keyS) {
        _switchToAdhkar();
        return true;
      }
      if (key == LogicalKeyboardKey.keyD ||
          key == LogicalKeyboardKey.colorF2Yellow) {
        _showSabahAdhkar();
        return true;
      }
      if (key == LogicalKeyboardKey.keyF ||
          key == LogicalKeyboardKey.colorF3Blue) {
        _showMasaAdhkar();
        return true;
      }
    }
    return false;
  }

  String _getVideoPath() {
    switch (currentTheme) {
      case AppThemeEnum.oldTheme:
        return "assets/videos/bg.mp4";
      case AppThemeEnum.newLightTheme:
        return "assets/videos/bg1.mp4";
      case AppThemeEnum.newDarkTheme:
        return "assets/videos/bg1.mp4";
      case AppThemeEnum.theme4:
        return "assets/videos/bg3.mp4";
      case AppThemeEnum.theme5:
        return "assets/videos/bg4.mp4";
    }
  }

  Future<void> _initVideo() async {
    _controller = VideoPlayerController.asset(_getVideoPath());

    await _controller!.initialize();

    if (!mounted) return;

    _controller!
      ..setLooping(true)
      ..setVolume(0)
      ..play();

    setState(() {});
  }

  Future<void> _changeTheme(AppThemeEnum newTheme) async {
    if (currentTheme == newTheme) return;

    currentTheme = newTheme;
    await saveTheme(newTheme);
    await _controller!.pause();
    await _controller!.dispose();

    _controller = VideoPlayerController.asset(_getVideoPath());

    await _controller!.initialize();

    if (!mounted) return;

    _controller!
      ..setLooping(true)
      ..setVolume(0)
      ..play();

    setState(() {});
  }

  Future<void> saveTheme(AppThemeEnum theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', theme.name); // 👈 important
  }

  Future<AppThemeEnum> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('theme');

    if (saved == null) return AppThemeEnum.newLightTheme;

    return AppThemeEnum.values.firstWhere(
      (e) => e.name == saved,
      orElse: () => AppThemeEnum.newLightTheme,
    );
  }

  Future<void> _initApp() async {
    // 1. هات الثيم
    currentTheme = await loadTheme();

    // 2. حضّر الفيديو
    await _initVideo();

    // 3. حمّل الداتا
    _loadAllData();

    // 4. شغّل التايمر
    _startClockTimer();

    setState(() {}); // 👈 مهم عشان يعمل rebuild بعد التحميل
  }

  @override
  void initState() {
    super.initState();

    _initApp();

    ServicesBinding.instance.keyboard.addHandler(_onGlobalKey);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _focusNode.requestFocus(),
    );
  }

  void _loadAllData() async {
    final prayers = await PrayerService.getTodayPrayers();
    final iqama = await IqamaService.getIqamaTimes();
    final quran = await IqamaService.getQuranMessages();
    final hadith = await IqamaService.getHadithMessages();
    final thaqil = await IqamaService.getThaqil();
    final prayerFromQuran = await IqamaService.getPrayerFromQuran();
    final salah = await IqamaService.getAdhkarSalah();
    final sabah = await IqamaService.getAdhkarSabah();
    final masa = await IqamaService.getAdhkarMasa();

    if (!mounted) return;

    setState(() {
      todayPrayerData = prayers;
      iqamaTimes = iqama;
      quranMessages = quran;
      hadithMessages = hadith;
      thaqilMessages = thaqil;
      prayerFromQuranMessages = prayerFromQuran;
      adhkarSalahMessages = salah;
      adhkarSabahMessages = sabah;
      adhkarMasaMessages = masa;

      startTimer(); // هنا مرة واحدة بس
    });
  }

  void _startClockTimer() {
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _now = DateTime.now();
        _cachedCountdown = PrayerService.calculateCountdown(todayPrayerData);
        if (appState == AppState.iqamaCount) {
          _iqamaCountdown = _getIqamaCountdown();
          if (_iqamaCountdown == '00:00') {
            appState = AppState.iqama;
            //!
            //?
            ///
            String currentPrayer = PrayerService.getCurrentPrayerName(
              todayPrayerData,
            );

            int delayMinutes;
            if (currentPrayer == "الفجر" || currentPrayer == "العشاء") {
              delayMinutes = 15;
            } else if (currentPrayer == 'الشروق') {
              delayMinutes = 5;
            } else {
              delayMinutes = 11;
            }

            // 2. الانتظار قبل الانتقال لصفحة الأذكار
            Future.delayed(Duration(minutes: delayMinutes), () {
              if (!mounted) return;
              // التأكد إننا لسه في حالة الإقامة قبل ما ننقل للأذكار
              if (appState == AppState.iqama && !isManualAdhkar) {
                setState(() => appState = AppState.adhkar);
                _startAdhkarTimer();
              }
            });
          }
        }
      });
      _checkPrayerTime();
    });
  }

  @override
  void dispose() {
    ServicesBinding.instance.keyboard.removeHandler(_onGlobalKey);
    timer?.cancel();
    _clockTimer?.cancel();
    _adhkarTimer?.cancel();
    _audioPlayer.dispose();
    _controller!.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const SizedBox(); // أو لودينج
    }
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      descendantsAreFocusable: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          final keyName = event.logicalKey.debugName;
          final key = event.logicalKey;
          if (keyName == 'ColorF0Red' ||
              key == LogicalKeyboardKey.keyA ||
              key.keyId == 0x100070001) {
            _switchToIqama();
            return KeyEventResult.handled;
          }
          if (keyName == 'ColorF1Green' ||
              key == LogicalKeyboardKey.keyS ||
              key.keyId == 0x100070002) {
            _switchToAdhkar();
            return KeyEventResult.handled;
          }
          if (keyName == 'ColorF2Yellow' ||
              key == LogicalKeyboardKey.keyD ||
              key.keyId == 0x100070003) {
            _showSabahAdhkar();
            return KeyEventResult.handled;
          }
          if (keyName == 'ColorF2Blue' ||
              key == LogicalKeyboardKey.keyF ||
              key.keyId == 0x100070004) {
            _showMasaAdhkar();
            return KeyEventResult.handled;
          }
          if (key == LogicalKeyboardKey.digit0) {
            _switchToNormal();

            return KeyEventResult.handled;
          }
          if (key == LogicalKeyboardKey.digit1) {
            _changeTheme(AppThemeEnum.oldTheme);

            return KeyEventResult.handled;
          }
          if (key == LogicalKeyboardKey.digit2) {
            _changeTheme(AppThemeEnum.newLightTheme);
            return KeyEventResult.handled;
          }
          if (key == LogicalKeyboardKey.digit3) {
            _changeTheme(AppThemeEnum.newDarkTheme);
            return KeyEventResult.handled;
          }
          if (key == LogicalKeyboardKey.digit4) {
            _changeTheme(AppThemeEnum.theme4);
            return KeyEventResult.handled;
          }
          if (key == LogicalKeyboardKey.digit5) {
            _changeTheme(AppThemeEnum.theme5);
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Scaffold(
        extendBody: true,

        body: Stack(
          children: [
            // ✅ الفيديو في RepaintBoundary منفصل
            if (_controller!.value.isInitialized)
              RepaintBoundary(
                child: SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller!.value.size.width,
                      height: _controller!.value.size.height,
                      child: VideoPlayer(_controller!),
                    ),
                  ),
                ),
              ),

            // SizedBox.expand(child: FittedBox(fit: BoxFit.cover, child: Image.asset('assets/images/bg2.png'))),

            // ✅ البلور في widget منفصل مش بيتأثر بالـ setState
            BlurOverlay(currentTheme: currentTheme),
            _buildMainContent(_now, _cachedCountdown),
            if (appState == AppState.normal ||
                appState == AppState.iqamaCount ||
                appState == AppState.adhkar)
              const Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: RepaintBoundary(child: BottomTicker()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(DateTime now, Map<String, dynamic> countdown) {
    if (appState == AppState.adhan) {
      return AdhanScreen(prayerName: currentPrayerName);
    }
    if (appState == AppState.iqama) {
      return IqamaScreen(prayerName: currentPrayerName);
    }
    return Stack(
      children: [
        Row(
          children: [
            PrayerTimesAndDateColunm(
              hijriDate: DateHelper.formatHijriDate(now),
              date: DateHelper.formatDate(now),
              day: DateHelper.formatDay(now),
              fullTime: DateHelper.formatTime(now),
              nextPrayName: countdown['name'],
              hours: countdown['h'],
              minutes: countdown['m'],
              seconds: countdown['s'],
              iqamaTime: _iqamaCountdown,
              appState: appState,
              currentTheme: currentTheme,
            ),
            AyatColumn(
              currentMessage: currentMainMessage,
              appState: appState,
              adhkarMessages: adhkarMessages,
              adhkarIndex: adhkarIndex,
              currentTheme: currentTheme,
            ),
          ],
        ),
        const Logo(),
      ],
    );
  }
}

// ✅ widget منفصل للبلور عشان مش يتعمله rebuild مع setState
// ignore: must_be_immutable
class BlurOverlay extends StatelessWidget {
  BlurOverlay({super.key, required this.currentTheme});
  AppThemeEnum currentTheme;
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: RepaintBoundary(
        child: Container(
          color:
              currentTheme == AppThemeEnum.theme4 ||
                  currentTheme == AppThemeEnum.theme5
              ? Colors.black.withOpacity(0.8)
              : Colors.black.withOpacity(0.3),
        ),
      ),
    );
  }
}
