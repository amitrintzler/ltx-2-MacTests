# LTX-2 Mac Tests (LTX-Video + XTTS v2)

This repo documents and scripts a local Mac workflow for generating a short LTX-Video clip and adding high‑quality English voice via Coqui XTTS v2. It is designed as a reproducible example that references the original Lightricks repositories.

## What’s inside

- `xtts_tts.py`: XTTS v2 audio generation helper (local, no cloud)
- `scripts/`: render video, generate audio, and mux into a MOV
- `REPRODUCE.md`: step‑by‑step reproduction guide with exact commands
- `CHANGELOG.md`: summary of changes

## Quick start

```bash
LTX_VIDEO_DIR=../LTX-Video scripts/render_video.sh
LTX_VIDEO_DIR=../LTX-Video scripts/make_audio_xtts.sh "I am here now. The jungle hears us..." /path/to/clean_voice.wav
LTX_VIDEO_DIR=../LTX-Video scripts/mux_audio.sh
```

See `REPRODUCE.md` for the full end‑to‑end workflow and environment details.

## Reference output

- `examples/with_audio_xtts_long.mov`

## Credits

- **LTX‑Video** by Lightricks: https://github.com/Lightricks/LTX-Video
- **LTX‑2** by Lightricks: https://github.com/Lightricks/LTX-2
- **Coqui XTTS v2**: https://github.com/coqui-ai/TTS
