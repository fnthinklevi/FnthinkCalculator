# 计算器语音短音频

- 用途：计算器按键与结果的离线语音播报。
- 生成工具：`tool/generate_voice_clips.py`（构建期脚本，不随 APK 运行）。
- 音色模型：Piper `zh_CN-huayan-medium`，MIT License，
  来源 https://huggingface.co/rhasspy/piper-voices/tree/main/zh/zh_CN/huayan/medium
- 处理：22050 Hz → 16000 Hz、单声道、16-bit、去首尾静音、峰值归一化。
- 总计约 789 KiB（48 个短音），满足 <1MB 目标。
- APK 不包含 Piper 模型或运行时；只包含生成后的 WAV 片段。
