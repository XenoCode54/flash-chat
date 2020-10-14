import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/constants.dart';
import 'package:flutter/material.dart';

final _database = Firestore.instance;
String messages = 'messages';
FirebaseUser loggedUser;

class ChatScreen extends StatefulWidget {
  static const String id = 'chat';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;

  final inputcontrol = TextEditingController();

  String message;

  Future<void> getLoggedUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedUser = user;
        print(loggedUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  void getStream() async {
    await for (var snapshot in _database.collection('messages').snapshots())
      for (var message in snapshot.documents) {
        print(message.data);
      }
  }

  @override
  void initState() {
    super.initState();
    getLoggedUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                // Implement logout functionality
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent[900],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: inputcontrol,
                      enableSuggestions: true,
                      onChanged: (value) {
                        //Do something with the user input.
                        message = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      //Implement send functionality.
                      _database.collection(messages).add({
                        'message': message,
                        'sender': loggedUser.email,
                        'time_server': FieldValue.serverTimestamp(),
                        'time': Timestamp.now(),
                      });

                      inputcontrol.clear();
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String sentMessage;
  final String sender;
  final bool isMe;

  const MessageBubble({Key key, this.sentMessage, this.sender, this.isMe})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          sender,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.blueGrey,
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: Offset(3, 2),
                ),
              ],
              // color: Colors.lightBlueAccent,
              gradient: RadialGradient(
                radius: isMe ? 4.5 : 9,
                colors: isMe
                    ? [Colors.lightBlue[500], Colors.lightBlueAccent]
                    : [Colors.white, Colors.lightBlueAccent[100]],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
                topLeft: isMe ? Radius.circular(30) : Radius.circular(0),
                topRight: isMe ? Radius.circular(0) : Radius.circular(30),
              ),
            ),
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Text(
              sentMessage,
              style: TextStyle(
                fontSize: 20,
                color: isMe ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class MessageStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _database
          .collection(messages)
          .orderBy('time_server', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.blueAccent,
            ),
          );
        } else {
          final messageData = snapshot.data.documents;
          List<Widget> messageWidgets = [];
          for (var message in messageData) {
            final sender = message.data['sender'];
            final sentMessage = message.data['message'];
            final currentUser = loggedUser.email;
            final messageText = MessageBubble(
              sender: sender,
              sentMessage: sentMessage,
              isMe: currentUser == sender,
            );
            messageWidgets.add(messageText);
          }
          return Expanded(
            child: ListView(
              reverse: true,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              children: messageWidgets,
            ),
          );
        }
      },
    );
  }
}
