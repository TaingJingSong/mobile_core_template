import contextlib
import importlib.util
import io
import json
from pathlib import Path
import tempfile
import unittest

spec = importlib.util.spec_from_file_location('sync', Path(__file__).parents[1] / 'sync_template.py')
sync = importlib.util.module_from_spec(spec)
spec.loader.exec_module(sync)


class SyncTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.local = Path(self.temp.name) / 'local'
        self.upstream = Path(self.temp.name) / 'upstream'
        for root in (self.local, self.upstream):
            (root / 'lib/core').mkdir(parents=True)
            (root / 'pubspec.yaml').write_text('name: app_base\n')
            (root / '.template-sealed').write_text('lib/core/\n')
            (root / '.template-version').write_text('2.0.0')
            for name in ('a.dart', 'b.dart'):
                (root / 'lib/core' / name).write_text('old\n')
        (self.local / '.template').mkdir()
        self.manifest = self.local / '.template/manifest.json'
        self.manifest.write_text(json.dumps({'version': '1.0.0', 'files': {
            'lib/core/a.dart': sync.digest(b'old\n'), 'lib/core/b.dart': sync.digest(b'old\n')}}))
        self.baseline = self.manifest.read_bytes()
        (self.upstream / 'lib/core/a.dart').write_text('new\n')
        (self.upstream / 'lib/core/b.dart').write_text('new\n')

    def run_sync(self, apply=True):
        with contextlib.redirect_stdout(io.StringIO()):
            sync.sync(self.local, self.upstream, apply)

    def test_repeated_conflict_preserves_entire_tree_and_baseline(self):
        (self.local / 'lib/core/b.dart').write_text('custom\n')
        for _ in range(2):
            with self.assertRaisesRegex(ValueError, 'Conflicts'):
                self.run_sync()
            self.assertEqual(self.manifest.read_bytes(), self.baseline)
            self.assertEqual((self.local / 'lib/core/a.dart').read_text(), 'old\n')
            self.assertEqual((self.local / 'lib/core/b.dart').read_text(), 'custom\n')

    def test_preview_never_writes_and_apply_is_idempotent(self):
        self.run_sync(False)
        self.assertEqual(self.manifest.read_bytes(), self.baseline)
        self.assertEqual((self.local / 'lib/core/a.dart').read_text(), 'old\n')
        self.run_sync()
        self.run_sync()
        self.assertEqual((self.local / 'lib/core/a.dart').read_text(), 'new\n')
        self.assertEqual(json.loads(self.manifest.read_text())['version'], '2.0.0')

    def test_local_deletion_is_a_conflict(self):
        (self.local / 'lib/core/a.dart').unlink()
        with self.assertRaisesRegex(ValueError, 'Conflicts'):
            self.run_sync()

    def test_untracked_collision_is_a_conflict(self):
        for root in (self.local, self.upstream):
            (root / 'lib/core/new.dart').write_text(str(root))
        with self.assertRaisesRegex(ValueError, 'Conflicts'):
            self.run_sync()

    def test_unchanged_upstream_deletion_is_applied(self):
        (self.upstream / 'lib/core/a.dart').unlink()
        self.run_sync()
        self.assertFalse((self.local / 'lib/core/a.dart').exists())

    def test_symlinks_and_traversal_are_rejected(self):
        (self.local / 'lib/core/a.dart').unlink()
        (self.local / 'lib/core/a.dart').symlink_to(self.upstream / 'lib/core/a.dart')
        with self.assertRaisesRegex(ValueError, 'symlink'):
            self.run_sync()
        with self.assertRaises(ValueError):
            sync.safe_path(self.local, '../outside')


if __name__ == '__main__':
    unittest.main()
