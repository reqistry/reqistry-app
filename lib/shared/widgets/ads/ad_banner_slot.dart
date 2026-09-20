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
      widget.controller ?? AdsController.shared;
  BannerAd? _banner;
  AnchoredAdaptiveBannerAdSize? _size;
  bool _loading = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleAdsChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadIfEligible();
  }

  void _handleAdsChanged() {
    if (!mounted) return;
    if (_controller.canShowAds) {
      _loadIfEligible();
      return;
    }
    if (_banner != null || _size != null) {
      _banner?.dispose();
      setState(() {
        _banner = null;
        _size = null;
      });
    }
  }

  void _loadIfEligible() {
    if (!_controller.canShowAds || _banner != null || _loading || _failed) {
      return;
    }
    _loading = true;
    _resolveAndLoad();
  }

  Future<void> _resolveAndLoad() async {
    final width = MediaQuery.sizeOf(context).width.truncate();
    AnchoredAdaptiveBannerAdSize? size;
    try {
      // Large adaptive banners may reserve an empty band above 50dp ads.
      // ignore: deprecated_member_use
      size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
        width,
      );
    } catch (_) {
      size = null;
    }
    if (!mounted || size == null) {
      if (mounted) {
        setState(() {
          _loading = false;
          _failed = true;
        });
      }
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
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner ad unavailable: $error');
          ad.dispose();
          if (mounted) {
            setState(() {
              _loading = false;
              _failed = true;
              _banner = null;
            });
          }
        },
      ),
    );
    try {
      await banner.load();
    } catch (error) {
      debugPrint('Banner ad load failed: $error');
      banner.dispose();
      if (mounted) {
        setState(() {
          _loading = false;
          _failed = true;
        });
      }
      return;
    }
    if (mounted) {
      setState(() {
        _loading = false;
        _banner = banner;
      });
    } else {
      banner.dispose();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleAdsChanged);
    _banner?.dispose();
    _banner = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banner = _banner;
    final size = _size;
    // Definitive failure (or ads not allowed): no gap, no error UI.
    if (!_controller.canShowAds || _failed || size == null) {
      return const SizedBox.shrink();
    }
    // No SafeArea here: the host bottom bar owns the single system inset,
    // so the creative sits flush with zero surrounding space.
    return SizedBox(
      width: size.width.toDouble(),
      height: size.height.toDouble(),
      // Empty reserved box while the creative loads.
      child: banner == null ? const SizedBox.shrink() : AdWidget(ad: banner),
    );
  }
}
