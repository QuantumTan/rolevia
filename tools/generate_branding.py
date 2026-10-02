"""Render the original bolt/check construction for native icon generators."""
from pathlib import Path
from PIL import Image, ImageDraw

root = Path(__file__).resolve().parents[1] / "assets" / "branding"
root.mkdir(parents=True, exist_ok=True)

def mark(background, inset=0):
    scale = 3
    image = Image.new("RGBA", (1024 * scale, 1024 * scale), background)
    draw = ImageDraw.Draw(image)
    factor = (1024 - 2 * inset) / 1024
    def point(x, y):
        return ((inset + x * factor) * scale, (inset + y * factor) * scale)
    draw.polygon([point(x, y) for x, y in [(565, 176), (312, 552), (478, 552),
        (446, 848), (712, 440), (536, 440)]], fill="white")
    line = [point(x, y) for x, y in [(270, 636), (373, 739), (578, 520)]]
    radius = 30 * factor * scale
    draw.line(line, fill="white", width=round(radius * 2), joint="curve")
    for x, y in line:
        draw.ellipse((x-radius, y-radius, x+radius, y+radius), fill="white")
    return image.resize((1024, 1024), Image.Resampling.LANCZOS)

mark("#3F51B5").convert("RGB").save(root / "app_icon.png")
mark((0, 0, 0, 0), 96).save(root / "foreground.png")
mark((0, 0, 0, 0), 160).resize((288, 288), Image.Resampling.LANCZOS).save(root / "splash.png")

web = root.parents[1] / "web"
for size in (192, 512):
    icon = mark("#3F51B5", 96).convert("RGB").resize((size, size), Image.Resampling.LANCZOS)
    for name in (f"Icon-{size}.png", f"Icon-maskable-{size}.png"):
        icon.save(web / "icons" / name)
mark("#3F51B5", 96).convert("RGB").resize((32, 32), Image.Resampling.LANCZOS).save(web / "favicon.png")
