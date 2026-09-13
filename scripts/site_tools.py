"""Generate the one-URL bootstrap, validate site files, and verify Pages freshness."""
from __future__ import annotations

import argparse
import json
import re
import time
from html.parser import HTMLParser
from pathlib import Path
from urllib.error import URLError
from urllib.parse import unquote, urljoin, urlsplit
from urllib.request import Request, urlopen


class Links(HTMLParser):
    def __init__(self) -> None:
        super().__init__()
        self.targets: list[str] = []

    def handle_starttag(self, tag, attrs):
        for key, value in attrs:
            if value and key in ('href', 'src'):
                self.targets.append(value)


def prepare(root: Path, sha: str, repository: str) -> None:
    if not re.fullmatch(r'[0-9a-f]{40}', sha):
        raise ValueError('Expected a full source commit SHA')
    if not re.fullmatch(r'[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+', repository):
        raise ValueError('Expected owner/repository')
    prompt = (root / 'PROMPT.md').read_text(encoding='utf-8')
    (root / 'docs' / 'PROMPT.md').write_text(prompt, encoding='utf-8')
    downloads = root / 'docs' / 'downloads'
    downloads.mkdir(exist_ok=True)
    (downloads / 'PROMPT.md').write_text(prompt, encoding='utf-8')
    marker = {'repository': repository, 'source_sha': sha}
    (root / 'docs' / 'build-info.json').write_text(json.dumps(marker, sort_keys=True) + '\n', encoding='utf-8')


def check_site(site: Path, base_url: str) -> list[str]:
    site = site.resolve()
    errors = []
    base = urlsplit(base_url.rstrip('/') + '/')
    required = ['index.html', 'PROMPT.html', 'downloads/PROMPT.md',
                'AMIT_AUTOMATION_CICD_LAB.html', 'search/search_index.json', 'build-info.json']
    for rel in required:
        if not (site / rel).is_file():
            errors.append(f'Missing site output: {rel}')
    for page in site.rglob('*.html'):
        parser = Links()
        parser.feed(page.read_text(encoding='utf-8'))
        page_url = urljoin(base_url.rstrip('/') + '/', page.relative_to(site).as_posix())
        for target in parser.targets:
            if target.startswith(('#', 'mailto:', 'tel:', 'data:', 'javascript:')):
                continue
            parts = urlsplit(urljoin(page_url, target))
            if parts.netloc != base.netloc or parts.scheme not in ('https', 'http'):
                continue
            if not parts.path.startswith(base.path):
                errors.append(f'{page.name}: link leaves project base path: {target}')
                continue
            rel = unquote(parts.path[len(base.path):])
            local = (site / rel).resolve()
            if not local.is_relative_to(site):
                errors.append(f'{page.name}: unsafe local link')
                continue
            if parts.path.endswith('/') or local.is_dir():
                local /= 'index.html'
            if not local.is_file():
                errors.append(f'{page.name}: missing local target: {target}')
    index = site / 'search/search_index.json'
    if index.exists():
        entries = json.loads(index.read_text(encoding='utf-8')).get('docs', [])
        if not entries or not any('PROMPT.html' in entry.get('location', '') for entry in entries):
            errors.append('Search index does not include the agent bootstrap')
    return sorted(set(errors))


def marker_matches(value: object, sha: str, repository: str) -> bool:
    return isinstance(value, dict) and value.get('source_sha') == sha and value.get('repository') == repository


def get(url: str) -> bytes:
    request = Request(url, headers={'User-Agent': 'chatgpt-aws-docs-check', 'Cache-Control': 'no-cache'})
    with urlopen(request, timeout=20) as response:
        return response.read()


def verify_live(base: str, sha: str, repository: str, attempts: int = 18, delay: int = 10) -> None:
    base = base.rstrip('/') + '/'
    for attempt in range(1, attempts + 1):
        try:
            marker_url = base + 'build-info.json?commit=' + sha
            marker = json.loads(get(marker_url))
            if not marker_matches(marker, sha, repository):
                raise ValueError('Site is reachable but serves a different commit')
            for path in ('', 'PROMPT.html', 'AMIT_AUTOMATION_CICD_LAB.html', 'downloads/PROMPT.md'):
                if not get(base + path + '?commit=' + sha):
                    raise ValueError('Empty live page')
            search = json.loads(get(base + 'search/search_index.json?commit=' + sha))
            if not any('PROMPT.html' in entry.get('location', '') for entry in search.get('docs', [])):
                raise ValueError('Live search index lacks PROMPT.html')
            if not marker_matches(json.loads(get(marker_url)), sha, repository):
                raise ValueError('Site changed during verification')
            print('PASS: live commit, bootstrap, custom HTML and search index')
            return
        except (URLError, ValueError, TimeoutError, OSError) as exc:
            print(f'Pages check {attempt}/{attempts}: {type(exc).__name__}')
            if attempt < attempts:
                time.sleep(delay)
    raise RuntimeError('Live Pages verification timed out; do not claim deployment verified')


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument('command', choices=['prepare', 'check', 'live'])
    parser.add_argument('--root', type=Path, default=Path('.'))
    parser.add_argument('--site', type=Path, default=Path('site'))
    parser.add_argument('--base-url', default='https://mytestlab123.github.io/chatgpt-aws/')
    parser.add_argument('--sha', default='')
    parser.add_argument('--repository', default='')
    args = parser.parse_args()
    if args.command == 'prepare':
        prepare(args.root, args.sha, args.repository)
    elif args.command == 'check':
        errors = check_site(args.site, args.base_url)
        print('\n'.join(errors) if errors else 'PASS: local links, required outputs and search index')
        return int(bool(errors))
    else:
        verify_live(args.base_url, args.sha, args.repository)
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
