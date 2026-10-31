"""Generate bundled calculator voice clips with Microsoft Edge TTS.

Build-time only:
  python -m pip install edge-tts imageio-ffmpeg
  python tool/generate_voice_clips.py

The generated MP3 files are committed under assets/voice/. The TTS engine and
voice model are not shipped with the app; playback is fully offline.
"""

import asyncio
import pathlib
import subprocess

import edge_tts
import imageio_ffmpeg

VOICE = 'zh-CN-XiaoxiaoNeural'

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


async def synthesize(text: str, output: pathlib.Path) -> None:
    communicate = edge_tts.Communicate(text, VOICE, rate='+0%')
    await communicate.save(str(output))


def trim(source: pathlib.Path, target: pathlib.Path) -> None:
    ffmpeg = imageio_ffmpeg.get_ffmpeg_exe()
    subprocess.run(
        [
            ffmpeg,
            '-y',
            '-loglevel',
            'error',
            '-i',
            str(source),
            '-af',
            'silenceremove=start_periods=1:start_duration=0.02:'
            'start_threshold=-50dB:detection=peak,'
            'areverse,'
            'silenceremove=start_periods=1:start_duration=0.02:'
            'start_threshold=-50dB:detection=peak,'
            'areverse',
            '-ac',
            '1',
            '-ar',
            '24000',
            '-b:a',
            '48k',
            str(target),
        ],
        check=True,
    )


def main() -> None:
    root = pathlib.Path(__file__).resolve().parents[1]
    out_dir = root / 'assets' / 'voice'
    raw_dir = root / 'build' / 'voice-gen' / 'edge-raw'
    out_dir.mkdir(parents=True, exist_ok=True)
    raw_dir.mkdir(parents=True, exist_ok=True)

    total = 0
    for index, (name, text) in enumerate(CLIPS.items(), start=1):
        raw = raw_dir / f'{name}.mp3'
        target = out_dir / f'{name}.mp3'
        asyncio.run(synthesize(text, raw))
        trim(raw, target)
        total += target.stat().st_size
        print(f'{index:02d}/{len(CLIPS)} {name}: {text}')

    print(f'generated {len(CLIPS)} clips, total {total / 1024:.1f} KiB')


if __name__ == '__main__':
    main()
