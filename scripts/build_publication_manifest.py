#!/usr/bin/env python3
"""Build a deterministic provenance manifest for the curated public docs tree."""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PUBLIC = ROOT / "public-docs"
ALLOWLIST = PUBLIC / "PUBLISH_ALLOWLIST.txt"


def load_allowlist() -> list[str]:
    entries: list[str] = []
    for raw in ALLOWLIST.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        entries.append(line)
    return sorted(entries)


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source-sha", required=True)
    parser.add_argument("--source-repository", default="mytestlab123/chatgpt-aws")
    parser.add_argument("--output", required=True)
    args = parser.parse_args()

    files: list[dict[str, str]] = []
    digest_input = hashlib.sha256()

    for rel in load_allowlist():
        path = PUBLIC / rel
        if not path.is_file():
            raise SystemExit(f"Allowlisted file is missing: {rel}")
        file_hash = sha256(path)
        files.append({"path": rel, "sha256": file_hash})
        digest_input.update(rel.encode("utf-8"))
        digest_input.update(b"\0")
        digest_input.update(file_hash.encode("ascii"))
        digest_input.update(b"\n")

    manifest = {
        "schema_version": 1,
        "source_repository": args.source_repository,
        "source_commit": args.source_sha,
        "content_digest": "sha256:" + digest_input.hexdigest(),
        "files": files,
    }

    output = Path(args.output)
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(manifest["content_digest"])
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
