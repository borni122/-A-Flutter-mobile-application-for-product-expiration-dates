import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../core/modele/LotsModel.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // unique id
  'High Importance Notifications', // user-visible name
  description: 'This channel is used for important notifications.', // description
  importance: Importance.high,
);

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/launcher_icon');

  final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
}

void scheduleNotification() async {
  await initializeNotifications();

  FirebaseFirestore.instance.collection('lots').snapshots().listen((snapshot) {
    List<String> notificationMessages = [];
    for (var document in snapshot.docs) {
      Lot lot = Lot.fromFirestore(document);
      _fetchProductName(lot).then((productName) {
        String message = _prepareNotificationMessage(lot, productName);
        if (message.isNotEmpty) {
          notificationMessages.add(message);
        }

        if (notificationMessages.isNotEmpty) {
          _showGroupedNotifications(notificationMessages);
        }
      });
    }
  });
}

Future<String> _fetchProductName(Lot lot) async {
  DocumentSnapshot productSnapshot = await lot.produitRef.get();
  var productData = productSnapshot.data() as Map<String, dynamic>;
  return productData['nomDeProduit'];
}

String _prepareNotificationMessage(Lot lot, String productName) {
  DateTime now = DateTime.now();
  DateTime expirationDate = lot.dateExpiration.toDate();
  Duration difference = expirationDate.difference(now);
  if (difference.inDays < 0) return "$productName est expiré.";
  if (difference.inDays == 0) return "$productName expire aujourd'hui.";
  if (difference.inDays <= 3 || difference.inDays == 6) {
    return "Il reste ${difference.inDays} jours avant l'expiration de $productName.";
  }
  return "";
}

void _showGroupedNotifications(List<String> messages) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'high_importance_channel',
    'Desi',
    channelDescription: 'Channel Description',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
    icon: '@mipmap/launcher_icon',
    largeIcon: DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
  );

  const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidDetails);

  String groupedMessage = messages.join('\n');
  await flutterLocalNotificationsPlugin.show(
    0, "Notification de Lot", groupedMessage, platformChannelSpecifics,
    payload: 'item x',
  );

  messages.clear();
}
