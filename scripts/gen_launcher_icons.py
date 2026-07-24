#!/usr/bin/env python3
"""Generate transparent blue house launcher icons per device size."""

from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
BLUE = (21, 140, 248, 255)

DRAWABLES_XML = """\
<drawables>
  <bitmap id="LauncherIcon" filename="launcher_icon.png"/>
</drawables>
"""

# Folder -> size (int square, or (w,h) rectangle)
TARGETS: dict[str, int | tuple[int, int]] = {
    "resources": 40,
    "resources-icon-30": 30,
    "resources-icon-35": 35,
    "resources-icon-36": 36,
    "resources-icon-40": 40,
    "resources-icon-56": 56,
    "resources-icon-60": 60,
    "resources-icon-61": 61,
    "resources-icon-65": 65,
    "resources-icon-70": 70,
    "resources-fr55": 35,
    "resources-vivoactive3": (40, 33),
}


def draw_house(size: int) -> Image.Image:
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    pad = size * 0.10
    s = size - 2 * pad
    ox, oy = pad, pad

    def xy(x: float, y: float) -> tuple[float, float]:
        return (ox + x / 24.0 * s, oy + y / 24.0 * s)

    d.polygon([xy(12, 1.5), xy(22.5, 11), xy(1.5, 11)], fill=BLUE)
    d.rectangle([xy(16.2, 3.2), xy(19.5, 10)], fill=BLUE)
    d.rounded_rectangle(
        [xy(4.5, 11), xy(19.5, 21.5)],
        radius=max(1, int(size * 0.04)),
        fill=BLUE,
    )

    mask = Image.new("L", (size, size), 0)
    md = ImageDraw.Draw(mask)
    door_l, door_t = xy(10, 14)
    door_r, door_b = xy(14, 21.5)
    md.rounded_rectangle(
        [door_l, door_t, door_r, door_b],
        radius=max(1, int(size * 0.06)),
        fill=255,
    )
    pixels = img.load()
    mp = mask.load()
    for y in range(size):
        for x in range(size):
            if mp[x, y] > 128:
                pixels[x, y] = (0, 0, 0, 0)
    return img


def write_icon(folder: str, size: int | tuple[int, int]) -> None:
    path = ROOT / folder / "drawables"
    path.mkdir(parents=True, exist_ok=True)
    if isinstance(size, tuple):
        w, h = size
        sq = draw_house(max(w, h)).resize((w, w), Image.Resampling.LANCZOS)
        top = (w - h) // 2
        icon = sq.crop((0, top, w, top + h))
    else:
        icon = draw_house(size)
    icon.save(path / "launcher_icon.png")
    (path / "drawables.xml").write_text(DRAWABLES_XML)
    print(f"wrote {path / 'launcher_icon.png'} ({icon.size[0]}x{icon.size[1]})")


def main() -> None:
    for folder, size in sorted(TARGETS.items()):
        write_icon(folder, size)


if __name__ == "__main__":
    main()
