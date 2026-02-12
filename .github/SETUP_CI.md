# GitHub Actions CI/CD Setup for iOS Build & Diawi Distribution

This guide explains how to set up the GitHub Actions workflow to automatically build your iOS app and upload it to Diawi for testing distribution.

## Prerequisites

1. **Apple Developer Account** - You have this ✓
2. **Diawi Account** - Create one at [diawi.com](https://diawi.com) (free)
3. **GitHub Repository** - Already set up at `channing173/LoadrApp` ✓

## Step 1: Generate Signing Certificate

### Option A: Using Xcode (Recommended)

1. Open your project in Xcode: `npx cap open ios`
2. Select the "App" target
3. Go to **Signing & Capabilities**
4. Make sure "Automatically manage signing" is **checked**
5. Let Xcode create the signing certificate for you

### Option B: Manual Certificate Generation

1. Go to [Apple Developer Portal](https://developer.apple.com/account/resources/certificates/list)
2. Click **"+"** to create a new certificate
3. Select **"Apple Distribution"** (for App Store distribution)
4. Follow the prompts to upload a Certificate Signing Request (CSR)
5. Download the `.cer` file

## Step 2: Export Signing Certificate as P12

1. Open **Keychain Access** on your Mac
2. Go to **My Certificates** tab
3. Find your Apple Distribution certificate
4. Right-click → **Export**
5. Save as `certificate.p12` with a password

## Step 3: Create Provisioning Profile

1. Go to [Apple Developer Portal - Provisioning Profiles](https://developer.apple.com/account/resources/identifiers/bundleIdentifier)
2. Create an App ID for `com.channing.loadr` if it doesn't exist
3. Go to [Provisioning Profiles](https://developer.apple.com/account/resources/profiles/list)
4. Click **"+"** to create a new profile
5. Select **App Store** as the type
6. Select your App ID (`com.channing.loadr`)
7. Select your certificate
8. Name it: **LoadrApp**
9. Download the `.mobileprovision` file

## Step 4: Prepare Secrets for GitHub

### Convert Certificate and Profile to Base64

```bash
# Convert P12 certificate to base64
base64 -i certificate.p12 | pbcopy

# Convert provisioning profile to base64
base64 -i LoadrApp.mobileprovision | pbcopy
```

## Step 5: Add GitHub Secrets

1. Go to your GitHub repository: [LoadrApp Settings](https://github.com/channing173/LoadrApp/settings)
2. Click **Secrets and variables** → **Actions**
3. Click **New repository secret** and add each:

| Secret Name | Value |
|---|---|
| `BUILD_CERTIFICATE_BASE64` | Output from step 4 (certificate converted to base64) |
| `P12_PASSWORD` | Password you created when exporting the certificate |
| `KEYCHAIN_PASSWORD` | Any secure password (for GitHub Actions keychain) - e.g., generate with `openssl rand -base64 32` |
| `APPLE_TEAM_ID` | Your 10-character Apple Team ID (from [Membership details](https://developer.apple.com/account/#membership)) |
| `PROVISIONING_PROFILE_BASE64` | Output from step 4 (profile converted to base64) |
| `DIAWI_TOKEN` | Your Diawi API token (see next section) |

## Step 6: Get Diawi API Token

1. Log in to [Diawi](https://diawi.com)
2. Go to **Account Settings**
3. Click **API** or **Tokens**
4. Generate or copy your API token
5. Add it as the `DIAWI_TOKEN` secret in GitHub

## Step 7: Update exportOptions.plist

Edit [ios/App/exportOptions.plist](../ios/App/exportOptions.plist) to include:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>provisioningProfiles</key>
    <dict>
        <key>com.channing.loadr</key>
        <string>LoadrApp</string>
    </dict>
    <key>signingStyle</key>
    <string>manual</string>
    <key>stripSwiftSymbols</key>
    <true/>
    <key>teamID</key>
    <string>YOUR_TEAM_ID_HERE</string>
</dict>
</plist>
```

Replace `YOUR_TEAM_ID_HERE` with your actual Apple Team ID.

## Step 8: Test the Workflow

1. Push a change to the `main` branch:
   ```bash
   git add .
   git commit -m "Setup CI/CD"
   git push origin main
   ```

2. Go to the **Actions** tab in your GitHub repository
3. Watch the **Build iOS IPA and Deploy to Diawi** workflow
4. Once complete, check Diawi for the uploaded build

## Troubleshooting

### Signing Issues
- Ensure the provisioning profile name matches what's in `exportOptions.plist`
- Verify the Team ID matches your Apple Developer account
- Check that the certificate is valid and not expired

### Build Failures
- Check the workflow logs in GitHub Actions
- Ensure all dependencies are installed: `npm ci`
- Try building locally with `npx cap open ios` → Xcode

### Diawi Upload Issues
- Verify the API token is correct
- Ensure the IPA was built successfully (check previous steps)
- Check Diawi's API documentation for the correct endpoint

## Manual Workflow Trigger

You can manually trigger the workflow from the **Actions** tab without pushing code:
1. Go to **Build iOS IPA and Deploy to Diawi**
2. Click **Run workflow**
3. Choose whether to upload to Diawi or just build

## Next Steps

- [ ] Generate and export signing certificate
- [ ] Create provisioning profile
- [ ] Add all secrets to GitHub
- [ ] Update exportOptions.plist
- [ ] Push to main branch to trigger build
- [ ] Verify build appears in Diawi
