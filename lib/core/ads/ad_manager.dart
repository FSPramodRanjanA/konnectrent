import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Singleton managing AdMob ads lifecycle.
/// Real ad unit IDs injected via --dart-define at release build time.
class AdManager {
  InterstitialAd? _interstitial;
  RewardedAd? _rewarded;

  // ── Test IDs (Google's public test ad units) ──────────────────────────────
  static const _testBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const _testInterstitialId = 'ca-app-pub-3940256099942544/1033173712';
  static const _testRewardedId = 'ca-app-pub-3940256099942544/5224354917';

  // ── Production IDs (injected via --dart-define in release builds) ─────────
  static String get bannerId => kDebugMode
      ? _testBannerId
      : const String.fromEnvironment(
          'ADMOB_BANNER_ID',
          defaultValue: _testBannerId,
        );

  static String get interstitialId => kDebugMode
      ? _testInterstitialId
      : const String.fromEnvironment(
          'ADMOB_INTERSTITIAL_ID',
          defaultValue: _testInterstitialId,
        );

  static String get rewardedId => kDebugMode
      ? _testRewardedId
      : const String.fromEnvironment(
          'ADMOB_REWARDED_ID',
          defaultValue: _testRewardedId,
        );

  bool get isInterstitialReady => _interstitial != null;
  bool get isRewardedReady => _rewarded != null;

  // Keep old getter name for backward compatibility
  bool get isReady => isInterstitialReady;

  Future<void> init() async {
    await MobileAds.instance.initialize();
    _loadInterstitial();
    _loadRewarded();
  }

  // ── Interstitial ──────────────────────────────────────────────────────────

  void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitial = ad;
          _interstitial!.setImmersiveMode(true);
        },
        onAdFailedToLoad: (_) => _interstitial = null,
      ),
    );
  }

  void showInterstitial() {
    _interstitial?.show();
    _interstitial = null;
    _loadInterstitial();
  }

  // ── Rewarded ──────────────────────────────────────────────────────────────

  void _loadRewarded() {
    RewardedAd.load(
      adUnitId: rewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _rewarded = ad,
        onAdFailedToLoad: (_) => _rewarded = null,
      ),
    );
  }

  /// Shows rewarded ad. Calls [onRewarded] when user earns the reward.
  /// Calls [onNotReady] if the ad hasn't loaded yet.
  void showRewarded({
    required void Function() onRewarded,
    required void Function() onNotReady,
  }) {
    if (_rewarded == null) {
      onNotReady();
      return;
    }
    _rewarded!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewarded = null;
        _loadRewarded();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _rewarded = null;
        _loadRewarded();
      },
    );
    _rewarded!.show(
      onUserEarnedReward: (_, __) => onRewarded(),
    );
    _rewarded = null;
  }
}
