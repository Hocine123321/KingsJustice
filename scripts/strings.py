#!/usr/bin/env python3
"""Keeps Resources/en.lproj/Localizable.strings in step with the UI text in the Swift sources.

  python3 scripts/strings.py --write   add any new UI strings (existing values are kept)
  python3 scripts/strings.py --check   fail if a UI string is missing from the file
"""
import glob
import re
import sys

STRINGS = "KingsJustice/Resources/en.lproj/Localizable.strings"
SOURCES = sorted(glob.glob("KingsJustice/UI/*.swift"))

LITERAL = r'"([^"\\]{2,})"'
PATTERNS = [
    re.compile(r'Text\(' + LITERAL + r'\)'),
    re.compile(r'\b(?:title|kick|label|description|desc|specialText|badgeText|hint|how|name|subtitle):\s*' + LITERAL),
    re.compile(r'static let (?:flash|guide|haptics|leftHand|assist|reduceMotion|colorSafe) = ' + LITERAL),
]


def found_in_sources():
    keys = set()
    for path in SOURCES:
        text = open(path, encoding="utf-8").read()
        for pat in PATTERNS:
            for m in pat.finditer(text):
                keys.add(m.group(m.lastindex))
    return keys


def read_existing():
    out = {}
    try:
        for line in open(STRINGS, encoding="utf-8"):
            m = re.match(r'^"(.*)" = "(.*)";\s*$', line)
            if m:
                out[m.group(1)] = m.group(2)
    except FileNotFoundError:
        pass
    return out


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else "--check"
    keys = found_in_sources()
    existing = read_existing()
    missing = sorted(k for k in keys if k not in existing)
    if mode == "--check":
        if missing:
            print("LINT FAIL: UI strings missing from Localizable.strings (run: python3 scripts/strings.py --write):")
            for k in missing:
                print("  " + k)
            return 1
        print("Strings file is complete (%d keys)." % len(existing))
        return 0
    merged = dict(existing)
    for k in keys:
        merged.setdefault(k, k)
    with open(STRINGS, "w", encoding="utf-8") as f:
        f.write("/* English UI text. To add a language, copy this folder to <code>.lproj and translate the values. */\n")
        for k in sorted(merged):
            f.write('"%s" = "%s";\n' % (k, merged[k]))
    print("Wrote %d keys (%d new)." % (len(merged), len(missing)))
    return 0


sys.exit(main())
