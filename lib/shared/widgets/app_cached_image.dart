import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/shared/widgets/image_loading.dart';
import 'package:api_scout/shared/widgets/image_fallback.dart';

/// Rate limiter that throttles concurrent image loads per domain.
///
/// Prevents HTTP 429 (Too Many Requests) when many images share the same
/// base domain. Each domain gets its own independent slot pool.
///
/// Usage:
/// ```dart
/// // Configure globally (default is 3)
/// DomainRateLimiter.instance.maxConcurrent = 2;
/// ```
class DomainRateLimiter {
  static final DomainRateLimiter instance = DomainRateLimiter._();
  DomainRateLimiter._();

  /// Maximum concurrent loads allowed per domain.
  int maxConcurrent = 3;

  final Map<String, int> _activeRequests = {};
  final Map<String, List<Completer<void>>> _queues = {};

  String _extractDomain(String url) {
    final uri = Uri.tryParse(url);
    return uri?.host ?? url;
  }

  /// Acquires a loading slot for the domain of [url].
  ///
  /// Resolves immediately if a slot is available, otherwise waits until one
  /// is released by another request completing.
  Future<void> acquire(String url) async {
    final domain = _extractDomain(url);
    final current = _activeRequests[domain] ?? 0;

    if (current < maxConcurrent) {
      _activeRequests[domain] = current + 1;
      return;
    }

    final completer = Completer<void>();
    _queues.putIfAbsent(domain, () => []).add(completer);
    await completer.future;
  }

  /// Releases the loading slot for the domain of [url].
  ///
  /// If other requests are queued for the same domain, the next one is
  /// unblocked immediately (slot is reused).
  void release(String url) {
    final domain = _extractDomain(url);
    final queue = _queues[domain];

    if (queue != null && queue.isNotEmpty) {
      queue.removeAt(0).complete();
    } else {
      final current = _activeRequests[domain] ?? 0;
      _activeRequests[domain] = (current - 1).clamp(0, maxConcurrent);
    }
  }
}

class AppCachedImage extends StatefulWidget {
  final String? imageUrl;
  final BoxFit fit;
  final Widget? fallback;
  final Widget? placeholder;
  final bool isCategory;

  const AppCachedImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.fallback,
    this.placeholder,
    this.isCategory = false,
  });

  @override
  State<AppCachedImage> createState() => _AppCachedImageState();
}

class _AppCachedImageState extends State<AppCachedImage> {
  bool _slotAcquired = false;
  bool _slotReleased = false;

  @override
  void initState() {
    super.initState();
    _acquireSlot();
  }

  @override
  void didUpdateWidget(covariant AppCachedImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _releaseSlot();
      _slotAcquired = false;
      _slotReleased = false;
      _acquireSlot();
    }
  }

  Future<void> _acquireSlot() async {
    final url = widget.imageUrl;
    if (url == null || url.isEmpty) return;

    await DomainRateLimiter.instance.acquire(url);

    if (mounted) {
      setState(() {
        _slotAcquired = true;
      });
    } else {
      // Widget disposed while waiting — release immediately so the slot
      // isn't held uselessly.
      DomainRateLimiter.instance.release(url);
    }
  }

  void _releaseSlot() {
    if (_slotReleased) return;
    _slotReleased = true;
    final url = widget.imageUrl;
    if (url != null && url.isNotEmpty) {
      DomainRateLimiter.instance.release(url);
    }
  }

  @override
  void dispose() {
    _releaseSlot();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final url = widget.imageUrl;
    if (url == null || url.isEmpty) {
      return widget.fallback ?? const ImageFallback();
    }

    if (!_slotAcquired) {
      return widget.placeholder ?? const ImageLoading();
    }

    return CachedNetworkImage(
      imageUrl: url,
      fit: widget.fit,
      placeholder: (_, __) => widget.placeholder ?? const ImageLoading(),
      errorWidget: (_, __, ___) {
        if (widget.isCategory) {
          debugPrint('Error loading category image: $url');
        }

        _releaseSlot();
        return widget.fallback ?? const ImageFallback();
      },
      imageBuilder: (context, imageProvider) {
        _releaseSlot();
        return Image(
          image: imageProvider,
          fit: widget.fit,
        );
      },
    );
  }
}

class CategoryImagePlaceholder extends StatelessWidget {
  final String? title;
  final String? name;
  final String? imageUrl;
  final double size;

  const CategoryImagePlaceholder({
    super.key,
    this.title,
    this.name,
    this.imageUrl,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    final displayName = name ?? title ?? '';
    final initials = displayName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: c.surfaceContainerHighest),
      child: AppCachedImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        fallback: Center(
          child: Text(
            initials.isEmpty ? '?' : initials,
            style: AppTextStyles.headlineSm.copyWith(
              color: c.primary,
              fontWeight: FontWeight.w800,
              fontSize: size * 0.35,
            ),
          ),
        ),
      ),
    );
  }
}
