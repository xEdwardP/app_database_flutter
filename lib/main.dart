import 'package:flutter/material.dart';
import '../models/note.dart';
import '../data/notes_db.dart';

// Main
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

// Clase Principal MyApp
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Database App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Database App'),
    );
  }
}

// Widget de la pantalla principal
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _input = TextEditingController();
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

  Future<void> _create() async {
    final txt = _input.text.trim();
    if (txt.isEmpty) return;
    await NotesDb.instance.create(Note(text: txt));
    _input.clear();
    await _reload();
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
    await NotesDb.instance.update(Note(id: n.id, text: newText));
    await _reload();
  }

  Future<void> _delete(Note n) async {
    await NotesDb.instance.delete(n.id!);
    await _reload();
  }

  // Interfaz de usuario
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _input,
                    decoration: const InputDecoration(
                      hintText: 'Escribe una nota...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _create(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _create,
                  child: const Text('Agregar'),
                ),
              ],
            ),
          ),
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
                          subtitle: Text('id: ${note.id ?? "-"}'),
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
          final ctrl = TextEditingController();
          final txt = await showDialog<String>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Nueva nota'),
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
          if (txt == null || txt.isEmpty) return;
          await NotesDb.instance.create(Note(text: txt));
          await _reload();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
