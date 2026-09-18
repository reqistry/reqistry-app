import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:api_scout/app/services/ads/ads_controller.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/l10n/app_localizations.dart';

/// Native ad rendered inside browse result lists through Google's official
/// medium template (no custom platform factory). Always carries a visible
/// "Ad" disclosure chip in a tinted container so it cannot be mistaken for
/// an API card. Collapses (and reports via [onUnavailable]) when ads are
/// not allowed or the fill fails — the parent must drop the slot.
class CatalogNativeAdCard extends StatefulWidget {
  const CatalogNativeAdCard({
    super.key,
    this.controller,
    this.onUnavailable,
  });

  /// Overrides the shared controller (tests inject fakes).
  final AdsController? controller;

  /// Called once when this slot can never render (not allowed or failed).
  final VoidCallback? onUnavailable;

  @override
  State<CatalogNativeAdCard> createState() => _CatalogNativeAdCardState();
}

class _CatalogNativeAdCardState extends State<CatalogNativeAdCard> {
  late final AdsController _controller =
      widget.controller ?? AdsController();
  NativeAd? _ad;
  bool _loaded = false;
  bool _reported = false;

  @override
  void initState() {
    super.initState();
    if (!_controller.canShowAds) {
      _reportUnavailable();
      return;
    }
    final ad = NativeAd(
      adUnitId: _controller.units.nativeUnitId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (adToDispose, _) {
          adToDispose.dispose();
          _fail();
        },
        onAdClicked: (_) {},
        onAdImpression: (_) {},
        onAdClosed: (_) {},
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
      ),
    );
    _ad = ad;
    try {
      ad.load();
    } catch (_) {
      _fail();
    }
  }

  void _fail() {
    _ad = null;
    _reportUnavailable();
    if (mounted) setState(() {});
  }

  void _reportUnavailable() {
    if (_reported) return;
    _reported = true;
    widget.onUnavailable?.call();
  }

  @override
  void dispose() {
    _ad?.dispose();
    _ad = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (!_loaded || ad == null) {
      return const SizedBox.shrink();
    }
    final c = AppColors.of(Theme.of(context).brightness);
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s12),
      decoration: BoxDecoration(
        color: c.surfaceContainerLow,
        border: Border.all(color: c.outlineVariant),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s6,
              vertical: AppSpacing.s2,
            ),
            color: c.surface,
            child: Text(
              l10n.adBadgeLabel,
              style: AppTextStyles.labelSm.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          SizedBox(
            height: 300,
            child: AdWidget(ad: ad),
          ),
        ],
      ),
    );
  }
}
