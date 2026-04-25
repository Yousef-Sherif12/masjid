class DayPrayer {
  final String date;
  final Map<String, String> times;

  DayPrayer({required this.date, required this.times});

  // دالة تحول الـ Map اللي جاية من الـ JSON لكائن DayPrayer
  factory DayPrayer.fromJson(Map<String, dynamic> json) {
    return DayPrayer(
      date: json['date'],
      times: Map<String, String>.from(json['times']),
    );
  }
}