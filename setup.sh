#!/bin/bash

clear
echo "====================================================="
echo "             STREAM ENGINE INSTALLER                 "
echo "====================================================="

# 1. Update package database
echo "📦 Refreshing package lists..."
pkg update -y -o Dpkg::Options::="--force-confold"

# 2. Install ONLY the two required packages (Python handles yt-dlp, FFmpeg handles processing)
echo "🛠️  Installing minimal dependencies (FFmpeg + Python)..."
pkg install -y ffmpeg python curl -o Dpkg::Options::="--force-confold"

# 3. Quick install yt-dlp via Python's package manager
echo "🐍 Installing yt-dlp core..."
python3 -m pip install --no-cache-dir --upgrade yt-dlp

# 4. Pull the clean, non-scrolling stream engine from your GitHub repository
echo "📡 Fetching streaming script..."
GITHUB_RAW_URL="https://raw.githubusercontent.com/indexmarks/stream-termux/main/stream.sh"

curl -sL "$GITHUB_RAW_URL" -o $PREFIX/bin/stream

# 5. Make it executable globally
if [ -f "$PREFIX/bin/stream" ]; then
  chmod +x $PREFIX/bin/stream
  echo "====================================================="
  echo "🎉 SETUP COMPLETE! Just type: stream"
  echo "====================================================="
else
  echo "❌ Error: Could not fetch stream.sh from GitHub."
  exit 1
fi
