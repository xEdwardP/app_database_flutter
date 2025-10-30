class Note {
  final int? id;
  final String text;
  final DateTime date;
  final String category;

  Note({
    this.id,
    required this.text,
    required this.date,
    required this.category,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'text': text,
    'date': date.toIso8601String().split('T').first,
    'category': category,
  };

  factory Note.fromMap(Map<String, dynamic> m) => Note(
    id: m['id'] as int?,
    text: m['text'] as String,
    date: DateTime.parse(m['date'] as String),
    category: m['category'] as String,
  );
}
