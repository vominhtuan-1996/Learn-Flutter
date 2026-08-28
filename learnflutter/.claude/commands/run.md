# Run Flutter App (Debug)

Run the Flutter app in debug mode. Always scan devices first, let user pick.

**Usage:**
- `/run` — scan devices → user picks → run
- `/run lib/main_story.dart` — scan devices → user picks → run with custom entry point

**Steps:**

1. Run `fvm flutter devices 2>/dev/null` to get all connected devices.

2. Parse and display a numbered list — **exclude** `macos`, `chrome`, `web`:
   ```
   Connected devices:
   1. iPhone của ISC  [iOS 27.0]  • 00008110-001919C00286601E  (physical)
   2. iPhone của ISC  [iOS 16.7]  • f7fd24941a810790747fcb46802809cba191d8e2  (physical)
   3. Pixel 7         [Android 14] • emulator-5554  (emulator)
   ```
   Mark physical devices vs simulator/emulator. If no devices found → tell user to connect a device and exit.

3. Ask user: **"Chọn device (nhập số):"** — use AskUserQuestion tool to prompt.

4. After user picks number, confirm the selected device name + ID.

5. Determine entry point:
   - If skill arg contains a `.dart` path → use that
   - Otherwise → `lib/main.dart`

6. Run:
   ```
   fvm flutter run -d <device-id> -t <entry-point>
   ```

7. Monitor output and report:
   - Build errors → show relevant error lines, stop
   - Launch success → "App đang chạy trên [device name]. Hot reload: `r` | Quit: `q`"
   - iOS local network error → "Vào System Settings > Privacy > Local Network → bật cho Terminal"

**Notes:**
- Always `fvm flutter`, never bare `flutter`
- Always show device list before running — never auto-pick silently
- Physical device > simulator when recommending, but user decides
