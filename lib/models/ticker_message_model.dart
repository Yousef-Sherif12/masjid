class TickerMessage {
  final String id;
  final String text;
  final bool active;
  final int order;

  TickerMessage({
    required this.id,
    required this.text,
    required this.active,
    required this.order,
  });

  factory TickerMessage.fromMap(Map<String, dynamic> map) {
    return TickerMessage(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      active: map['active'] ?? true,
      order: map['order'] ?? 0,
    );
  }
}