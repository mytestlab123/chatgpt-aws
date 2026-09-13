#!/usr/bin/env python3
"""Validate the curated public-docs tree before cross-repository publication."""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PUBLIC = ROOT / "public-docs"
ALLOWLIST = PUBLIC / "PUBLISH_ALLOWLIST.txt"

SECRET_PATTERNS = {
    "AWS access key id": re.compile(r"\b(?:AKIA|ASIA)[A-Z0-9]{16}\b"),
    "private key": re.compile(r"-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----"),
    "GitHub token": re.compile(r"\bgh(?:p|o|u|s|r)_[A-Za-z0-9_]{20,}\b"),
    "12-digit AWS account id": re.compile(r"(?<!\d)\d{12}(?!\d)"),
    "AWS secret key assignment": re.compile(
        r"(?i)aws_secret_access_key\s*[:=]\s*['\"]?[A-Za-z0-9/+=]{30,}"
    ),
}


def load_allowlist() -> set[str]:
    entries: set[str] = set()
    for raw in ALLOWLIST.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        if line.startswith("/") or ".." in Path(line).parts:
            raise SystemExit(f"Invalid allowlist path: {line}")
        entries.add(line)
    return entries


def actual_files() -> set[str]:
    return {
        path.relative_to(PUBLIC).as_posix()
        for path in PUBLIC.rglob("*")
        if path.is_file() or path.is_symlink()
    }


def main() -> int:
    if not ALLOWLIST.is_file():
        print("ERROR: public-docs/PUBLISH_ALLOWLIST.txt is missing")
        return 1

    allowed = load_allowlist()
    actual = actual_files()
    errors: list[str] = []

    missing = sorted(allowed - actual)
    unexpected = sorted(actual - allowed)
    if missing:
        errors.append("Allowlisted files missing: " + ", ".join(missing))
    if unexpected:
        errors.append("Unexpected files in public-docs/: " + ", ".join(unexpected))

    for rel in sorted(actual):
        path = PUBLIC / rel
        if path.is_symlink():
            errors.append(f"Symlink is not allowed: {rel}")
            continue

        data = path.read_bytes()
        if b"\x00" in data:
            errors.append(f"Binary/NUL content is not allowed: {rel}")
            continue

        try:
            text = data.decode("utf-8")
        except UnicodeDecodeError:
            errors.append(f"Non-UTF-8 file is not allowed: {rel}")
            continue

        for label, pattern in SECRET_PATTERNS.items():
            if pattern.search(text):
                errors.append(f"Potential {label} found in {rel}")

    if errors:
        print("Public docs validation FAILED")
        for error in errors:
            print(f"- {error}")
        return 1

    print(f"Public docs validation PASS: {len(actual)} allowlisted UTF-8 files")
    return 0


if __name__ == "__main__":
    sys.exit(main())
