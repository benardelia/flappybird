import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS)
    await MobileAds.instance.initialize();
  await Hive.initFlutter();
  Box box = await Hive.openBox('Score');
  int topScore;
  box.isEmpty
      ? topScore = 0
      : box.get('Top Score') == null
          ? topScore = 0
          : topScore = box.get('Top Score');

  runApp(MaterialApp(
    home: Homepage(
      highScore: topScore,
      box: box,
    ),
    debugShowCheckedModeBanner: false,
  ));
}
