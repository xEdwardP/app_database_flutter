class Note {
  final int? id;
  final String text;

  Note({this.id, required this.text});

  Map<String, dynamic> toMap() => {'id': id, 'text': text};

  factory Note.fromMap(Map<String, dynamic> m) =>
      Note(id: m['id'] as int?, text: m['text'] as String);
}
