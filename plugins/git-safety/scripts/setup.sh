#!/bin/bash
# Git Safety Setup Script
# Checks for and installs gitleaks and trufflehog

set -e

echo "=== Git Safety Setup ==="
echo ""

# Detect OS
OS="unknown"
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
fi

echo "Detected OS: $OS"
echo ""

# Check for existing installations
GITLEAKS_INSTALLED=false
TRUFFLEHOG_INSTALLED=false

if command -v gitleaks &> /dev/null; then
    GITLEAKS_INSTALLED=true
    echo "[✓] Gitleaks already installed: $(gitleaks version 2>&1 | head -1)"
else
    echo "[✗] Gitleaks not found"
fi

if command -v trufflehog &> /dev/null; then
    TRUFFLEHOG_INSTALLED=true
    echo "[✓] TruffleHog already installed: $(trufflehog --version 2>&1 | head -1)"
else
    echo "[✗] TruffleHog not found"
fi

echo ""

# If both installed, we're done
if [ "$GITLEAKS_INSTALLED" = true ] && [ "$TRUFFLEHOG_INSTALLED" = true ]; then
    echo "All tools already installed! You're ready to use /secure-repo."
    exit 0
fi

# Installation instructions based on OS
echo "=== Installation Required ==="
echo ""

if [ "$OS" = "macos" ]; then
    echo "On macOS, the easiest way is via Homebrew:"
    echo ""

    if [ "$GITLEAKS_INSTALLED" = false ]; then
        echo "  brew install gitleaks"
    fi

    if [ "$TRUFFLEHOG_INSTALLED" = false ]; then
        echo "  brew install trufflehog"
    fi

    echo ""
    echo "Or install both at once:"
    echo "  brew install gitleaks trufflehog"

elif [ "$OS" = "linux" ]; then
    echo "On Linux, download the binaries from GitHub:"
    echo ""

    if [ "$GITLEAKS_INSTALLED" = false ]; then
        echo "Gitleaks:"
        echo "  # Get latest version"
        echo "  GITLEAKS_VERSION=\$(curl -s https://api.github.com/repos/gitleaks/gitleaks/releases/latest | grep tag_name | cut -d'\"' -f4)"
        echo "  curl -sSL https://github.com/gitleaks/gitleaks/releases/download/\${GITLEAKS_VERSION}/gitleaks_\${GITLEAKS_VERSION#v}_linux_x64.tar.gz | sudo tar -xz -C /usr/local/bin gitleaks"
        echo ""
    fi

    if [ "$TRUFFLEHOG_INSTALLED" = false ]; then
        echo "TruffleHog:"
        echo "  # Get latest version"
        echo "  TRUFFLEHOG_VERSION=\$(curl -s https://api.github.com/repos/trufflesecurity/trufflehog/releases/latest | grep tag_name | cut -d'\"' -f4)"
        echo "  curl -sSL https://github.com/trufflesecurity/trufflehog/releases/download/\${TRUFFLEHOG_VERSION}/trufflehog_\${TRUFFLEHOG_VERSION#v}_linux_amd64.tar.gz | sudo tar -xz -C /usr/local/bin trufflehog"
        echo ""
    fi
else
    echo "Manual installation required. Download from:"
    echo "  Gitleaks:   https://github.com/gitleaks/gitleaks/releases"
    echo "  TruffleHog: https://github.com/trufflesecurity/trufflehog/releases"
fi

echo ""
echo "After installing, run this setup again to verify."
exit 1
