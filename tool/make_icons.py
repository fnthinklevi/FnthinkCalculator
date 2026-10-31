#!/usr/bin/env python3
"""生成启动图标：白色圆角底、黑色 + − ×、橙色等号键。

输出 assets/icon/ 源图、Android 各密度 mipmap（含 adaptive foreground）
与 mipmap-anydpi-v26 自适应图标配置。依赖 Pillow。
"""

from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent.parent
SIZE = 1024
SS = 2
CANVAS = SIZE * SS

BLACK = (26, 26, 26, 255)
WHITE = (255, 255, 255, 255)
ORANGE_TOP = (255, 148, 32)
ORANGE_BOTTOM = (255, 92, 0)

CX1 = 310
CY1 = 305
CX2 = 714
CY2 = 692
ARM = 109
STROKE = 56
MULT_OFFSET = 65
KEY_HALF = 174
KEY_RADIUS = 100
BAR_HALF_W = 87
BAR_HALF_H = 17
BAR_OFFSET = 44
FOREGROUND_SCALE = 0.657

LEGACY_RADIUS = 232
DENSITIES = {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}


def capsule(draw, x1, y1, x2, y2, width, fill):
    draw.rounded_rectangle([x1, y1, x2, y2], radius=width / 2, fill=fill)


def draw_symbols():
    layer = Image.new("RGBA", (CANVAS, CANVAS), (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)
    k = SS
    arm = ARM * k
    stroke = STROKE * k

    def plus(cx, cy):
        cx, cy = cx * k, cy * k
        capsule(draw, cx - arm, cy - stroke / 2, cx + arm, cy + stroke / 2, stroke, BLACK)
        capsule(draw, cx - stroke / 2, cy - arm, cx + stroke / 2, cy + arm, stroke, BLACK)

    def minus(cx, cy):
        cx, cy = cx * k, cy * k
        capsule(draw, cx - arm, cy - stroke / 2, cx + arm, cy + stroke / 2, stroke, BLACK)

    def multiply(cx, cy):
        cx, cy = cx * k, cy * k
        off = MULT_OFFSET * k
        for dx, dy in ((1, 1), (1, -1)):
            draw.line([(cx - off * dx, cy - off * dy), (cx + off * dx, cy + off * dy)], fill=BLACK, width=stroke)
            for x, y in ((cx - off * dx, cy - off * dy), (cx + off * dx, cy + off * dy)):
                draw.ellipse([x - stroke / 2, y - stroke / 2, x + stroke / 2, y + stroke / 2], fill=BLACK)

    def equals_key(cx, cy):
        cx, cy = cx * k, cy * k
        half = KEY_HALF * k
        box = [int(cx - half), int(cy - half), int(cx + half), int(cy + half)]
        gradient = Image.new("RGBA", (box[2] - box[0], box[3] - box[1]))
        pixels = gradient.load()
        for y in range(gradient.height):
            t = y / max(gradient.height - 1, 1)
            color = tuple(
                round(ORANGE_TOP[i] + (ORANGE_BOTTOM[i] - ORANGE_TOP[i]) * t)
                for i in range(3)
            ) + (255,)
            for x in range(gradient.width):
                pixels[x, y] = color
        mask = Image.new("L", gradient.size, 0)
        ImageDraw.Draw(mask).rounded_rectangle(
            [0, 0, gradient.width - 1, gradient.height - 1],
            radius=KEY_RADIUS * k,
            fill=255,
        )
        layer.paste(gradient, (box[0], box[1]), mask)
        for offset in (-BAR_OFFSET, BAR_OFFSET):
            y0 = cy + offset * k
            capsule(
                draw,
                cx - BAR_HALF_W * k,
                y0 - BAR_HALF_H * k,
                cx + BAR_HALF_W * k,
                y0 + BAR_HALF_H * k,
                BAR_HALF_H * 2 * k,
                WHITE,
            )

    plus(CX1, CY1)
    minus(CX2, CY1)
    multiply(CX1, CY2)
    equals_key(CX2, CY2)
    return layer.resize((SIZE, SIZE), Image.LANCZOS)


def white_squircle():
    layer = Image.new("RGBA", (CANVAS, CANVAS), (0, 0, 0, 0))
    ImageDraw.Draw(layer).rounded_rectangle(
        [0, 0, CANVAS - 1, CANVAS - 1], radius=LEGACY_RADIUS * SS, fill=WHITE
    )
    return layer.resize((SIZE, SIZE), Image.LANCZOS)


def white_circle():
    layer = Image.new("RGBA", (CANVAS, CANVAS), (0, 0, 0, 0))
    ImageDraw.Draw(layer).ellipse([0, 0, CANVAS - 1, CANVAS - 1], fill=WHITE)
    return layer.resize((SIZE, SIZE), Image.LANCZOS)


def scaled(symbols, scale):
    size = round(SIZE * scale)
    small = symbols.resize((size, size), Image.LANCZOS)
    layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    offset = (SIZE - size) // 2
    layer.paste(small, (offset, offset), small)
    return layer


def write_adaptive_config(res):
    adaptive = res / "mipmap-anydpi-v26"
    adaptive.mkdir(parents=True, exist_ok=True)
    xml = """<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background" />
    <foreground android:drawable="@mipmap/ic_launcher_foreground" />
</adaptive-icon>
"""
    (adaptive / "ic_launcher.xml").write_text(xml, encoding="utf-8")
    (adaptive / "ic_launcher_round.xml").write_text(xml, encoding="utf-8")
    (res / "values" / "ic_launcher_background.xml").write_text(
        """<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="ic_launcher_background">#FFFFFF</color>
</resources>
""",
        encoding="utf-8",
    )


def main():
    symbols = draw_symbols()
    foreground = scaled(symbols, FOREGROUND_SCALE)
    legacy = Image.alpha_composite(white_squircle(), symbols)
    round_icon = Image.alpha_composite(white_circle(), symbols)

    icon_dir = ROOT / "assets" / "icon"
    legacy.save(icon_dir / "app_icon.png")
    legacy.save(icon_dir / "app_icon_source.png")
    legacy.resize((512, 512), Image.LANCZOS).save(icon_dir / "app_icon_512.png")
    foreground.save(icon_dir / "app_icon_foreground.png")

    res = ROOT / "android" / "app" / "src" / "main" / "res"
    for name, size in DENSITIES.items():
        folder = res / f"mipmap-{name}"
        folder.mkdir(parents=True, exist_ok=True)
        legacy.resize((size, size), Image.LANCZOS).save(folder / "ic_launcher.png")
        round_icon.resize((size, size), Image.LANCZOS).save(folder / "ic_launcher_round.png")
        fg_size = round(size * 108 / 48)
        foreground.resize((fg_size, fg_size), Image.LANCZOS).save(
            folder / "ic_launcher_foreground.png"
        )
    write_adaptive_config(res)
    print("icons generated")


if __name__ == "__main__":
    main()
