#!/usr/bin/env bash
set -euo pipefail

TEXT=${1:-"I am here now. The jungle hears us, the river moves, and your choices will echo through my kingdom."}
SPEAKER_WAV=${2:-"/path/to/clean_voice.wav"}
LTX_VIDEO_DIR=${LTX_VIDEO_DIR:-"../LTX-Video"}
AMBIENT_WAV=${3:-"$LTX_VIDEO_DIR/outputs/ambient_jungle_v3.wav"}
OUT_VOICE=${4:-"$LTX_VIDEO_DIR/outputs/xtts_voice_long.wav"}
OUT_MIX=${5:-"$LTX_VIDEO_DIR/outputs/xtts_voice_long_mix.wav"}
REPO_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

FFMPEG_BIN=${FFMPEG_BIN:-""}
if [ -z "$FFMPEG_BIN" ]; then
  if command -v ffmpeg >/dev/null 2>&1; then
    FFMPEG_BIN=$(command -v ffmpeg)
  else
    FFMPEG_BIN="/opt/homebrew/lib/python3.11/site-packages/imageio_ffmpeg/binaries/ffmpeg-macos-aarch64-v7.1"
  fi
fi

if [ ! -f "$AMBIENT_WAV" ]; then
  mkdir -p "$(dirname "$AMBIENT_WAV")"
  "$FFMPEG_BIN" -y \
    -f lavfi -i "anoisesrc=color=brown:amplitude=0.04:duration=10.1" \
    -f lavfi -i "anoisesrc=color=pink:amplitude=0.02:duration=10.1" \
    -f lavfi -i "sine=frequency=65:duration=10.1,volume=0.015" \
    -f lavfi -i "sine=frequency=3800:duration=10.1,volume=0.006,tremolo=f=6.0:d=0.7" \
    -filter_complex "[0:a][1:a][2:a][3:a]amix=inputs=4:normalize=0,highpass=f=40,lowpass=f=12000,acompressor=threshold=-30dB:ratio=2.5:attack=50:release=300,alimiter=limit=0.9" \
    -c:a pcm_s16le "$AMBIENT_WAV"
fi

export COQUI_TOS_AGREED=1

python3.11 "$REPO_DIR/xtts_tts.py" \
  --text "$TEXT" \
  --speaker-wav "$SPEAKER_WAV" \
  --out "$OUT_VOICE" \
  --ambient "$AMBIENT_WAV" \
  --mix-out "$OUT_MIX"
