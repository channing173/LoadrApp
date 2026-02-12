# Manual iOS Signing Certificate Setup on Linux

Complete guide to generate signing certificates, provisioning profiles, and prepare them for GitHub Actions without Xcode.

## Prerequisites

- OpenSSL (usually pre-installed on Linux)
- Apple Developer Account
- Access to Apple Developer Portal at developer.apple.com

## Step 1: Create a Certificate Signing Request (CSR) on Linux

Run these commands in your terminal:

```bash
# Create a private key (2048-bit RSA)
openssl genrsa -out private.key 2048

# Create a Certificate Signing Request (CSR)
openssl req -new -key private.key -out LoadrApp.csr -subj "/C=US/ST=YourState/L=YourCity/O=YourOrganization/CN=Loadr"
```

**Important:** Keep `private.key` safe - you'll need it to convert the certificate later.

## Step 2: Upload CSR to Apple Developer Portal

1. Go to [Apple Developer Portal - Certificates](https://developer.apple.com/account/resources/certificates/list)
2. Click **"+" (Create a new certificate)**
3. Select **"Apple Distribution"** certificate type
4. Click **Continue**
5. Click **"Choose File"** and upload your `LoadrApp.csr` from the previous step
6. Click **Continue** → **Download**
7. Save the `.cer` file as `distribution.cer`

## Step 3: Convert the Certificate to P12 Format

The `.cer` file from Apple is just the public certificate. To get a complete `.p12` file (which includes private key), we need to combine it with your private key:

```bash
# Find your certificate issuer (usually "Apple Worldwide Developer Relations Certification Authority")
openssl x509 -in distribution.cer -text -noout | grep -A1 "Issuer:"

# Create P12 file with private key (you'll be prompted for a password)
openssl pkcs12 -export -inkey private.key -in distribution.cer -out LoadrApp.p12 -name "Apple Distribution"
```

When prompted, enter a secure password. You'll need this for GitHub Actions as `P12_PASSWORD`.

**Important:** The P12 file is sensitive - keep it secure!

## Step 4: Create App ID (if not exists)

1. Go to [App IDs](https://developer.apple.com/account/resources/identifiers/list/bundleId)
2. Click **"+" (Register an App ID)**
3. Select **App** as the platform
4. Enter:
   - **Name:** Loadr
   - **Bundle ID:** com.channing.loadr (exact match in capacitor.config.json)
5. Click **Continue** → **Register**

## Step 5: Create Provisioning Profile

1. Go to [Provisioning Profiles](https://developer.apple.com/account/resources/profiles/list)
2. Click **"+" (Create a new profile)**
3. Select **App Store** as the profile type
4. Click **Continue**
5. Select your **App ID** (`com.channing.loadr`)
6. Click **Continue**
7. Select your **certificate** (the distribution one you just created)
8. Click **Continue**
9. Enter **Name:** `LoadrApp`
10. Click **Continue** → **Download**
11. Save as `LoadrApp.mobileprovision`

## Step 6: Convert Files to Base64 for GitHub

Run these commands on Linux to encode your certificate and profile:

```bash
# Encode P12 certificate to base64
base64 -w 0 LoadrApp.p12 > BUILD_CERTIFICATE_BASE64.txt
cat BUILD_CERTIFICATE_BASE64.txt

# Encode provisioning profile to base64
base64 -w 0 LoadrApp.mobileprovision > PROVISIONING_PROFILE_BASE64.txt
cat PROVISIONING_PROFILE_BASE64.txt
```

Copy the full output from each command - these are your secrets.

## Step 7: Get Your Apple Team ID

1. Go to [Apple Developer - Membership](https://developer.apple.com/account/#membership)
2. Find **Team ID** - it's a 10-character code (e.g., `ABC1234567`)
3. Copy this value for the `APPLE_TEAM_ID` secret

## Step 8: Add GitHub Secrets

Go to [LoadrApp Settings → Secrets and variables → Actions](https://github.com/channing173/LoadrApp/settings/secrets/actions)

Click **New repository secret** for each:

| Secret Name | Value | From Step |
|---|---|---|
| `BUILD_CERTIFICATE_BASE64` | Entire output from `cat BUILD_CERTIFICATE_BASE64.txt` | Step 6 |
| `P12_PASSWORD` | The password you entered when creating P12 | Step 3 |
| `KEYCHAIN_PASSWORD` | Any secure password (generate: `openssl rand -base64 32`) | New |
| `APPLE_TEAM_ID` | Your 10-character team ID | Step 7 |
| `PROVISIONING_PROFILE_BASE64` | Entire output from `cat PROVISIONING_PROFILE_BASE64.txt` | Step 6 |
| `DIAWI_TOKEN` | [Your Diawi API token](https://diawi.com) | Diawi account |

## Step 9: Update exportOptions.plist

Edit [ios/App/exportOptions.plist](../../ios/App/exportOptions.plist) and replace `YOUR_TEAM_ID` with your actual 10-character Apple Team ID.

## Step 10: Test the Workflow

```bash
# Verify your files are in place
ls -la LoadrApp.p12
ls -la LoadrApp.mobileprovision

# Push your setup to GitHub
git add .
git commit -m "Setup iOS CI/CD with certificates"
git push origin main
```

Then watch the workflow run in the **Actions** tab of your GitHub repository.

## Troubleshooting

### Import Certificate Error
If you get "certificate could not be imported", ensure:
- The private key (`private.key`) matches the `.cer` from Apple
- The P12 password is correct
- Use the name `"Apple Distribution"` when creating P12

### Code Signing Failure
- Verify Team ID is correct (10 characters)
- Ensure provisioning profile name is **exactly** `LoadrApp`
- Check bundle ID matches `com.channing.loadr` everywhere

### Certificate Expired
- CSR-based certificates are valid for 1 year
- Create a new CSR and repeat the process if expired

## File Cleanup

After setup, you can safely delete on Linux:
```bash
rm private.key          # Not needed after P12 is created
rm distribution.cer     # Not needed after P12 is created
rm LoadrApp.csr         # Not needed after Apple processes it
```

Keep safe:
- `LoadrApp.p12` - Back up securely (encrypted storage)
- `LoadrApp.mobileprovision` - Can re-download from Apple
- Base64 text files from Step 6 - Already in GitHub secrets
