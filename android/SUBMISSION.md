# Établi Probe — Android submission checklist

## Build outputs
- **Debug APK** — `app/build/outputs/apk/debug/app-debug.apk` (17 MB)
- **Release AAB** — `app/build/outputs/bundle/release/app-release.aab` (3.7 MB, signed, R8 + resource-shrink)

## Signing
Upload keystore at `app/upload-keystore.jks`; credentials in `keystore.properties` (gitignored). Placeholder password (`android`) — **regenerate with a real password before publishing** (same pattern as the other Etabli Android twins):

```bash
keytool -genkeypair -v -keystore app/upload-keystore.jks -alias upload \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -dname "CN=Your Name, O=Your Org, C=DE"
```

## What's done
- Native Kotlin + Compose with the byte-identical Coder DS theme tokens
- HttpURLConnection-based WebDAV client (PROPFIND / GET / PUT / MKCOL) — no OkHttp/external HTTP dep, uses the platform XmlPullParser
- WebView-driven foreground checker via `AndroidView` interop in Compose
- HttpURLConnection background checker with hand-rolled redirect follower (so http→https captures show as such, like iOS URLSession does)
- Append-only CSV logger in `filesDir/probe_logs/`
- Credentials in `EncryptedSharedPreferences` (AES-256 GCM, master key in Android Keystore)
- Per-install UUID in the same encrypted prefs blob — explicitly NOT a hardware/device ID
- `FileProvider` configured for share-sheet exports (`${applicationId}.fileprovider`)
- Settings: mode chips, delay/timeout sliders, Nextcloud creds with PROPFIND "Save & test", theme chips
- R8 + resource shrinking on release; Tink (`security-crypto` transitive) keep rules added so EncryptedSharedPreferences survives minify
- ApplicationIdSuffix `.debug` so debug + release builds coexist on a device

## What you must do before publishing
- [ ] Real upload key (see signing section)
- [ ] Privacy policy URL
- [ ] Play Console store listing — short/long description, 512×512 icon, 1024×500 feature graphic, ≥ 2 phone screenshots
- [ ] Content rating questionnaire (IARC)
- [ ] Data safety form — declare: user-entered server URL + Nextcloud app password (stored on-device, encrypted, never transmitted to us)
- [ ] **Background-mode caveat**: the Run tab's "background" mode runs sequentially in the foreground (the same in-app loop). For OS-budget-aware unattended sweeps, schedule a `OneTimeWorkRequest` (WorkManager is already in the deps) processing the persisted queue in slices. Mirror the pattern from the Flutter archive at `etabli_probe_flutter_ARCHIVE/`.

## How to build + install
```bash
cd "iOS Sandbox/EtabliProbeAndroid"
export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
export ANDROID_HOME="$HOME/Library/Android/sdk"

# Build
./gradlew assembleDebug bundleRelease

# Install on a running emulator / device
adb install -r app/build/outputs/apk/debug/app-debug.apk
adb shell am start -n com.raban.etabli.probe.debug/com.raban.etabli.probe.MainActivity

# Verify the release AAB locally:
brew install bundletool
bundletool build-apks --bundle=app/build/outputs/bundle/release/app-release.aab \
  --output=/tmp/probe.apks --mode=universal
bundletool install-apks --apks=/tmp/probe.apks
```

## File layout
```
app/src/main/java/com/raban/etabli/probe/
  EtabliProbeApplication.kt   process-wide singletons + applicationScope
  MainActivity.kt             setContent { CoderTheme { RootScreen() } }
  engine/
    Models.kt                 UrlEntry, CheckResult, RunMode, …
    CsvLoader.kt              comma/semicolon/tab auto-detect, RFC-4180-ish
    Checker.kt                BackgroundChecker (HttpURLConnection)
    Logger.kt                 append-only CSV
  net/
    WebDavClient.kt           PROPFIND / GET / PUT / MKCOL (Basic auth)
  prefs/
    SettingsStore.kt          DataStore (mode/delay/timeout/theme/upload dir/log rotation)
    CredsStore.kt             EncryptedSharedPreferences (Nextcloud + install UUID)
  ui/
    RootScreen.kt             bottom-nav scaffold
    RunState.kt               cross-screen run state holder
    theme/                    byte-identical Coder DS tokens + components
    screens/
      Common.kt               TextInput, ChipButton
      SourceScreen.kt         file picker + WebDAV fetch + column map
      RunScreen.kt            WebView foreground + sequential background
      ResultsScreen.kt        log table + filter + share + upload
      SettingsScreen.kt       mode/delay/timeout/Nextcloud/theme/about
```

## Why CSV not xlsx
The other Etabli Android twins are zero-extra-dep (just Compose + DataStore + the platform stdlib). Reading xlsx natively requires Apache POI (huge) or rolling our own ZIP + XML reader (≈ 300 LOC). To stay consistent with the suite, CSV only — both comma- and semicolon-separated dialects auto-detected. Most spreadsheet apps export to CSV in two clicks.
