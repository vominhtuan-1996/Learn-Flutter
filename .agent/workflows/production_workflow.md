---
name: production_workflow
description: Quy trình Production Workflow kết hợp Shorebird, Fastlane, Firebase App Distribution và Enterprise signing
---

# 🚀 Production Workflow

Kết hợp:
- Shorebird
- Fastlane
- Firebase App Distribution
- Enterprise signing

workflow sẽ là:

```text
Flutter
   ↓
Shorebird release
   ↓
Fastlane build/sign
   ↓
Enterprise IPA/APK
   ↓
Firebase Distribution
   ↓
OTA patch via Shorebird
```

## 🧠 1. Recommended Structure
```text
project/
├── fastlane/
│   ├── Fastfile
│   ├── Appfile
│   ├── Matchfile
│   ├── release_ios.sh
│   ├── release_android.sh
│   ├── patch.sh
│   └── .env
│
├── shorebird.yaml
├── firebase.json
└── .github/workflows/
```

## ⚡ 2. Enterprise Signing Setup

Trong Apple Developer:
- Enterprise Certificate
- Enterprise Provisioning Profile

Xcode:
- Signing & Capabilities
  ↓
- Automatically manage signing = OFF

Dùng:
- manual signing
- enterprise profile

## 🚀 3. Install
**Fastlane**
```bash
brew install fastlane
```

**Shorebird**

Shorebird Official Website
```bash
curl --proto '=https' --tlsv1.2 https://raw.githubusercontent.com/shorebirdtech/install/main/install.sh -sSf | bash
```

**Firebase CLI**
```bash
npm install -g firebase-tools
```

## 🌊 4. Shorebird Release
First release
```bash
shorebird release ios
shorebird release android
```

## 🎯 5. Fastlane Enterprise Build
`fastlane/Fastfile`
```ruby
default_platform(:ios)

platform :ios do

  desc "Enterprise Release"

  lane :enterprise do

    build_app(
      workspace: "Runner.xcworkspace",
      scheme: "production",

      export_method: "enterprise",

      export_options: {
        provisioningProfiles: {
          "com.example.app" =>
            "Enterprise_Profile"
        }
      }
    )

    firebase_app_distribution(
      app: ENV["FIREBASE_IOS_APP_ID"],

      groups: "tester",

      release_notes: "Enterprise build"
    )
  end

  desc "OTA Patch"

  lane :patch do
    sh("shorebird patch ios")
  end
end
```

## ⚡ 6. Android Lane
`fastlane/Fastfile` (tiếp theo)
```ruby
default_platform(:android)

platform :android do

  desc "Enterprise Android"

  lane :enterprise do

    gradle(
      task: "bundle",
      build_type: "Release"
    )

    firebase_app_distribution(
      app: ENV["FIREBASE_ANDROID_APP_ID"],

      groups: "tester",

      release_notes: "Enterprise Android"
    )
  end

  desc "OTA Patch"

  lane :patch do
    sh("shorebird patch android")
  end
end
```

## 🎬 7. Firebase Distribution

Firebase Console

Tester groups:
- internal
- qa
- tester
- beta

## 🧠 8. Environment Config
`.env`
```env
FIREBASE_IOS_APP_ID=xxx
FIREBASE_ANDROID_APP_ID=xxx
```

## 🚀 9. Full Enterprise Pipeline
```text
git push
   ↓
CI/CD
   ↓
fastlane enterprise
   ↓
sign ipa/apk
   ↓
firebase distribute
   ↓
shorebird patch
```

## ⚡ 10. Release Script
`fastlane/release_ios.sh`
```bash
#!/bin/bash

set -e

shorebird release ios

cd ios

fastlane enterprise
```

`fastlane/release_android.sh`
```bash
#!/bin/bash

set -e

shorebird release android

cd android

fastlane enterprise
```

## 🌊 11. OTA Patch Script
`fastlane/patch.sh`
```bash
#!/bin/bash

shorebird patch ios
shorebird patch android
```

## 🎯 12. Very Important Architecture

**Store/Enterprise Build**
- native changes
- plugin changes
- permission changes

**Shorebird Patch**
- dart logic
- ui
- animation
- feed
- business logic

## 🚀 13. Best Practice
- ✅ semantic release notes
- ✅ patch small frequently
- ✅ feature flags
- ✅ remote config
- ✅ rollback strategy

## ⚡ 14. Recommended CI/CD
| Tool | Role |
|---|---|
| GitHub Actions | CI |
| Fastlane | sign/build |
| Shorebird | OTA |
| Firebase | distribution |

## 🌊 15. Best Production Stack cho bạn
```text
Flutter
   ↓
Fastlane
   ↓
Firebase Distribution
   ↓
Shorebird OTA
   ↓
Remote Config
```

## 🎮 16. Perfect for your app

Vì bạn đang build:

- animation engine
- render layer engine
- viewport transform
- sliver feed

👉 OTA patch rất đáng giá:

- tune animation
- fix rendering
- tweak interaction
- patch feed

realtime.

## 🧠 17. Advanced direction

Mình recommend build thêm:

1. 🔥 Patch rollback engine
2. 🌊 Dynamic staged rollout
3. 🎥 OTA-safe feature flags
4. ⚡ Patch analytics dashboard
5. 🧠 Auto patch release notes

👉 để thành:
**enterprise-grade Flutter delivery platform.**
