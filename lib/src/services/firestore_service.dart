import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  // Ao tentar criar referenciar uma coleção inexistente, ele cria uma nova.
  static final CollectionReference decks =
      FirebaseFirestore.instance.collection('decks');

  //CRUD
  Future<void> createDeck({
    required String title,
    required String description,
  }) {
    return decks.add({
      'title': title,
      'description': description,
      'timestamp': Timestamp.now(),
    });
  }

  Stream<QuerySnapshot> readDecks() {
    final deckList = decks.orderBy('timestamp', descending: true).snapshots();
    return deckList;
  }

  Future<void> updateDeck({
    required String deckId,
    required String title,
    required String description,
  }) {
    return decks.doc(deckId).update({
      'title': title,
      'description': description,
      'timestamp': Timestamp.now(),
    });
  }

  Future<void> deleteDeck({required String deckId}) {
    return decks.doc(deckId).delete();
  }
}
