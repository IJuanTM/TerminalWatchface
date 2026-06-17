#!/usr/bin/env python3
"""
Removes all generated resource files so they can be cleanly regenerated.

Run from the project root:
    python scripts/clean.py

Then regenerate with:
    python scripts/generate_resources.py
    python scripts/gen_icons.py
"""

import os
import shutil

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

GENERATED_FILES = [
    os.path.join(BASE, "resources", "properties.xml"),
    os.path.join(BASE, "resources", "strings", "strings.xml"),
    os.path.join(BASE, "resources", "settings.xml"),
    os.path.join(BASE, "resources", "drawables", "drawables.xml"),
]

GENERATED_DIRS = [
    os.path.join(BASE, "resources", "drawables", "icons"),
]

removed = 0

for path in GENERATED_FILES:
    if os.path.exists(path):
        os.remove(path)
        print(f"  removed {os.path.relpath(path, BASE)}")
        removed += 1
    else:
        print(f"  skip    {os.path.relpath(path, BASE)} (not found)")

for path in GENERATED_DIRS:
    if os.path.isdir(path):
        count = sum(len(files) for _, _, files in os.walk(path))
        shutil.rmtree(path)
        print(f"  removed {os.path.relpath(path, BASE)}/ ({count} files)")
        removed += count
    else:
        print(f"  skip    {os.path.relpath(path, BASE)}/ (not found)")

print(f"\nDone. {removed} file(s) removed.")
