import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:dy_food_flutter/food_info.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
  }

  static Future<void> checkAllergyAlert(
    List<FoodInfo> foodList, 
    List<int> userAllergies
  ) async {
    List<String> allergyFoods = [];
    
    for (var food in foodList) {
      for (var allergen in food.allergens) {
        if (userAllergies.contains(allergen)) {
          allergyFoods.add(food.name);
          break;
        }
      }
    }

    if (allergyFoods.isNotEmpty) {
      await _showAllergyNotification(allergyFoods);
    }
  }

  static Future<void> _showAllergyNotification(List<String> allergyFoods) async {
    const androidDetails = AndroidNotificationDetails(
      'allergy_channel',
      '알레르기 알림',
      channelDescription: '알레르기 음식 알림',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    String foodNames = allergyFoods.join(', ');
    
    await _notifications.show(
      0,
      '⚠️ 알레르기 주의!',
      '오늘 급식에 알레르기 음식이 있어요: $foodNames',
      details,
    );
  }
}