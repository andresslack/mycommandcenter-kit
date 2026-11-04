#!/usr/bin/env python3
"""Why isn't this file shown? (File Save Log explain check)

Usage: python3 explain.py "<full path to the file>"

Run it from the filesave-log folder, or pass --config-dir <folder>
holding FileSaveLog-Excludes.json and FileSaveLog-Excludes.user.json.

The check walks the visibility layers in order and names the first
one that hides the path, with the exact config rule responsible:

  1. complete exclusion (config)  -> not in the panel, log, or CSV
  2. panel-only rule (config)     -> in the log and CSV, off the panel
  3. link test                    -> in the log and CSV, off the panel
  4. otherwise the config does not hide it: if it is still not on
     the panel, the cause is on the board itself (Dismiss, Hide
     this file always, or the extension / count filters), which
     this script cannot see; check the panel's Hidden items list
     and filter settings.
"""

from __future__ import annotations

import fnmatch
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from excludes import load_excludes  # noqa: E402  (the shared loader)

DRIVE_RE = re.compile(r"^[A-Za-z]:[\\/]")
MAC_PREFIXES = ("/Users/", "/Volumes/")


def _split(path: str):
    return [s for s in re.split(r"[\\/]+", path or "") if s]


def attribute(rules, path: str, scope: str):
    parts = _split(path)
    name = parts[-1].lower() if parts else ""
    folders = [s.lower() for s in parts[:-1]]
    for ext in rules.extensions:
        if name.endswith(ext):
            return f"{scope}: extension rule {ext!r}"
    for pat in rules.file_name_patterns:
        if fnmatch.fnmatchcase(name, pat):
            return f"{scope}: file-name rule {pat!r}"
    for seg in folders:
        if seg in rules.folder_segments:
            return f"{scope}: folder-segment rule {seg!r}"
    for i in range(len(folders) - 1):
        pair = (folders[i], folders[i + 1])
        if pair in rules.segment_pairs:
            return f"{scope}: segment-pair rule {pair[0]!r} > {pair[1]!r}"
    if rules.matches_self_path(path):
        return f"{scope}: selfPaths rule (the scanner's own folders)"
    if rules.matches_path_prefix(path):
        return f"{scope}: path-prefix rule"
    return None


def has_working_link(path: str) -> bool:
    p = path or ""
    return bool(DRIVE_RE.match(p)) or p.startswith("\\\\") \
        or p.startswith(MAC_PREFIXES)


def main(argv) -> int:
    args = [a for a in argv[1:] if not a.startswith("--")]
    config_dir = Path(__file__).resolve().parent
    if "--config-dir" in argv:
        config_dir = Path(argv[argv.index("--config-dir") + 1])
    if not args:
        print(__doc__)
        return 2
    path = args[0]
    rules = load_excludes(config_dir / "FileSaveLog-Excludes.json",
                          config_dir / "FileSaveLog-Excludes.user.json")
    for warning in rules.warnings:
        print(f"warning: {warning}", file=sys.stderr)

    hit = attribute(rules, path, "complete exclusion (config)")
    if hit:
        print(f"NOT SHOWN anywhere (panel, master log, CSV).\nLayer: {hit}")
        return 0
    if rules.panel is not None:
        hit = attribute(rules.panel, path, "panel-only (config panelOnly)")
        if hit:
            print(f"IN the master log and CSV, NOT on the panel.\nLayer: {hit}")
            return 0
    if not has_working_link(path):
        print("IN the master log and CSV, NOT on the panel.\n"
              "Layer: link test (the path cannot be turned into a "
              "working link; workspace and sandbox paths fail)")
        return 0
    print("Not hidden by any config rule or the link test. If the "
          "file is not on the panel, the cause is on the board: a "
          "Dismiss, a Hide-this-file-always entry, or the extension "
          "/ count filters. Check the panel's Hidden items list and "
          "filter settings.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
