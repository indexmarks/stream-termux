#!/bin/bash

read -p "Video URL: " VIDEO_URL
read -p "Stream Target: " STREAM_TARGET
read -p "Bitrate (default: 6000k): " STREAM_BITRATE
read -p "Resolution (default: 1080): " STREAM_RESOLUTION
read -p "FPS (default: 60): " STREAM_FPS
read -p "Preset (ultrafast/superfast/veryfast/medium) [default: ultrafast]: " STREAM_PRESET
read -p "Infinite Loop? (y/n): " ENABLE_LOOP

STREAM_BITRATE=${STREAM_BITRATE:-6000k}
STREAM_RESOLUTION=${STREAM_RESOLUTION:-1080}
STREAM_FPS=${STREAM_FPS:-60}
STREAM_PRESET=${STREAM_PRESET:-ultrafast}

if [ -z "$VIDEO_URL" ] || [ -z "$STREAM_TARGET" ]; then
    echo "Error: Missing required inputs."
    exit 1
fi

GOP_SIZE=$((STREAM_FPS * 2))

while true; do
    MAPS=$(yt-dlp -g -f "bestvideo[height<=${STREAM_RESOLUTION}]+bestaudio/best/best" "$VIDEO_URL" 2>/dev/null)
    if [ $? -ne 0 ] || [ -z "$MAPS" ]; then
        echo "Error: Stream extraction failed."
        if [ "$ENABLE_LOOP" != "y" ]; then exit 1; fi
        sleep 5
        continue
    fi

    VIDEO_TRACK=$(echo "$MAPS" | sed -n '1p')
    AUDIO_TRACK=$(echo "$MAPS" | sed -n '2p')

    FFMPEG_ARGS=(-hide_banner -v error -stats)
    NET_OPTS=(-reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 5)

    if [ -n "$AUDIO_TRACK" ]; then
        FFMPEG_ARGS+=("${NET_OPTS[@]}" -re -i "$VIDEO_TRACK" "${NET_OPTS[@]}" -re -i "$AUDIO_TRACK" -map 0:v:0 -map 1:a:0)
    else
        FFMPEG_ARGS+=("${NET_OPTS[@]}" -re -i "$VIDEO_TRACK")
    fi

    FFMPEG_ARGS+=(
        -c:v libx264 -preset "$STREAM_PRESET" -tune film
        -b:v "$STREAM_BITRATE" -maxrate "$STREAM_BITRATE" -bufsize "$STREAM_BITRATE"
        -r "$STREAM_FPS" -g "$GOP_SIZE" -pix_fmt yuv420p
        -c:a aac -b:a 320k -ar 44100
        -f flv -flvflags no_sequence_end -tls_verify 0
        "$STREAM_TARGET"
    )

    ffmpeg "${FFMPEG_ARGS[@]}"
    EXIT_CODE=$?

    if [ $EXIT_CODE -eq 0 ] && [ "$ENABLE_LOOP" != "y" ]; then
        break
    fi

    if [ "$ENABLE_LOOP" != "y" ]; then
        echo "Error: Stream stopped prematurely (Code $EXIT_CODE)."
        break
    fi

    sleep 5
done
