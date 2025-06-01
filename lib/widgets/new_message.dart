import "package:flutter/material.dart";
import "package:firebase_core/firebase_core.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});
  @override
  State<NewMessage> createState() {
    return _NewMessageState();
  }
}

class _NewMessageState extends State<NewMessage> {
  final TextEditingController _messageController = TextEditingController();

  void _submitMessage() async {
    final String enteredMessage = _messageController.text;
    final User user = FirebaseAuth.instance.currentUser!;

    if(enteredMessage.trim().isEmpty) {
      return;
    }

    FocusScope.of(context).unfocus();
    _messageController.clear();

    final DocumentSnapshot<Map<String, dynamic>> userData = await FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: "chat").
    collection("users").
    doc(user.uid).get();

    FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: "chat").collection("chat").add({
      "text": enteredMessage,
      "createdAt": Timestamp.now(),
      "userId": user.uid,
      "username": userData.data()!["username"],
      "user_image": userData.data()!["user_url"]
    });

  }
  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.only(left: 15, right: 1, bottom: 14),
        child: Row(children: [
          Expanded(child: TextField(
            controller: _messageController,
            textCapitalization: TextCapitalization.sentences,
            autocorrect: true,
            enableSuggestions: true,
            decoration: InputDecoration(labelText: "Send a message..."),
          )),
          IconButton(color: Theme.of(context).colorScheme.primary, icon: const Icon(Icons.send), onPressed: _submitMessage,)
    ],),);
  }
}