import 'dart:convert';

import 'package:http/http.dart';
import 'package:meta/meta.dart';

class Messaging {
  static final Client client = Client();

  // from 'https://console.firebase.google.com'
  // --> project settings --> cloud messaging --> "Server key"
  static const String serverKey =
      'AAAAKA8w4Ps:APA91bGLQVTDuYyl75Z6FA0RtUaFialLuv9FcxXq0SrylytKQaz9mQawfL3G4iW0BzywWpV4tlT14IHLdA9NrHwf931vJS9mQmYRkyY7m3QNoKtXJANbb50hJuWIAdAwVjRXdNWcwNqJ';

  static Future<Response> sendToAll({
    @required String title,
    @required String body,
  }) =>
      sendToTopic(title: title, body: body, topic: 'All');

  static Future<Response> sendToTopic(
          {@required String title,
          @required String body,
          @required String topic }) =>
      sendTo(title: title, body: body, fcmToken: '/topics/$topic');

  static Future<Response> sendTo({
    @required String title,
    @required String body,
    @required String fcmToken,
  }) =>
      client.post(
        'https://fcm.googleapis.com/fcm/send',
        body: json.encode({
          'notification': {'body': '$body', 'title': '$title'},
          'priority': 'high',
          'data': {
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
            "sound": "default",
            "color": "#990000",
          },
          'to': '$fcmToken',
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
      );
}
