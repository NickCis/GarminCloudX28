Connect IQ (Monkey C) watch app — CloudX28

Prerequisites
- Garmin Connect IQ SDK installed (monkeyc on PATH or set SDK in Makefile).
- A developer signing key in PKCS#8 DER form (private_key.der). Generate with OpenSSL:
    openssl genrsa -out private_key.pem 4096
    openssl pkcs8 -topk8 -inform PEM -outform DER -in private_key.pem -out private_key.der -nocrypt
  Keep this key private; do not commit it to public repos.

Build
  cd /path/to/garmin
  make build
  # or:
  monkeyc -f monkey.jungle -o CloudX28.prg -y private_key.der -d fenix7spro -w

Use DEVICE=... if your watch matches another product id from the manifest.

Simulator (emulator)
1) Start the Connect IQ Simulator: run `connectiq` from the SDK bin directory (or launch "Connect IQ" from the SDK / your IDE). Leave it running.
2) Build the .prg (see above). `monkeyc` also writes a sibling `CloudX28-settings.json` (same basename as the `.prg`) describing Connect IQ app settings.
3) Push and run on the simulated device:
     make run
   `make run` passes that JSON into the simulator virtual filesystem (`GARMIN/Settings/…`) so **File → Edit Persistent Storage → Edit Application.properties data** works on Linux. If you invoke `monkeydo` yourself, do the same:
     monkeydo CloudX28.prg fenix7spro -a "CloudX28-settings.json:GARMIN/Settings/CLOUDX28-settings.json"
   Without that `-a` copy on Linux, the simulator often shows “No settings file found for this app” even though the app defines settings. Alternatively, copy `CloudX28-settings.json` to `/tmp/com.garmin.connectiq/GARMIN/Settings/CLOUDX28-settings.json` before opening the editor (see Garmin forum bug “Unable to detect settings file for watchface/app on Linux”).
   `monkeydo` talks to the already-running simulator over the SDK shell.

Notes for this app
- HTTPS goes through Garmin Connect Mobile on a real watch; the simulator uses the host network. You still need valid mail/password/PIN in app settings for API calls to succeed.
- After `make run`, set mail/password/PIN via **File → Edit Persistent Storage → Edit Application.properties data** (or the in-simulator app settings UI if your SDK shows it). On a physical watch, use Garmin Connect on the phone as documented below.

Physical watch
1) Pair the watch with Garmin Connect on your phone; keep Bluetooth on.
2) Build CloudX28.prg signed with your developer key (same as above).
3) Install to the watch:
   - Easiest: Garmin Connect IQ Extension for VS Code — "Run on device" / send to device.
   - Or: copy the .prg to the watch via USB mass storage if your model supports it (many newer watches do not expose app sideloading this way).
   - Or: publish as a private Connect IQ Store app and install from the store.
4) On the phone: Garmin Connect → Garmin Devices → your device → Connect IQ Apps → your app → Settings — set mail, password, and PIN. Sync so settings reach the watch.
5) Open the app on the watch from the apps list or add it as a favorite.

Garmin docs: Connect IQ Programmer's Guide (Getting Started, Command Line, Simulator).
