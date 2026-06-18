"""
Generate two sets (A = lineHeight 30, B = lineHeight 32) of color-tinted watch
icons from FontAwesome source PNGs, one variant per color in COLORS (10 colors).

Output: resources/drawables/icons/{key}_{ab}_{ci}.png
Also rewrites resources/drawables/drawables.xml.

Icon types: aup (arrow up), adn (arrow down), deg (degree circle), bolt
Font sets:  a = JetBrainsMono/FiraCode/NBArchitekt (lineHeight 30)
            b = SpaceMono (lineHeight 32)
"""

import os
import re
from PIL import Image

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
BASE = os.path.dirname(SCRIPT_DIR)
FA_DIR = os.path.join(BASE, "resources", "drawables", "FA")
ICON_DIR = os.path.join(BASE, "resources", "drawables", "icons")
DRW_XML = os.path.join(BASE, "resources", "drawables", "drawables.xml")

# Must stay in sync with COLORS in TerminalWatchfaceView.mc
COLORS = [
    (0xFF, 0xFF, 0xFF),  # 0  white
    (0x55, 0xFF, 0x77),  # 1  green
    (0x55, 0xFF, 0xFF),  # 2  cyan
    (0xFF, 0xEE, 0x55),  # 3  yellow
    (0xFF, 0x99, 0x44),  # 4  orange
    (0xFF, 0x55, 0x55),  # 5  red
    (0x66, 0x99, 0xFF),  # 6  blue
    (0xFF, 0x55, 0xFF),  # 7  magenta
    (0xBB, 0xBB, 0xBB),  # 8  light grey
    (0xAA, 0x77, 0xFF),  # 9  purple
]

SIZE_A = 28  # lineHeight: JetBrainsMono, FiraCode, NBArchitekt
SIZE_B = 30  # lineHeight: SpaceMono

ARROW_H_A = 15
BOLT_H_A  = 19
BOLT_W_A  = 15
DEG_H_A   = 7
scale_b   = SIZE_B / SIZE_A
ARROW_H_B = round(ARROW_H_A * scale_b)
BOLT_H_B  = round(BOLT_H_A  * scale_b)
BOLT_W_B  = round(BOLT_W_A  * scale_b)
DEG_H_B   = round(DEG_H_A   * scale_b)

ICONS: dict[str, tuple[str, int, int]] = {
    "aup":  ("FA_arrow-up-long-solid.png",   ARROW_H_A, ARROW_H_B),
    "adn":  ("FA_arrow-down-long-solid.png",  ARROW_H_A, ARROW_H_B),
    "deg":  ("FA_circle-regular.png",         DEG_H_A,   DEG_H_B),
    "bolt": ("FA_bolt-solid.png",             BOLT_H_A,  BOLT_H_B),
}

RES_PREFIX = {"aup": "Aup", "adn": "Adn", "deg": "Deg", "bolt": "Bolt"}


def _downsample(img: Image.Image, target_w: int, target_h: int) -> Image.Image:
    """Progressive halving then a final LANCZOS step to preserve thin features."""
    cur_w, cur_h = img.size
    while cur_h > target_h * 2:
        cur_h //= 2
        cur_w = max(1, round(img.width * cur_h / img.height))
        img = img.resize((cur_w, cur_h), Image.LANCZOS)
    return img.resize((target_w, target_h), Image.LANCZOS)


def make_icon(
    fa_path: str,
    target_h: int,
    rgb: tuple[int, int, int],
    target_w: int | None = None,
    alpha_threshold: int = 20,
) -> Image.Image:
    """Scale FA source to target size, tint with rgb, and binarise alpha."""
    img = Image.open(fa_path).convert("RGBA")
    if target_w is None:
        target_w = max(1, round(img.width * target_h / img.height))
    img = _downsample(img, target_w, target_h)
    bbox = img.getbbox()
    if bbox:
        img = img.crop(bbox)
    _, _, _, a_ch = img.split()
    a_ch = a_ch.point(lambda a: 255 if a > alpha_threshold else 0)
    r, g, b = rgb
    solid = Image.new("RGBA", img.size, (r, g, b, 255))
    solid.putalpha(a_ch)
    return solid


def make_degree(target_h: int, rgb: tuple[int, int, int]) -> Image.Image:
    """Draw a 1px-stroke degree ring at target_h × target_h using 8× oversampling."""
    scale = 8
    big_h = target_h * scale
    r, g, b = rgb
    cx = cy = big_h / 2.0
    outer_r = cx
    inner_r = outer_r - scale  # 1px stroke at target resolution

    pixels = []
    for py in range(big_h):
        for px in range(big_h):
            d = ((px + 0.5 - cx) ** 2 + (py + 0.5 - cy) ** 2) ** 0.5
            pixels.append((r, g, b, 255 if inner_r < d < outer_r else 0))

    big_img = Image.new("RGBA", (big_h, big_h), (0, 0, 0, 0))
    big_img.putdata(pixels)
    img = big_img.resize((target_h, target_h), Image.LANCZOS)

    _, _, _, a_ch = img.split()
    a_ch = a_ch.point(lambda a: 255 if a > 20 else 0)
    solid = Image.new("RGBA", img.size, (r, g, b, 255))
    solid.putalpha(a_ch)
    return solid


BOLT_COLOR_IDX = 3   # bolt is always yellow
COLOR_ICONS = ("aup", "adn", "deg")


def run() -> None:
    os.makedirs(ICON_DIR, exist_ok=True)

    sizes: dict[str, dict[str, tuple[int, int]]] = {"a": {}, "b": {}}

    for key in COLOR_ICONS:
        fa_name, h_a, h_b = ICONS[key]
        fa_path = os.path.join(FA_DIR, fa_name)
        for ci, rgb in enumerate(COLORS):
            if key == "deg":
                img_a = make_degree(h_a, rgb)
                img_b = make_degree(h_b, rgb)
            else:
                img_a = make_icon(fa_path, h_a, rgb)
                img_b = make_icon(fa_path, h_b, rgb)
            img_a.save(os.path.join(ICON_DIR, f"{key}_a_{ci}.png"), "PNG", optimize=True)
            img_b.save(os.path.join(ICON_DIR, f"{key}_b_{ci}.png"), "PNG", optimize=True)
            if ci == 0:
                sizes["a"][key] = (img_a.width, img_a.height)
                sizes["b"][key] = (img_b.width, img_b.height)

    # Bolt: single yellow variant per size set
    fa_name, h_a, h_b = ICONS["bolt"]
    fa_path = os.path.join(FA_DIR, fa_name)
    yellow = COLORS[BOLT_COLOR_IDX]
    img_a = make_icon(fa_path, h_a, yellow, target_w=BOLT_W_A, alpha_threshold=100)
    img_a.save(os.path.join(ICON_DIR, "bolt_a.png"), "PNG", optimize=True)
    sizes["a"]["bolt"] = (img_a.width, img_a.height)
    img_b = make_icon(fa_path, h_b, yellow, target_w=BOLT_W_B, alpha_threshold=100)
    img_b.save(os.path.join(ICON_DIR, "bolt_b.png"), "PNG", optimize=True)
    sizes["b"]["bolt"] = (img_b.width, img_b.height)

    # Remove stale icon files for color indices that no longer exist
    removed = 0
    for fname in os.listdir(ICON_DIR):
        m = re.match(r"^(aup|adn|deg)_([ab])_(\d+)\.png$", fname)
        if m and int(m.group(3)) >= len(COLORS):
            os.remove(os.path.join(ICON_DIR, fname))
            removed += 1
    if removed:
        print(f"Removed {removed} stale icon(s)")

    total = len(COLOR_ICONS) * len(COLORS) * 2 + 2
    print(f"Generated {total} icons in {ICON_DIR}\n")
    for ab in ("a", "b"):
        label = f"Set {'A' if ab == 'a' else 'B'} (lineHeight {SIZE_A if ab == 'a' else SIZE_B})"
        print(f"{label}:")
        for k, (w, h) in sizes[ab].items():
            print(f"  {k}: {w} x {h}")
    print()

    lines = ["<drawables>"]
    lines.append('    <bitmap id="LauncherIcon" filename="launcher_icon.png" />')
    for key in COLOR_ICONS:
        pfx = RES_PREFIX[key]
        for ab in ("a", "b"):
            for ci in range(len(COLORS)):
                lines.append(
                    f'    <bitmap id="{pfx}{ab.upper()}{ci}" filename="icons/{key}_{ab}_{ci}.png" />'
                )
    lines.append('    <bitmap id="BoltA" filename="icons/bolt_a.png" />')
    lines.append('    <bitmap id="BoltB" filename="icons/bolt_b.png" />')
    lines.append("</drawables>")
    with open(DRW_XML, "w") as f:
        f.write("\n".join(lines) + "\n")
    print(f"Wrote {DRW_XML}")


if __name__ == "__main__":
    run()
