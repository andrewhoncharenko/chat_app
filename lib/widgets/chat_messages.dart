import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import "package:flutter_chat/widgets/message_bubble.dart";

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});
  @override
  Widget build(BuildContext context) {
    final User authenticatedUser = FirebaseAuth.instance.currentUser!;

    return StreamBuilder(stream: FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: "chat").
    collection("chat").
    orderBy("createdAt", descending: true).
    snapshots(), builder: (ctx, chatSnapshots) {
      if(chatSnapshots.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator(),);
      }
      if(!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
        return const Center(child: Text("No messages yet."),);
      }
      if(chatSnapshots.hasError) {
        return const Center(child: Text("Something went wrong."),);
      }

      final List loadedMessages = chatSnapshots.data!.docs;

      return ListView.builder(itemCount: loadedMessages.length,
          padding: EdgeInsets.only(bottom: 40, left: 13, right: 13),
          reverse: true,
          itemBuilder: (ctx, index) {
            final chatMessage = loadedMessages[index].data();
            final nextChatMessage = index + 1 < loadedMessages.length ? loadedMessages[index + 1] : null;
            final currentMessageUserId = chatMessage["userId"];
            final nextMessageUserId = nextChatMessage != null ? nextChatMessage["userId"] : null;
            final nextUserIsSame = nextMessageUserId == currentMessageUserId;
            if(nextUserIsSame) {
              return MessageBubble.next(message: chatMessage["text"], isMe: authenticatedUser.uid == currentMessageUserId,);
            }
            else {
              return MessageBubble.first(userImage: chatMessage["user_image"],
                username: chatMessage["username"],
                message: chatMessage["text"],
                isMe: authenticatedUser.uid == currentMessageUserId);
            }
          }
      );
    });
  }
}