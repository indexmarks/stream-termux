#!/bin/bash

clear
echo "================================================="
echo "      MOBILE STREAM ENGINE      "
echo "================================================="
echo ""

# Gather operational inputs on the device
read -p "🔗 Enter Video URL: " VIDEO_URL
read -p "📊 Enter Bitrate (e.g., 3500k, 5000k, 8000k): " STREAM_BITRATE
read -p "📺 Enter Max Resolution (1080, 720, 480): " MAX_RES
read -p "⚡ Enter Target FPS (60, 30): " TARGET_FPS
read -p "🔄 Enable Infinite Loop? (y/n): " ENABLE_LOOP
read -p "🔑 Enter Stream Target (RTMP URI + Key): " STREAM_TARGET

# Fallback configuration defaults
[ -z "$STREAM_BITRATE" ] && STREAM_BITRATE="4000k"
[ -z "$MAX_RES" ] && MAX_RES="720"
[ -z "$TARGET_FPS" ] && TARGET_FPS="30"
[ -z "$ENABLE_LOOP" ] && ENABLE_LOOP="n"

if [ -z "$VIDEO_URL" ] || [ -z "$STREAM_TARGET" ]; then
  echo "❌ Error: Video URL and Stream Target are mandatory!"
  exit 1
fi

GOP_SIZE=$((TARGET_FPS * 2))

run_stream() {
  echo ""
  echo "🔄 Extracting asset links naturally with yt-dlp..."
  URLS=$(yt-dlp -g -f "bestvideo[height<=${MAX_RES}]+bestaudio/best" --cookies $HOME/cookies.txt "$VIDEO_URL" 2>/dev/null)
  
  if [ -z "$URLS" ]; then
    echo "❌ Link extraction failed."
    return 1
  fi

  PARSED_VIDEO=$(echo "$URLS" | sed -n '1p')
  PARSED_AUDIO=$(echo "$URLS" | sed -n '2p')

  echo "🚀 Dispatched hardware stream threads..."

  if [ -n "$PARSED_AUDIO" ]; then
    ffmpeg -reconnect 1 -reconnect_at_eof 1 -reconnect_streamed 1 -reconnect_delay_max 5 -re \
      -i "$PARSED_VIDEO" -re -i "$PARSED_AUDIO" -map 0:v:0 -map 1:a:0 \
      -c:v libx264 -preset ultrafast -tune film \
      -b:v "$STREAM_BITRATE" -maxrate "$STREAM_BITRATE" -bufsize "$STREAM_BITRATE" \
      -r "$TARGET_FPS" -g "$GOP_SIZE" -pix_fmt yuv420p \
      -c:a aac -b:a 160k -ar 44100 -f flv -flvflags no_sequence_end -tls_verify 0 "$STREAM_TARGET"
  else
    ffmpeg -reconnect 1 -reconnect_at_eof 1 -reconnect_streamed 1 -reconnect_delay_max 5 -re \
      -i "$PARSED_VIDEO" \
      -c:v libx264 -preset ultrafast -tune film \
      -b:v "$STREAM_BITRATE" -maxrate "$STREAM_BITRATE" -bufsize "$STREAM_BITRATE" \
      -r "$TARGET_FPS" -g "$GOP_SIZE" -pix_fmt yuv420p \
      -c:a aac -b:a 160k -ar 44100 -f flv -flvflags no_sequence_end -tls_verify 0 "$STREAM_TARGET"
  fi
  return $?
}

if [ "$ENABLE_LOOP" = "y" ] || [ "$ENABLE_LOOP" = "Y" ]; then
  while true; do
    run_stream
    [ $? -ne 0 ] && sleep 5
  done
else
  run_stream
fi
