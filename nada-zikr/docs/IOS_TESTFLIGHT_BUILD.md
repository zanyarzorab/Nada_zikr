# iOS TestFlight & App Store Distribution Guide for Nada: Dhikr & Quran

This document explains how the iOS release workflow produces a **genuine Apple Distribution-signed IPA** for **Nada: Dhikr & Quran** using GitHub Actions, and how to submit it to **Apple TestFlight / App Store Connect**.

---

## 1. What Was Changed

* **Workflow Created**: [`.github/workflows/flutter-ios-release.yml`](../.github/workflows/flutter-ios-release.yml) — Runs on a GitHub-hosted Apple Silicon runner (`macos-14`), creates an ephemeral signing keychain, installs dual provisioning profiles (for the main app and the WidgetKit extension), configures manual signing settings for both targets, executes `flutter build ipa --release` with an App Store `ExportOptions.plist`, strictly validates code signatures, and uploads the verified `.ipa` and `.xcarchive` artifacts.
* **Security Rules Added**: Root [`.gitignore`](../.gitignore) and [`nada-zikr/.gitignore`](../nada-zikr/.gitignore) updated to prevent any `.p12`, `.cer`, `.p8`, `.mobileprovision`, `.keystore`, or `.ipa` files from ever being committed to Git.
* **Obsolete Workflows Removed**: Removed legacy workflows that previously built unsigned or sideload-only packages.
* **Helper Script Provided**: [`tools/export_signing_secrets.sh`](../tools/export_signing_secrets.sh) created to automate certificate and profile export on macOS.
* **Existing Application Code**: **100% untouched.** Zero changes were made to the Dart codebase, UI, database, Azkar/Quran/Hadith assets, translations, notifications, or Android configuration.

---

## 2. How Apple Distribution Signing Works

In Apple's ecosystem, an iOS app destined for TestFlight or the App Store cannot be simply zipped or self-signed. It requires:

1. An **Apple Distribution Certificate** issued by Apple's Certificate Authority to a paid Apple Developer Account. This proves the authenticity of the developer.
2. An **App Store Distribution Provisioning Profile** for each app target:
   - **Main App Target**: `com.nada.nadaZikrakanm`
   - **WidgetKit Extension Target**: `com.nada.nadaZikrakanm.PrayerTimesWidget`
   Both profiles must have `get-task-allow = false` (production distribution) and be linked to the shared App Group: `group.com.nada.nadaZikrakanm`.
3. An **`ExportOptions.plist`** with:
   - `method = app-store`
   - `signingStyle = manual`
   - Target bundle IDs mapped to their respective provisioning profile UUIDs.
4. During archive export, Xcode signs both the widget `.appex` and the main `.app`, creates cryptographic `_CodeSignature` directories, and embeds `embedded.mobileprovision` into both bundles.

---

## 3. Required GitHub Secrets

To ensure security, **no credentials or passwords are saved in the repository**. Instead, encrypted GitHub Secrets are used.

Navigate in your GitHub repository to:  
**Settings** → **Secrets and variables** → **Actions** → **New repository secret**

| Secret Name | Description | Example Value |
|---|---|---|
| `BUILD_CERTIFICATE_BASE64` | Base64 string of the exported Apple Distribution `.p12` file | `MIIK...` (base64 string) |
| `P12_PASSWORD` | The password chosen when exporting the `.p12` certificate | `bismilah` (or your chosen password) |
| `BUILD_PROVISION_PROFILE_BASE64` | Base64 string of the App Store distribution `.mobileprovision` for `com.nada.nadaZikrakanm` | `MIIX...` (base64 string) |
| `WIDGET_PROVISION_PROFILE_BASE64` | Base64 string of the App Store distribution `.mobileprovision` for `com.nada.nadaZikrakanm.PrayerTimesWidget` | `MIIX...` (base64 string) |
| `KEYCHAIN_PASSWORD` *(Optional)* | Password for the temporary CI keychain (defaults to a random UUID if omitted) | *(Optional)* |

> [!IMPORTANT]
> The workflow will **fail immediately** if any of the 4 required secrets are missing. It will never silently fall back to an unsigned or sideloaded build.

---

## 4. How the Apple Developer Account Owner Provides Credentials

Share these instructions with the owner of the Apple Developer account:

### Step A: Verify App Identifiers on developer.apple.com
1. Go to [developer.apple.com/account/resources/identifiers/list](https://developer.apple.com/account/resources/identifiers/list).
2. Under **App Groups**, verify `group.com.nada.nadaZikrakanm` exists.
3. Under **App IDs**:
   - Verify `com.nada.nadaZikrakanm` has **App Groups** and **Time-Sensitive Notifications** checked.
   - Verify `com.nada.nadaZikrakanm.PrayerTimesWidget` has **App Groups** checked.

### Step B: Download Provisioning Profiles
1. Go to [developer.apple.com/account/resources/profiles/list](https://developer.apple.com/account/resources/profiles/list).
2. Create/Download an **App Store** distribution profile for `com.nada.nadaZikrakanm`.
3. Create/Download an **App Store** distribution profile for `com.nada.nadaZikrakanm.PrayerTimesWidget`.

### Step C: Run the Automated Export Script (on Mac)
Your friend can clone this repository on their Mac and run:
```bash
bash tools/export_signing_secrets.sh
```
The script will:
1. Automatically find their **Apple Distribution** certificate in Keychain Access.
2. Export it with password `bismilah`.
3. Ask to drag and drop the two `.mobileprovision` files.
4. Generate a file named **`github_secrets_ready_to_paste.txt`** containing the exact 4 values to paste into GitHub Secrets.

---

## 5. How to Run the Workflow from Windows

1. Open your repository on **GitHub.com** in any browser.
2. Click the **Actions** tab at the top.
3. In the left sidebar, click **Flutter iOS Release**.
4. Click the **Run workflow** dropdown button:
   - **Branch**: `main`
   - **Marketing version name override**: Leave blank (uses `1.0.0` from `pubspec.yaml`), or enter a new version.
   - **Build number override**: Leave blank (uses `5` from `pubspec.yaml`), or enter a new build number.
5. Click the green **Run workflow** button.

---

## 6. How to Download the IPA

Once the workflow finishes (approx. 10–15 minutes):
1. Click the completed run under the **Actions** tab.
2. Scroll to the bottom to the **Artifacts** section.
3. Download:
   - **`Nada-iOS-v1.0.0-build5`**: The distribution IPA (zipped).
   - **`Nada-iOS-v1.0.0-build5-xcarchive`**: The full Xcode archive (for crash symbolication and debugging).
4. Extract the zip on Windows to obtain `Nada-iOS-v1.0.0-build5.ipa`.

---

## 7. How the Workflow Automatically Verifies the IPA

The workflow performs strict automated validation before marking the build as successful:
1. **Integrity Check**: Checks file size (> 1 MB, not corrupt).
2. **Bundle Identifiers**: Verifies `com.nada.nadaZikrakanm` and `com.nada.nadaZikrakanm.PrayerTimesWidget`.
3. **Version & Build**: Verifies `1.0.0` and `5`.
4. **Code Signatures**: Verifies `_CodeSignature` exists in both `Runner.app` and `PrayerTimesWidget.appex`.
5. **Apple Tools Verification**: Runs `codesign --verify --deep --strict` using Apple's official verification tools.
6. **Signing Authority**: Verifies that the signing certificate is an official **Apple Distribution** certificate.
7. **Embedded Profiles**: Verifies `embedded.mobileprovision` is present in both targets and confirms `get-task-allow = false` (distribution profile).
8. **Device Architecture**: Checks `lipo -info` to ensure the binary contains `arm64` and is not a simulator build.

---

## 8. How to Upload the IPA to App Store Connect

Because you have the signed IPA, your friend (or anyone with access) can upload it using:

### Method 1: Apple Transporter App (Recommended)
1. Install **Transporter** (free from the Mac App Store).
2. Sign in with the Apple Developer Apple ID.
3. Drag and drop `Nada-iOS-v1.0.0-build5.ipa` into Transporter.
4. Click **Deliver**.
5. The build will process on Apple's servers and appear under TestFlight in 5–10 minutes.

### Method 2: Xcode Organizer
1. Unzip `Nada-iOS-v1.0.0-build5-xcarchive.zip`.
2. Double-click `Runner.xcarchive` on macOS. Xcode Organizer opens.
3. Click **Distribute App** → **TestFlight & App Store** → **Upload**.

---

## 9. How to Add Testers in TestFlight

Once Apple finishes processing the build in App Store Connect:
1. Go to [appstoreconnect.apple.com](https://appstoreconnect.apple.com) → **My Apps** → **Nada**.
2. Click the **TestFlight** tab.
3. Select build `1.0.0 (5)`:
   - **Internal Testers**: Add members of your App Store Connect team for instant testing (no Apple review needed).
   - **External Testers**: Create a public group (e.g. "Beta Testers"), add email addresses or generate a public invite link (requires a brief Apple Beta App Review).

---

## 10. How to Create Future Releases (Build 6, Build 7, etc.)

Apple requires every new upload to have a higher build number:

### Option A: Update in Code (Recommended)
Edit `nada-zikr/pubspec.yaml`:
```yaml
version: 1.0.0+6   # Changes build number to 6
```
Commit and push to `main`. When you trigger the workflow, it automatically builds `Nada-iOS-v1.0.0-build6.ipa`.

### Option B: Override in Workflow UI
When clicking **Run workflow** in GitHub Actions, type `6` into the **Build number override** field. The workflow will produce Build 6 without modifying any code.
