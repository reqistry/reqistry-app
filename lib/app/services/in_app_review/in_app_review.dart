import 'package:flutter/foundation.dart';

import 'package:api_scout/app/services/in_app_review/in_app_review_service.dart';
import 'package:api_scout/app/services/local_db/hive/locals_box.dart';

/// Single owner of the in-app-review policy (see package docs: prompt after
/// real value moments, sparingly, never via button or mid-task).
///
/// Call [recordWinAndMaybePrompt] after genuine wins (bookmark saved,
/// project created). Never blocks or throws — review must not break UX.
class InAppReview {
  InAppReview({InAppReviewService? service, LocalsDB? locals})
      : _service = service ?? InAppReviewService(),
        _locals = locals ?? LocalsDB.instance;

  final InAppReviewService _service;
  final LocalsDB _locals;

  static const winsKey = 'reviewWinsCount';
  static const firstWinAtKey = 'reviewFirstWinAt';
  static const lastPromptedAtKey = 'reviewLastPromptedAt';
  static const detailVisitsKey = 'reviewDetailVisits';

  static const minWins = 3;
  static const minDaysSinceFirstWin = 3;
  static const cooldownDays = 90;
  static const minDetailVisits = 3;

  Future<void> recordWinAndMaybePrompt({DateTime? now}) async {
    try {
      final current = DateTime.now();
      final wins = ((_locals.getWithKey(winsKey) as num?)?.toInt() ?? 0) + 1;
      await _locals.putWithKey(winsKey, wins);

      var firstWinAt = _parseDate(_locals.getWithKey(firstWinAtKey));
      firstWinAt ??= current;
      if (_locals.getWithKey(firstWinAtKey) == null) {
        await _locals.putWithKey(
            firstWinAtKey, firstWinAt.toIso8601String());
      }

      final lastPromptedAt = _parseDate(_locals.getWithKey(lastPromptedAtKey));
      if (!shouldPromptForReview(
        wins: wins,
        firstWinAt: firstWinAt,
        lastPromptedAt: lastPromptedAt,
        now: now ?? current,
      )) {
        return;
      }
      await _service.request();
      await _locals.putWithKey(
          lastPromptedAtKey, (now ?? current).toIso8601String());
    } catch (_) {
      // Review prompts are best-effort; never surface failures.
    }
  }

  /// Records an API detail visit and prompts once the visitor is engaged
  /// ([minDetailVisits] visits). No seasoning wait — visits are engagement.
  /// Shares the prompt cooldown with [recordWinAndMaybePrompt].
  Future<void> recordDetailVisitAndMaybePrompt({DateTime? now}) async {
    try {
      final current = now ?? DateTime.now();
      final visits =
          ((_locals.getWithKey(detailVisitsKey) as num?)?.toInt() ?? 0) + 1;
      await _locals.putWithKey(detailVisitsKey, visits);

      final lastPromptedAt = _parseDate(_locals.getWithKey(lastPromptedAtKey));
      if (!shouldPromptForDetailVisits(
        visits: visits,
        lastPromptedAt: lastPromptedAt,
        now: current,
      )) {
        return;
      }
      await _service.request();
      await _locals.putWithKey(
          lastPromptedAtKey, current.toIso8601String());
    } catch (_) {
      // Review prompts are best-effort; never surface failures.
    }
  }

  /// Pure prompt decision, extracted for testing.
  @visibleForTesting
  static bool shouldPromptForDetailVisits({
    required int visits,
    required DateTime? lastPromptedAt,
    required DateTime now,
  }) {
    if (visits < minDetailVisits) return false;
    if (lastPromptedAt != null &&
        now.difference(lastPromptedAt).inDays < cooldownDays) {
      return false;
    }
    return true;
  }

  /// Pure prompt decision, extracted for testing.
  @visibleForTesting
  static bool shouldPromptForReview({
    required int wins,
    required DateTime? firstWinAt,
    required DateTime? lastPromptedAt,
    required DateTime now,
  }) {
    if (wins < minWins) return false;
    if (firstWinAt == null) return false;
    if (now.difference(firstWinAt).inDays < minDaysSinceFirstWin) {
      return false;
    }
    if (lastPromptedAt != null &&
        now.difference(lastPromptedAt).inDays < cooldownDays) {
      return false;
    }
    return true;
  }

  static DateTime? _parseDate(Object? value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
