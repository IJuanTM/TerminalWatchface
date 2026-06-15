"""
Generate two sets (A = lineHeight 30, B = lineHeight 32) of color-tinted watch
icons from FontAwesome source PNGs, one variant per color in COLORS (20 colors).

Output: resources/drawables/icons/{key}_{ab}_{ci}.png  (160 files total)
Also rewrites resources/drawables/drawables.xml.

Icon types: aup (arrow up), adn (arrow down), deg (degree circle), bolt
Font sets:  a = JetBrainsMono/FiraCode/NBArchitekt (lineHeight 30)
            b = SpaceMono (lineHeight 32)
"""

import os
from PIL import Image, ImageDraw

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
BASE = os.path.dirname(SCRIPT_DIR)
FA_DIR = os.path.join(BASE, "resources", "drawables", "FA")
ICON_DIR = os.path.join(BASE, "resources", "drawables", "icons")
DRW_XML = os.path.join(BASE, "resources", "drawables", "drawables.xml")

# Colors array — must stay in sync with COLORS in TerminalWatchfaceView.mc
COLORS = [
    (0xFF, 0xFF, 0xFF),  # 0  white
    (0x44, 0xDD, 0x88),  # 1  green
    (0x55, 0xDD, 0xFF),  # 2  cyan
    (0xEE, 0xDD, 0x55),  # 3  yellow
    (0xFF, 0xAA, 0x55),  # 4  orange
    (0xFF, 0x55, 0x55),  # 5  red
    (0x77, 0x99, 0xFF),  # 6  blue
    (0xDD, 0x77, 0xFF),  # 7  magenta
    (0xCC, 0xCC, 0xCC),  # 8  light grey
    (0xFF, 0x77, 0xCC),  # 9  pink
    (0xAA, 0xFF, 0x55),  # 10 lime
    (0x33, 0xBB, 0xAA),  # 11 teal
    (0x88, 0x44, 0xFF),  # 12 purple
    (0x88, 0x88, 0x88),  # 13 dark grey
    (0x44, 0xAA, 0xFF),  # 14 sky blue
    (0xFF, 0xBB, 0x00),  # 15 amber
    (0x00, 0xCC, 0x55),  # 16 emerald
    (0x00, 0xDD, 0xB0),  # 17 turquoise
    (0xFF, 0x77, 0x66),  # 18 coral
    (0xAA, 0x66, 0xFF),  # 19 violet
]

SIZE_A = 28  # lineHeight: JetBrainsMono, FiraCode, NBArchitekt
SIZE_B = 30  # lineHeight: SpaceMono

ARROW_H_A = 15
BOLT_H_A  = 17
BOLT_W_A  = 15
DEG_H_A   = 7
scale_b   = SIZE_B / SIZE_A
ARROW_H_B = round(ARROW_H_A * scale_b)
BOLT_H_B  = round(BOLT_H_A  * scale_b)
BOLT_W_B  = round(BOLT_W_A  * scale_b)
DEG_H_B   = round(DEG_H_A   * scale_b)

# (fa_filename, target_h_a, target_h_b)
ICONS: dict[str, tuple[str, int, int]] = {
    "aup":  ("FA_arrow-up-long-solid.png",   ARROW_H_A, ARROW_H_B),
    "adn":  ("FA_arrow-down-long-solid.png",  ARROW_H_A, ARROW_H_B),
    "deg":  ("FA_circle-regular.png",         DEG_H_A,   DEG_H_B),
    "bolt": ("FA_bolt-solid.png",             BOLT_H_A,  BOLT_H_B),
}

# Resource-ID prefix used in drawables.xml and CIQ code (capitalized key)
RES_PREFIX = {"aup": "Aup", "adn": "Adn", "deg": "Deg", "bolt": "Bolt"}


def _downsample(img: Image.Image, target_w: int, target_h: int) -> Image.Image:
    """Progressive halving then a final LANCZOS step for large-ratio downscales.

    A single LANCZOS pass from 640px → 16px (40× ratio) applies a very wide kernel
    that can smear thin features (arrow shaft, arrowhead tips). Halving the image
    repeatedly keeps every intermediate step within the 2× range where LANCZOS is
    sharpest, then finishes with one precise final resize.
    """
    cur_w, cur_h = img.size
    while cur_h > target_h * 2:
        cur_h //= 2
        cur_w = max(1, round(img.width * cur_h / img.height))
        img = img.resize((cur_w, cur_h), Image.LANCZOS)
    return img.resize((target_w, target_h), Image.LANCZOS)


def make_icon(fa_path: str, target_h: int, rgb: tuple[int, int, int], target_w: int | None = None) -> Image.Image:
    """Progressively scale FA source to target_h, trim, then tint with rgb.

    After scaling, alpha is binarised (threshold 20/255): LANCZOS at small sizes
    still leaves some shaft pixels at partial opacity which look washed-out on a
    black AMOLED background. Snapping to fully-opaque or transparent keeps edges
    crisp while matching the configured color exactly.
    """
    img = Image.open(fa_path).convert("RGBA")
    src_w, src_h = img.size
    if target_w is None:
        target_w = max(1, round(src_w * target_h / src_h))
    img = _downsample(img, target_w, target_h)
    bbox = img.getbbox()
    if bbox:
        img = img.crop(bbox)
    # Binary alpha: threshold at 20/255 (captures edge pixels without noise)
    _, _, _, a_ch = img.split()
    a_ch = a_ch.point(lambda a: 255 if a > 20 else 0)
    r, g, b = rgb
    solid = Image.new("RGBA", img.size, (r, g, b, 255))
    solid.putalpha(a_ch)
    return solid


def make_degree(target_h: int, rgb: tuple[int, int, int]) -> Image.Image:
    """Draw a degree-symbol ring at target_h × target_h with binary alpha.

    Draws at 8× resolution then LANCZOS-downsamples to target size. At native
    8–9 px the pixel grid is too coarse for a circle to look round; oversampling
    lets the downsample step act as a proper anti-alias pass before the binary
    alpha threshold snaps edges to fully-opaque or transparent.

    stroke = 1px at target resolution (scaled up during oversample draw).
    """
    scale = 8
    big_h = target_h * scale
    r, g, b = rgb
    cx = cy = big_h / 2.0
    outer_r = cx
    inner_r = outer_r - 1.0 * scale

    pixels = []
    for py in range(big_h):
        for px in range(big_h):
            d = ((px + 0.5 - cx) ** 2 + (py + 0.5 - cy) ** 2) ** 0.5
            alpha = 255 if inner_r < d < outer_r else 0
            pixels.append((r, g, b, alpha))

    big_img = Image.new("RGBA", (big_h, big_h), (0, 0, 0, 0))
    big_img.putdata(pixels)
    img = big_img.resize((target_h, target_h), Image.LANCZOS)

    _, _, _, a_ch = img.split()
    a_ch = a_ch.point(lambda a: 255 if a > 20 else 0)
    solid = Image.new("RGBA", img.size, (r, g, b, 255))
    solid.putalpha(a_ch)
    return solid


BOLT_COLOR_IDX = 3  # bolt is always yellow (index 3)
COLOR_ICONS = ("aup", "adn", "deg")  # these get all 20 color variants


def run() -> None:
    os.makedirs(ICON_DIR, exist_ok=True)

    sizes: dict[str, dict[str, tuple[int, int]]] = {"a": {}, "b": {}}

    # Color icons: all 20 variants
    for key in COLOR_ICONS:
        fa_name, h_a, h_b = ICONS[key]
        fa_path = os.path.join(FA_DIR, fa_name)
        for ci, rgb in enumerate(COLORS):
            if key == "deg":
                # Degree circle drawn programmatically for precise 2px stroke
                img_a = make_degree(h_a, rgb)
                img_b = make_degree(h_b, rgb)
            else:
                img_a = make_icon(fa_path, h_a, rgb)
                img_b = make_icon(fa_path, h_b, rgb)
            img_a.save(os.path.join(ICON_DIR, f"{key}_a_{ci}.png"), "PNG", optimize=True)
            if ci == 0:
                sizes["a"][key] = (img_a.width, img_a.height)
            img_b.save(os.path.join(ICON_DIR, f"{key}_b_{ci}.png"), "PNG", optimize=True)
            if ci == 0:
                sizes["b"][key] = (img_b.width, img_b.height)

    # Bolt: yellow only, no color index in filename
    fa_name, h_a, h_b = ICONS["bolt"]
    fa_path = os.path.join(FA_DIR, fa_name)
    yellow = COLORS[BOLT_COLOR_IDX]
    img_a = make_icon(fa_path, h_a, yellow, target_w=BOLT_W_A)
    img_a.save(os.path.join(ICON_DIR, "bolt_a.png"), "PNG", optimize=True)
    sizes["a"]["bolt"] = (img_a.width, img_a.height)
    img_b = make_icon(fa_path, h_b, yellow, target_w=BOLT_W_B)
    img_b.save(os.path.join(ICON_DIR, "bolt_b.png"), "PNG", optimize=True)
    sizes["b"]["bolt"] = (img_b.width, img_b.height)

    total = len(COLOR_ICONS) * len(COLORS) * 2 + 2
    print(f"Generated {total} icons in {ICON_DIR}\n")
    for ab in ("a", "b"):
        label = f"Set {'A' if ab == 'a' else 'B'} (lineHeight {SIZE_A if ab == 'a' else SIZE_B})"
        print(f"{label}:")
        for k, (w, h) in sizes[ab].items():
            print(f"  {k}: {w} x {h}")
    print()

    # Write drawables.xml
    lines = ["<drawables>"]
    lines.append('    <bitmap id="LauncherIcon" filename="launcher_icon.png" />')
    for key in COLOR_ICONS:
        pfx = RES_PREFIX[key]
        for ab in ("a", "b"):
            AB = ab.upper()
            for ci in range(len(COLORS)):
                lines.append(
                    f'    <bitmap id="{pfx}{AB}{ci}" filename="icons/{key}_{ab}_{ci}.png" />'
                )
    # Bolt: single resource per size set
    lines.append('    <bitmap id="BoltA" filename="icons/bolt_a.png" />')
    lines.append('    <bitmap id="BoltB" filename="icons/bolt_b.png" />')
    lines.append("</drawables>")
    with open(DRW_XML, "w") as f:
        f.write("\n".join(lines) + "\n")
    print(f"Wrote {DRW_XML}")


if __name__ == "__main__":
    run()
