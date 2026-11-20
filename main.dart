import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

// ================= الأذكار =================
class Dhikr {
  final String count;
  final String source;
  final String? morning;
  final String? evening;
  const Dhikr(this.count, this.source, this.morning, this.evening);
}

const List<Dhikr> kAdhkar = [
  Dhikr(r'''مرة''', r'''سورة البقرة ٢٥٥''', r'''اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَّهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَن ذَا الَّذِي يَشْفَعُ عِندَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ''', null),
  Dhikr(r'''٣ مرات''', r'''أبو داود والترمذي''', r'''قُلْ هُوَ اللَّهُ أَحَدٌ ۝ اللَّهُ الصَّمَدُ ۝ لَمْ يَلِدْ وَلَمْ يُولَدْ ۝ وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ''', null),
  Dhikr(r'''٣ مرات''', r'''أبو داود والترمذي''', r'''قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ ۝ مِن شَرِّ مَا خَلَقَ ۝ وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ ۝ وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ ۝ وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ''', null),
  Dhikr(r'''٣ مرات''', r'''أبو داود والترمذي''', r'''قُلْ أَعُوذُ بِرَبِّ النَّاسِ ۝ مَلِكِ النَّاسِ ۝ إِلَٰهِ النَّاسِ ۝ مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ ۝ الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ ۝ مِنَ الْجِنَّةِ وَالنَّاسِ''', null),
  Dhikr(r'''مرة''', r'''رواه مسلم''', r'''أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ، رَبِّ أَسْأَلُكَ خَيْرَ مَا فِي هَذَا الْيَوْمِ وَخَيْرَ مَا بَعْدَهُ، وَأَعُوذُ بِكَ مِنْ شَرِّ مَا فِي هَذَا الْيَوْمِ وَشَرِّ مَا بَعْدَهُ، رَبِّ أَعُوذُ بِكَ مِنَ الْكَسَلِ وَسُوءِ الْكِبَرِ، رَبِّ أَعُوذُ بِكَ مِنْ عَذَابٍ فِي النَّارِ وَعَذَابٍ فِي الْقَبْرِ''', r'''أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ، رَبِّ أَسْأَلُكَ خَيْرَ مَا فِي هَذِهِ اللَّيْلَةِ وَخَيْرَ مَا بَعْدَهَا، وَأَعُوذُ بِكَ مِنْ شَرِّ مَا فِي هَذِهِ اللَّيْلَةِ وَشَرِّ مَا بَعْدَهَا، رَبِّ أَعُوذُ بِكَ مِنَ الْكَسَلِ وَسُوءِ الْكِبَرِ، رَبِّ أَعُوذُ بِكَ مِنْ عَذَابٍ فِي النَّارِ وَعَذَابٍ فِي الْقَبْرِ'''),
  Dhikr(r'''مرة''', r'''رواه الترمذي''', r'''اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ النُّشُورُ''', r'''اللَّهُمَّ بِكَ أَمْسَيْنَا، وَبِكَ أَصْبَحْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ الْمَصِيرُ'''),
  Dhikr(r'''مرة''', r'''رواه البخاري (سيد الاستغفار)''', r'''اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ لَكَ بِذَنْبِي فَاغْفِرْ لِي، فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ''', null),
  Dhikr(r'''٤ مرات''', r'''رواه أبو داود''', r'''اللَّهُمَّ إِنِّي أَصْبَحْتُ أُشْهِدُكَ، وَأُشْهِدُ حَمَلَةَ عَرْشِكَ، وَمَلَائِكَتَكَ، وَجَمِيعَ خَلْقِكَ، أَنَّكَ أَنْتَ اللَّهُ لَا إِلَهَ إِلَّا أَنْتَ وَحْدَكَ لَا شَرِيكَ لَكَ، وَأَنَّ مُحَمَّدًا عَبْدُكَ وَرَسُولُكَ''', r'''اللَّهُمَّ إِنِّي أَمْسَيْتُ أُشْهِدُكَ، وَأُشْهِدُ حَمَلَةَ عَرْشِكَ، وَمَلَائِكَتَكَ، وَجَمِيعَ خَلْقِكَ، أَنَّكَ أَنْتَ اللَّهُ لَا إِلَهَ إِلَّا أَنْتَ وَحْدَكَ لَا شَرِيكَ لَكَ، وَأَنَّ مُحَمَّدًا عَبْدُكَ وَرَسُولُكَ'''),
  Dhikr(r'''مرة''', r'''رواه أبو داود''', r'''اللَّهُمَّ مَا أَصْبَحَ بِي مِنْ نِعْمَةٍ أَوْ بِأَحَدٍ مِنْ خَلْقِكَ فَمِنْكَ وَحْدَكَ لَا شَرِيكَ لَكَ، فَلَكَ الْحَمْدُ وَلَكَ الشُّكْرُ''', r'''اللَّهُمَّ مَا أَمْسَى بِي مِنْ نِعْمَةٍ أَوْ بِأَحَدٍ مِنْ خَلْقِكَ فَمِنْكَ وَحْدَكَ لَا شَرِيكَ لَكَ، فَلَكَ الْحَمْدُ وَلَكَ الشُّكْرُ'''),
  Dhikr(r'''٣ مرات''', r'''رواه أبو داود''', r'''اللَّهُمَّ عَافِنِي فِي بَدَنِي، اللَّهُمَّ عَافِنِي فِي سَمْعِي، اللَّهُمَّ عَافِنِي فِي بَصَرِي، لَا إِلَهَ إِلَّا أَنْتَ. اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْكُفْرِ وَالْفَقْرِ، وَأَعُوذُ بِكَ مِنْ عَذَابِ الْقَبْرِ، لَا إِلَهَ إِلَّا أَنْتَ''', null),
  Dhikr(r'''٧ مرات''', r'''رواه أبو داود''', r'''حَسْبِيَ اللَّهُ لَا إِلَهَ إِلَّا هُوَ، عَلَيْهِ تَوَكَّلْتُ وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ''', null),
  Dhikr(r'''مرة''', r'''أبو داود وابن ماجه''', r'''اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي الدُّنْيَا وَالْآخِرَةِ، اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي دِينِي وَدُنْيَايَ وَأَهْلِي وَمَالِي، اللَّهُمَّ اسْتُرْ عَوْرَاتِي وَآمِنْ رَوْعَاتِي، اللَّهُمَّ احْفَظْنِي مِنْ بَيْنِ يَدَيَّ، وَمِنْ خَلْفِي، وَعَنْ يَمِينِي، وَعَنْ شِمَالِي، وَمِنْ فَوْقِي، وَأَعُوذُ بِعَظَمَتِكَ أَنْ أُغْتَالَ مِنْ تَحْتِي''', null),
  Dhikr(r'''مرة''', r'''الترمذي وأبو داود''', r'''اللَّهُمَّ عَالِمَ الْغَيْبِ وَالشَّهَادَةِ فَاطِرَ السَّمَاوَاتِ وَالْأَرْضِ، رَبَّ كُلِّ شَيْءٍ وَمَلِيكَهُ، أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا أَنْتَ، أَعُوذُ بِكَ مِنْ شَرِّ نَفْسِي، وَمِنْ شَرِّ الشَّيْطَانِ وَشِرْكِهِ، وَأَنْ أَقْتَرِفَ عَلَى نَفْسِي سُوءًا أَوْ أَجُرَّهُ إِلَى مُسْلِمٍ''', null),
  Dhikr(r'''٣ مرات''', r'''أبو داود والترمذي''', r'''بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ''', null),
  Dhikr(r'''٣ مرات''', r'''أبو داود والترمذي''', r'''رَضِيتُ بِاللَّهِ رَبًّا، وَبِالْإِسْلَامِ دِينًا، وَبِمُحَمَّدٍ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ نَبِيًّا''', null),
  Dhikr(r'''مرة''', r'''الحاكم''', r'''يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ، أَصْلِحْ لِي شَأْنِي كُلَّهُ، وَلَا تَكِلْنِي إِلَى نَفْسِي طَرْفَةَ عَيْنٍ''', null),
  Dhikr(r'''مرة''', r'''رواه أحمد''', r'''أَصْبَحْنَا عَلَى فِطْرَةِ الْإِسْلَامِ، وَعَلَى كَلِمَةِ الْإِخْلَاصِ، وَعَلَى دِينِ نَبِيِّنَا مُحَمَّدٍ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ، وَعَلَى مِلَّةِ أَبِينَا إِبْرَاهِيمَ حَنِيفًا مُسْلِمًا وَمَا كَانَ مِنَ الْمُشْرِكِينَ''', r'''أَمْسَيْنَا عَلَى فِطْرَةِ الْإِسْلَامِ، وَعَلَى كَلِمَةِ الْإِخْلَاصِ، وَعَلَى دِينِ نَبِيِّنَا مُحَمَّدٍ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ، وَعَلَى مِلَّةِ أَبِينَا إِبْرَاهِيمَ حَنِيفًا مُسْلِمًا وَمَا كَانَ مِنَ الْمُشْرِكِينَ'''),
  Dhikr(r'''١٠٠ مرة''', r'''رواه مسلم''', r'''سُبْحَانَ اللَّهِ وَبِحَمْدِهِ''', null),
  Dhikr(r'''١٠ مرات''', r'''النسائي وأحمد''', r'''لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ''', null),
  Dhikr(r'''٣ مرات''', r'''رواه مسلم''', r'''سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، عَدَدَ خَلْقِهِ وَرِضَا نَفْسِهِ وَزِنَةَ عَرْشِهِ وَمِدَادَ كَلِمَاتِهِ''', null),
  Dhikr(r'''مرة''', r'''رواه أبو داود''', r'''اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ، وَأَعُوذُ بِكَ مِنَ الْعَجْزِ وَالْكَسَلِ، وَأَعُوذُ بِكَ مِنَ الْجُبْنِ وَالْبُخْلِ، وَأَعُوذُ بِكَ مِنْ غَلَبَةِ الدَّيْنِ وَقَهْرِ الرِّجَالِ''', null),
  Dhikr(r'''٣ مرات (مساءً)''', r'''رواه مسلم''', null, r'''أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ'''),
  Dhikr(r'''١٠ مرات''', r'''رواه الطبراني''', r'''اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ''', null),
];


// ================= الإشعارات =================
class Notifier {
  static final FlutterLocalNotificationsPlugin _p = FlutterLocalNotificationsPlugin();
  static bool _ready = false;

  static Future<void> init() async {
    try {
      tzdata.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Africa/Cairo'));
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      await _p.initialize(const InitializationSettings(android: android));
      final impl = _p.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await impl?.requestNotificationsPermission();
      _ready = true;
    } catch (e) {
      _ready = false;
    }
  }

  static NotificationDetails _details(String kind) {
    switch (kind) {
      case 'adhan':
        return NotificationDetails(
          android: AndroidNotificationDetails(
            'adhan_v1',
            'الأذان',
            channelDescription: 'أذان الصلوات',
            importance: Importance.max,
            priority: Priority.max,
            playSound: true,
            sound: const RawResourceAndroidNotificationSound('adhan'),
            audioAttributesUsage: AudioAttributesUsage.alarm,
            category: AndroidNotificationCategory.alarm,
          ),
        );
      case 'fajr':
        return NotificationDetails(
          android: AndroidNotificationDetails(
            'adhan_fajr_v1',
            'أذان الفجر',
            channelDescription: 'أذان الفجر',
            importance: Importance.max,
            priority: Priority.max,
            playSound: true,
            sound: const RawResourceAndroidNotificationSound('adhan_fajr'),
            audioAttributesUsage: AudioAttributesUsage.alarm,
            category: AndroidNotificationCategory.alarm,
          ),
        );
      case 'iqama':
        return NotificationDetails(
          android: AndroidNotificationDetails(
            'iqama_v1',
            'الإقامة',
            channelDescription: 'تنبيه الإقامة',
            importance: Importance.max,
            priority: Priority.max,
            playSound: true,
            sound: const RawResourceAndroidNotificationSound('iqama'),
            audioAttributesUsage: AudioAttributesUsage.alarm,
            category: AndroidNotificationCategory.alarm,
          ),
        );
      case 'silent':
        return NotificationDetails(
          android: AndroidNotificationDetails(
            'silent_v1',
            'تنبيه صامت',
            channelDescription: 'تنبيهات بدون صوت',
            importance: Importance.low,
            priority: Priority.low,
            playSound: false,
            enableVibration: false,
          ),
        );
      default:
        return NotificationDetails(
          android: AndroidNotificationDetails(
            'wird_channel',
            'تذكير الأوراد',
            channelDescription: 'تذكيرات الأوراد اليومية',
            importance: Importance.high,
            priority: Priority.high,
          ),
        );
    }
  }

  static Future<void> schedule(int id, String title, String body, DateTime when, {String kind = 'tone'}) async {
    if (!_ready) return;
    final t = tz.TZDateTime.from(when, tz.local);
    if (!t.isAfter(tz.TZDateTime.now(tz.local))) return;
    try {
      await _p.zonedSchedule(
        id,
        title,
        body,
        t,
        _details(kind),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      try {
        await _p.zonedSchedule(
          id,
          title,
          body,
          t,
          _details(kind),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        );
      } catch (e2) {
        // تجاهل
      }
    }
  }

  static Future<void> cancelAll() async {
    if (!_ready) return;
    try {
      await _p.cancelAll();
    } catch (e) {
      // تجاهل
    }
  }

  static Future<void> showNow(String title, String body, {String kind = 'tone'}) async {
    if (!_ready) return;
    try {
      await _p.show(99, title, body, _details(kind));
    } catch (e) {
      // تجاهل
    }
  }
}

// ================= ثوابت =================
const List<String> kUnits = ['دقيقة', 'آيات', 'صفحات', 'أجزاء', 'أوجه', 'ربع', 'مرة', 'ركعات', 'يوم'];
const List<String> kDayNames = ['', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];
const List<String> kMonths = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
const Color kGold = Color(0xFFB0852E);

String ar(Object n) {
  const d = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  final chars = n.toString().split('');
  final out = StringBuffer();
  for (final c in chars) {
    final i = int.tryParse(c);
    out.write(i == null ? c : d[i]);
  }
  return out.toString();
}

String two(int n) => n.toString().padLeft(2, '0');

String dayKey(DateTime d) => '${d.year}-${two(d.month)}-${two(d.day)}';

Map<String, dynamic> _item(String i, String n, int t, {String? g, String? note}) {
  return <String, dynamic>{'i': i, 'n': n, 't': t, 'g': g, 'note': note};
}

// مفتاح، رقم الإشعار، الاسم، نص الإشعار، الميعاد الافتراضي
const List<List<dynamic>> kReminders = [
  ['pf', 11, 'صلاة الفجر', 'حان وقت صلاة الفجر', '05:00'],
  ['m', 1, 'أذكار الصباح', 'حان وقت أذكار الصباح', '05:30'],
  ['dh', 16, 'صلاة الضحى', 'حان وقت صلاة الضحى', '09:00'],
  ['pd', 12, 'صلاة الظهر', 'حان وقت صلاة الظهر', '11:55'],
  ['pa', 13, 'صلاة العصر', 'حان وقت صلاة العصر', '15:00'],
  ['e', 2, 'أذكار المساء', 'حان وقت أذكار المساء', '15:30'],
  ['pm', 14, 'صلاة المغرب', 'حان وقت صلاة المغرب', '16:50'],
  ['pi', 15, 'صلاة العشاء', 'حان وقت صلاة العشاء', '18:30'],
  ['q', 3, 'قيام الليل', 'تذكير بقيام الليل', '21:30'],
];

const List<List<dynamic>> kCities = [
  ['القاهرة', 30.0444, 31.2357],
  ['الجيزة', 30.0131, 31.2089],
  ['الإسكندرية', 31.2001, 29.9187],
  ['شبين الكوم', 30.5594, 31.0114],
  ['طنطا', 30.7865, 31.0004],
  ['المنصورة', 31.0409, 31.3785],
  ['الزقازيق', 30.5877, 31.5020],
  ['بنها', 30.4660, 31.1848],
  ['دمنهور', 31.0341, 30.4682],
  ['كفر الشيخ', 31.1107, 30.9388],
  ['دمياط', 31.4165, 31.8133],
  ['بورسعيد', 31.2653, 32.3019],
  ['الإسماعيلية', 30.5965, 32.2715],
  ['السويس', 29.9668, 32.5498],
  ['الفيوم', 29.3084, 30.8428],
  ['بني سويف', 29.0661, 31.0994],
  ['المنيا', 28.1099, 30.7503],
  ['أسيوط', 27.1783, 31.1859],
  ['سوهاج', 26.5591, 31.6948],
  ['قنا', 26.1551, 32.7160],
  ['الأقصر', 25.6872, 32.6396],
  ['أسوان', 24.0889, 32.8998],
  ['الغردقة', 27.2579, 33.8116],
  ['مرسى مطروح', 31.3543, 27.2373],
  ['العريش', 31.1316, 33.7984],
  ['شرم الشيخ', 27.9158, 34.3300],
];

Map<String, dynamic> defaultSnd() {
  return <String, dynamic>{'pf': 'adhan', 'pd': 'adhan', 'pa': 'adhan', 'pm': 'adhan', 'pi': 'adhan'};
}

Map<String, dynamic> defaultIq() {
  return <String, dynamic>{'pf': 20, 'pd': 15, 'pa': 15, 'pm': 10, 'pi': 15};
}

Map<String, dynamic> defaultLoc() {
  return <String, dynamic>{'name': 'القاهرة', 'lat': 30.0444, 'lng': 31.2357, 'src': 'city'};
}

Map<String, dynamic> defaultRem() {
  final out = <String, dynamic>{};
  for (final d in kReminders) {
    out[d[0] as String] = <String, dynamic>{'on': true, 't': d[4] as String};
  }
  return out;
}

Map<String, dynamic> baseState() {
  const fr = 'الفرائض في جماعة';
  const sn = 'السنن الرواتب';
  const pr = 'بعد الصلوات (مرة بعد كل فرض)';
  const sl = 'قبل النوم';
  const dy = 'على مدار اليوم';
  final m = <String, dynamic>{
    'order': ['salah', 'listen', 'memo', 'read', 'qiyam', 'adsm', 'adh', 'siyam'],
    'w': {
      'salah': {
        'n': 'ورد الصلاة',
        'kind': 'list',
        'items': [
          _item('f1', 'الفجر في جماعة', 1, g: fr),
          _item('f2', 'الظهر في جماعة', 1, g: fr),
          _item('f3', 'العصر في جماعة', 1, g: fr),
          _item('f4', 'المغرب في جماعة', 1, g: fr),
          _item('f5', 'العشاء في جماعة', 1, g: fr),
          _item('r1', 'ركعتان قبل الفجر', 1, g: sn),
          _item('r2', 'أربع ركعات قبل الظهر', 1, g: sn),
          _item('r3', 'ركعتان بعد الظهر', 1, g: sn),
          _item('r4', 'ركعتان بعد المغرب', 1, g: sn),
          _item('r5', 'ركعتان بعد العشاء', 1, g: sn),
        ],
      },
      'listen': {'n': 'ورد السماع', 'kind': 'count', 't': 20, 'u': 'دقيقة', 'stop': ''},
      'memo': {'n': 'ورد الحفظ', 'kind': 'count', 't': 5, 'u': 'آيات', 'stop': ''},
      'read': {'n': 'ورد القراءة', 'kind': 'count', 't': 5, 'u': 'صفحات', 'stop': ''},
      'qiyam': {'n': 'قيام الليل', 'kind': 'count', 't': 2, 'u': 'ركعات', 'stop': ''},
      'adsm': {
        'n': 'أذكار الصباح والمساء',
        'kind': 'list',
        'items': [
          _item('m', 'أذكار الصباح', 1, note: 'بعد الفجر'),
          _item('e', 'أذكار المساء', 1, note: 'بعد العصر'),
        ],
      },
      'adh': {
        'n': 'أذكار من السنة',
        'kind': 'list',
        'items': [
          _item('a1', 'التسبيح ٣٣ والتحميد ٣٣ والتكبير ٣٤', 5, g: pr, note: 'رواه مسلم'),
          _item('a2', 'آية الكرسي دبر الصلاة', 5, g: pr, note: 'رواه النسائي'),
          _item('a3', 'الإخلاص والفلق والناس دبر الصلاة', 5, g: pr, note: 'أبو داود والترمذي'),
          _item('s1', 'آية الكرسي', 1, g: sl, note: 'رواه البخاري'),
          _item('s2', 'آخر آيتين من سورة البقرة', 1, g: sl, note: 'رواه البخاري'),
          _item('s3', 'الإخلاص والفلق والناس (ثلاث مرات)', 1, g: sl, note: 'رواه البخاري'),
          _item('s4', 'باسمك اللهم أموت وأحيا', 1, g: sl, note: 'رواه البخاري'),
          _item('d1', 'سبحان الله وبحمده', 100, g: dy, note: 'متفق عليه'),
          _item('d2', 'الاستغفار', 100, g: dy, note: 'رواه مسلم'),
        ],
      },
      'siyam': {'n': 'صيام الاثنين والخميس', 'kind': 'count', 't': 1, 'u': 'يوم', 'days': [1, 4], 'stop': ''},
    },
    'log': {},
    'rem': defaultRem(),
    'loc': defaultLoc(),
    'calc': {'asr': 'shafi'},
    'auto': true,
    'snd': defaultSnd(),
    'iq': defaultIq(),
  };
  return jsonDecode(jsonEncode(m)) as Map<String, dynamic>;
}

// ================= التطبيق =================
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Notifier.init();
  runApp(const WirdApp());
}

class WirdApp extends StatelessWidget {
  const WirdApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF1F5A47);
    return MaterialApp(
      title: 'وردي',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: seed)),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
      ),
      builder: (context, child) => Directionality(textDirection: TextDirection.rtl, child: child!),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  Map<String, dynamic> S = baseState();
  SharedPreferences? prefs;
  bool loaded = false;
  final TextEditingController nameC = TextEditingController();
  final TextEditingController tC = TextEditingController(text: '1');
  String newUnit = 'مرة';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    nameC.dispose();
    tC.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {});
      _resched();
    }
  }

  Future<void> _load() async {
    prefs = await SharedPreferences.getInstance();
    final raw = prefs!.getString('wird_state');
    if (raw != null) {
      try {
        S = jsonDecode(raw) as Map<String, dynamic>;
      } catch (e) {
        S = baseState();
      }
    }
    final defRem = defaultRem();
    final curRem = (S['rem'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    for (final k in defRem.keys) {
      curRem.putIfAbsent(k, () => defRem[k]);
    }
    S['rem'] = curRem;
    S['loc'] ??= defaultLoc();
    S['calc'] ??= <String, dynamic>{'asr': 'shafi'};
    S['auto'] ??= true;
    S['snd'] ??= defaultSnd();
    S['iq'] ??= defaultIq();
    setState(() {
      loaded = true;
    });
    _resched();
  }

  void _save() {
    prefs?.setString('wird_state', jsonEncode(S));
  }

  Map<String, dynamic> get W => S['w'] as Map<String, dynamic>;
  List<dynamic> get order => S['order'] as List<dynamic>;
  Map<String, dynamic> get logs => S['log'] as Map<String, dynamic>;
  String get todayKey => dayKey(DateTime.now());

  Map<String, dynamic> dayLog(String k) {
    final x = logs.putIfAbsent(k, () => <String, dynamic>{});
    return x as Map<String, dynamic>;
  }

  int cnt(Map<String, dynamic> l, String key) {
    final v = l[key];
    return v is int ? v : 0;
  }

  List<int> prog(String id, Map<String, dynamic> l) {
    final w = W[id] as Map<String, dynamic>;
    if (w['kind'] == 'list') {
      final items = w['items'] as List<dynamic>;
      int d = 0;
      for (final raw in items) {
        final it = raw as Map<String, dynamic>;
        final iid = it['i'] as String;
        if (cnt(l, '$id.$iid') >= (it['t'] as int)) d++;
      }
      return [d, items.length];
    }
    final t = w['t'] as int;
    final c = cnt(l, id);
    return [c > t ? t : c, t];
  }

  List<String> active(String k) {
    final wd = DateTime.parse(k).weekday;
    final out = <String>[];
    for (final raw in order) {
      final id = raw as String;
      final w = W[id];
      if (w == null) continue;
      final days = (w as Map<String, dynamic>)['days'];
      if (days == null || (days as List<dynamic>).contains(wd)) {
        out.add(id);
      }
    }
    return out;
  }

  int doneCount(String k) {
    final l = (logs[k] ?? <String, dynamic>{}) as Map<String, dynamic>;
    int n = 0;
    for (final id in active(k)) {
      final p = prog(id, l);
      if (p[0] >= p[1]) n++;
    }
    return n;
  }

  bool full(String k) {
    final a = active(k).length;
    return a > 0 && doneCount(k) == a;
  }

  int streak() {
    int s = 0;
    var d = DateTime.now();
    if (!full(dayKey(d))) {
      d = d.subtract(const Duration(days: 1));
    }
    while (full(dayKey(d))) {
      s++;
      d = d.subtract(const Duration(days: 1));
    }
    return s;
  }

  int _step(String u, int t) {
    if (u == 'دقيقة') return 5;
    return t >= 100 ? 10 : 1;
  }

  void _add(String id, int d) {
    final l = dayLog(todayKey);
    final c = cnt(l, id) + d;
    l[id] = c < 0 ? 0 : c;
    _save();
    setState(() {});
  }

  void _complete(String id, int t) {
    final l = dayLog(todayKey);
    final c = cnt(l, id);
    l[id] = c > t ? c : t;
    _save();
    setState(() {});
  }

  void _setKey(String key, int v) {
    final l = dayLog(todayKey);
    l[key] = v;
    _save();
    setState(() {});
  }

  void _addKey(String key, int d, int t) {
    final l = dayLog(todayKey);
    int c = cnt(l, key) + d;
    if (c < 0) c = 0;
    if (c > t) c = t;
    l[key] = c;
    _save();
    setState(() {});
  }

  bool _rs = false;
  bool _rsAgain = false;

  Future<void> _resched() async {
    if (_rs) {
      _rsAgain = true;
      return;
    }
    _rs = true;
    try {
      await Notifier.cancelAll();
      final rem = S['rem'] as Map<String, dynamic>;
      final auto = S['auto'] != false;
      final snd = S['snd'] as Map<String, dynamic>;
      final iq = S['iq'] as Map<String, dynamic>;
      final now = DateTime.now();
      for (int day = 0; day < 14; day++) {
        Map<String, DateTime> times = <String, DateTime>{};
        try {
          times = _dayTimes(DateTime(now.year, now.month, now.day + day), auto);
        } catch (e) {
          times = <String, DateTime>{};
        }
        if (times.isEmpty) continue;
        for (int i = 0; i < kReminders.length; i++) {
          final d = kReminders[i];
          final r = rem[d[0] as String] as Map<String, dynamic>?;
          if (r == null || r['on'] != true) continue;
          final t = times[d[0] as String];
          if (t == null || !t.isAfter(now)) continue;
          final key = d[0] as String;
          String kind = 'tone';
          String title = d[2] as String;
          bool silent = false;
          if (snd.containsKey(key)) {
            final sv = snd[key];
            if (sv == 'adhan') {
              kind = key == 'pf' ? 'fajr' : 'adhan';
              title = 'أذان $title';
            } else if (sv == 'silent') {
              kind = 'silent';
              silent = true;
            }
          }
          await Notifier.schedule(1000 + day * 10 + i, title, d[3] as String, t, kind: kind);
          final im = iq[key];
          if (snd.containsKey(key) && im is int && im > 0) {
            await Notifier.schedule(
              2000 + day * 10 + i,
              'إقامة ${d[2]}',
              'حان وقت الإقامة',
              t.add(Duration(minutes: im)),
              kind: silent ? 'silent' : 'iqama',
            );
          }
        }
      }
    } finally {
      _rs = false;
    }
    if (_rsAgain) {
      _rsAgain = false;
      await _resched();
    }
  }

  Coordinates _coords() {
    final loc = S['loc'] as Map<String, dynamic>;
    return Coordinates((loc['lat'] as num).toDouble(), (loc['lng'] as num).toDouble());
  }

  CalculationParameters _params() {
    final calc = S['calc'] as Map<String, dynamic>;
    final p = CalculationMethod.egyptian.getParameters();
    p.madhab = calc['asr'] == 'hanafi' ? Madhab.hanafi : Madhab.shafi;
    return p;
  }

  Map<String, DateTime> _dayTimes(DateTime day, bool auto) {
    final out = <String, DateTime>{};
    final rem = S['rem'] as Map<String, dynamic>;
    if (auto) {
      final pt = PrayerTimes(_coords(), DateComponents.from(day), _params());
      out['pf'] = pt.fajr;
      out['pd'] = pt.dhuhr;
      out['pa'] = pt.asr;
      out['pm'] = pt.maghrib;
      out['pi'] = pt.isha;
      out['m'] = pt.fajr.add(const Duration(minutes: 30));
      out['dh'] = pt.sunrise.add(const Duration(minutes: 20));
      out['e'] = pt.asr.add(const Duration(minutes: 30));
      out['q'] = pt.isha.add(const Duration(minutes: 120));
    } else {
      for (final d in kReminders) {
        final k = d[0] as String;
        final r = rem[k] as Map<String, dynamic>?;
        if (r == null) continue;
        final p = (r['t'] as String).split(':');
        out[k] = DateTime(day.year, day.month, day.day, int.parse(p[0]), int.parse(p[1]));
      }
    }
    return out;
  }

  String _fmt12(DateTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    return '${ar(h)}:${ar(two(t.minute))} ${t.hour < 12 ? 'ص' : 'م'}';
  }

  String _effLabel(String key) {
    final auto = S['auto'] != false;
    try {
      final t = _dayTimes(DateTime.now(), auto)[key];
      if (t == null) return '';
      return '${_fmt12(t)} ${auto ? '(تلقائي)' : '(يدوي)'}';
    } catch (e) {
      return '';
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _useGps() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        _snack('شغّل خدمة الموقع (GPS) في الموبايل ثم جرّب تاني');
        return;
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        _snack('محتاج صلاحية الموقع. فعّلها من إعدادات التطبيق أو اختار مدينتك يدويًا');
        return;
      }
      _snack('بحدد موقعك...');
      Position? pos;
      try {
        pos = await Geolocator.getCurrentPosition().timeout(const Duration(seconds: 25));
      } catch (e) {
        pos = await Geolocator.getLastKnownPosition();
      }
      if (pos == null) {
        _snack('ما قدرتش أحدد موقعك. اختار مدينتك يدويًا');
        return;
      }
      S['loc'] = <String, dynamic>{'name': 'موقعي (GPS)', 'lat': pos.latitude, 'lng': pos.longitude, 'src': 'gps'};
      _save();
      _resched();
      setState(() {});
      _snack('تم تحديد موقعك وتحديث المواقيت');
    } catch (e) {
      _snack('حصل خطأ في تحديد الموقع. اختار مدينتك يدويًا');
    }
  }

  void _setCity(String name) {
    for (final c in kCities) {
      if (c[0] == name) {
        S['loc'] = <String, dynamic>{'name': name, 'lat': c[1], 'lng': c[2], 'src': 'city'};
        _save();
        _resched();
        setState(() {});
        return;
      }
    }
  }

  Widget _locationCard() {
    final loc = S['loc'] as Map<String, dynamic>;
    final auto = S['auto'] != false;
    final calc = S['calc'] as Map<String, dynamic>;
    final chips = <Widget>[];
    try {
      final times = _dayTimes(DateTime.now(), true);
      const labels = <String, String>{'pf': 'الفجر', 'pd': 'الظهر', 'pa': 'العصر', 'pm': 'المغرب', 'pi': 'العشاء'};
      for (final e in labels.entries) {
        chips.add(Chip(label: Text('${e.value} ${_fmt12(times[e.key]!)}')));
      }
    } catch (e) {
      chips.add(const Text('تعذّر حساب المواقيت'));
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الموقع ومواقيت الصلاة', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text('${loc['name']} · ${ar((loc['lat'] as num).toStringAsFixed(2))}، ${ar((loc['lng'] as num).toStringAsFixed(2))}'),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _useGps,
              icon: const Icon(Icons.my_location),
              label: const Text('حدّد موقعي'),
            ),
            DropdownButton<String>(
              hint: const Text('أو اختار مدينتك'),
              isExpanded: true,
              value: null,
              items: kCities.map((c) => DropdownMenuItem<String>(value: c[0] as String, child: Text(c[0] as String))).toList(),
              onChanged: (v) {
                if (v != null) _setCity(v);
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('المواعيد التلقائية (طريقة الهيئة المصرية)'),
              value: auto,
              onChanged: (v) {
                S['auto'] = v;
                _save();
                _resched();
                setState(() {});
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('العصر بالمذهب الحنفي (ظل مثلين)'),
              value: calc['asr'] == 'hanafi',
              onChanged: (v) {
                calc['asr'] = v ? 'hanafi' : 'shafi';
                _save();
                _resched();
                setState(() {});
              },
            ),
            const Text('مواقيت اليوم', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(spacing: 6, runSpacing: 0, children: chips),
            const SizedBox(height: 6),
            OutlinedButton(
              onPressed: () => Geolocator.openAppSettings(),
              child: const Text('إعدادات التطبيق (البطارية والصلاحيات)'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickTime(String key) async {
    final rem = S['rem'] as Map<String, dynamic>;
    final r = rem[key] as Map<String, dynamic>;
    final p = (r['t'] as String).split(':');
    final res = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: int.parse(p[0]), minute: int.parse(p[1])),
    );
    if (res == null) return;
    r['t'] = '${two(res.hour)}:${two(res.minute)}';
    _save();
    _resched();
    setState(() {});
  }

  // ---------- واجهة ----------
  @override
  Widget build(BuildContext context) {
    if (!loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final k = todayKey;
    final l = dayLog(k);
    final act = active(k);
    double sum = 0;
    for (final id in act) {
      final p = prog(id, l);
      sum += p[1] == 0 ? 0 : p[0] / p[1];
    }
    final pct = act.isEmpty ? 0.0 : sum / act.length;
    final cards = <Widget>[];
    for (final raw in order) {
      final id = raw as String;
      if (W[id] == null) continue;
      cards.add(_wirdCard(id, l, act.contains(id)));
    }
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _header(pct),
            const SizedBox(height: 12),
            ...cards,
            _addButton(),
            _locationCard(),
            _adhanCard(),
            _remindersCard(),
            _statsCard(),
          ],
        ),
      ),
    );
  }

  Widget _header(double pct) {
    final n = DateTime.now();
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        SizedBox(
          width: 88,
          height: 88,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: pct,
                strokeWidth: 9,
                color: kGold,
                backgroundColor: cs.surfaceContainerHighest,
              ),
              Center(child: Text('${ar((pct * 100).round())}٪', style: const TextStyle(fontSize: 18))),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('وردي اليومي', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              Text('${kDayNames[n.weekday]} ${ar(n.day)} ${kMonths[n.month - 1]}'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _wirdCard(String id, Map<String, dynamic> l, bool on) {
    final w = W[id] as Map<String, dynamic>;
    final cs = Theme.of(context).colorScheme;
    final name = w['n'] as String;
    final menu = PopupMenuButton<String>(
      onSelected: (v) {
        if (v == 'edit') _editDialog(id);
        if (v == 'del') _delDialog(id);
      },
      itemBuilder: (c) => const [
        PopupMenuItem<String>(value: 'edit', child: Text('تعديل')),
        PopupMenuItem<String>(value: 'del', child: Text('حذف')),
      ],
    );
    if (!on) {
      final days = (w['days'] as List<dynamic>).map((d) => kDayNames[d as int]).join(' و ');
      return Card(
        child: ListTile(
          title: Text(name),
          subtitle: Text('مش مطلوب النهارده. أيام الورد: $days'),
          trailing: menu,
        ),
      );
    }
    final p = prog(id, l);
    final done = p[0] >= p[1];
    final Widget body = w['kind'] == 'list' ? _listBody(id, w, l) : _countBody(id, w, l);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: done ? cs.primary : cs.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(name, style: Theme.of(context).textTheme.titleLarge)),
                if (done) Text('تم بحمد الله', style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold)),
                menu,
              ],
            ),
            LinearProgressIndicator(
              value: p[1] == 0 ? 0.0 : p[0] / p[1],
              minHeight: 8,
              borderRadius: BorderRadius.circular(6),
            ),
            const SizedBox(height: 8),
            body,
          ],
        ),
      ),
    );
  }

  Widget _countBody(String id, Map<String, dynamic> w, Map<String, dynamic> l) {
    final t = w['t'] as int;
    final u = w['u'] as String;
    final c = cnt(l, id);
    final shown = c > t ? t : c;
    final step = _step(u, t);
    return Column(
      children: [
        Row(
          children: [
            IconButton.outlined(onPressed: () => _add(id, -step), icon: const Icon(Icons.remove)),
            Expanded(
              child: Text(
                '${ar(shown)} من ${ar(t)} $u',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 17),
              ),
            ),
            IconButton.outlined(onPressed: () => _add(id, step), icon: const Icon(Icons.add)),
            const SizedBox(width: 8),
            FilledButton(onPressed: () => _complete(id, t), child: const Text('أتممت')),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          key: ValueKey('note-$id'),
          initialValue: (w['stop'] ?? '') as String,
          onChanged: (v) {
            w['stop'] = v;
            _save();
          },
          decoration: const InputDecoration(
            hintText: 'ملاحظة أو موضع التوقف',
            isDense: true,
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _listBody(String id, Map<String, dynamic> w, Map<String, dynamic> l) {
    final items = w['items'] as List<dynamic>;
    final rows = <Widget>[];
    String? lastG;
    for (final raw in items) {
      final it = raw as Map<String, dynamic>;
      final g = it['g'] as String?;
      if (g != null && g != lastG) {
        lastG = g;
        rows.add(
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 2),
            child: Text(g, style: const TextStyle(color: kGold, fontWeight: FontWeight.bold)),
          ),
        );
      }
      rows.add(_itemRow(id, it, l));
      final iid = it['i'] as String;
      if (id == 'adsm' && (iid == 'm' || iid == 'e')) {
        rows.add(_azTile(iid));
      }
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows);
  }

  Widget _itemRow(String id, Map<String, dynamic> it, Map<String, dynamic> l) {
    final iid = it['i'] as String;
    final key = '$id.$iid';
    final t = it['t'] as int;
    final c = cnt(l, key);
    final dn = c >= t;
    final note = it['note'] as String?;
    final primary = Theme.of(context).colorScheme.primary;
    final label = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(it['n'] as String, style: const TextStyle(fontSize: 16)),
        if (note != null && note.isNotEmpty) Text(note, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
    if (t == 1) {
      return InkWell(
        onTap: () => _setKey(key, dn ? 0 : 1),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Icon(dn ? Icons.check_box : Icons.check_box_outline_blank, color: dn ? primary : null),
              const SizedBox(width: 10),
              Expanded(child: label),
            ],
          ),
        ),
      );
    }
    final st = t >= 100 ? 10 : 1;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: label),
          IconButton(onPressed: () => _addKey(key, -st, t), icon: const Icon(Icons.remove_circle_outline)),
          Text('${ar(c)} / ${ar(t)}'),
          IconButton(onPressed: () => _addKey(key, st, t), icon: const Icon(Icons.add_circle_outline)),
        ],
      ),
    );
  }

  Widget _azTile(String r) {
    final list = kAdhkar.where((a) => r == 'm' ? a.morning != null : (a.evening ?? a.morning) != null).toList();
    final children = <Widget>[];
    for (final a in list) {
      final txt = r == 'm' ? a.morning! : (a.evening ?? a.morning)!;
      children.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(txt, style: const TextStyle(fontSize: 21, height: 2.0)),
              Text('${a.count} · ${a.source}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const Divider(),
            ],
          ),
        ),
      );
    }
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: const Text('عرض الأذكار', style: TextStyle(fontWeight: FontWeight.bold)),
      children: children,
    );
  }

  Future<void> _editDialog(String id) async {
    final w = W[id] as Map<String, dynamic>;
    final isCount = w['kind'] == 'count';
    final nameCtl = TextEditingController(text: w['n'] as String);
    final tCtl = TextEditingController(text: isCount ? '${w['t']}' : '');
    String unit = isCount ? (w['u'] as String) : kUnits[0];
    if (!kUnits.contains(unit)) unit = kUnits[0];
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setD) => AlertDialog(
          title: const Text('تعديل الورد'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtl, decoration: const InputDecoration(labelText: 'اسم الورد')),
              if (isCount)
                TextField(
                  controller: tCtl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'الكمية'),
                ),
              if (isCount)
                DropdownButton<String>(
                  value: unit,
                  isExpanded: true,
                  items: kUnits.map((u) => DropdownMenuItem<String>(value: u, child: Text(u))).toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setD(() {
                        unit = v;
                      });
                    }
                  },
                ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx2), child: const Text('إلغاء')),
            FilledButton(
              onPressed: () {
                final n = nameCtl.text.trim();
                if (n.isNotEmpty) w['n'] = n;
                if (isCount) {
                  final t = int.tryParse(tCtl.text);
                  if (t != null && t > 0) w['t'] = t;
                  w['u'] = unit;
                }
                _save();
                Navigator.pop(ctx2);
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
    setState(() {});
  }

  Future<void> _delDialog(String id) async {
    final w = W[id] as Map<String, dynamic>;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('حذف ${w['n']}؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('حذف')),
        ],
      ),
    );
    if (ok == true) {
      W.remove(id);
      S['order'] = order.where((x) => x != id).toList();
      _save();
      setState(() {});
    }
  }

  void _addWird() {
    final n = nameC.text.trim();
    if (n.isEmpty) return;
    final t = int.tryParse(tC.text) ?? 1;
    final id = 'w${DateTime.now().millisecondsSinceEpoch}';
    W[id] = <String, dynamic>{'n': n, 'kind': 'count', 't': t < 1 ? 1 : t, 'u': newUnit, 'stop': ''};
    order.add(id);
    nameC.clear();
    tC.text = '1';
    _save();
    setState(() {});
  }

  Widget _addCard() {
    const presets = <List<dynamic>>[
      ['الاستغفار', 100, 'مرة'],
      ['الصلاة على النبي', 100, 'مرة'],
      ['ضحى', 2, 'ركعات'],
      ['صدقة', 1, 'مرة'],
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('إضافة ورد جديد', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final p in presets)
                  ActionChip(
                    label: Text(p[0] as String),
                    onPressed: () {
                      setState(() {
                        nameC.text = p[0] as String;
                        tC.text = '${p[1]}';
                        newUnit = p[2] as String;
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: nameC,
                    decoration: const InputDecoration(hintText: 'اسم الورد', isDense: true, border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 70,
                  child: TextField(
                    controller: tC,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            DropdownButton<String>(
              value: newUnit,
              isExpanded: true,
              items: kUnits.map((u) => DropdownMenuItem<String>(value: u, child: Text(u))).toList(),
              onChanged: (v) {
                if (v != null) {
                  setState(() {
                    newUnit = v;
                  });
                }
              },
            ),
            FilledButton(onPressed: _addWird, child: const Text('إضافة الورد')),
          ],
        ),
      ),
    );
  }

  Widget _addButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: FilledButton.icon(
        onPressed: _addDialog,
        icon: const Icon(Icons.add),
        label: const Text('إضافة ورد جديد'),
      ),
    );
  }

  Future<void> _addDialog() async {
    final nCtl = TextEditingController();
    final cCtl = TextEditingController(text: '1');
    String unit = 'مرة';
    const presets = <List<dynamic>>[
      ['الاستغفار', 100, 'مرة'],
      ['الصلاة على النبي', 100, 'مرة'],
      ['ضحى', 2, 'ركعات'],
      ['صدقة', 1, 'مرة'],
    ];
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setD) => AlertDialog(
          title: const Text('إضافة ورد جديد'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  spacing: 8,
                  children: [
                    for (final p in presets)
                      ActionChip(
                        label: Text(p[0] as String),
                        onPressed: () {
                          setD(() {
                            nCtl.text = p[0] as String;
                            cCtl.text = '${p[1]}';
                            unit = p[2] as String;
                          });
                        },
                      ),
                  ],
                ),
                TextField(controller: nCtl, decoration: const InputDecoration(labelText: 'اسم الورد')),
                TextField(
                  controller: cCtl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'العدد'),
                ),
                DropdownButton<String>(
                  value: unit,
                  isExpanded: true,
                  items: kUnits.map((u) => DropdownMenuItem<String>(value: u, child: Text(u))).toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setD(() {
                        unit = v;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx2), child: const Text('إلغاء')),
            FilledButton(
              onPressed: () {
                final n = nCtl.text.trim();
                if (n.isEmpty) return;
                final t = int.tryParse(cCtl.text) ?? 1;
                final id = 'w${DateTime.now().millisecondsSinceEpoch}';
                W[id] = <String, dynamic>{'n': n, 'kind': 'count', 't': t < 1 ? 1 : t, 'u': unit, 'stop': ''};
                order.add(id);
                _save();
                Navigator.pop(ctx2);
              },
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
    setState(() {});
  }

  Widget _adhanCard() {
    final snd = S['snd'] as Map<String, dynamic>;
    final iq = S['iq'] as Map<String, dynamic>;
    const names = <String, String>{'pf': 'الفجر', 'pd': 'الظهر', 'pa': 'العصر', 'pm': 'المغرب', 'pi': 'العشاء'};
    final rows = <Widget>[];
    for (final e in names.entries) {
      final k = e.key;
      final mins = iq[k] is int ? iq[k] as int : 0;
      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              SizedBox(width: 52, child: Text(e.value, style: const TextStyle(fontWeight: FontWeight.bold))),
              Expanded(
                child: DropdownButton<String>(
                  value: snd[k] is String ? snd[k] as String : 'adhan',
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem<String>(value: 'adhan', child: Text('أذان')),
                    DropdownMenuItem<String>(value: 'tone', child: Text('نغمة')),
                    DropdownMenuItem<String>(value: 'silent', child: Text('صامت')),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      snd[k] = v;
                      _save();
                      _resched();
                      setState(() {});
                    }
                  },
                ),
              ),
              IconButton(
                onPressed: mins > 0
                    ? () {
                        iq[k] = mins - 5 < 0 ? 0 : mins - 5;
                        _save();
                        _resched();
                        setState(() {});
                      }
                    : null,
                icon: const Icon(Icons.remove_circle_outline),
              ),
              SizedBox(
                width: 76,
                child: Text(
                  mins == 0 ? 'بدون إقامة' : 'إقامة ${ar(mins)} د',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              IconButton(
                onPressed: mins < 60
                    ? () {
                        iq[k] = mins + 5;
                        _save();
                        _resched();
                        setState(() {});
                      }
                    : null,
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الأذان والإقامة', style: Theme.of(context).textTheme.titleLarge),
            const Text(
              'اختار صوت كل صلاة، وحدد مدة الإقامة بعد الأذان بالدقايق (٠ = بدون إقامة).',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            ...rows,
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton(
                  onPressed: () {
                    Notifier.schedule(97, 'أذان تجريبي', 'ده اختبار صوت الأذان', DateTime.now().add(const Duration(seconds: 10)), kind: 'adhan');
                    _snack('اقفل الشاشة وانتظر ١٠ ثواني');
                  },
                  child: const Text('جرّب الأذان'),
                ),
                OutlinedButton(
                  onPressed: () {
                    Notifier.schedule(96, 'إقامة تجريبية', 'ده اختبار صوت الإقامة', DateTime.now().add(const Duration(seconds: 10)), kind: 'iqama');
                    _snack('اقفل الشاشة وانتظر ١٠ ثواني');
                  },
                  child: const Text('جرّب الإقامة'),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'الصوت الحالي نغمة تجريبية، ولتركيب أذان حقيقي ارفع ملفات الصوت في مجلد sounds بالمستودع.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _remindersCard() {
    final rem = S['rem'] as Map<String, dynamic>;
    final tiles = <Widget>[];
    for (final d in kReminders) {
      final key = d[0] as String;
      final r = rem[key] as Map<String, dynamic>;
      tiles.add(
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(d[2] as String),
          subtitle: Text(_effLabel(key)),
          onTap: () {
            if (S['auto'] == false) {
              _pickTime(key);
            } else {
              _snack('المواعيد تلقائية حسب موقعك. عطّل «المواعيد التلقائية» لتغييرها يدويًا.');
            }
          },
          trailing: Switch(
            value: r['on'] == true,
            onChanged: (v) {
              r['on'] = v;
              _save();
              _resched();
              setState(() {});
            },
          ),
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('تذكير بالإشعارات', style: Theme.of(context).textTheme.titleLarge),
            const Text('دوس على أي ميعاد لتغييره. الإشعار بيتكرر كل يوم.', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ...tiles,
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton(
                  onPressed: () => Notifier.showNow('وردي', 'الإشعارات شغالة بحمد الله'),
                  child: const Text('جرّب إشعار الآن'),
                ),
                OutlinedButton(
                  onPressed: () {
                    Notifier.schedule(98, 'وردي', 'الإشعار المجدول اشتغل والتطبيق مقفول', DateTime.now().add(const Duration(minutes: 1)));
                    _snack('اقفل التطبيق تمامًا وانتظر دقيقة');
                  },
                  child: const Text('جرّب إشعار بعد دقيقة'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statsCard() {
    final cs = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final cells = <Widget>[];
    for (int i = 6; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      final k = dayKey(d);
      final n = doneCount(k);
      final f = full(k);
      cells.add(
        Expanded(
          child: Column(
            children: [
              Container(
                height: 34,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: f ? cs.primary : (n > 0 ? kGold : cs.surfaceContainerHighest),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: n > 0
                    ? Text(ar(n), style: TextStyle(color: f ? cs.onPrimary : Colors.white, fontWeight: FontWeight.bold))
                    : null,
              ),
              const SizedBox(height: 4),
              Text(kDayNames[d.weekday], style: const TextStyle(fontSize: 10)),
            ],
          ),
        ),
      );
    }
    final s = streak();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الأسبوع', style: Theme.of(context).textTheme.titleLarge),
            Text(
              s > 0 ? '${ar(s)} يوم متواصل بإتمام كل أوراد اليوم' : 'أتمم كل أوراد اليوم لتبدأ سلسلتك',
              style: const TextStyle(color: kGold, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(children: cells),
            TextButton(
              onPressed: () {
                logs[todayKey] = <String, dynamic>{};
                _save();
                setState(() {});
              },
              child: const Text('مسح بيانات اليوم'),
            ),
          ],
        ),
      ),
    );
  }
}
