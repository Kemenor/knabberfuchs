#!/usr/bin/env python3
"""Generate the Play Store hi-res icon (512x512) and feature graphic (1024x500)
from the app's source fox art. Output goes into the en-US listing images dir.

    python3 tool/make_store_graphics.py
"""
import subprocess
from PIL import Image, ImageDraw, ImageFont

OUT = 'fastlane/metadata/android/en-US/images'
FONT = subprocess.run(
    ['fc-match', '-f', '%{file}', 'Noto Sans:weight=bold'],
    capture_output=True, text=True).stdout.strip() \
    or '/usr/share/fonts/google-noto/NotoSans-Bold.ttf'

# 1) hi-res icon — downscale the real app icon; 32-bit PNG as Play requires
Image.open('assets/icon/cutefox.png').convert('RGBA').resize(
    (512, 512), Image.LANCZOS).save(f'{OUT}/icon.png')

# 2) feature graphic — fox on a green gradient with the app name.
# NOTE: deliberately frozen pre-rebrand palette — the published Play feature
# graphic uses it. If you regenerate store art, switch this gradient to the
# tangerine triad first (see lib/core/theme.dart / the fuchsbau package).
W, H = 1024, 500
top, bot = (124, 166, 60), (58, 107, 42)
bg = Image.new('RGB', (W, H))
px = bg.load()
for y in range(H):
    t = y / (H - 1)
    row = tuple(int(top[i] + (bot[i] - top[i]) * t) for i in range(3))
    for x in range(W):
        px[x, y] = row
banner = bg.convert('RGBA')

fh = 380
fox = Image.open('assets/icon/cutefox_nobg.png').convert('RGBA').resize(
    (fh, fh), Image.LANCZOS)
fox_x, fox_y = 55, (H - fh) // 2
banner.alpha_composite(fox, (fox_x, fox_y))

draw = ImageDraw.Draw(banner)
text_x = fox_x + fh + 40
text_w = W - text_x - 50


def fit(text, max_size):
    for s in range(max_size, 8, -2):
        f = ImageFont.truetype(FONT, s)
        if draw.textlength(text, font=f) <= text_w:
            return f
    return ImageFont.truetype(FONT, 10)


def th(f):
    a = f.getbbox('Hg')
    return a[3] - a[1]


title_f = fit('Knabberfuchs', 96)
sub_f = fit('Ad-free calorie tracker', 46)
tag_f = fit('no account · offline · your data stays home', 30)
gap1, gap2 = 22, 16
block = th(title_f) + gap1 + th(sub_f) + gap2 + th(tag_f)
y = (H - block) // 2 - 10


def line(text, f, fill, y):
    draw.text((text_x + 2, y + 2), text, font=f, fill=(30, 50, 20, 160))
    draw.text((text_x, y), text, font=f, fill=fill)
    return y + th(f)


y = line('Knabberfuchs', title_f, (255, 255, 255, 255), y) + gap1
y = line('Ad-free calorie tracker', sub_f, (236, 246, 222, 255), y) + gap2
line('no account · offline · your data stays home', tag_f, (214, 232, 190, 255), y)

banner.convert('RGB').save(f'{OUT}/featureGraphic.png')
print('wrote icon.png (512x512) and featureGraphic.png (1024x500)')
