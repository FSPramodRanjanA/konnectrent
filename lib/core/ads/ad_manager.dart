import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Singleton managing AdMob ads lifecycle.
/// Real ad unit IDs are injected via --dart-define at release build time.
class AdManager {
  InterstitialAd? _interstitial;

  // Test ad unit IDs used in debug; override via --dart-define in release.
  static const _testBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const _testInterstitialId = 'ca-app-pub-3940256099942544/1033173712';

  static String get bannerId =>
      kDebugMode
          ? _testBannerId
          : const String.fromEnvironment(
              'ADMOB_BANNER_ID',
              defaultValue: _testBannerId,
            );

  static String get interstitialId =>
      kDebugMode
          ? _testInterstitialId
          : const String.fromEnvironment(
              'ADMOB_INTERSTITIAL_ID',
              defaultValue: _testInterstitialId,
            );

  bool get isReady => _interstitial != null;

  Future<void> init() async {
    await MobileAds.instance.initialize();
    _loadInterstitial();
  }

  void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitial = ad;
          _interstitial!.setImmersiveMode(true);
        },
        onAdFailedToLoad: (_) {
          _interstitial = null;
        },
      ),
    );
  }

  void showInterstitial() {
    _interstitial?.show();
    _interstitial = null;
    _loadInterstitial();
  }
}
