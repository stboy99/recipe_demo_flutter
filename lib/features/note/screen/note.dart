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

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }
  
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

  void _deleteNote(String id) {
    DatabaseService.noteBox.delete(id);
  }

  Widget _buildNoteList() {
    return ValueListenableBuilder(
      valueListenable: DatabaseService.noteBox.listenable(),
      builder: (context, Box<Note> box, _) {
        if (box.values.isEmpty) {
          return Center(child: Text('No notes yet.'));
        }

        final notes = box.values.toList();

        return ListView.builder(
          itemCount: notes.length,
          itemBuilder: (context, index) {
            final note = notes[index];
            return ListTile(
              title: Text(note.content),
              subtitle: Text(
                'Added on ${note.createdAt.toLocal().toString().split(' ')[0]}',
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteNote(note.id),
              ),
            );
          },
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
          Expanded(
            child: _buildNoteList(),
          ),
        ],
      ),
    );
  }
}
