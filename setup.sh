#!/bin/bash

# 1. Update Termux repositories and packages quietly
pkg update -y && pkg upgrade -y
pkg install -y ffmpeg python curl sed

# 2. Upgrade pip and install yt-dlp
pip install --upgrade pip yt-dlp

# 3. Fetch the raw streaming script directly into the global system folder
curl -sL "https://raw.githubusercontent.com/indexmarks/stream-termux/main/stream.sh" -o "$PREFIX/bin/stream"

# 4. Make the global stream command executable
chmod +x "$PREFIX/bin/stream"

# 5. Clear the screen and execute it immediately for the first setup run
clear
stream
