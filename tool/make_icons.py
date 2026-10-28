from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "assets" / "icon" / "app_icon_source.png"
ICON = ROOT / "assets" / "icon" / "app_icon.png"
FOREGROUND = ROOT / "assets" / "icon" / "app_icon_foreground.png"
RES = ROOT / "android" / "app" / "src" / "main" / "res"

BACKGROUND = (253, 101, 0, 255)

LEGACY_SIZES = {
    "mdpi": 48,
    "hdpi": 72,
    "xhdpi": 96,
    "xxhdpi": 144,
    "xxxhdpi": 192,
}


def remove_watermark(image: Image.Image) -> Image.Image:
    clean = image.copy()
    patch = clean.crop((840, 920, 1024, 960))
    clean.paste(patch, (840, 984))
    return clean


def make_round(image: Image.Image, size: int) -> Image.Image:
    scaled = image.resize((size, size), Image.LANCZOS)
    mask = Image.new("L", (size, size), 0)
    ImageDraw.Draw(mask).ellipse((0, 0, size - 1, size - 1), fill=255)
    round_icon = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    round_icon.paste(scaled, (0, 0), mask)
    return round_icon


def main() -> None:
    image = remove_watermark(Image.open(SOURCE).convert("RGBA"))
    image.save(ICON)

    foreground = Image.new("RGBA", (1024, 1024), BACKGROUND)
    scaled = image.resize((901, 901), Image.LANCZOS)
    foreground.paste(scaled, ((1024 - 901) // 2, (1024 - 901) // 2), scaled)
    foreground.save(FOREGROUND)

    image.resize((512, 512), Image.LANCZOS).save(ROOT / "assets" / "icon" / "app_icon_512.png")

    for density, size in LEGACY_SIZES.items():
        folder = RES / f"mipmap-{density}"
        folder.mkdir(parents=True, exist_ok=True)
        image.resize((size, size), Image.LANCZOS).save(folder / "ic_launcher.png")
        make_round(image, size).save(folder / "ic_launcher_round.png")
        foreground_size = round(size * 108 / 48)
        foreground.resize((foreground_size, foreground_size), Image.LANCZOS).save(
            folder / "ic_launcher_foreground.png"
        )

    adaptive = RES / "mipmap-anydpi-v26"
    adaptive.mkdir(parents=True, exist_ok=True)
    adaptive_icon = """<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background" />
    <foreground android:drawable="@mipmap/ic_launcher_foreground" />
</adaptive-icon>
"""
    (adaptive / "ic_launcher.xml").write_text(adaptive_icon, encoding="utf-8")
    (adaptive / "ic_launcher_round.xml").write_text(adaptive_icon, encoding="utf-8")

    values = RES / "values"
    values.mkdir(parents=True, exist_ok=True)
    (values / "ic_launcher_background.xml").write_text(
        """<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="ic_launcher_background">#FD6500</color>
</resources>
""",
        encoding="utf-8",
    )


if __name__ == "__main__":
    main()
