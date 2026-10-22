#!/usr/bin/env python3
"""Discover upstream StoryTold Craft Linux release tarballs and pin their SHA256.

Does not execute downloads. Replaces releases.json atomically only if every
selected asset has an upstream SHA256SUMS.txt entry and a valid tar.gz filename.
No third-party packaging flake. The source of truth is upstream GitHub releases.
"""
import json
import os
from pathlib import Path
import re
import tempfile
import urllib.error
import urllib.request

ROOT = Path(__file__).resolve().parent
API = 'https://api.github.com'
HEADERS = {'User-Agent': 'local-artcraft-nix-updater', 'Accept': 'application/vnd.github+json'}


def get(url):
    request = urllib.request.Request(url, headers=HEADERS)
    with urllib.request.urlopen(request, timeout=35) as response:
        return response.read()


def api(path):
    return json.loads(get(API + path))


def app_repos():
    # Discover, do not hardcode the list of current Craft applications.
    # The upstream owner is fixed to prevent unrelated third-party sources.
    page = 1
    while True:
        rows = api(f'/users/storytold/repos?per_page=100&page={page}')
        if not isinstance(rows, list): raise RuntimeError('Unexpected GitHub API response')
        for repo in rows:
            name = repo.get('name', '')
            if re.fullmatch(r'[a-z][a-z0-9-]*craft', name) and not repo.get('fork', False):
                yield name
        if len(rows) < 100: break
        page += 1
        if page > 20: raise RuntimeError('GitHub repo pagination safety guard')


def find_release(name):
    try:
        release = api(f'/repos/storytold/{name}/releases/latest')
    except urllib.error.HTTPError as error:
        if error.code == 404: return None
        raise
    assets = release.get('assets', [])
    matches = [a for a in assets if re.fullmatch(
        rf'{re.escape(name)}-.*-linux-x86_64\.tar\.gz', a.get('name', ''), re.I)]
    if len(matches) != 1:
        # No reliable archive format; do not invent one.
        return None
    checksum_assets = [a for a in assets if a.get('name') == 'SHA256SUMS.txt']
    if len(checksum_assets) != 1: return None
    sums = get(checksum_assets[0]['browser_download_url']).decode('utf-8')
    expected = {}
    for line in sums.splitlines():
        match = re.fullmatch(r'([0-9a-fA-F]{64})\s+\*?(.+)', line.strip())
        if match: expected[Path(match.group(2)).name] = match.group(1).lower()
    asset = matches[0]
    if asset['name'] not in expected: return None
    digest = expected[asset['name']]
    return {'version': release['tag_name'], 'url': asset['browser_download_url'], 'hash': 'sha256-' + __import__('base64').b64encode(bytes.fromhex(digest)).decode('ascii')}


def main():
    found = {}
    names = sorted(set(app_repos()))
    if not names: raise RuntimeError('No upstream Craft repositories discovered; keeping existing manifest')
    for name in names:
        item = find_release(name)
        if item:
            found[name] = item
            print('PIN', name, item['version'])
        else:
            print('SKIP (no verified x86_64 Linux tar.gz)', name)
    if not found: raise RuntimeError('No verified release archives; keeping existing manifest')
    output = ROOT / 'releases.json'
    text = json.dumps(found, indent=2, sort_keys=True) + '\n'
    with tempfile.NamedTemporaryFile('w', dir=ROOT, prefix='.artcraft-', delete=False) as f:
        f.write(text)
        temporary = Path(f.name)
    os.replace(temporary, output)
    print('Pinned', len(found), 'upstream apps:', output)

if __name__ == '__main__':
    main()
