#!/usr/bin/env python3
"""Preview reviewed source upgrades; never execute code from the fetched repository."""
import argparse
import difflib
import hashlib
import json
import os
from pathlib import Path, PurePosixPath
import subprocess
import tempfile

DEFAULT_REPO = 'https://github.com/TaingJingSong/mobile_core_template.git'


def digest(data):
    return hashlib.sha256(data).hexdigest()


def safe_path(root, name):
    parts = PurePosixPath(name).parts
    if not parts or name.startswith('/') or '..' in parts or parts[0] == '.git':
        raise ValueError(f'Unsafe template path: {name}')
    target = root / name
    for parent in (target, *target.parents):
        if parent == root:
            break
        if parent.is_symlink():
            raise ValueError(f'Refusing symlink: {name}')
    if not target.resolve().is_relative_to(root.resolve()):
        raise ValueError(f'Path escapes project: {name}')
    return target


def sealed_files(root):
    files = {}
    for line in (root / '.template-sealed').read_text().splitlines():
        name = line.strip()
        if not name or name.startswith('#'):
            continue
        # Updates cannot claim app composition, credentials, or Git internals.
        if not (name.startswith('lib/core/') or name.startswith('scripts/') or name.startswith('tool/') or name == 'NEW_PROJECT.md'):
            raise ValueError(f'Unsupported sealed path: {name}')
        source = safe_path(root, name)
        entries = sorted(source.rglob('*')) if source.is_dir() else [source]
        for entry in entries:
            rel = entry.relative_to(root).as_posix()
            safe_path(root, rel)
            if entry.is_file():
                files[rel] = entry.read_bytes()
    return files


def package_name(root):
    for line in (root / 'pubspec.yaml').read_text().splitlines():
        if line.startswith('name:'):
            name = line.split(':', 1)[1].strip()
            if not name.replace('_', '').isalnum():
                raise ValueError('Invalid package name')
            return name
    raise ValueError('Missing pubspec name')


def sync(local, upstream, apply=False):
    manifest_path = local / '.template/manifest.json'
    safe_path(local, '.template/manifest.json')
    previous = json.loads(manifest_path.read_text())
    incoming = sealed_files(upstream)
    source_pkg, target_pkg = package_name(upstream), package_name(local)
    for name, data in incoming.items():
        if name.endswith('.dart'):
            incoming[name] = data.replace(f'package:{source_pkg}/'.encode(), f'package:{target_pkg}/'.encode())
    changes, conflicts = {}, []
    for name in sorted(set(previous['files']) | set(incoming)):
        target = safe_path(local, name)
        if target.exists() and not target.is_file():
            raise ValueError(f'Expected a regular file: {name}')
        current = target.read_bytes() if target.is_file() else None
        new = incoming.get(name)
        old_hash = previous['files'].get(name)
        if current == new:
            continue
        # A local deletion or collision with an untracked file is also a conflict.
        if (old_hash is None and current is not None) or (old_hash is not None and (current is None or digest(current) != old_hash)):
            conflicts.append(name)
        changes[name] = (current, new)
        before = (current or b'').decode('utf-8', errors='replace').splitlines(True)
        after = (new or b'').decode('utf-8', errors='replace').splitlines(True)
        print(''.join(difflib.unified_diff(before, after, fromfile=f'a/{name}', tofile=f'b/{name}')), end='')
    if conflicts:
        raise ValueError('Conflicts; no files or baseline changed: ' + ', '.join(conflicts))
    if not apply:
        print(f'Preview: {len(changes)} change(s). Use --apply after reviewing the diff.')
        return
    # Preflight every path before any writes. On ordinary I/O errors, restore originals.
    original_manifest = manifest_path.read_bytes()
    try:
        for name, (_, new) in changes.items():
            target = local / name
            if new is None:
                target.unlink()
            else:
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes(new)
        manifest = {'version': (upstream / '.template-version').read_text().strip(),
                    'files': {name: digest(data) for name, data in incoming.items()}}
        staging = manifest_path.with_suffix('.json.tmp')
        safe_path(local, '.template/manifest.json.tmp')
        staging.write_text(json.dumps(manifest, indent=2) + '\n')
        staging.replace(manifest_path)
    except BaseException:
        for name, (old, _) in changes.items():
            target = local / name
            if old is None:
                target.unlink(missing_ok=True)
            else:
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes(old)
        manifest_path.write_bytes(original_manifest)
        raise
    print(f'Applied {len(changes)} change(s). Run verification and review git diff before committing.')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('ref', nargs='?', help='tag or branch (default: repository default branch)')
    modes = parser.add_mutually_exclusive_group()
    modes.add_argument('--apply', action='store_true')
    modes.add_argument('--check', '--dry-run', action='store_true')
    args = parser.parse_args()
    repo = os.environ.get('TEMPLATE_REPO') or DEFAULT_REPO
    if repo.startswith('-') or not (repo.startswith(('https://', 'ssh://', 'git@')) or Path(repo).is_dir()):
        parser.error('TEMPLATE_REPO must be an HTTPS/SSH repository URL or an existing local repository')
    if args.ref and args.ref.startswith('-'):
        parser.error('Invalid ref')
    try:
        with tempfile.TemporaryDirectory(prefix='mobile-core-sync-') as temp:
            upstream = Path(temp) / 'upstream'
            command = ['git', 'clone', '--quiet', '--depth', '1']
            if args.ref:
                command += ['--branch', args.ref]
            subprocess.run([*command, '--', repo, str(upstream)], check=True)
            sync(Path.cwd(), upstream, args.apply)
    except (ValueError, OSError, subprocess.CalledProcessError) as error:
        parser.exit(1, f'{error}\n')


if __name__ == '__main__':
    main()
