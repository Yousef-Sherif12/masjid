import 'dart:async';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:masjid/enums/adhkar_type_enum.dart';
import 'package:masjid/enums/app_state_enum.dart';
import 'package:masjid/enums/app_theme_enum.dart';
import 'package:masjid/firebase_options.dart';
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
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('ar', null);
  WakelockPlus.enable();
  // await FirebaseFirestore.instance
  //     .collection('settings')
  //     .doc('live_display')
  //     .set({
  //       'collection': '',
  //       'docId': '',
  //       'active': false,
  //     }, SetOptions(merge: true)); // merge عشان ميمسحش اللي موجود
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
  List<Map<String, dynamic>> _activeCollections = [];

  final AudioPlayer _audioPlayer = AudioPlayer();
  AppThemeEnum currentTheme = AppThemeEnum.newLightTheme;

  // Live Display
  Message? _liveMessage;
  bool _isLiveDisplay = false;
  StreamSubscription? _liveDisplaySubscription;

  DayPrayer? todayPrayerData;
  Map<String, int> iqamaTimes = {};

  AppState appState = AppState.normal;
  String currentPrayerName = '';
  String _iqamaCountdown = '';
  String? _lastTriggeredPrayer;

  Timer? timer;
  Timer? _clockTimer;
  Timer? _adhkarTimer;

  // List<Message> quranMessages = [];
  // List<Message> hadithMessages = [];
  // List<Message> faniMessages = [];
  // List<Message> prayerFromQuranMessages = [];
  // List<Message> thaqilMessages = [];

  List<Message> adhkarMessages = [];
  List<Message> adhkarSalahMessages = [];
  List<Message> adhkarSabahMessages = [];
  List<Message> adhkarMasaMessages = [];
  Map<String, List<Message>> _collectionMessages = {};
  List<String> _activeCollectionKeys = [];
  Map<String, int> _collectionIndices = {};

  int adhkarIndex = 0;
  // int quranIndex = 0;
  // int thaqilIndex = 0;
  // int hadithIndex = 0;
  // int faniIndex = 0;
  int contentTypeIndex = 0;
  // int prayerFromQuranIndex = 0;

  bool isManualIqama = false; // عشان نفرق بين النوعين

  DateTime _now = DateTime.now();

  // ✅ cached countdown - مش بيتحسب في كل build
  Map<String, dynamic> _cachedCountdown = {"name": "-", "h": 0, "m": 0, "s": 0};
  Message? get currentMainMessage {
    if (_activeCollectionKeys.isEmpty) return null;
    final key =
        _activeCollectionKeys[contentTypeIndex % _activeCollectionKeys.length];

    final messages = _collectionMessages[key] ?? [];
    if (messages.isEmpty) return null;
    final index = _collectionIndices[key] ?? 0;
    return messages[index % messages.length];
  }

  // Message? get currentMainMessage {
  //   switch (contentTypeIndex) {
  //     case 0:
  //       return quranMessages.isNotEmpty ? quranMessages[quranIndex] : null;
  //     case 1:
  //       return hadithMessages.isNotEmpty ? hadithMessages[hadithIndex] : null;
  //     case 2:
  //       return prayerFromQuranMessages.isNotEmpty
  //           ? prayerFromQuranMessages[prayerFromQuranIndex]
  //           : null;
  //     case 3:
  //       return thaqilMessages.isNotEmpty ? thaqilMessages[thaqilIndex] : null;
  //     default:
  //       return null;
  //   }
  // }
  void _nextContent() {
    if (_activeCollectionKeys.isEmpty) return;
    final key =
        _activeCollectionKeys[contentTypeIndex % _activeCollectionKeys.length];
    final messages = _collectionMessages[key] ?? [];
    if (messages.isNotEmpty) {
      final currentIndex = _collectionIndices[key] ?? 0;
      _collectionIndices[key] = (currentIndex + 1) % messages.length;
    }
    contentTypeIndex = (contentTypeIndex + 1) % _activeCollectionKeys.length;
  }
  // void _nextContent() {
  //   switch (contentTypeIndex) {
  //     case 0:
  //       quranIndex = (quranIndex + 1) % quranMessages.length;
  //       break;
  //     case 1:
  //       hadithIndex = (hadithIndex + 1) % hadithMessages.length;
  //       break;
  //     case 2:
  //       prayerFromQuranIndex =
  //           (prayerFromQuranIndex + 1) % prayerFromQuranMessages.length;
  //       break; // ✅
  //     case 3:
  //       thaqilIndex = (thaqilIndex + 1) % thaqilMessages.length;
  //       break;
  //   }
  //   contentTypeIndex = (contentTypeIndex + 1) % 4; // ✅ 4 محتويات
  // }

  StreamSubscription? _collectionsSubscription;
  void _listenToCollectionsChanges() {
    _collectionsSubscription = FirebaseFirestore.instance
        .collection('collections_config')
        .snapshots()
        .listen((snapshot) async {
          if (!mounted) return;

          final newActiveKeys =
              snapshot.docs
                  .where((doc) => doc.data()['active'] == true)
                  .toList()
                ..sort(
                  (a, b) => (a.data()['order'] ?? 0).compareTo(
                    b.data()['order'] ?? 0,
                  ),
                );

          final keys = newActiveKeys.map((doc) => doc.id).toList();

          if (keys.toString() != _activeCollectionKeys.toString()) {
            // ✅ امسح كاش الـ collections
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('cache_active_collections');

            final Map<String, List<Message>> messages = {};
            for (final key in keys) {
              messages[key] =
                  _collectionMessages[key] ??
                  await IqamaService.getCollectionMessages(key);
            }

            if (!mounted) return;

            final newIndices = {for (final k in keys) k: 0};

            setState(() {
              _activeCollectionKeys = keys;
              _collectionMessages = messages;
              _collectionIndices = newIndices;
              contentTypeIndex = 0;

              // ✅ ضيف السطر ده
              _activeCollections =
                  snapshot.docs
                      .where((doc) => doc.data()['active'] == true)
                      .map((doc) => {'id': doc.id, ...doc.data()})
                      .toList()
                    ..sort(
                      (a, b) => (a['order'] ?? 0).compareTo(b['order'] ?? 0),
                    );
            });
            timer?.cancel();
            startTimer();
          }
        });
  }

  void _listenToLiveDisplay() {
    _liveDisplaySubscription = FirebaseFirestore.instance
        .collection('settings')
        .doc('live_display')
        .snapshots()
        .listen((snapshot) {
          if (!mounted) return;
          final data = snapshot.data();

          // 1. لو الأدمن قفل العرض (active == false)
          if (data == null || data['active'] != true) {
            if (_isLiveDisplay) {
              // لو كانت الرسالة معروضة فعلاً
              setState(() {
                _isLiveDisplay = false;
                _liveMessage = null;
              });
              startTimer(); // رجّع التايمر العادي يشتغل لعرض المحتوى الدوري
            }
            return;
          }

          // 2. استخراج البيانات من Firebase
          final collection = data['collection'] as String;
          final docId = data['docId'] as String;
          if (collection.isEmpty || docId.isEmpty) return;

          final allMessages = {
            ..._collectionMessages, // ✅ ديناميكي
            'adhkar_salah': adhkarSalahMessages,
            'adhkar_sabah': adhkarSabahMessages,
            'adhkar_masa': adhkarMasaMessages,
          };
          // final allMessages = {
          //   'quran_messages': quranMessages,
          //   'hadith_messages': hadithMessages,
          //   'thaqil': thaqilMessages,
          //   'prayer_from_quran': prayerFromQuranMessages,
          //   'adhkar_salah': adhkarSalahMessages,
          //   'adhkar_sabah': adhkarSabahMessages,
          //   'adhkar_masa': adhkarMasaMessages,
          // };

          // 3. البحث عن الرسالة المطلوبة
          Message? found;
          final list = allMessages[collection];
          if (list != null) {
            try {
              found = list.firstWhere((msg) => msg.docId == docId);
            } catch (e) {
              found = null;
            }
          }

          // 4. عرض الرسالة وإيقاف التايمر الدوري
          if (found != null) {
            timer?.cancel(); // وقف عرض القرآن/الحديث الدوري
            setState(() {
              _liveMessage = found;
              _isLiveDisplay = true;
            });
          }
        });
  }

  void startTimer() {
    timer?.cancel();
    final current = currentMainMessage;

    if (current == null) {
      _nextContent(); // ✅ skip بدل ما يوقف
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
      adhkarMessages = _getAdhkarByType();
    } else {
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
    isManualIqama = false;
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
    isManualIqama = false;
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
    _controller?.play();
    setState(() {
      _audioPlayer.stop(); // إيقاف الصوت عند العودة للوضع الطبيعي

      appState = AppState.adhan;
    });
    try {
      if (currentPrayerName != 'الشروق') {
        _audioPlayer.stop(); // إيقاف الصوت عند العودة للوضع الطبيعي

        _audioPlayer.play(AssetSource('audios/adhan.mp3'));
      }
      // ignore: empty_catches
    } catch (e) {}
    final int delay;
    if (currentPrayerName == 'الشروق') {
      delay = 3;
    } else {
      delay = 60 * 3;
    }
    Future.delayed(Duration(seconds: delay), () {
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
      // if (now.hour == prayerTime.hour && now.minute == prayerTime.minute) {
      //   _triggerAdhan(prayerName);
      //   return;
      // }
      final diff = prayerTime.difference(now).inSeconds;

      if (diff <= 0 && diff > -60) {
        _triggerAdhan(prayerName);
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

    if (diff.isNegative || diff.inSeconds <= 0) return '00:00';

    // ✅ الحساب الصح بالثواني
    final totalSeconds = diff.inSeconds;
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
  // String _getIqamaCountdown() {
  //   if (todayPrayerData == null) return '';
  //   final now = DateTime.now();
  //   final timeStr = todayPrayerData!.times[currentPrayerName];
  //   if (timeStr == null) return '';
  //   final prayerTime = PrayerService.parseTime(timeStr, now);
  //   final iqamaMinutes = iqamaTimes[currentPrayerName] ?? 10;
  //   final iqamaTime = prayerTime.add(Duration(minutes: iqamaMinutes));
  //   final diff = iqamaTime.difference(now);
  //   if (diff.isNegative) return '00:00';
  //   final m = diff.inMinutes.toString().padLeft(2, '0');
  //   final s = (diff.inSeconds % 60).toString().padLeft(2, '0');
  //   return '$m:$s';
  // }

  void _switchToIqama() {
    setState(() {
      appState = AppState.iqama;
      isManualIqama = false;
    });

    // حساب الوقت بناءً على الصلاة الحالية
    String currentPrayer = PrayerService.getCurrentPrayerName(todayPrayerData);
    int delayMinutes = (currentPrayer == "الفجر" || currentPrayer == "العشاء")
        ? 15
        : 11;
    if (currentPrayer == 'الشروق') delayMinutes = 5;

    // تايمر الخروج التلقائي حتى للضغط اليدوي
    Future.delayed(Duration(minutes: delayMinutes), () {
      if (!mounted) return;
      // لو لسه على شاشة الإقامة ومحدش غير الحالة يدوياً لحاجة تانية
      if (appState == AppState.iqama) {
        setState(() => appState = AppState.adhkar);
        _startAdhkarTimer();
      }
    });
  }

  void _switchToAdhkar() {
    _adhkarTimer?.cancel();

    adhkarIndex = 0;
    isManualAdhkar = true; // تفعيل الوضع اليدوي لضمان عدم تداخل الأوقات
    isManualIqama = false;
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
    isManualAdhkar = false;
    isManualIqama = false;
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
      case AppThemeEnum.hajTheme:
        return "assets/videos/haram3.mp4";
      case AppThemeEnum.hajTheme2:
        return "assets/videos/haram2.mp4";
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

    // ✅ إيقاف صوت تكبيرات العيد (أو أي صوت شغال) فور تغيير الثيم
    await _audioPlayer.stop();
    await _audioPlayer.setReleaseMode(ReleaseMode.release);

    currentTheme = newTheme;
    await saveTheme(newTheme);

    // 🚨 تم حذف سطر getAttributes الخطأ من هنا
    if (_controller != null) {
      await _controller!.pause();
      await _controller!.dispose();
    }

    _controller = VideoPlayerController.asset(_getVideoPath());

    await _controller!.initialize();

    if (!mounted) return;

    _controller!
      ..setLooping(true)
      ..setVolume(0)
      ..play();

    setState(() {});
  }
  // Future<void> _changeTheme(AppThemeEnum newTheme) async {
  //   if (currentTheme == newTheme) return;

  //   currentTheme = newTheme;
  //   await saveTheme(newTheme);
  //   await _controller?.pause();
  //   await _controller?.dispose();

  //   _controller = VideoPlayerController.asset(_getVideoPath());

  //   await _controller!.initialize();

  //   if (!mounted) return;

  //   _controller!
  //     ..setLooping(true)
  //     ..setVolume(0)
  //     ..play();

  //   setState(() {});
  // }

  Future<void> saveTheme(AppThemeEnum theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', theme.name);
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
    currentTheme = await loadTheme();

    await _initVideo();

    _loadAllData();

    _startClockTimer();

    setState(() {});
  }

  // upload_data.dart - شغّله مرة واحدة بس
  Future<void> uploadAllJsons() async {
    final db = FirebaseFirestore.instance;

    final collections = {
      'quran_messages': 'assets/jsons/quran_messages.json',
      'hadith_messages': 'assets/jsons/hadith_messages.json',
      'prayer_from_quran': 'assets/jsons/prayer_from_quran.json',
      'thaqil': 'assets/jsons/thaqil.json',
      'adhkar_salah': 'assets/jsons/adhkar_salah.json',
      'adhkar_sabah': 'assets/jsons/sabah_adhkar.json',
      'adhkar_masa': 'assets/jsons/masaa_adhkar.json',
    };

    for (final entry in collections.entries) {
      try {
        await _uploadMessages(db, entry.key, entry.value);
        // ignore: empty_catches
      } catch (e) {}
    }
    try {
      await _uploadIqama(db);
      await db.collection('settings').doc('versions').set({
        'messages_version': 1,
        'prayers_version': 1,
        'iqama_version': 1,
      });
      // ignore: empty_catches
    } catch (e) {}
  }

  Future<void> _uploadMessages(
    FirebaseFirestore db,
    String collectionName,
    String jsonPath,
  ) async {
    final String response = await rootBundle.loadString(jsonPath);
    final List<dynamic> data = json.decode(response);

    // احذف القديم الأول
    final existing = await db.collection(collectionName).get();
    for (final doc in existing.docs) {
      await doc.reference.delete();
    }

    // ارفع الجديد
    for (int i = 0; i < data.length; i++) {
      await db.collection(collectionName).add({
        ...data[i],
        'order': i, // ✅ مهم للترتيب
      });
    }
  }

  Future<void> _uploadIqama(FirebaseFirestore db) async {
    final String response = await rootBundle.loadString(
      'assets/jsons/iqama_times.json',
    );
    final Map<String, dynamic> data = json.decode(response);

    await db.collection('settings').doc('iqama_times').set(data);
  }

  @override
  void initState() {
    super.initState();

    _initApp();
    // uploadAllJsons();
    _listenToVersionChanges();
    _listenToCollectionsChanges(); // ✅
    _listenToLiveDisplay();

    ServicesBinding.instance.keyboard.addHandler(_onGlobalKey);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _focusNode.requestFocus(),
    );
  }

  void _listenToVersionChanges() {
    FirebaseFirestore.instance
        .collection('settings')
        .doc('versions')
        .snapshots()
        .listen((snapshot) async {
          if (!mounted) return;
          final data = snapshot.data();
          if (data == null) return;

          final prefs = await SharedPreferences.getInstance();
          final localVersion = prefs.getInt('messages_version') ?? 0;
          final remoteVersion = (data['messages_version'] ?? 0) as int;

          if (remoteVersion > localVersion) {
            // ✅ امسح كل الكاش بما فيه collections
            prefs
                .getKeys()
                .where((k) => k.startsWith('cache_'))
                .forEach((k) => prefs.remove(k));

            await prefs.setInt('messages_version', remoteVersion);
            IqamaService.resetSessionCache();
            await _reloadMessages();
          }
        });
  }

  Future<void> _reloadMessages() async {
    // ✅ أول حاجة — جيب الـ collections النشطة الجديدة
    final activeCollections = await IqamaService.getActiveCollections();
    final keys = activeCollections.map((c) => c['id'] as String).toList();

    final Map<String, List<Message>> messages = {};
    for (final key in keys) {
      messages[key] = await IqamaService.getCollectionMessages(key);
    }

    final salah = await IqamaService.getAdhkarSalah();
    final sabah = await IqamaService.getAdhkarSabah();
    final masa = await IqamaService.getAdhkarMasa();

    if (!mounted) return;

    final newIndices = {for (final k in keys) k: 0};

    setState(() {
      _activeCollections = activeCollections; // ✅
      _activeCollectionKeys = keys;
      _collectionMessages = messages;
      _collectionIndices = newIndices;
      contentTypeIndex = 0;
      adhkarSalahMessages = salah;
      adhkarSabahMessages = sabah;
      adhkarMasaMessages = masa;
    });

    // ✅ أعد تشغيل التايمر
    timer?.cancel();
    startTimer();
  }
  // Future<void> _reloadMessages() async {
  //   final quran = await IqamaService.getQuranMessages();
  //   final hadith = await IqamaService.getHadithMessages();
  //   final thaqil = await IqamaService.getThaqil();
  //   final prayerFromQuran = await IqamaService.getPrayerFromQuran();
  //   final salah = await IqamaService.getAdhkarSalah(); // ✅
  //   final sabah = await IqamaService.getAdhkarSabah(); // ✅
  //   final masa = await IqamaService.getAdhkarMasa(); // ✅

  //   if (!mounted) return;
  //   setState(() {
  //     quranMessages = quran;
  //     hadithMessages = hadith;
  //     thaqilMessages = thaqil;
  //     prayerFromQuranMessages = prayerFromQuran;
  //     adhkarSalahMessages = salah; // ✅
  //     adhkarSabahMessages = sabah; // ✅
  //     adhkarMasaMessages = masa; // ✅
  //   });

  // }

  String get currentCollectionLabel {
    print('🏷️ _activeCollections: $_activeCollections');
    print('🏷️ _activeCollectionKeys: $_activeCollectionKeys');
    print('🏷️ contentTypeIndex: $contentTypeIndex');

    if (_activeCollectionKeys.isEmpty) return '';
    final key =
        _activeCollectionKeys[contentTypeIndex % _activeCollectionKeys.length];
    print('🏷️ looking for key: $key');

    final col = _activeCollections.firstWhere(
      (c) => c['id'] == key,
      orElse: () => {'label': ''},
    );
    print('🏷️ found col: $col');
    print('🏷️ label: ${col['label']}');

    return col['label']?.toString() ?? '';
  }

  void _loadAllData() async {
    final prayers = await PrayerService.getTodayPrayers();
    final iqama = await IqamaService.getIqamaTimes();

    // ✅ جيب النشطين بس بدل الـ hardcoded
    final activeCollections = await IqamaService.getActiveCollections();
    final keys = activeCollections.map((c) => c['id'] as String).toList();

    final Map<String, List<Message>> messages = {};
    for (final key in keys) {
      messages[key] = await IqamaService.getCollectionMessages(key);
    }

    final salah = await IqamaService.getAdhkarSalah();
    final sabah = await IqamaService.getAdhkarSabah();
    final masa = await IqamaService.getAdhkarMasa();

    if (!mounted) return;

    final newIndices = {for (final k in keys) k: 0};

    setState(() {
      todayPrayerData = prayers;
      iqamaTimes = iqama;
      _activeCollectionKeys = keys;
      _activeCollections = activeCollections; // ✅ ضيف السطر ده

      _collectionMessages = messages;
      _collectionIndices = newIndices;
      contentTypeIndex = 0;
      adhkarSalahMessages = salah;
      adhkarSabahMessages = sabah;
      adhkarMasaMessages = masa;
      startTimer();
    });
  }
  // void _loadAllData() async {
  //   final prayers = await PrayerService.getTodayPrayers();
  //   final iqama = await IqamaService.getIqamaTimes();
  //   final quran = await IqamaService.getQuranMessages();
  //   final hadith = await IqamaService.getHadithMessages();
  //   final thaqil = await IqamaService.getThaqil();
  //   final prayerFromQuran = await IqamaService.getPrayerFromQuran();
  //   final salah = await IqamaService.getAdhkarSalah();
  //   final sabah = await IqamaService.getAdhkarSabah();
  //   final masa = await IqamaService.getAdhkarMasa();

  //   if (!mounted) return;
  //   setState(() {
  //     todayPrayerData = prayers;
  //     iqamaTimes = iqama;
  //     quranMessages = quran;
  //     hadithMessages = hadith;
  //     thaqilMessages = thaqil;
  //     prayerFromQuranMessages = prayerFromQuran;
  //     adhkarSalahMessages = salah;
  //     adhkarSabahMessages = sabah;
  //     adhkarMasaMessages = masa;

  //     startTimer();
  //   });
  //   // setState(() {
  //   //   todayPrayerData = prayers;
  //   //   iqamaTimes = iqama;
  //   //   quranMessages = quran;
  //   //   hadithMessages = hadith;
  //   //   thaqilMessages = thaqil;
  //   //   prayerFromQuranMessages = prayerFromQuran;
  //   //   adhkarSalahMessages = salah;
  //   //   adhkarSabahMessages = sabah;
  //   //   adhkarMasaMessages = masa;

  //   //   startTimer(); // هنا مرة واحدة بس
  //   // });
  // }
  DateTime? _lastLoadedDay;
  void _startClockTimer() {
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _now = DateTime.now();
        _cachedCountdown = PrayerService.calculateCountdown(todayPrayerData);
        final today = DateTime(_now.year, _now.month, _now.day);

        if (_lastLoadedDay == null || today != _lastLoadedDay) {
          _lastLoadedDay = today;
          _reloadPrayerTimes();
        }
        if (appState == AppState.iqamaCount) {
          _iqamaCountdown = _getIqamaCountdown();
          // ابحث عن الجزء ده داخل _startClockTimer وتأكد إنه كدا:
          if (_iqamaCountdown == '00:00') {
            setState(() => appState = AppState.iqama);

            String currentPrayer = PrayerService.getCurrentPrayerName(
              todayPrayerData,
            );
            int delayMinutes =
                (currentPrayer == "الفجر" || currentPrayer == "العشاء")
                ? 15
                : 11;
            if (currentPrayer == 'الشروق') delayMinutes = 5;

            Future.delayed(Duration(minutes: delayMinutes), () {
              if (!mounted) return;
              // بينقل للأذكار لو لسه الحالة إقامة ومفيش أذكار يدوية شغالة
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

  Future<void> _reloadPrayerTimes() async {
    // ✅ بس استدعي التحميل من جديد
    final prayers = await PrayerService.getTodayPrayers();

    if (!mounted) return;
    setState(() {
      todayPrayerData = prayers;
      _lastTriggeredPrayer = null; // ✅ مهم — يسمح بأذان الفجر
    });

    print(
      '✅ تم تحديث أوقات الصلاة: ${DateTime.now().day}/${DateTime.now().month}',
    );
  }

  @override
  void dispose() {
    ServicesBinding.instance.keyboard.removeHandler(_onGlobalKey);
    timer?.cancel();
    _clockTimer?.cancel();
    _adhkarTimer?.cancel();
    _audioPlayer.dispose();
    // _controller!.dispose();
    _focusNode.dispose();
    _collectionsSubscription?.cancel();
    _liveDisplaySubscription?.cancel();

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
            _audioPlayer.stop(); // إيقاف الصوت عند العودة للوضع الطبيعي

            _switchToIqama();
            return KeyEventResult.handled;
          }
          if (keyName == 'ColorF1Green' ||
              key == LogicalKeyboardKey.keyS ||
              key.keyId == 0x100070002) {
            _audioPlayer.stop(); // إيقاف الصوت عند العودة للوضع الطبيعي

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
            _audioPlayer.stop(); // إيقاف الصوت عند العودة للوضع الطبيعي
            _switchToNormal();

            return KeyEventResult.handled;
          }
          if (key == LogicalKeyboardKey.digit1) {
            _audioPlayer.stop(); // إيقاف الصوت عند العودة للوضع الطبيعي
            _changeTheme(AppThemeEnum.oldTheme);

            return KeyEventResult.handled;
          }
          if (key == LogicalKeyboardKey.digit2) {
            _audioPlayer.stop(); // إيقاف الصوت عند العودة للوضع الطبيعي
            _changeTheme(AppThemeEnum.newLightTheme);
            return KeyEventResult.handled;
          }
          if (key == LogicalKeyboardKey.digit3) {
            _audioPlayer.stop(); // إيقاف الصوت عند العودة للوضع الطبيعي
            _changeTheme(AppThemeEnum.newDarkTheme);
            return KeyEventResult.handled;
          }
          if (key == LogicalKeyboardKey.digit4) {
            _audioPlayer.stop(); // إيقاف الصوت عند العودة للوضع الطبيعي
            _changeTheme(AppThemeEnum.theme4);
            return KeyEventResult.handled;
          }
          if (key == LogicalKeyboardKey.digit5) {
            // بنستدعي تغيير الثيم، ولما يخلص (تنتهي الـ Future) بنشغل الصوت
            _changeTheme(AppThemeEnum.hajTheme).then((_) {
              try {
                _audioPlayer.setReleaseMode(ReleaseMode.loop);
                _audioPlayer.play(
                  AssetSource(
                    'audios/takbeerat.mp3',
                  ), // المسار الصحيح بدون assets/
                );
              } catch (e) {
                print("Error playing takbeerat: $e");
              }
            });

            return KeyEventResult.handled;
          }
          if (key == LogicalKeyboardKey.digit6) {
            _audioPlayer.stop(); // إيقاف الصوت عند العودة للوضع الطبيعي
            _changeTheme(AppThemeEnum.hajTheme2);
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Scaffold(
        extendBody: true,
        body: Stack(
          children: [
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

            BlurOverlay(currentTheme: currentTheme),

            // ✅ الشاشة الأساسية دايماً موجودة
            _buildMainContent(_now, _cachedCountdown),

            // ✅ الأذان كـ overlay
            if (appState == AppState.adhan)
              Positioned.fill(
                child: AdhanScreen(prayerName: currentPrayerName),
              ),

            // ✅ الإقامة كـ overlay
            if (appState == AppState.iqama)
              Positioned.fill(
                child: IqamaScreen(prayerName: currentPrayerName),
              ),

            if (appState == AppState.normal ||
                appState == AppState.iqamaCount ||
                appState == AppState.adhkar)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: RepaintBoundary(
                  child: BottomTicker(currentTheme: currentTheme),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(DateTime now, Map<String, dynamic> countdown) {
    // ✅ لو أذان أو إقامة ارجع widget فاضي
    if (appState == AppState.adhan || appState == AppState.iqama) {
      return const SizedBox.shrink();
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
              currentMessage: _isLiveDisplay
                  ? _liveMessage
                  : currentMainMessage,
              appState: appState,
              adhkarMessages: adhkarMessages,
              adhkarIndex: adhkarIndex,
              currentTheme: currentTheme,
              collectionLabel: currentCollectionLabel,
            ),
          ],
        ),
        Logo(currentTheme: currentTheme),
      ],
    );
  }
}

// ignore: must_be_immutable
class BlurOverlay extends StatelessWidget {
  BlurOverlay({super.key, required this.currentTheme});
  AppThemeEnum currentTheme;
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: RepaintBoundary(
        child: Container(
          color: currentTheme == AppThemeEnum.theme4
              ? Colors.black.withOpacity(0.8)
              : currentTheme == AppThemeEnum.hajTheme ||
                    currentTheme == AppThemeEnum.hajTheme2
              ? Colors.black.withOpacity(0.65)
              : Colors.black.withOpacity(0.3),
        ),
      ),
    );
  }
}
