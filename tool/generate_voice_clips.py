"""Generate the bundled calculator voice clips.

Build-time only. Requires piper-tts and a Piper Chinese voice model:
  python -m pip install piper-tts
  # model: rhasspy/piper-voices zh_CN-huayan-medium (MIT)
  python tool/generate_voice_clips.py build/voice-gen/zh_CN-huayan-medium.onnx

The generated WAV files are committed under assets/voice/. The model is not
shipped with the app.
"""

import pathlib
import subprocess
import sys
import wave

import numpy as np
from scipy.signal import resample_poly

CLIPS = {
    'zero': '零',
    'one': '一',
    'two': '二',
    'three': '三',
    'four': '四',
    'five': '五',
    'six': '六',
    'seven': '七',
    'eight': '八',
    'nine': '九',
    'ten': '十',
    'hundred': '百',
    'thousand': '千',
    'ten_thousand': '万',
    'hundred_million': '亿',
    'point': '点',
    'negative': '负',
    'plus': '加',
    'minus': '减',
    'multiply': '乘',
    'divide': '除',
    'equals': '等于',
    'percent': '百分号',
    'left_paren': '左括号',
    'right_paren': '右括号',
    'clear': '清空',
    'backspace': '退格',
    'switch': '切换',
    'sign': '正负号',
    'sin': '正弦',
    'cos': '余弦',
    'tan': '正切',
    'asin': '反正弦',
    'acos': '反余弦',
    'atan': '反正切',
    'ln': '自然对数',
    'log': '常用对数',
    'sqrt': '平方根',
    'power': '乘方',
    'factorial': '阶乘',
    'reciprocal': '倒数',
    'pi': '圆周率',
    'e': '自然常数',
    'second': '第二功能',
    'angle': '角度',
    'error': '错误',
    'result': '结果',
    'approximate': '约',
}

TARGET_RATE = 16000


def trim(samples: np.ndarray) -> np.ndarray:
    if samples.size == 0:
        return samples
    threshold = max(0.02, float(np.max(np.abs(samples))) * 0.02)
    indices = np.where(np.abs(samples) > threshold)[0]
    if indices.size == 0:
        return samples
    start = max(0, int(indices[0]) - int(TARGET_RATE * 0.02))
    end = min(samples.size, int(indices[-1]) + int(TARGET_RATE * 0.03))
    return samples[start:end]


def main() -> None:
    if len(sys.argv) != 2:
        raise SystemExit('usage: generate_voice_clips.py <model.onnx>')
    model = pathlib.Path(sys.argv[1]).resolve()
    if not model.exists():
        raise SystemExit(f'model not found: {model}')

    root = pathlib.Path(__file__).resolve().parents[1]
    out_dir = root / 'assets' / 'voice'
    raw_dir = root / 'build' / 'voice-gen' / 'raw'
    out_dir.mkdir(parents=True, exist_ok=True)
    raw_dir.mkdir(parents=True, exist_ok=True)

    total_bytes = 0
    for name, text in CLIPS.items():
        raw = raw_dir / f'{name}.wav'
        subprocess.run(
            [
                sys.executable,
                '-m',
                'piper',
                '--model',
                str(model),
                '--output_file',
                str(raw),
                '--',
                text,
            ],
            check=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        with wave.open(str(raw), 'rb') as source:
            rate = source.getframerate()
            channels = source.getnchannels()
            width = source.getsampwidth()
            if channels != 1 or width != 2:
                raise SystemExit(f'unexpected format for {name}')
            data = np.frombuffer(
                source.readframes(source.getnframes()), dtype='<i2'
            ).astype(np.float32) / 32768.0
        if rate != TARGET_RATE:
            data = resample_poly(data, TARGET_RATE, rate)
        data = trim(data)
        peak = float(np.max(np.abs(data))) if data.size else 0.0
        if peak > 0:
            data = data / peak * 0.9
        pcm = np.clip(data * 32767.0, -32768, 32767).astype('<i2')
        target = out_dir / f'{name}.wav'
        with wave.open(str(target), 'wb') as sink:
            sink.setnchannels(1)
            sink.setsampwidth(2)
            sink.setframerate(TARGET_RATE)
            sink.writeframes(pcm.tobytes())
        total_bytes += target.stat().st_size

    print(f'generated {len(CLIPS)} clips, total {total_bytes / 1024:.1f} KiB')


if __name__ == '__main__':
    main()
