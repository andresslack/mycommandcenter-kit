#!/usr/bin/env python3
"""Config-driven exclusion rules for the File Save Log.

One design, two files (user decision 2026-11-02):

- FileSaveLog-Excludes.json       shipped kit defaults, replaced on
                                  every kit update.
- FileSaveLog-Excludes.user.json  the user's own additions, never
                                  overwritten by updates.

Schema (both files): version, extensions[], fileNames[] (wildcards,
case-insensitive), folderSegments[], segmentPairs[[parent, child]],
selfPaths[], and in the defaults file an optional{} block of rule
groups shipped disabled, enabled by listing their keys in the user
file's enableOptional[]. The defaults file also carries a settings{}
object (panelSize, retentionMonths) that the user file may override
per key; see _load_settings for validation and fallback.

Matching is case-insensitive throughout. Segment pairs require
adjacency: the child folder directly under the parent folder, so an
unrelated folder named "cache" or "output" is not excluded.

Fail-safe: a missing or invalid file contributes the built-in minimal
safe set (for the defaults file) or nothing (for the user file, whose
absence is normal), a warning is recorded for the caller's log, and
loading never raises.
"""

from __future__ import annotations

import fnmatch
import json
import re
from pathlib import Path

# Built-in minimal safe default set: used when the defaults file is
# missing or invalid. Deliberately small: it keeps the classic
# transient and lock artifacts out, and nothing else.
FALLBACK = {
    "extensions": [".tmp", ".temp", ".crdownload", ".partial", ".part", ".log"],
    "fileNames": ["desktop.ini", "Thumbs.db", ".DS_Store", "~$*"],
    "folderSegments": [".git", "node_modules", "__pycache__"],
    "segmentPairs": [],
    "selfPaths": [],
}

_SPLIT = re.compile(r"[\\/]+")


def _split(path: str):
    return [seg for seg in _SPLIT.split(path or "") if seg]


def _normalise_fs(path: str) -> str:
    return (path or "").replace("\\", "/").lower().rstrip("/")


class ExclusionRules:
    def __init__(self):
        self.extensions = []        # lowercased suffix entries
        self.file_name_patterns = []  # lowercased fnmatch patterns
        self.folder_segments = set()
        self.segment_pairs = set()  # {(parent_lower, child_lower)}
        self.self_paths = []        # normalised absolute prefixes
        self.path_prefixes = []     # normalised absolute path prefixes
        self.warnings = []
        self.settings = {"panelSize": 40, "retentionMonths": 12}
        self.panel = None           # ExclusionRules for panel-only rules

    # -- construction -------------------------------------------------
    def _absorb(self, data: dict, source: str) -> None:
        if not isinstance(data, dict):
            self.warnings.append(f"{source}: not a JSON object, ignored")
            return
        for entry in data.get("extensions", []) or []:
            self.extensions.append(str(entry).lower())
        for entry in data.get("fileNames", []) or []:
            self.file_name_patterns.append(str(entry).lower())
        for entry in data.get("folderSegments", []) or []:
            self.folder_segments.add(str(entry).lower())
        for pair in data.get("segmentPairs", []) or []:
            if isinstance(pair, (list, tuple)) and len(pair) == 2:
                self.segment_pairs.add((str(pair[0]).lower(), str(pair[1]).lower()))
            else:
                self.warnings.append(f"{source}: bad segmentPairs entry {pair!r}, skipped")
        for entry in data.get("selfPaths", []) or []:
            self.self_paths.append(_normalise_fs(str(entry)))
        for entry in data.get("pathPrefixes", []) or []:
            self.path_prefixes.append(_normalise_fs(str(entry)))

    # -- matching ------------------------------------------------------
    def matches_extension(self, path: str) -> bool:
        name = _split(path)[-1].lower() if _split(path) else ""
        return any(name.endswith(ext) for ext in self.extensions)

    def matches_file_name(self, path: str) -> bool:
        parts = _split(path)
        name = parts[-1].lower() if parts else ""
        return any(fnmatch.fnmatchcase(name, pat) for pat in self.file_name_patterns)

    def matches_segment_rules(self, path: str) -> bool:
        segments = [seg.lower() for seg in _split(path)]
        folders = segments[:-1]  # the file name is not a folder segment
        if any(seg in self.folder_segments for seg in folders):
            return True
        return any(
            (folders[i], folders[i + 1]) in self.segment_pairs
            for i in range(len(folders) - 1)
        )

    def matches_self_path(self, path: str) -> bool:
        normalised = _normalise_fs(path)
        return any(
            normalised == base or normalised.startswith(base + "/")
            for base in self.self_paths
            if base
        )

    def matches_path_prefix(self, path: str) -> bool:
        normalised = _normalise_fs(path)
        return any(
            normalised.startswith(prefix if prefix.endswith("/") else prefix + "/")
            or normalised == prefix
            for prefix in self.path_prefixes
            if prefix
        )

    def is_panel_excluded(self, path: str) -> bool:
        """Panel-only rules (the config files' panelOnly block): the
        entry stays in the master log and CSV but never reaches the
        panel. Scanners must NOT use this; it is aggregator/panel
        logic only."""
        if self.panel is None:
            return False
        return self.panel.is_excluded(path) or self.panel.matches_path_prefix(path)

    def is_excluded(self, path: str) -> bool:
        return (
            self.matches_extension(path)
            or self.matches_file_name(path)
            or self.matches_segment_rules(path)
            or self.matches_self_path(path)
        )


# Settings (user decision 2026-11-02): two aggregator numbers are
# user preferences, not constants: panelSize (saves shown in the
# File Saves History panel) and retentionMonths (months kept in the
# master log). They live in the defaults file's "settings" object;
# the user file may override either key. Validation: a whole number
# in range. An invalid user value falls back to the defaults file
# value; an invalid defaults value falls back to the built-in here.
# Every fallback records a warning naming the key and the bad value;
# a bad value is never treated as zero or unlimited.
SETTING_SPECS = {
    "panelSize": (40, 10, 200),        # (built-in, min, max)
    "retentionMonths": (12, 1, 60),
}


def _valid_setting(key: str, value) -> bool:
    if isinstance(value, bool) or not isinstance(value, int):
        return False
    _, lo, hi = SETTING_SPECS[key]
    return lo <= value <= hi


def _load_settings(rules: ExclusionRules, defaults, user, warnings: list) -> None:
    settings = {}
    defaults_settings = (
        defaults.get("settings") if isinstance(defaults, dict) else None
    )
    if not isinstance(defaults_settings, dict):
        defaults_settings = {}
    for key, (builtin, _lo, _hi) in SETTING_SPECS.items():
        if key in defaults_settings:
            value = defaults_settings[key]
            if _valid_setting(key, value):
                settings[key] = value
            else:
                warnings.append(
                    f"settings.{key}: invalid value {value!r} in the "
                    f"defaults file, using the built-in {builtin}"
                )
                settings[key] = builtin
        else:
            settings[key] = builtin
    user_settings = user.get("settings") if isinstance(user, dict) else None
    if isinstance(user_settings, dict):
        for key in SETTING_SPECS:
            if key in user_settings:
                value = user_settings[key]
                if _valid_setting(key, value):
                    settings[key] = value
                else:
                    warnings.append(
                        f"settings.{key}: invalid value {value!r} in the "
                        f"user file, using the defaults value {settings[key]}"
                    )
    rules.settings = settings


def _read_json(path: Path, warnings: list):
    try:
        with path.open("r", encoding="utf-8") as fh:
            return json.load(fh)
    except FileNotFoundError:
        warnings.append(f"{path}: not found")
    except (OSError, json.JSONDecodeError) as exc:
        warnings.append(f"{path}: unreadable or invalid JSON ({exc})")
    return None


def load_excludes(defaults_path, user_path=None) -> ExclusionRules:
    """Load and merge the defaults and user exclusion files.

    Never raises. A missing or invalid defaults file falls back to
    the built-in minimal set; a missing user file is normal (no
    personal rules yet), an invalid one is ignored with a warning.
    Warnings are available on rules.warnings for the caller's log.
    """
    rules = ExclusionRules()
    warnings = []

    defaults = _read_json(Path(defaults_path), warnings) if defaults_path else None
    if defaults is None:
        warnings.append("using the built-in minimal exclusion set")
        defaults = FALLBACK
    rules._absorb(defaults, str(defaults_path))

    enabled_optional = []
    user = None
    if user_path:
        user = _read_json(Path(user_path), warnings)
        if user is not None:
            rules._absorb(user, str(user_path))
            enabled_optional = [
                str(key) for key in (user.get("enableOptional") or [])
            ]

    optional = defaults.get("optional") if isinstance(defaults, dict) else None
    if optional and enabled_optional:
        for key in enabled_optional:
            group = optional.get(key)
            if isinstance(group, dict):
                rules._absorb(group, f"optional:{key}")
            else:
                warnings.append(f"enableOptional: unknown group {key!r}, skipped")

    _load_settings(rules, defaults, user, warnings)

    # Panel-only rules: a separate matcher absorbed from each file's
    # "panelOnly" block (defaults first, then the user's additions).
    panel = ExclusionRules()
    for source_name, data in (("defaults", defaults), ("user", user)):
        if isinstance(data, dict) and isinstance(data.get("panelOnly"), dict):
            panel._absorb(data["panelOnly"], f"{source_name}:panelOnly")
    rules.panel = panel

    rules.warnings.extend(warnings)
    return rules
