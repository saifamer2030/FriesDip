import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:friesdip/admin/ControlPanel/NotificationAllUsers/api/messaging.dart';
import 'package:friesdip/admin/ControlPanel/NotificationAllUsers/model/message.dart';
import 'package:friesdip/admin/ControlPanel/NotificationAllUsers/page/first_page.dart';
import 'package:friesdip/admin/ControlPanel/NotificationAllUsers/page/second_page.dart';

import 'package:localize_and_translate/localize_and_translate.dart';
class MainPage extends StatelessWidget {
  final String appTitle;

  const MainPage({this.appTitle});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(appTitle),
    ),
    body: MessagingWidget(),
  );
}

class MessagingWidget extends StatefulWidget {
  @override
  _MessagingWidgetState createState() => _MessagingWidgetState();
}

class _MessagingWidgetState extends State<MessagingWidget> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final TextEditingController titleController =
      TextEditingController(text: translator.translate('Title'),);
  final TextEditingController bodyController =
      TextEditingController(text: translator.translate('Body'),);
  final List<Message> messages = [];

  @override
  void initState() {
    super.initState();

    _firebaseMessaging.onTokenRefresh.listen(sendTokenToServer);
    _firebaseMessaging.getToken();


    _firebaseMessaging.subscribeToTopic('All');

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        final notification = message['notification'];

        setState(() {
          messages.add(Message(
              title: notification['title'], body: notification['body']));
        });

        // handleRouting(notification);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");

        final notification = message['data'];
        setState(() {
          messages.add(Message(
            title: '${notification['title']}',
            body: '${notification['body']}',
          ));
        });

        // handleRouting(notification);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        final notification = message['data'];
        // handleRouting(notification);
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
  }

  void handleRouting(dynamic notification) {
    switch (notification['title']) {
      case 'first':
        Navigator.of(context).push(
            MaterialPageRoute(builder: (BuildContext context) => FirstPage()));
        break;
      case 'second':
        Navigator.of(context).push(
            MaterialPageRoute(builder: (BuildContext context) => SecondPage()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) => ListView(
        children: [
          TextFormField(
            controller: titleController,
            decoration: InputDecoration(labelText: translator.translate('Title'),),
          ),
          TextFormField(
            controller: bodyController,
            decoration: InputDecoration(labelText:  translator.translate('Body'),),
          ),
          RaisedButton(
            onPressed: sendNotification,
            child: Text(translator.translate('SendNotificationToAll'),),
          ),
        ]..addAll(messages.map(buildMessage).toList()),
      );

  Widget buildMessage(Message message) => ListTile(
        title: Text('${translator.translate('Title')}: ${message.title}'),
        subtitle: Text('${translator.translate('Body')}: ${message.body}'),
      );

  Future sendNotification() async {
    final response = await Messaging.sendToAll(
      title: titleController.text,
      body: bodyController.text,
      // fcmToken: fcmToken,
    );

    if (response.statusCode != 200) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content:
            Text('[${response.statusCode}] Error message: ${response.body}'),
      ));
    }
  }

  void sendTokenToServer(String fcmToken) {
    print('Token: $fcmToken');
    // send key to your server to allow server to use
    // this token to send push notifications
  }
}
