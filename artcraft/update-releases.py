#!/usr/bin/env python3
"""Pin verified official StoryTold Craft x86_64 Linux tarball releases.

Only github.com/storytold repositories are considered. A release is accepted
only when exactly one matching official tar.gz asset exists and its SHA-256 is
listed in that same release's SHA256SUMS.txt. The manifest is replaced
atomically only after every previously pinned application is still available.
"""

from __future__ import annotations

import base64
import hashlib
import json
import os
from pathlib import Path
import re
import tempfile
import urllib.error
import urllib.parse
import urllib.request

ROOT = Path(__file__).resolve().parent
OUTPUT = ROOT / "releases.json"
API_ROOT = "https://api.github.com"
OWNER = "storytold"
HEADERS = {
    "Accept": "application/vnd.github+json",
    "User-Agent": "joel-local-artcraft-nix-updater",
    "X-GitHub-Api-Version": "2022-11-28",
}

REPO_NAME = re.compile(r"[a-z][a-z0-9-]*craft")
ASSET_NAME = re.compile(r"(?P<name>[a-z][a-z0-9-]*craft)-.+-linux-x86_64\.tar\.gz", re.I)
CHECKSUM_LINE = re.compile(r"([0-9a-fA-F]{64})\s+\*?(.+)")


def get(url: str) -> bytes:
    request = urllib.request.Request(url, headers=HEADERS)
    with urllib.request.urlopen(request, timeout=60) as response:
        return response.read()


def api(path: str):
    return json.loads(get(API_ROOT + path))


def existing_manifest() -> dict:
    if not OUTPUT.exists():
        return {}
    data = json.loads(OUTPUT.read_text(encoding="utf-8"))
    if not isinstance(data, dict):
        raise RuntimeError("releases.json must contain an object")
    return data


def discover_repositories() -> list[str]:
    result: list[str] = []
    for page in range(1, 21):
        rows = api(f"/users/{OWNER}/repos?per_page=100&page={page}&type=public")
        if not isinstance(rows, list):
            raise RuntimeError("Unexpected GitHub repository response")
        for repo in rows:
            name = repo.get("name", "")
            if REPO_NAME.fullmatch(name) and not repo.get("fork", False) and not repo.get("archived", False):
                result.append(name)
        if len(rows) < 100:
            break
    return sorted(set(result))


def latest_verified_release(name: str) -> dict | None:
    try:
        release = api(f"/repos/{OWNER}/{name}/releases/latest")
    except urllib.error.HTTPError as error:
        if error.code == 404:
            return None
        raise

    if release.get("draft") or release.get("prerelease"):
        return None

    assets = release.get("assets", [])
    archives = [
        asset for asset in assets
        if ASSET_NAME.fullmatch(asset.get("name", ""))
        and ASSET_NAME.fullmatch(asset["name"]).group("name").lower() == name.lower()
    ]
    checksum_assets = [asset for asset in assets if asset.get("name") == "SHA256SUMS.txt"]
    if len(archives) != 1 or len(checksum_assets) != 1:
        return None

    checksums: dict[str, str] = {}
    checksum_text = get(checksum_assets[0]["browser_download_url"]).decode("utf-8", errors="strict")
    for raw_line in checksum_text.splitlines():
        match = CHECKSUM_LINE.fullmatch(raw_line.strip())
        if match:
            checksums[Path(match.group(2)).name] = match.group(1).lower()

    asset = archives[0]
    filename = asset["name"]
    digest = checksums.get(filename)
    if digest is None:
        return None

    sri = "sha256-" + base64.b64encode(bytes.fromhex(digest)).decode("ascii")
    return {
        "version": release["tag_name"],
        "url": asset["browser_download_url"],
        "hash": sri,
    }


def atomic_write(data: dict) -> None:
    text = json.dumps(data, indent=2, sort_keys=True) + "\n"
    with tempfile.NamedTemporaryFile(
        "w", encoding="utf-8", dir=ROOT, prefix=".releases-", delete=False
    ) as handle:
        handle.write(text)
        temporary = Path(handle.name)
    os.replace(temporary, OUTPUT)


def main() -> None:
    previous = existing_manifest()
    repositories = discover_repositories()
    if not repositories:
        raise RuntimeError("No official StoryTold Craft repositories discovered")

    updated: dict[str, dict] = {}
    skipped: list[str] = []
    for name in repositories:
        item = latest_verified_release(name)
        if item is None:
            skipped.append(name)
            print(f"SKIP {name}: no unique verified stable x86_64 Linux tarball")
            continue
        updated[name] = item
        print(f"PIN  {name} {item['version']}")

    missing_previous = sorted(set(previous) - set(updated))
    if missing_previous:
        raise RuntimeError(
            "Refusing partial manifest; previously pinned apps missing verified releases: "
            + ", ".join(missing_previous)
        )
    if not updated:
        raise RuntimeError("No verified official release archives found")

    atomic_write(updated)
    print(f"Pinned {len(updated)} official upstream apps in {OUTPUT}")
    if skipped:
        print("Repositories skipped safely: " + ", ".join(skipped))


if __name__ == "__main__":
    main()
