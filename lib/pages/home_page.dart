import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:simple_note/db/database_service.dart';
import 'package:simple_note/extentions/format_date.dart';
import 'package:simple_note/models/note.dart';
import 'package:simple_note/utils/app_routes.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseService dbService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("simple Note App"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          GoRouter.of(context).goNamed(
            AppRoutes.addNote,
          );
        },
        child: const Icon(
          Icons.note_add_rounded,
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box(DatabaseService.boxName).listenable(),
        builder: (context, box, child) {
          if (box.isEmpty) {
            return Center(
              child: Text('Tidak ada catatan'),
            );
          } else {
            return ListView.separated(
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key(box.getAt(index).key.toString()),
                  child: NoteCard(
                    note: box.getAt(index),
                  ),
                  onDismissed: (_) async {
                    await dbService.deleteNote(box.getAt(index)).then((_) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content:
                            Text("${box.getAt(index).title} telah dihapus"
                            ),
                      ));
                    });
                  },
                );
              },
              separatorBuilder: (context, index) => const SizedBox(
                height: 8,
              ),
              itemCount: box.length,
            );
          }
        },
      ),
    );
  }
}

class NoteCard extends StatelessWidget {
  const NoteCard({super.key, required this.note});

  final Note note;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white,
      ),
      child: ListTile(
        onTap: () {
          GoRouter.of(context).pushNamed(AppRoutes.editNote,
          extra: note,
          );
        },
        title: Text(
          note.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          note.description,
          maxLines: 1,
          ),
        trailing: Text(note.createdAt.formatDate()),
      ),
    );
  }
}
