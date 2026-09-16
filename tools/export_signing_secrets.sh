#!/bin/bash
# ==============================================================================
# Helper Script for Nada: Dhikr & Quran iOS Signing Secrets
# Run this on the Mac that has access to the Apple Developer Account.
# ==============================================================================

set -e

echo "================================================================"
echo " Nada: Dhikr & Quran - Apple Developer Secrets Exporter"
echo "================================================================"
echo ""

OUTPUT_FILE="github_secrets_ready_to_paste.txt"
rm -f "$OUTPUT_FILE"

# 1. P12 Password
P12_PASS="bismilah"

# 2. Find Apple Distribution Certificate in Keychain
echo "Searching Keychain for Apple Distribution certificate..."
CERT_NAME=$(security find-identity -v -p codesigning | grep -o 'Apple Distribution:.*' | head -1 || true)

if [ -z "$CERT_NAME" ]; then
    CERT_NAME=$(security find-identity -v -p codesigning | grep -o 'iPhone Distribution:.*' | head -1 || true)
fi

if [ -z "$CERT_NAME" ]; then
    echo "ERROR: No 'Apple Distribution' or 'iPhone Distribution' certificate found in Keychain!"
    echo "Please download and install your Distribution certificate from developer.apple.com first."
    exit 1
fi

echo "Found Certificate: $CERT_NAME"

# Clean name for security export
CLEAN_CERT_NAME=$(echo "$CERT_NAME" | sed 's/"//g')

# Export .p12
P12_TMP="temp_distribution.p12"
rm -f "$P12_TMP"

echo "Exporting certificate to .p12 (Enter your Mac login password if prompted)..."
security export -k login.keychain-db -t identities -f pkcs12 -o "$P12_TMP" -P "$P12_PASS"

CERT_BASE64=$(base64 -i "$P12_TMP" | tr -d '\r\n')
rm -f "$P12_TMP"

# 3. Provisioning Profiles
echo ""
echo "Now we need the two App Store Provisioning Profiles from developer.apple.com:"
echo "1) Profile for: com.nada.nadaZikrakanm"
echo "2) Profile for: com.nada.nadaZikrakanm.PrayerTimesWidget"
echo ""

# Ask for Main App Profile Path
read -r -p "Enter path to main app .mobileprovision (or drag and drop file here): " MAIN_PP_PATH
MAIN_PP_PATH=$(echo "$MAIN_PP_PATH" | sed -e "s/^'//" -e "s/'$//" -e 's/^"//' -e 's/"$//' -e 's/\\ / /g')

if [ ! -f "$MAIN_PP_PATH" ]; then
    echo "ERROR: File not found at '$MAIN_PP_PATH'"
    exit 1
fi

MAIN_PP_BASE64=$(base64 -i "$MAIN_PP_PATH" | tr -d '\r\n')

# Ask for Widget Profile Path
read -r -p "Enter path to widget .mobileprovision (or drag and drop file here): " WIDGET_PP_PATH
WIDGET_PP_PATH=$(echo "$WIDGET_PP_PATH" | sed -e "s/^'//" -e "s/'$//" -e 's/^"//' -e 's/"$//' -e 's/\\ / /g')

if [ ! -f "$WIDGET_PP_PATH" ]; then
    echo "ERROR: File not found at '$WIDGET_PP_PATH'"
    exit 1
fi

WIDGET_PP_BASE64=$(base64 -i "$WIDGET_PP_PATH" | tr -d '\r\n')

# 4. Write all 4 secrets to output file
cat <<EOF > "$OUTPUT_FILE"
================================================================================
GITHUB SECRETS FOR NADA IOS BUILD (COPY AND PASTE TO GITHUB)
================================================================================

1. Secret Name: BUILD_CERTIFICATE_BASE64
Value:
$CERT_BASE64

--------------------------------------------------------------------------------

2. Secret Name: P12_PASSWORD
Value:
$P12_PASS

--------------------------------------------------------------------------------

3. Secret Name: BUILD_PROVISION_PROFILE_BASE64
Value:
$MAIN_PP_BASE64

--------------------------------------------------------------------------------

4. Secret Name: WIDGET_PROVISION_PROFILE_BASE64
Value:
$WIDGET_PP_BASE64

================================================================================
EOF

echo ""
echo "================================================================"
echo " SUCCESS! All 4 secrets saved to: $OUTPUT_FILE"
echo " Just open that file, copy each value, and add to GitHub Secrets!"
echo "================================================================"
