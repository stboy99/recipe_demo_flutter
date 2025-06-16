import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:recipe_demo_flutter/features/note/model/note.dart';
import 'package:recipe_demo_flutter/services/database_service.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final TextEditingController _controller = TextEditingController();

  void _addNote() {
    if (_controller.text.trim().isEmpty) return;

    final note = Note(
      id: DateTime.now().toString(),
      content: _controller.text,
      createdAt: DateTime.now(),
    );

    DatabaseService.noteBox.put(note.id, note);
    _controller.clear();
  }

  void _editNote(Note note) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        final editController = TextEditingController(text: note.content);
        return AlertDialog(
          title: const Text('Edit Note'),
          content: TextField(
            controller: editController,
            maxLines: null,
            decoration: const InputDecoration(
              hintText: 'Update your note...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, editController.text.trim()),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      final updatedNote = Note(
        id: note.id,
        content: result,
        createdAt: note.createdAt,
      );
      DatabaseService.noteBox.put(note.id, updatedNote);
    }
  }

Widget _buildNoteList() {
  return ValueListenableBuilder(
    valueListenable: DatabaseService.noteBox.listenable(),
    builder: (context, Box<Note> box, _) {
      if (box.values.isEmpty) {
        return const Center(child: Text('No notes yet.'));
      }

      final notes = box.values.toList().reversed.toList();

      return Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Text(
              'Tip: Swipe a note to delete it',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];

                return Dismissible(
                  key: Key(note.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    DatabaseService.noteBox.delete(note.id);
                  },
                  child: GestureDetector(
                    onTap: () => _editNote(note),
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        title: Text(note.content),
                        subtitle: Text(
                          'Added on ${note.createdAt.toLocal().toString().split(' ')[0]}',
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 4,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Write a new note...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addNote(),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addNote,
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          Expanded(child: _buildNoteList()),
        ],
      ),
    );
  }
}
