# 01a0fec6-0147-7a52-9be0-19cfa12eb79f
[Open replay](https://us.posthog.com/project/638414/replay/01a0fec6-0147-7a52-9be0-19cfa12eb79f) · 2026-10-02 22:39–22:41 UTC · 56s wall · start `reqistry.dev/#mcp` · Mobile/Android/Firefox · 2 events

## Timeline
- 22:39:46 `$pageview /`
- 22:41:01 `$pageleave /` (75s later — **actually read the page**)

## What the user does
Middle of the #mcp triplet, on Firefox (others Chrome): reads for 75 seconds, clean pageleave. The only triplet member with a proper read + leave pair.

## Weird moment
Correction to the first-pass report: this was NOT a bounce — 75s dwell with a clean leave is a completed read. Browser-switch theory holds ("maybe it renders in Firefox") — and Firefox seemingly delivered where Chrome didn't hold them (6s and 46s).

## Delays
52s of the 56 recorded as inactive — reading.

## Emotion arc
Troubleshooting their own way around your page, then (apparently) satisfied. The happiest docs outcome in the set, earned the hard way.

## Improvements
1. Diff Chrome vs Firefox mobile render of #mcp (code-block overflow? sticky nav? font load?). Whatever Firefox does right, backport.
2. If 75s reads are the success shape, add a 60s "was this helpful" hook to catch the next triplet-user mid-struggle.
