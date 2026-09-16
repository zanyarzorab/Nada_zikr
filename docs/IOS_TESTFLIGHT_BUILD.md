# iOS TestFlight & App Store Build Guide

This document explains how to produce a production-quality, distribution-signed iOS `.ipa` for **Nada: Dhikr & Quran** using GitHub Actions, and how to submit it to **Apple TestFlight / App Store Connect**.

---

## 1. How the Workflow Works

The workflow is located at:
[`.github/workflows/flutter-ios-release.yml`](../.github/workflows/flutter-ios-release.yml)

It executes on a GitHub-hosted Apple Silicon macOS runner (`macos-14`) and performs the following automated steps:

```
[Trigger (Manual Dispatch)]
          │
          ▼
[Pre-flight Check] ──► Fails immediately if any required Apple signing secrets are missing
          │
          ▼
[Environment Setup] ──► Sets up Flutter (stable), Java 17, and installs CocoaPods dependencies
          │
          ▼
[Secure Keychain] ──► Creates a temporary CI keychain & imports Apple Distribution certificate
          │
          ▼
[Inspect Profiles] ──► Decodes & validates profiles for Runner (App) and PrayerTimesWidget (Extension)
          │
          ▼
[ExportOptions & Xcode] ──► Dynamically configures manual signing for all targets
          │
          ▼
[Build & Export IPA] ──► Executes `flutter build ipa --release` using Apple Distribution signing
          │
          ▼
[Deep Validation] ──► Verifies: size, bundle IDs, version, arm64, extension integrity, and signatures
          │
          ▼
[Artifact Upload] ──► Uploads `Nada-iOS-v1.0.0-build5.ipa` (ready to download on Windows!)
          │
          ▼ (Optional)
[TestFlight Upload] ──► Submits build directly to TestFlight if API key secrets are present
```

---

## 2. Required GitHub Secrets

To protect security, **no certificates or passwords are saved in the repository**. Instead, your friend (the Apple Developer account owner) provides encrypted GitHub Secrets.

Navigate in your GitHub repository to:
**Settings** → **Secrets and variables** → **Actions** → **New repository secret**

### Mandatory Signing Secrets (Required to produce the signed IPA)

| Secret Name | Description | Example / Format |
|---|---|---|
| `BUILD_CERTIFICATE_BASE64` | The **Apple Distribution Certificate** with its private key exported as a `.p12` file, converted to a Base64 string. | Base64 string (`MIIK...`) |
| `P12_PASSWORD` | The password chosen by your friend when exporting the `.p12` file from Keychain Access. | `YourSecurePassword123` |
| `BUILD_PROVISION_PROFILE_BASE64` | The **App Store Distribution Provisioning Profile** for the main app bundle ID (`com.nada.nadaZikrakanm`), converted to a Base64 string. | Base64 string (`MIIX...`) |
| `WIDGET_PROVISION_PROFILE_BASE64` | The **App Store Distribution Provisioning Profile** for the widget extension bundle ID (`com.nada.nadaZikrakanm.PrayerTimesWidget`), converted to a Base64 string. | Base64 string (`MIIX...`) |

### Optional Secrets (For Direct Upload to TestFlight)

If your friend wants GitHub Actions to automatically upload the build to TestFlight:

| Secret Name | Description | Where to find in Apple Developer |
|---|---|---|
| `APPSTORE_KEY_ID` | 10-character API Key ID | **App Store Connect** → Users and Access → Integrations → Keys |
| `APPSTORE_ISSUER_ID` | Issuer ID (UUID) | Shown above the keys table on App Store Connect |
| `APPSTORE_PRIVATE_KEY` | Contents of the downloaded `.p8` private key file | Open `AuthKey_XXXXX.p8` in a text editor and paste entire text |

*(If these optional secrets are omitted, the workflow still builds and validates the signed IPA and uploads it as a downloadable GitHub Actions artifact).*

---

## 3. Instructions for Your Friend (Apple Developer Account Owner)

Share these instructions with your friend who owns the Apple Developer account:

### Step A: Verify App IDs & App Groups on developer.apple.com

Nada uses an iOS WidgetKit extension, which means **two App IDs** and **one App Group** must exist:

1. **App Group**:
   - Identifier: `group.com.nada.nadaZikrakanm`
2. **Main App Identifier**:
   - Identifier: `com.nada.nadaZikrakanm`
   - Capabilities enabled:
     - **App Groups** (checked and linked to `group.com.nada.nadaZikrakanm`)
     - **Time-Sensitive Notifications**
3. **Widget Extension Identifier**:
   - Identifier: `com.nada.nadaZikrakanm.PrayerTimesWidget`
   - Capabilities enabled:
     - **App Groups** (checked and linked to `group.com.nada.nadaZikrakanm`)

### Step B: Create / Export the Apple Distribution Certificate (`.p12`)

1. On a Mac, open **Keychain Access**.
2. If your friend does not already have an active **Apple Distribution Certificate**:
   - Go to [developer.apple.com/account/resources/certificates](https://developer.apple.com/account/resources/certificates).
   - Click `+`, select **Apple Distribution**, and upload a Certificate Signing Request (CSR) generated from Keychain Access.
   - Download the generated `.cer` file and double-click to install it into Keychain Access.
3. In **Keychain Access**, find the certificate named `Apple Distribution: [Friend's Name / Org Name]`.
4. Click the disclosure arrow next to it so both the certificate and its private key are visible.
5. Right-click the certificate and choose **Export "Apple Distribution: ..."**.
6. Select **Format: Personal Information Exchange (.p12)**.
7. Enter a password (e.g. `MyStrongPass2026!`). Note this password down—it is `P12_PASSWORD`.
8. In macOS Terminal, convert the `.p12` file to Base64:
   ```bash
   base64 -i distribution.p12 -o cert_base64.txt
   ```
9. Copy the contents of `cert_base64.txt` and save as GitHub Secret `BUILD_CERTIFICATE_BASE64`.

### Step C: Generate the Provisioning Profiles

Your friend needs **two App Store Distribution profiles**:

1. Go to [developer.apple.com/account/resources/profiles](https://developer.apple.com/account/resources/profiles).
2. **Profile 1 (Main App)**:
   - Click `+` → Select **App Store** under Distribution → Continue.
   - App ID: Select `com.nada.nadaZikrakanm` (Nada).
   - Certificate: Select the Apple Distribution Certificate created above.
   - Profile Name: `Nada AppStore Profile` → Generate & Download.
   - In Terminal, encode to Base64:
     ```bash
     base64 -i Nada_AppStore_Profile.mobileprovision -o profile_main_base64.txt
     ```
   - Copy contents to GitHub Secret: `BUILD_PROVISION_PROFILE_BASE64`.
3. **Profile 2 (Widget Extension)**:
   - Click `+` → Select **App Store** under Distribution → Continue.
   - App ID: Select `com.nada.nadaZikrakanm.PrayerTimesWidget`.
   - Certificate: Select the same Apple Distribution Certificate.
   - Profile Name: `Nada Widget AppStore Profile` → Generate & Download.
   - In Terminal, encode to Base64:
     ```bash
     base64 -i Nada_Widget_AppStore_Profile.mobileprovision -o profile_widget_base64.txt
     ```
   - Copy contents to GitHub Secret: `WIDGET_PROVISION_PROFILE_BASE64`.

---

## 4. How to Run the Workflow from Windows

You can run the build anytime directly from your web browser on Windows:

1. Open your repository on **GitHub.com**.
2. Click the **Actions** tab at the top.
3. In the left sidebar, click **iOS Release (App Store / TestFlight)**.
4. Click the **Run workflow** dropdown button on the right:
   - **Branch**: `main`
   - **Marketing version name override**: Leave blank (uses `1.0.0` from `pubspec.yaml`), or enter a new version like `1.0.1`.
   - **Build number override**: Leave blank (uses `5` from `pubspec.yaml`), or enter a new build number like `6`.
   - **Upload directly to TestFlight**: Set to `true` if you added the `APPSTORE_*` API key secrets, or leave `false` to download the `.ipa` artifact manually.
5. Click the green **Run workflow** button.

---

## 5. Where to Download the Generated IPA

Once the workflow finishes (takes approx. 10-15 minutes):

1. Click on the completed workflow run in the **Actions** tab.
2. Scroll to the bottom to the **Artifacts** section.
3. You will see:
   - `Nada-iOS-v1.0.0-build5` (The ready-to-use distribution IPA).
   - `Nada-iOS-v1.0.0-build5-xcarchive` (The full Xcode archive for symbolication/troubleshooting).
4. Click on `Nada-iOS-v1.0.0-build5` to download the zip file to your Windows computer.
5. Extract the zip to get `Nada-iOS-v1.0.0-build5.ipa`.

---

## 6. How Your Friend Can Upload the IPA to App Store Connect / TestFlight

There are two easy methods to upload the downloaded IPA to TestFlight:

### Method 1: Using the Apple "Transporter" App (Easiest)

1. Have your friend install **Transporter** (free from the Mac App Store).
2. Sign in with their Apple Developer Apple ID.
3. Send them the downloaded `Nada-iOS-v1.0.0-build5.ipa`.
4. Drag and drop the `.ipa` into Transporter.
5. Click **Deliver**.
6. In a few minutes, the build will appear under **TestFlight** in App Store Connect.

### Method 2: Using the macOS Terminal (`xcrun altool`)

Your friend can upload directly from their Mac terminal:

```bash
xcrun altool --upload-app \
  -f "Nada-iOS-v1.0.0-build5.ipa" \
  -t ios \
  -u "apple-developer-email@example.com" \
  -p "app-specific-password"
```

*(Or use an App Store Connect API Key with `--apiKey` and `--apiIssuer`).*

---

## 7. How to Increment the Build Number for Future Releases

Apple requires every new upload to TestFlight to have a **higher build number** than the previous one.

You have two choices:

### Option A: Update in Code (Recommended for Git tracking)
Open `nada-zikr/pubspec.yaml` and update line 4:
```yaml
version: 1.0.0+6   # +6 is the build number
```
Commit and push to `main`. When you trigger the workflow, it will automatically build Version `1.0.0`, Build `6`.

### Option B: Override via Workflow Dispatch UI
When clicking **Run workflow** in GitHub Actions, type `6` (or `7`, etc.) into the **Build number override** field. The workflow will build with that number without modifying your code.

---

## 8. Troubleshooting Common Signing & Provisioning Errors

### Error: "Runner provisioning profile is a DEVELOPMENT profile (get-task-allow=true)"
- **Cause**: The profile downloaded from developer.apple.com was created under "iOS App Development" instead of "App Store" under Distribution.
- **Fix**: Generate a new profile under **Distribution → App Store**, convert to Base64, and update `BUILD_PROVISION_PROFILE_BASE64`.

### Error: "Widget profile App ID does not match target bundle ID"
- **Cause**: The widget profile was created for the wrong App ID.
- **Fix**: Verify the App ID in the Apple Portal is `com.nada.nadaZikrakanm.PrayerTimesWidget` and recreate the profile.

### Error: "Code signature authority is not an Apple Distribution certificate"
- **Cause**: An Apple Development / iOS Developer certificate was exported instead of an Apple Distribution certificate.
- **Fix**: Ensure the certificate in Keychain Access begins with `Apple Distribution:` or `iPhone Distribution:`.

### Error: "Missing required signing secret(s)"
- **Cause**: One of the four mandatory secrets is not set or misspelled.
- **Fix**: Check `Settings` → `Secrets and variables` → `Actions` and ensure exact names:
  - `BUILD_CERTIFICATE_BASE64`
  - `P12_PASSWORD`
  - `BUILD_PROVISION_PROFILE_BASE64`
  - `WIDGET_PROVISION_PROFILE_BASE64`
