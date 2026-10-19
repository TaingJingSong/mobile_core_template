import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/mobile_core.dart' as cli;

void main() {
  test('minimal is default and input errors fail before writes', () {
    expect(cli.createOptions(['--name', 'my_app', '--output', '../my_app'])['preset'], 'minimal');
    for (final args in [
      ['--name', '../bad', '--output', '../app'],
      ['--name', 'my_app'],
      ['--name', 'my_app', '--output', '../app', '--preset', 'unknown'],
      ['--name', 'my_app', '--output', '../app', '--org', 'bad/path'],
      ['--name', 'my_app', '--output', '../app', '--force'],
    ]) {
      expect(() => cli.createOptions(args), throwsFormatException);
    }
  });

  test('renaming imports preserves SDK/package/relative ordering', () {
    expect(cli.sortImports("import '../local.dart';\nimport 'package:z/z.dart';\nimport 'dart:io';\n"), "import 'dart:io';\nimport 'package:z/z.dart';\nimport '../local.dart';\n");
  });

  test('existing destination cannot be replaced even in dry run', () async {
    final temp = Directory.systemTemp.createTempSync('generator-test-');
    addTearDown(() => temp.deleteSync(recursive: true));
    final sentinel = File('${temp.path}/custom.dart')..writeAsStringSync('app code');
    await expectLater(cli.createProject(['--name', 'my_app', '--output', temp.path, '--dry-run']), throwsStateError);
    expect(sentinel.readAsStringSync(), 'app code');
  });

  test('dry run creates no destination', () async {
    final temp = Directory.systemTemp.createTempSync('generator-test-');
    addTearDown(() => temp.deleteSync(recursive: true));
    final destination = '${temp.path}/new_app';
    await cli.createProject(['--name', 'my_app', '--output', destination, '--dry-run']);
    expect(Directory(destination).existsSync(), isFalse);
  });

  test('mandatory command failure propagates', () async {
    await expectLater(cli.run('sh', ['-c', 'exit 7'], Directory.current), throwsStateError);
  });

  test('module rerun refuses to replace app code', () async {
    final temp = Directory.systemTemp.createTempSync('module-test-');
    addTearDown(() => temp.deleteSync(recursive: true));
    File('${temp.path}/pubspec.yaml').writeAsStringSync('name: sample_app\n');
    Directory('${temp.path}/lib').createSync();
    File('${temp.path}/lib/register.dart').writeAsStringSync('');
    final script = '${Directory.current.path}/scripts/add_module.sh';
    expect((await Process.run('bash', [script, 'profile'], workingDirectory: temp.path)).exitCode, 0);
    final file = File('${temp.path}/lib/modules/profile/models/profile_model.dart')..writeAsStringSync('custom');
    expect((await Process.run('bash', [script, 'profile'], workingDirectory: temp.path)).exitCode, isNot(0));
    expect(file.readAsStringSync(), 'custom');
    expect((await Process.run('bash', [script, 'profile', '--force'], workingDirectory: temp.path)).exitCode, 0);
    final backup = Directory('${temp.path}/.module-backups').listSync().single.path;
    final restored = await Process.run('tar', ['-xOf', backup, 'profile/models/profile_model.dart']);
    expect(restored.exitCode, 0);
    expect(restored.stdout, 'custom');

    expect((await Process.run('bash', [script, 'profile', '--force'], workingDirectory: temp.path)).exitCode, 0);
    expect(file.readAsStringSync(), isNot('custom'));
  });
}
