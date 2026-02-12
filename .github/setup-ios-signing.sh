#!/bin/bash

# iOS Certificate & Provisioning Profile Setup Script for Linux
# This script automates common tasks for generating signing certificates

set -e

echo "=========================================="
echo "iOS Certificate Setup for Linux"
echo "=========================================="
echo ""

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Step 1: Generate Private Key and CSR
generate_csr() {
    echo -e "${YELLOW}[Step 1/4] Generating Certificate Signing Request (CSR)${NC}"
    echo ""
    
    if [ -f "private.key" ]; then
        read -p "private.key already exists. Overwrite? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Using existing private.key"
            return
        fi
    fi
    
    echo "Enter your information for the certificate:"
    read -p "Country Code (e.g., US): " COUNTRY
    read -p "State/Province (e.g., CA): " STATE
    read -p "City (e.g., San Francisco): " CITY
    read -p "Organization (e.g., My Company): " ORG
    
    # Generate private key
    openssl genrsa -out private.key 2048
    echo -e "${GREEN}✓ Created private.key${NC}"
    echo ""
    
    # Generate CSR
    openssl req -new -key private.key -out LoadrApp.csr \
        -subj "/C=$COUNTRY/ST=$STATE/L=$CITY/O=$ORG/CN=Loadr"
    echo -e "${GREEN}✓ Created LoadrApp.csr${NC}"
    echo ""
    echo "Next: Upload LoadrApp.csr to Apple Developer Portal"
    echo "  1. Go to: https://developer.apple.com/account/resources/certificates/list"
    echo "  2. Click '+' → Select 'Apple Distribution'"
    echo "  3. Upload LoadrApp.csr"
    echo "  4. Download as distribution.cer"
    echo ""
    read -p "Press Enter once you've downloaded distribution.cer"
}

# Step 2: Convert Certificate to P12
convert_to_p12() {
    if [ ! -f "distribution.cer" ]; then
        echo -e "${RED}✗ distribution.cer not found!${NC}"
        echo "Download it from Apple Developer Portal first."
        exit 1
    fi
    
    if [ ! -f "private.key" ]; then
        echo -e "${RED}✗ private.key not found!${NC}"
        echo "Run step 1 first."
        exit 1
    fi
    
    echo -e "${YELLOW}[Step 2/4] Converting Certificate to P12 Format${NC}"
    echo ""
    echo "Creating LoadrApp.p12 (you'll be prompted for a password)"
    
    openssl pkcs12 -export -inkey private.key -in distribution.cer \
        -out LoadrApp.p12 -name "Apple Distribution"
    
    echo -e "${GREEN}✓ Created LoadrApp.p12${NC}"
    echo ""
}

# Step 3: Encode to Base64
encode_base64() {
    echo -e "${YELLOW}[Step 3/4] Encoding Files to Base64${NC}"
    echo ""
    
    if [ ! -f "LoadrApp.p12" ]; then
        echo -e "${RED}✗ LoadrApp.p12 not found!${NC}"
        exit 1
    fi
    
    if [ ! -f "LoadrApp.mobileprovision" ]; then
        echo -e "${RED}✗ LoadrApp.mobileprovision not found!${NC}"
        echo "Download it from Apple Developer Portal:"
        echo "  1. Go to: https://developer.apple.com/account/resources/profiles/list"
        echo "  2. Create new profile (App Store type)"
        echo "  3. Select Bundle ID: com.channing.loadr"
        echo "  4. Select your distribution certificate"
        echo "  5. Name it: LoadrApp"
        echo "  6. Download the .mobileprovision file"
        echo ""
        read -p "Press Enter once you've downloaded LoadrApp.mobileprovision"
    fi
    
    # Encode P12
    echo "Encoding P12 certificate..."
    base64 -w 0 LoadrApp.p12 > BUILD_CERTIFICATE_BASE64.txt
    echo -e "${GREEN}✓ Saved to BUILD_CERTIFICATE_BASE64.txt${NC}"
    
    # Encode Provisioning Profile
    echo "Encoding provisioning profile..."
    base64 -w 0 LoadrApp.mobileprovision > PROVISIONING_PROFILE_BASE64.txt
    echo -e "${GREEN}✓ Saved to PROVISIONING_PROFILE_BASE64.txt${NC}"
    echo ""
}

# Step 4: Display Summary
show_secrets() {
    echo -e "${YELLOW}[Step 4/4] GitHub Secrets${NC}"
    echo ""
    echo "Add these secrets to your GitHub repository:"
    echo "https://github.com/channing173/LoadrApp/settings/secrets/actions"
    echo ""
    echo "=${YELLOW}BUILD_CERTIFICATE_BASE64${NC}="
    cat BUILD_CERTIFICATE_BASE64.txt
    echo ""
    echo ""
    echo "=${YELLOW}PROVISIONING_PROFILE_BASE64${NC}="
    cat PROVISIONING_PROFILE_BASE64.txt
    echo ""
    echo ""
    echo -e "${YELLOW}P12_PASSWORD${NC}"
    echo "(The password you entered when creating the P12 file)"
    echo ""
    echo -e "${YELLOW}KEYCHAIN_PASSWORD${NC}"
    echo "(Generate a secure password, e.g.):"
    openssl rand -base64 32
    echo ""
    echo -e "${YELLOW}APPLE_TEAM_ID${NC}"
    echo "Get from: https://developer.apple.com/account/#membership"
    echo "(10-character code)"
    echo ""
}

# Main menu
main() {
    echo "Choose an option:"
    echo ""
    echo "1) Generate CSR (start here)"
    echo "2) Convert certificate to P12"
    echo "3) Encode files to Base64"
    echo "4) Show all secrets"
    echo "5) Run complete setup (1-4)"
    echo "6) Exit"
    echo ""
    read -p "Enter choice [1-6]: " choice
    
    case $choice in
        1) generate_csr && main ;;
        2) convert_to_p12 && main ;;
        3) encode_base64 && main ;;
        4) show_secrets && main ;;
        5) 
            generate_csr
            convert_to_p12
            encode_base64
            show_secrets
            ;;
        6) 
            echo -e "${GREEN}Done!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice${NC}"
            main
            ;;
    esac
}

# Run main menu
main
