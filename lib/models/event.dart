class GameEvent {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String time;
  final String location;
  final double latitude;
  final double longitude;
  final List<String> games;
  final int maxParticipants;
  final String imageUrl;
  final bool isHighlighted;

  GameEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.games,
    required this.maxParticipants,
    this.imageUrl = '',
    this.isHighlighted = false,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GameEvent && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
