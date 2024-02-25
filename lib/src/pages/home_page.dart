import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_basics/src/services/firestore_service.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  openDeckDialog([
    String? deckId,
    String deckTitle = '',
    String deckDescription = '',
  ]) {
    if (deckId != null) {
      _titleController.text = deckTitle;
      _descriptionController.text = deckDescription;
    } else {
      _titleController.clear();
      _descriptionController.clear();
    }
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: (deckId == null)
            ? const Text("Criar Novo Deck")
            : const Text("Atulizar Deck"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Titulo",
              ),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: "Descrição",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Ok"),
            onPressed: () {
              if (deckId == null) {
                firestoreService.createDeck(
                  title: _titleController.text,
                  description: _descriptionController.text,
                );
              } else {
                firestoreService.updateDeck(
                  deckId: deckId,
                  title: _titleController.text,
                  description: _descriptionController.text,
                );
              }
              Navigator.of(context).popUntil(
                (route) => route.isFirst,
              );
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Ação concluída com sucesso!"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).popUntil(
                            (route) => route.isFirst,
                          );
                        },
                        child: const Text("Ok"),
                      )
                    ],
                  );
                },
              );
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.readDecks(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            List deckList = snapshot.data!.docs;

            return ListView.builder(
              itemCount: deckList.length,
              itemBuilder: (context, index) {
                DocumentSnapshot deckDocument = deckList[index];
                final deckId = deckDocument.id;

                Map<String, dynamic> deck =
                    deckDocument.data() as Map<String, dynamic>;

                final deckTitle = deck['title'];
                final deckDescription = deck['description'];

                return ListTile(
                  title: Text(deckTitle),
                  subtitle: Text(deckDescription),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => openDeckDialog(
                          deckId,
                          deckTitle.toString(),
                          deckDescription.toString(),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () =>
                            firestoreService.deleteDeck(deckId: deckId),
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return const Center(
              child: Text("Nenhuma Informação Cadastrada"),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => openDeckDialog(),
      ),
    );
  }
}
