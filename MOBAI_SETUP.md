# MobAI setup — reqistry-app (Linux → cloud iOS simulator via Codemagic)

Goal: develop Flutter on Linux; OpenCode builds, launches, screenshots, taps,
and tests this app on a cloud iOS simulator. No local Mac.

Docs: https://mobai.run/docs/ · https://mobai.run/docs/cloud-agents/ ·
CLI: https://mobai.run/docs/cli/ · MCP/simulator: https://mobai.run/docs/ios-simulator/
Installed: `mobai-dev 1.3.4` (`~/.mobai/bin`, via `curl -fsSL https://mobai.run/cloud/install.sh | sh`)
plus desktop `mobai 3.3.2` from the `.deb` (`/usr/local/bin/mobai`, installed but not running).

## Done so far

- `mobai-dev setup --framework flutter` → `.mobai/config.json` (untracked).
- `ios/` generated (`flutter create --platforms=ios --org com.gwhyyy`), bundle ID
  set to `com.gwhyyy.publicApis` (= Android `applicationId`). Untracked, not committed.
- `scripts/mobai-sim-start.sh|mobai-sim-test.sh|mobai-sim-stop.sh` (this doc's workflows).
- Bztamy experiment fully reverted; nothing from it remains there.

## Blocked on you (all free; no payment)

1. **MobAI account email.** Sign-in creates the free account via emailed code:
   `mobai-dev login --email <you>` then `... --code <6 digits>`.
   Unblocks: preview engine install (`mobai-dev engines install flutter`),
   `mobai-up` device server, `sim start`. Reply with the email; never paste
   tokens/keys in chat — export them in your own shell (`export CODEMAGIC_API_TOKEN=...`).
2. **Codemagic app.** Create an app connected to a GitHub repo (YAML config),
   then reply with the app ID (after `/app/` in its URL). Then:
   `mobai-dev build init --provider codemagic --app-id <id> --branch main`
   writes `builder.json` + `codemagic.yaml` + `.builder/ci/runner.sh`; commit
   and push those to `main` (Codemagic reads workflows from the branch).
   Set `CODEMAGIC_API_TOKEN` (Account settings) in this shell before builds.
3. **Which GitHub repo?** You picked `API-Scout-App/api-scout-app`, but
   `mobai-dev` derives the snapshot repo from git `origin`
   (`anasfik/public-apis-mobile-client`). Confirm the Codemagic app connects
   to the same repo MobAI pushes snapshots to, or builds will miss.
4. **Firebase iOS app.** `lib/firebase_options.dart` iOS entry is a placeholder
   (`YOUR_IOS_APP_ID`, bundle `...publicApisDesktopClient`) and there is no
   `ios/Runner/GoogleService-Info.plist`. `MainInit` calls
   `Firebase.initializeApp` unconditionally → first simulator launch will fail
   until you register bundle `com.gwhyyy.publicApis` in the Firebase console
   and replace the placeholder + add the plist.
5. **AdMob iOS (later).** Ads init fails safe today (try/catch in
   `ads_controller.dart`), but real iOS ads need `GADApplicationIdentifier`
   in `ios/Runner/Info.plist`. Not needed for the first simulator smoke test.

## Codemagic secrets (`builder` env group, values Secret; plus non-secret `BUILDER=1`)

- `MOBAI_API_KEY` — required for `sim start` (publishes simulator to your account).
- `.env` materialization + `build_runner`: this app uses `envied`
  (`.env.dev`/`.env.prod` → `env.g.dart`, both git-ignored). The generated
  MobAI workflow only runs `flutter pub get`; mirror secret-to-`.env` steps
  plus `dart run build_runner build --delete-conflicting-outputs` or clean
  builds fail. Source values from Codemagic secrets, never the repo.
- Signed builds only: `IOS_CERTIFICATE_<SET>`, `IOS_CERTIFICATE_PASSWORD_<SET>`,
  `IOS_PROVISIONING_PROFILE_<SET>`, `IOS_EXTENSION_PROFILES_<SET>`
  (`<SET>` = DEVELOPMENT/AD_HOC/STORE). Unsigned simulator builds need none.
  Simulator sessions cap at 60 min idle on Codemagic (default 30 min).

## Costs (Oct 2026, verify before purchase)

- MobAI: builds/previews/shared simulators free with account; phone sessions
  60 min/day free, Pro $9.99/mo. MobAI charges nothing for CI minutes.
- Codemagic: 500 free macOS M2 min/mo, 1 parallel build, 120-min limit;
  then $0.095/min M2 ($0.114 M4). Failed builds consume minutes.

## Workflows

```sh
export PATH="$HOME/.mobai/bin:$PATH"
export CODEMAGIC_API_TOKEN='<from Codemagic account settings>'

sh scripts/mobai-sim-start.sh --duration 30m   # mobai-up + build + boot + install
MOBAI_DEVICE='<id-from-start>' sh scripts/mobai-sim-test.sh ./artifacts
sh scripts/mobai-sim-stop.sh                   # idle timeout ends it anyway
```

Drive manually (https://mobai.run/docs/cli/): `mobai devices list`,
`mobai observe`, `mobai app launch com.gwhyyy.publicApis`,
`mobai screenshot --path ./artifacts --name s --full`, `mobai tap "text-contains:X"`,
`mobai wait --stable`, `mobai assert exists "id:y"`, `mobai test ./flows/x.mob`.

## OpenCode integration

- CLI-first: OpenCode runs the scripts/`mobai` commands above directly.
- MCP (`http://127.0.0.1:8686/mcp`) is served by the desktop app / `mobai-dev start`
  on this machine only — a remote agent cannot reach another machine's `127.0.0.1`
  (per MobAI docs). No `mobai` MCP entry added to `opencode.json` yet; add
  `{"type":"remote","url":"http://127.0.0.1:8686/mcp"}` once the local server
  runs and you want it. MobAI documents no shared-simulator MCP endpoint.
