import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:masjid/models/message_model.dart';

class IqamaService {
  // 💡 دالة مساعدة لفك تشفير الملفات بـ UTF-8 لضمان ظهور الرموز الخاصة
  static Future<String> _loadUtf8Asset(String path) async {
    final ByteData data = await rootBundle.load(path);
    // تحويل الـ Bytes لنص باستخدام utf8.decode لحل مشكلة المربعات
    return utf8.decode(data.buffer.asUint8List());
  }

  // ===================== إقامة =====================
  static Future<Map<String, int>> getIqamaTimes() async {
    final String response = await _loadUtf8Asset(
      'assets/jsons/iqama_times.json',
    );
    final Map<String, dynamic> data = json.decode(response);
    return data.map((key, value) => MapEntry(key, value as int));
  }

  // ===================== دالة التحميل الموحدة والذكية =====================
  static Future<List<Message>> _loadMessages(String path) async {
    final String response = await _loadUtf8Asset(
      path,
    ); // استخدام الدالة الجديدة هنا
    final List<dynamic> data = json.decode(response);

    return data.map((e) {
      Duration? parsedDuration;

      // ✅ معالجة الـ Duration
      if (e['customDuration'] != null) {
        List<String> parts = e['customDuration'].toString().split(':');
        if (parts.length == 3) {
          int hours = int.parse(parts[0]);
          int minutes = int.parse(parts[1]);
          double seconds = double.parse(parts[2]);
          parsedDuration = Duration(
            hours: hours,
            minutes: minutes,
            seconds: seconds.toInt(),
          );
        }
      } else if (e['duration'] != null) {
        parsedDuration = Duration(seconds: e['duration'] as int);
      }

      return Message(
        type: e['type'] ?? "",
        text: e['text'] ?? "",
        subText: e['subText'],
        fadl: e['fadl'],
        fontSize: e['fontSize'] != null
            ? (e['fontSize'] as num).toDouble()
            : null,
        customDuration: parsedDuration,
      );
    }).toList();
  }

  // ===================== استدعاء الملفات =====================
  static Future<List<Message>> getQuranMessages() async =>
      _loadMessages("assets/jsons/quran_messages.json");

  static Future<List<Message>> getHadithMessages() async =>
      _loadMessages('assets/jsons/hadith_messages.json');
  static Future<List<Message>> getPrayerFromQuran() async =>
      _loadMessages('assets/jsons/prayer_from_quran.json');

  static Future<List<Message>> getThaqil() async =>
      _loadMessages('assets/jsons/thaqil.json');

  static Future<List<Message>> getAdhkarSalah() async =>
      _loadMessages('assets/jsons/adhkar_salah.json');

  static Future<List<Message>> getAdhkarSabah() async =>
      _loadMessages('assets/jsons/sabah_adhkar.json');

  static Future<List<Message>> getAdhkarMasa() async =>
      _loadMessages('assets/jsons/masaa_adhkar.json');
}
