import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

Future<void> _messageHandler(RemoteMessage message) async {
  print('background message ${message.notification!.body}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_messageHandler);
  runApp(MessagingTutorial());
}

class MessagingTutorial extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase Messaging',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Firebase Messaging'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late FirebaseMessaging messaging;
  String? notificationText;

  @override
  void initState() {
    super.initState();
    messaging = FirebaseMessaging.instance;

    // Subscribe to a topic
    messaging.subscribeToTopic("messaging");

    // Get the FCM token
    messaging.getToken().then((value) {
      print(value);
    });

    // Listen for foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      print("Message received");
      print("Notification: ${event.notification!.body}");
      print("Data: ${event.data}");

      // Determine the notification type and set the dialog color
      String notificationType = event.data['type'] ?? 'regular';
      Color dialogColor =
          notificationType == 'important' ? Colors.red : Colors.green;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: dialogColor,
            title: Text(
              notificationType == 'important'
                  ? "Important Notification"
                  : "Notification",
              style: const TextStyle(color: Colors.white),
            ),
            content: Text(
              event.notification!.body!,
              style: const TextStyle(color: Colors.white),
            ),
            actions: [
              TextButton(
                child: const Text("Ok", style: TextStyle(color: Colors.white)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    });

    // Handle notification click when the app is in the background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('Message clicked!');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
      ),
      body: Center(child: Text("Messaging Tutorial")),
    );
  }
}
