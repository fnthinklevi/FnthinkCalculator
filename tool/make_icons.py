#!/usr/bin/env python3
"""生成启动图标：日间白底 / 夜间深灰底，黑色或浅色 + − ×、橙色等号键。

输出 assets/icon/ 源图、Android 各密度 mipmap（含 adaptive foreground）、
日间与夜间自适应图标配置。依赖 Pillow。
"""

from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent.parent
SIZE = 1024
SS = 2
CANVAS = SIZE * SS

DAY = {
    "symbol": (26, 26, 26, 255),
    "background": (255, 255, 255, 255),
    "background_hex": "#FFFFFF",
    "orange_top": (255, 148, 32),
    "orange_bottom": (255, 92, 0),
    "bar": (255, 255, 255, 255),
}
NIGHT = {
    "symbol": (245, 245, 245, 255),
    "background": (28, 28, 30, 255),
    "background_hex": "#1C1C1E",
    "orange_top": (255, 199, 154),
    "orange_bottom": (255, 178, 122),
    "bar": (28, 28, 30, 255),
}

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


def draw_symbols(palette):
    layer = Image.new("RGBA", (CANVAS, CANVAS), (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)
    k = SS
    arm = ARM * k
    stroke = STROKE * k
    symbol_color = palette["symbol"]

    def plus(cx, cy):
        cx, cy = cx * k, cy * k
        capsule(draw, cx - arm, cy - stroke / 2, cx + arm, cy + stroke / 2, stroke, symbol_color)
        capsule(draw, cx - stroke / 2, cy - arm, cx + stroke / 2, cy + arm, stroke, symbol_color)

    def minus(cx, cy):
        cx, cy = cx * k, cy * k
        capsule(draw, cx - arm, cy - stroke / 2, cx + arm, cy + stroke / 2, stroke, symbol_color)

    def multiply(cx, cy):
        cx, cy = cx * k, cy * k
        off = MULT_OFFSET * k
        for dx, dy in ((1, 1), (1, -1)):
            draw.line(
                [(cx - off * dx, cy - off * dy), (cx + off * dx, cy + off * dy)],
                fill=symbol_color,
                width=stroke,
            )
            for x, y in ((cx - off * dx, cy - off * dy), (cx + off * dx, cy + off * dy)):
                draw.ellipse(
                    [x - stroke / 2, y - stroke / 2, x + stroke / 2, y + stroke / 2],
                    fill=symbol_color,
                )

    def equals_key(cx, cy):
        cx, cy = cx * k, cy * k
        half = KEY_HALF * k
        box = [int(cx - half), int(cy - half), int(cx + half), int(cy + half)]
        gradient = Image.new("RGBA", (box[2] - box[0], box[3] - box[1]))
        pixels = gradient.load()
        top = palette["orange_top"]
        bottom = palette["orange_bottom"]
        for y in range(gradient.height):
            t = y / max(gradient.height - 1, 1)
            color = tuple(round(top[i] + (bottom[i] - top[i]) * t) for i in range(3)) + (255,)
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
                palette["bar"],
            )

    plus(CX1, CY1)
    minus(CX2, CY1)
    multiply(CX1, CY2)
    equals_key(CX2, CY2)
    return layer.resize((SIZE, SIZE), Image.LANCZOS)


def squircle(fill):
    layer = Image.new("RGBA", (CANVAS, CANVAS), (0, 0, 0, 0))
    ImageDraw.Draw(layer).rounded_rectangle(
        [0, 0, CANVAS - 1, CANVAS - 1], radius=LEGACY_RADIUS * SS, fill=fill
    )
    return layer.resize((SIZE, SIZE), Image.LANCZOS)


def circle(fill):
    layer = Image.new("RGBA", (CANVAS, CANVAS), (0, 0, 0, 0))
    ImageDraw.Draw(layer).ellipse([0, 0, CANVAS - 1, CANVAS - 1], fill=fill)
    return layer.resize((SIZE, SIZE), Image.LANCZOS)


def scaled(symbols, scale):
    size = round(SIZE * scale)
    small = symbols.resize((size, size), Image.LANCZOS)
    layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    offset = (SIZE - size) // 2
    layer.paste(small, (offset, offset), small)
    return layer


def write_adaptive_config(res):
    xml = """<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background" />
    <foreground android:drawable="@mipmap/ic_launcher_foreground" />
</adaptive-icon>
"""
    for folder in ("mipmap-anydpi-v26", "mipmap-night-anydpi-v26"):
        adaptive = res / folder
        adaptive.mkdir(parents=True, exist_ok=True)
        (adaptive / "ic_launcher.xml").write_text(xml, encoding="utf-8")
        (adaptive / "ic_launcher_round.xml").write_text(xml, encoding="utf-8")


def write_background_colors(res):
    for folder, value in (
        ("values", DAY["background_hex"]),
        ("values-night", NIGHT["background_hex"]),
    ):
        directory = res / folder
        directory.mkdir(parents=True, exist_ok=True)
        (directory / "ic_launcher_background.xml").write_text(
            f"""<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="ic_launcher_background">{value}</color>
</resources>
""",
            encoding="utf-8",
        )


def write_theme(res, icon_dir, palette, suffix, density_folder):
    symbols = draw_symbols(palette)
    foreground = scaled(symbols, FOREGROUND_SCALE)
    legacy = Image.alpha_composite(squircle(palette["background"]), symbols)
    round_icon = Image.alpha_composite(circle(palette["background"]), symbols)

    legacy.save(icon_dir / f"app_icon{suffix}_source.png")
    legacy.resize((512, 512), Image.LANCZOS).save(icon_dir / f"app_icon{suffix}_512.png")
    if suffix == "":
        legacy.save(icon_dir / "app_icon.png")
        foreground.save(icon_dir / "app_icon_foreground.png")
    else:
        legacy.save(icon_dir / f"app_icon{suffix}.png")
        foreground.save(icon_dir / f"app_icon_foreground{suffix}.png")

    for name, size in DENSITIES.items():
        folder = res / density_folder(name)
        folder.mkdir(parents=True, exist_ok=True)
        legacy.resize((size, size), Image.LANCZOS).save(folder / "ic_launcher.png")
        round_icon.resize((size, size), Image.LANCZOS).save(folder / "ic_launcher_round.png")
        fg_size = round(size * 108 / 48)
        foreground.resize((fg_size, fg_size), Image.LANCZOS).save(
            folder / "ic_launcher_foreground.png"
        )


def main():
    icon_dir = ROOT / "assets" / "icon"
    res = ROOT / "android" / "app" / "src" / "main" / "res"

    write_theme(res, icon_dir, DAY, "", lambda name: f"mipmap-{name}")
    write_theme(res, icon_dir, NIGHT, "_dark", lambda name: f"mipmap-night-{name}")
    write_adaptive_config(res)
    write_background_colors(res)
    print("icons generated: day + night")


if __name__ == "__main__":
    main()
