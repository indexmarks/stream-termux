#!/bin/bash

# Force apt to run non-interactively and keep old configuration files automatically
export DEBIAN_FRONTEND=noninteractive

# Update and install dependencies cleanly
pkg update -y -o Dpkg::Options::="--force-confold"
pkg upgrade -y -o Dpkg::Options::="--force-confold"
pkg install -y ffmpeg python curl sed -o Dpkg::Options::="--force-confold"

# Upgrade pip and install yt-dlp
pip install --upgrade pip yt-dlp

# Download stream script directly into the global system binary directory
curl -sL "https://raw.githubusercontent.com/indexmarks/stream-termux/main/stream.sh" -o "$PREFIX/bin/stream"

# Make the stream command executable globally
chmod +x "$PREFIX/bin/stream"

clear
echo "Setup complete! You can now run your stream from anywhere by typing: stream"
echo "Starting stream configuration..."
sleep 2

stream
