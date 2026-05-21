import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:masjid/models/message_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:masjid/models/ticker_message_model.dart';

class IqamaService {
  static final _db = FirebaseFirestore.instance;

  // ===================== الكاش =====================
  static Future<void> _saveToCache(
    String key,
    List<Map<String, dynamic>> data,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, jsonEncode(data));
    // ignore: empty_catches
    } catch (e) {
    }
  }

  static Future<List<Map<String, dynamic>>?> _loadFromCache(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(key);
      if (cached == null) {
        return null;
      }
      final List<dynamic> raw = jsonDecode(cached);
      final result = raw
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      return result;
    } catch (e) {
      return null;
    }
  }

  // ===================== Version Check =====================
  static bool _versionCheckedThisSession = false;
  static bool _hasUpdateThisSession = false;

  static Future<bool> _hasNewVersion(String versionKey) async {
    // ✅ لو اتعمل check قبل كده في نفس الجلسة رجّع نفس النتيجة
    if (_versionCheckedThisSession) return _hasUpdateThisSession;

    try {
      final prefs = await SharedPreferences.getInstance();
      final localVersion = prefs.getInt(versionKey) ?? 0;

      final doc = await _db
          .collection('settings')
          .doc('versions')
          .get()
          .timeout(const Duration(seconds: 5));

      final remoteVersion = (doc.data()?['messages_version'] ?? 0) as int;

      _versionCheckedThisSession = true;

      if (remoteVersion > localVersion) {
        await prefs.setInt(versionKey, remoteVersion);
        _hasUpdateThisSession = true;
        return true;
      }

      _hasUpdateThisSession = false;
      return false;
    } catch (e) {
      _versionCheckedThisSession = true;
      _hasUpdateThisSession = false;
      return false;
    }
  }
  // ✅ ضيفها مع المتغيرات في الأول

  // ✅ الدالة الجديدة
  static void resetSessionCache() {
    _versionCheckedThisSession = false;
    _hasUpdateThisSession = false;
  }

  // ===================== دالة مساعدة للـ preview =====================
  // ignore: unused_element
  static String _preview(String text) {
    return text.substring(0, text.length.clamp(0, 15));
  }

  // ===================== دالة التحميل الموحدة =====================
  static Future<List<Message>> _getMessages(String collection) async {
    final cacheKey = 'cache_$collection';
    const versionKey = 'messages_version';

    final hasUpdate = await _hasNewVersion(versionKey);
    final cached = await _loadFromCache(cacheKey);


    if (hasUpdate || cached == null) {
      try {
        final snapshot = await _db
            .collection(collection)
            .orderBy('order')
            .get()
            .timeout(const Duration(seconds: 10));


    
        // ✅ الصح
        final data = snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList();
        await _saveToCache(cacheKey, data);
        return _parseMessages(data);
      } catch (e) {
        if (cached != null && cached.isNotEmpty) {
          return _parseMessages(cached);
        }
        return _loadFromLocalJson(_getLocalPath(collection));
      }
    }

    final messages = _parseMessages(cached);
  
    return messages;
  }

  // ===================== Active Collections =====================
  static Future<List<Map<String, dynamic>>> getActiveCollections() async {
    const cacheKey = 'cache_active_collections';

    try {
      final snapshot = await _db
          .collection('collections_config')
          .where('active', isEqualTo: true)
          .orderBy('order')
          .get()
          .timeout(const Duration(seconds: 5));

      final data = snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();

      // ✅ حدّث الكاش
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(cacheKey, jsonEncode(data));

      return data;
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(cacheKey);
      if (cached != null) {
        return List<Map<String, dynamic>>.from(
          (jsonDecode(cached) as List).map((e) => Map<String, dynamic>.from(e)),
        );
      }
      return [
        {'id': 'quran_messages', 'label': 'قرآن', 'order': 0},
        {'id': 'hadith_messages', 'label': 'حديث', 'order': 1},
        {'id': 'thaqil', 'label': 'ثقل', 'order': 2},
        {'id': 'prayer_from_quran', 'label': 'دعاء', 'order': 3},
      ];
    }
  }

  static Future<List<Message>> getCollectionMessages(String collection) =>
      _getMessages(collection);

  // ===================== Parse Messages =====================
  static List<Message> _parseMessages(List<Map<String, dynamic>> data) {
    return data
        .map((e) {
          try {
            Duration? parsedDuration;

            // معالجة الـ customDuration
            if (e['customDuration'] != null &&
                e['customDuration'].toString().isNotEmpty) {
              List<String> parts = e['customDuration'].toString().split(':');
              if (parts.length == 3) {
                parsedDuration = Duration(
                  hours: int.tryParse(parts[0]) ?? 0,
                  minutes: int.tryParse(parts[1]) ?? 0,
                  seconds: double.tryParse(parts[2])?.toInt() ?? 0,
                );
              }
            }

            // معالجة الـ duration العادي (حل مشكلة الـ String الفاضي)
            if (parsedDuration == null && e['duration'] != null) {
              final d = num.tryParse(e['duration'].toString());
              if (d != null) {
                parsedDuration = Duration(seconds: d.toInt());
              }
            }

            return Message(
              type: e['type']?.toString() ?? '',
              text: e['text']?.toString() ?? '',
              subText: e['subText']?.toString(),
              fadl: e['fadl']?.toString(),
              // الحل السحري للـ fontSize:
              fontSize: double.tryParse(e['fontSize']?.toString() ?? ''),
              docId: e['id']?.toString(),
              customDuration: parsedDuration,
            );
          } catch (err) {
            return Message(type: '', text: '');
          }
        })
        .where((m) => m.text.isNotEmpty)
        .toList();
  }

  // ===================== Fallback للـ JSON المحلي =====================
  static String _getLocalPath(String collection) {
    const paths = {
      'quran_messages': 'assets/jsons/quran_messages.json',
      'hadith_messages': 'assets/jsons/hadith_messages.json',
      'prayer_from_quran': 'assets/jsons/prayer_from_quran.json',
      'thaqil': 'assets/jsons/thaqil.json',
      'adhkar_salah': 'assets/jsons/adhkar_salah.json',
      'adhkar_sabah': 'assets/jsons/sabah_adhkar.json',
      'adhkar_masa': 'assets/jsons/masaa_adhkar.json',
    };
    return paths[collection] ?? '';
  }

  static Future<List<Message>> _loadFromLocalJson(String path) async {
    if (path.isEmpty) return [];
    try {
      final ByteData data = await rootBundle.load(path);
      final String response = utf8.decode(data.buffer.asUint8List());
      final List<dynamic> jsonData = json.decode(response);
      return _parseMessages(
        jsonData.map((e) => Map<String, dynamic>.from(e as Map)).toList(),
      );
    } catch (e) {
      return [];
    }
  }

  // ===================== إقامة =====================
  static Future<Map<String, int>> getIqamaTimes() async {
    const cacheKey = 'cache_iqama_times';
    const versionKey = 'iqama_version';

    final hasUpdate = await _hasNewVersion(versionKey);
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(cacheKey);

    if (hasUpdate || cached == null) {
      try {
        final doc = await _db
            .collection('settings')
            .doc('iqama_times')
            .get()
            .timeout(const Duration(seconds: 5));

        final data = Map<String, dynamic>.from(doc.data() ?? {});
        await prefs.setString(cacheKey, jsonEncode(data));
        return data.map((k, v) => MapEntry(k, (v as num).toInt()));
      } catch (e) {
        if (cached != null) {
          final data = Map<String, dynamic>.from(jsonDecode(cached));
          return data.map((k, v) => MapEntry(k, (v as num).toInt()));
        }
        final ByteData byteData = await rootBundle.load(
          'assets/jsons/iqama_times.json',
        );
        final String response = utf8.decode(byteData.buffer.asUint8List());
        final Map<String, dynamic> jsonData = json.decode(response);
        return jsonData.map((k, v) => MapEntry(k, (v as num).toInt()));
      }
    }

    final data = Map<String, dynamic>.from(jsonDecode(cached));
    return data.map((k, v) => MapEntry(k, (v as num).toInt()));
  }

  // ===================== استدعاء الملفات =====================
  static Future<List<Message>> getQuranMessages() =>
      _getMessages('quran_messages');
  static Future<List<Message>> getHadithMessages() =>
      _getMessages('hadith_messages');
  static Future<List<Message>> getPrayerFromQuran() =>
      _getMessages('prayer_from_quran');
  static Future<List<Message>> getThaqil() => _getMessages('thaqil');
  static Future<List<Message>> getAdhkarSalah() => _getMessages('adhkar_salah');
  static Future<List<Message>> getAdhkarSabah() => _getMessages('adhkar_sabah');
  static Future<List<Message>> getAdhkarMasa() => _getMessages('adhkar_masa');

static Future<bool> _hasNewTickerVersion() async {
  try {
    final prefs = await SharedPreferences.getInstance();

    final localVersion = prefs.getInt('ticker_version') ?? 0;

    final doc = await _db
        .collection('settings')
        .doc('versions')
        .get();

    final remoteVersion =
        (doc.data()?['ticker_version'] ?? 0) as int;

    if (remoteVersion > localVersion) {
      await prefs.setInt('ticker_version', remoteVersion);
      return true;
    }

    return false;
  } catch (e) {
    return false;
  }
}
static Future<List<TickerMessage>> getTickerMessages() async {
  const cacheKey = 'cache_ticker_messages';

  final hasUpdate = await _hasNewTickerVersion();

  final cached = await _loadFromCache(cacheKey);

  if (hasUpdate || cached == null) {
    try {
      final snapshot = await _db
          .collection('ticker_messages')
          .where('active', isEqualTo: true)
          .orderBy('order')
          .get();

      final data = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();

      await _saveToCache(cacheKey, data);

      return data
          .map((e) => TickerMessage.fromMap(e))
          .toList();
    } catch (e) {
      if (cached != null) {
        return cached
            .map((e) => TickerMessage.fromMap(e))
            .toList();
      }

      return [];
    }
  }

  return cached
      .map((e) => TickerMessage.fromMap(e))
      .toList();
}
static Stream<List<TickerMessage>> listenToTickerMessages() {
  return _db
      .collection('ticker_messages')
      .orderBy('order')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => TickerMessage.fromMap({'id': doc.id, ...doc.data()}))
          .toList());
}

}
