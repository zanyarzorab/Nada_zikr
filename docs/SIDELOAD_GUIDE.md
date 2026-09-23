# 📱 iOS Sideloading Guide (SideStore, iLoader, AltStore & TrollStore)

This guide explains how to build and install **Nada Dhikr** onto your iPhone or iPad without an App Store developer account using GitHub Actions and popular sideloading utilities.

---

## 🛠️ 1. Building the IPA via GitHub Actions

The repository includes an automated workflow: `.github/workflows/sidestore-iloader-ipa.yml`.

### How to trigger a build:
1. Go to your GitHub repository in your browser.
2. Click on the **Actions** tab.
3. In the left sidebar, click **Build SideStore & iLoader IPA**.
4. Click **Run workflow** (top right dropdown).
   - **Flutter channel**: Select `stable` (recommended).
   - **Publish to GitHub Releases**: Keep `true` (recommended, allows direct Safari downloads on iOS).
   - **Custom release tag name**: Optional (leave blank to auto-generate).
5. Click the green **Run workflow** button.
6. The macOS runner will compile and sanitize the IPAs in ~5–7 minutes.

---

## 📦 2. Which IPA Should You Use?

The workflow automatically generates two distinct IPAs:

| File Name | Intended Use / Compatibility | Why? |
| :--- | :--- | :--- |
| **`Nada-Zikr-SideStore.ipa`** *(Recommended)* | **SideStore, iLoader, AltStore** | Free Apple IDs have a limit of **10 App IDs** every 7 days and cannot sign App Extensions. This IPA strips `.appex` to ensure 100% plug-and-play installation without error popups. |
| **`Nada-Zikr-Full.ipa`** | **TrollStore, Scarlet, ESign, Paid Apple ID** | Retains the Home Screen **Prayer Times Widget** (`PrayerTimesWidget.appex`). Perfect for TrollStore or paid developer accounts. |

---

## 🚀 3. Sideloading Instructions

### 📲 Method A: SideStore (On-Device via iPhone Safari)
*SideStore allows you to refresh and install apps directly on your iPhone over Wi-Fi without needing a PC after initial setup.*

1. On your iPhone, open **Safari** and navigate to your GitHub repository's **Releases** page (or Actions run artifacts).
2. Download **`Nada-Zikr-SideStore.ipa`**.
3. Ensure your **SideStore WireGuard VPN** is enabled in `Settings > VPN`.
4. Open the **SideStore** app.
5. Tap the **`+` (Plus)** button in the top left corner of the **My Apps** tab.
6. Select the downloaded `Nada-Zikr-SideStore.ipa`.
7. SideStore will re-sign the IPA with your personal Apple ID and install it.

---

### 💻 Method B: iLoader / Sideloadly (PC or Mac via USB)
*Fast and reliable desktop sideloading.*

1. Download **`Nada-Zikr-SideStore.ipa`** to your computer from GitHub Releases or Artifacts.
2. Launch **iLoader** or **Sideloadly**.
3. Connect your iPhone to your PC/Mac via lightning or USB-C cable and unlock your screen.
4. Drag and drop `Nada-Zikr-SideStore.ipa` into the sideloading tool.
5. Enter your Apple ID email.
6. Click **Start** / **Install** and enter your Apple ID password (or app-specific password if requested).
7. Once finished:
   - On your iPhone, open **Settings > General > VPN & Device Management**.
   - Tap your Apple ID under *Developer App* and tap **Trust**.
   - (iOS 16+): Go to **Settings > Privacy & Security > Developer Mode** and toggle it **ON** (device will reboot).

---

### 💻 Method C: AltStore
1. Download `Nada-Zikr-SideStore.ipa` on your iPhone via Safari.
2. Open **AltStore**, navigate to **My Apps**, and tap the **`+`** icon.
3. Select `Nada-Zikr-SideStore.ipa`.
4. Wait for AltServer to install the app.

---

### ⚡ Method D: TrollStore (iOS 14.0 - 16.6.1 / 17.0)
*No 7-day expiration, no app ID limits, no revokes.*

1. Open Safari on your TrollStore-enabled iPhone.
2. Download **`Nada-Zikr-Full.ipa`**.
3. Tap the file in Safari Downloads -> tap the Share Sheet -> tap **TrollStore**.
4. Tap **Install**. The app and its Widget Extension will be permanently installed.

---

## ❓ Frequently Asked Questions & Troubleshooting

### Q: Why does SideStore show "Failed to verify code signature" with normal IPAs?
**A:** Building an iOS app with `flutter build ios --no-codesign` leaves behind incomplete placeholder signature blocks (`_CodeSignature`). When SideStore attempts to apply your free developer profile on top of residual signatures, iOS rejects the bundle. Our workflow automatically strips all stale code signatures and provisioning profiles before compressing the IPA.

### Q: Why does SideStore say "Maximum number of apps reached" or fail on widgets?
**A:** Free Apple IDs are limited to 10 active App IDs per week. A main app + a widget extension takes 2 App IDs. Furthermore, free accounts often fail to generate provisioning profiles for app extensions. Using `Nada-Zikr-SideStore.ipa` avoids this completely.
