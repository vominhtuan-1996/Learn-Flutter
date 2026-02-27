---
description: mcp workflow 
---

my_flutter_app/
 ├─ lib/
 ├─ ios/
 ├─ android/
 ├─ scripts/               👈 bash scripts (CI/CD dùng lại)
 │   ├─ build_ios.sh
 │   ├─ clean_ios.sh
 │   ├─ pod_install.sh
 │   ├─ build_xcframework.sh
 │   ├─ rename_xcframework.sh
 │   ├─ open_simulator.sh
 │   ├─ tail_log.sh
 │   └─ fastlane.sh
 │
 ├─ mcp/                   👈 MCP server
 │   ├─ package.json
 │   ├─ server.js
 │   └─ tools/
 │       ├─ shell.js
 │       ├─ flutter.js
 │       ├─ ios.js
 │       ├─ git.js
 │       └─ file.js
 │
 └─ pubspec.yaml