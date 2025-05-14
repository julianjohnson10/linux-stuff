#!/usr/bin/env bash
# Updates Neovim AppImage if a newer version is available.

set -euo pipefail

INSTALL_DIR="/usr/local/bin"
APPIMAGE_NAME="nvim.appimage"
APPIMAGE_PATH="$INSTALL_DIR/nvim"

# Get current version
if command -v nvim >/dev/null; then
  CURRENT_VERSION=$(nvim --version | head -n1 | awk '{print $2}' | sed 's/^v//')
else
  CURRENT_VERSION=""
fi

# Fetch latest version from GitHub
LATEST_TAG=$(curl -s https://api.github.com/repos/neovim/neovim/releases/latest | \
  grep -Po '"tag_name": "\Kv[^"]+')
LATEST_VERSION="${LATEST_TAG#v}"

echo "Current Neovim version: ${CURRENT_VERSION:-Not installed}"
echo "Latest Neovim version:  $LATEST_VERSION"

# Check if update is needed
if [[ "$CURRENT_VERSION" == "$LATEST_VERSION" ]]; then
  echo "Neovim is already up to date."
  exit 0
fi

# Ask user for confirmation
read -rp "Update Neovim to version $LATEST_VERSION? [y/N]: " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
  echo "Update cancelled."
  exit 0
fi

# Download and install
DOWNLOAD_URL="https://github.com/neovim/neovim/releases/download/${LATEST_TAG}/nvim-linux-x86_64.appimage"
echo "Downloading from: $DOWNLOAD_URL"

curl -L "$DOWNLOAD_URL" -o "$APPIMAGE_NAME"
chmod u+x "$APPIMAGE_NAME"
sudo mv "$APPIMAGE_NAME" "$APPIMAGE_PATH"

echo "Neovim $LATEST_VERSION installed to $APPIMAGE_PATH"
"$APPIMAGE_PATH" --version

