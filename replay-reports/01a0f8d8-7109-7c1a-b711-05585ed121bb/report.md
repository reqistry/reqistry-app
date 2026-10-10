# 01a0f8d8-7109-7c1a-b711-05585ed121bb
[Open replay](https://us.posthog.com/project/638414/replay/01a0f8d8-7109-7c1a-b711-05585ed121bb) · 2026-10-01 19:02–19:11 UTC (events run 19:02:37–19:11:31, ~9 min) · 36 clicks · start `/submissions` · Mobile/Android · 80 events — the SHARER

## Timeline
- Starts on `/submissions` (returning user, no install) → root → auth → `$identify` → submit-api → bg → back → root → `$set`
- 19:03:44 slug + detail → 19:03:47 `$exception` **[ConcurrentModificationError]** (3s) → save → created → deleted (11s) → save → created …
- 19:04:35 bg → back → 19:04:36 `api_detail_shared` (immediately on return — came back TO share) → deleted → save → created → health → deleted → save → created
- 19:06:12 root → bg ×3 with returns → notifications → root → 19:07:24 detail → save/create/delete ×3 → 19:07:52 outbound → bg → back
- 19:08:00 slug → **82s gap** → 19:09:22 `api_detail_shared` #2 (composing a message!) → deleted → created + save → 19:10:22 outbound #2 → bg → back → health → deleted → save → created → root ×3 → bg → back → root, end

## What the user does
Social/distribution behavior: 2 shares (only multi-share session), 2 outbound docs, 2 health checks, 9 saves + 9 creates + 7 deletes — collecting APIs to send elsewhere, managing the collection mid-share.

## Weird moment
Share #1 fires instantly on foreground (19:04:36, 1s after return) — the background gap was message-composition elsewhere. Share #2 follows an 82s on-page pause — same pattern. 9 backgroundings (~1/min) = copy-link → paste-in-chat → back, all session long. And save-thrash infects even this happy flow (created→deleted 11s apart, repeatedly).

## Delays
66s recorded inactive, but the real gaps are the 82s compose + bg-switching — productive absence.

## Emotion arc
Enthusiastic curator throughout. Sharing = delight; save-thrash = papercut inside delight; the single exception 3s into the first detail didn't dent anything.

## Improvements
1. Build for this user: system share-sheet with rich link cards, "copy 3 links at once" multi-share, chat-app deep links with previews — they're doing it manually twice over.
2. Same save-toggle fix; thrash even infects happy sessions (9/7 here).
