import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:api_scout/app/services/ads/ads_controller.dart';

/// Anchored adaptive banner slot. Reserves its exact height while loading
/// or loaded, collapses to nothing on definitive failure or when ads are
/// not allowed. Never shows error UI; never touches the ad platform when
/// [AdsController.canShowAds] is false.
class AdBannerSlot extends StatefulWidget {
  const AdBannerSlot({super.key, this.controller});

  /// Overrides the shared controller (tests inject fakes).
  final AdsController? controller;

  @override
  State<AdBannerSlot> createState() => _AdBannerSlotState();
}

class _AdBannerSlotState extends State<AdBannerSlot> {
  late final AdsController _controller =
      widget.controller ?? AdsController();
  BannerAd? _banner;
  AnchoredAdaptiveBannerAdSize? _size;
  bool _failed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_banner != null || _failed) return;
    if (!_controller.canShowAds) {
      _failed = true;
      return;
    }
    _resolveAndLoad();
  }

  Future<void> _resolveAndLoad() async {
    final width = MediaQuery.sizeOf(context).width.truncate();
    AnchoredAdaptiveBannerAdSize? size;
    try {
      size = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(width);
    } catch (_) {
      size = null;
    }
    if (!mounted || size == null) {
      if (mounted) setState(() => _failed = true);
      return;
    }
    // Reserve the exact height before the creative arrives.
    if (mounted) setState(() => _size = size);
    final banner = BannerAd(
      size: size,
      adUnitId: _controller.units.bannerUnitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() {});
        },
        onAdFailedToLoad: (ad, _) {
          ad.dispose();
          if (mounted) {
            setState(() {
              _failed = true;
              _banner = null;
            });
          }
        },
      ),
    );
    try {
      await banner.load();
    } catch (_) {
      banner.dispose();
      if (mounted) setState(() => _failed = true);
      return;
    }
    if (mounted) {
      setState(() => _banner = banner);
    } else {
      banner.dispose();
    }
  }

  @override
  void dispose() {
    _banner?.dispose();
    _banner = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banner = _banner;
    final size = _size;
    // Definitive failure (or ads not allowed): no gap, no error UI.
    if (_failed || size == null) {
      return const SizedBox.shrink();
    }
    return SafeArea(
      top: false,
      child: SizedBox(
        width: size.width.toDouble(),
        height: size.height.toDouble(),
        // Empty reserved box while the creative loads.
        child: banner == null ? const SizedBox.shrink() : AdWidget(ad: banner),
      ),
    );
  }
}
