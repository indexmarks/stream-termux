#!/bin/bash

clear
echo "====================================================="
echo "   MOBILE STREAM ENGINE: SETUP      "
echo "====================================================="
echo "⏳ Initializing modular deployment architecture..."
echo "-----------------------------------------------------"

# 1. Update Core Package Repositories
echo "📦 Updating core system repositories..."
pkg update -y -o Dpkg::Options::="--force-confold"

# 2. Install Environment Binaries
echo "🛠️  Installing system infrastructure (FFmpeg, Python, Curl)..."
pkg install -y ffmpeg python ndk-sysroot clang make libffi openssl c-ares curl -o Dpkg::Options::="--force-confold"

# 3. Deploy Extractor Dependencies
echo "🐍 Deploying extraction libraries..."
python3 -m pip install --upgrade pip
python3 -m pip install --upgrade yt-dlp

# 4. Pull the Core Stream Script directly from GitHub
echo "📡 Fetching core execution assets from repository..."
GITHUB_RAW_URL="https://raw.githubusercontent.com/indexmarks/stream-termux/main/stream.sh"

curl -sL "$GITHUB_RAW_URL" -o $PREFIX/bin/stream

# 5. Lock Down System Permissions
if [ -f "$PREFIX/bin/stream" ]; then
  chmod +x $PREFIX/bin/stream
  echo ""
  echo "====================================================="
  echo "   🎉 DEPLOYMENT SUCCESSFUL! SYSTEM READY            "
  echo "====================================================="
  echo "💡 To start streaming anytime, just type: stream"
  echo "====================================================="
else
  echo "❌ Critical Error: Could not download stream core script from GitHub."
  exit 1
fi
