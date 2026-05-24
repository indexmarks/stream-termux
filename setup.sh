#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
pkg install -y ffmpeg python curl sed -o Dpkg::Options::="--force-confold"
pip install --upgrade pip yt-dlp
curl -sL "https://raw.githubusercontent.com/indexmarks/stream-termux/main/stream.sh" -o "$PREFIX/bin/stream"
chmod +x "$PREFIX/bin/stream"
clear
echo "Setup complete! You can now run your stream from anywhere by typing: stream"
