import 'package:flutter/material.dart';
import '../models/note.dart';
import '../data/notes_db.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Database App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Database App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Note> _notes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final data = await NotesDb.instance.readAll();
    setState(() {
      _notes = data;
      _loading = false;
    });
  }

  Future<void> _edit(Note n) async {
    final ctrl = TextEditingController(text: n.text);
    final newText = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar nota'),
        content: TextField(controller: ctrl, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (newText == null || newText.isEmpty) return;
    await NotesDb.instance.update(
      Note(id: n.id, text: newText, date: n.date, category: n.category),
    );
    await _reload();
  }

  Future<void> _delete(Note n) async {
    await NotesDb.instance.delete(n.id!);
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: _notes.isEmpty
                  ? const Center(child: Text('Sin notas'))
                  : ListView.builder(
                      itemCount: _notes.length,
                      itemBuilder: (_, i) {
                        final note = _notes[i];
                        return ListTile(
                          title: Text(note.text),
                          subtitle: Text(
                            'Fecha: ${note.date.toLocal().toString().split(' ')[0]} | Categoría: ${note.category}',
                          ),
                          onTap: () => _edit(note),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _delete(note),
                          ),
                        );
                      },
                    ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final textCtrl = TextEditingController();
          DateTime? selectedDate;
          String? selectedCategory;

          final result = await showDialog<Note>(
            context: context,
            builder: (_) => StatefulBuilder(
              builder: (context, setState) => AlertDialog(
                title: const Text('Nueva nota'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: textCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Texto',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              selectedDate == null
                                  ? 'Fecha no seleccionada'
                                  : 'Fecha: ${selectedDate!.toLocal().toString().split(' ')[0]}',
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              final now = DateTime.now();
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: now,
                                firstDate: DateTime(now.year - 5),
                                lastDate: DateTime(now.year + 5),
                              );
                              if (picked != null) {
                                setState(() => selectedDate = picked);
                              }
                            },
                            child: const Text('Seleccionar fecha'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Categoría',
                          border: OutlineInputBorder(),
                        ),
                        items: ['Personal', 'Trabajo', 'Estudio', 'Otro']
                            .map(
                              (cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(cat),
                              ),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setState(() => selectedCategory = val),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final txt = textCtrl.text.trim();
                      if (txt.isEmpty ||
                          selectedDate == null ||
                          selectedCategory == null)
                        return;
                      final newNote = Note(
                        text: txt,
                        date: selectedDate!,
                        category: selectedCategory!,
                      );
                      Navigator.pop(context, newNote);
                    },
                    child: const Text('Guardar'),
                  ),
                ],
              ),
            ),
          );

          if (result != null) {
            await NotesDb.instance.create(result);
            await _reload();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
