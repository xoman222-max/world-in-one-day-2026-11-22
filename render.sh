#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PNG="$DIR/entry.png"

google-chrome --headless=new --no-sandbox --disable-gpu --hide-scrollbars --window-size=1024,1024 --screenshot="$PNG" "file://$DIR/poster.html"

python3 - "$PNG" <<'PY'
import os
import sys
from PIL import Image

path = sys.argv[1]
with Image.open(path) as image:
    if image.size != (1024, 1024):
        raise SystemExit(f"unexpected screenshot size: {image.size}")
    if os.path.getsize(path) < 1024 * 1024:
        raise SystemExit(0)
    for colors in (128, 64, 32):
        image.convert("RGB").quantize(colors=colors, method=Image.Quantize.MEDIANCUT).save(path, optimize=True)
        if os.path.getsize(path) < 1024 * 1024:
            break
    if os.path.getsize(path) >= 1024 * 1024:
        raise SystemExit("entry.png is still over 1 MiB")
PY
