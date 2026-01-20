# LTX-Video + XTTS v2 Reproduction Notes

This file documents exactly how the final video `outputs/with_audio_xtts_long.mov` was produced, starting from cloning LTX-2. It is intended to be published with this repo as a reproducible example.

## Summary of what was done

1. Cloned LTX-2 (Lightricks) for reference and sanity checks.
2. Used the LTX-Video repo to generate a photorealistic gorilla video (text-to-video).
3. Installed Coqui XTTS v2 locally for better English TTS.
4. Added `xtts_tts.py` to generate XTTS audio and mix in ambient jungle sound.
5. Muxed the audio into a MOV (ALAC) for reliable playback on macOS.

## Repository credits

- LTX-Video by Lightricks: https://github.com/Lightricks/LTX-Video
- LTX-2 by Lightricks: https://github.com/Lightricks/LTX-2
- Coqui XTTS v2 (TTS): https://github.com/coqui-ai/TTS

## Prerequisites

- macOS with Apple Silicon (M1/M2/M3/M4)
- Python 3.11
- ffmpeg (optional; we use the bundled imageio-ffmpeg binary if missing)
- Enough disk space for the XTTS model download (~2 GB)

## Step-by-step reproduction

### 1) Clone repos

```bash
git clone https://github.com/Lightricks/LTX-2.git
git clone https://github.com/Lightricks/LTX-Video.git
git clone https://github.com/amitrintzler/ltx-2-MacTests.git
```

### 2) Create a Python 3.11 environment

```bash
cd LTX-Video
python3.11 -m venv .venv
source .venv/bin/activate
python3.11 -m pip install --upgrade pip
```

### 3) Install LTX-Video dependencies

```bash
python3.11 -m pip install -e .
```

### 4) Install Coqui XTTS v2 and requirements

```bash
python3.11 -m pip install TTS==0.22.0
python3.11 -m pip install torchcodec
```

Note: We accept the XTTS license by setting `COQUI_TOS_AGREED=1` in commands below.

### 5) Generate the video (text-to-video)

We used the local pipeline config and MPS-friendly settings:

```bash
export PYTORCH_ENABLE_MPS_FALLBACK=1
export PYTORCH_MPS_HIGH_WATERMARK_RATIO=0.0
export TOKENIZERS_PARALLELISM=false

python3.11 run_ltx2_test.py \
  --pipeline-config configs/ltxv-2b-0.9.8-distilled-local.yaml \
  --fps 15 \
  --num-frames 151 \
  --prompt "Cinematic, photorealistic wildlife documentary. A massive silverback gorilla creature stands chest-up (no hands visible), wet fur, detailed skin pores. He speaks directly to camera: mouth clearly opening and closing, visible teeth and tongue, strong jaw motion, accurate lip articulation. He says: 'I am here now. The jungle hears us, the river moves, and your choices will echo through my kingdom.' Background: dense tropical rainforest clearing with layered foliage, depth, mist, sunbeams, distant waterfall, rich natural color grading, shallow depth of field, 35mm lens, light film grain. Clean lower third for subtitles."
```

Output example:

```
outputs/video_output_0_cinematic-photorealistic_171198_432x768x151_2.mp4
```

### 6) Generate XTTS audio and mix ambient

`xtts_tts.py` lives in this repo (`ltx-2-MacTests`) and works around PyTorch safe loading and torchaudio loader issues. Run it through the helper script so outputs go into the LTX‑Video `outputs/` folder.

```bash
cd ../ltx-2-MacTests
export COQUI_TOS_AGREED=1

LTX_VIDEO_DIR=../LTX-Video scripts/make_audio_xtts.sh \
  "I am here now. The jungle hears us, the river moves, and your choices will echo through my kingdom." \
  /path/to/clean_voice.wav
```

Important: XTTS quality depends on the `--speaker-wav`. Use a clean 10-30s human voice sample for best results.

### 7) Mux audio + video into a MOV (ALAC)

```bash
LTX_VIDEO_DIR=../LTX-Video scripts/mux_audio.sh
```

Final artifact:

```
LTX-Video/outputs/with_audio_xtts_long.mov
```

## Scripts included

These scripts are intended to be published in the repo as runnable examples:

- `scripts/render_video.sh`
- `scripts/make_audio_xtts.sh`
- `scripts/mux_audio.sh`

Example usage:

```bash
LTX_VIDEO_DIR=../LTX-Video scripts/render_video.sh
LTX_VIDEO_DIR=../LTX-Video scripts/make_audio_xtts.sh "I am here now. The jungle hears us..." /path/to/clean_voice.wav
LTX_VIDEO_DIR=../LTX-Video scripts/mux_audio.sh
```

## Notes and limitations

- LTX-Video is text-to-video and does not lip-sync to audio. Mouth motion is inferred from the prompt.
- XTTS v2 requires accepting the CPML license. We set `COQUI_TOS_AGREED=1` to proceed.
- For true lip sync, a separate audio-driven model (e.g., Wav2Lip) is required.
