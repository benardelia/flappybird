import 'dart:io';

class AdHelper {

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-9035859643875042/2196747911';
    } else if (Platform.isIOS) {
      return '';
    } else {
      throw new UnsupportedError('Unsupported platform');
    }
  }

 
}