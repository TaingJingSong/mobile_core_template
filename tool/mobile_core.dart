import 'dart:convert';
import 'dart:io';

const help = '''Mobile Core (Flutter 3.44.3 / Dart 3.12.2)
  dart tool/mobile_core.dart create --name my_app --org com.acme --output ../my_app [--preset minimal|standard|enterprise] [--dry-run]
  dart /path/to/template/tool/mobile_core.dart feature list
  dart /path/to/template/tool/mobile_core.dart feature add|remove firebase|networking_dio [--dry-run]
  dart /path/to/template/tool/mobile_core.dart module add profile [--force]
  dart /path/to/template/tool/mobile_core.dart doctor|verify
Run feature/module/doctor/verify commands from the generated app root.
Creation always formats, analyzes, and tests before reporting success.
''';

final templateRoot = File.fromUri(Platform.script).parent.parent;
const manifestName = '.mobile-core.json';

Future<void> main(List<String> args) async {
  try {
    if (args.isEmpty || args.contains('--help') || args.contains('-h')) {
      stdout.write(help);
      return;
    }
    switch (args.first) {
      case 'create':
        await createProject(args.sublist(1));
      case 'feature':
        await featureCommand(args.sublist(1));
      case 'module':
        if (args.length < 3 || args.length > 4 || args[1] != 'add' || (args.length == 4 && args[3] != '--force')) {
          throw const FormatException('Use module add <name> [--force].');
        }
        await run('bash', ['${templateRoot.path}/scripts/add_module.sh', ...args.sublist(2)], Directory.current);
      case 'doctor':
        if (args.length != 1) throw const FormatException('doctor takes no options.');
        final manifest = readManifest();
        stdout.writeln('Preset: ${manifest['preset']}; template: ${manifest['templateVersion']}');
        await run('flutter', ['doctor', '-v'], Directory.current);
        for (final name in (manifest['features'] as Map<String, dynamic>).keys) {
          stdout.writeln('$name: ${featureMetadata(name)['requirements']}');
        }
      case 'verify':
        if (args.length != 1) throw const FormatException('verify takes no options.');
        await verify(Directory.current);
      default:
        throw FormatException('Unknown command: ${args.first}');
    }
  } on FormatException catch (error) {
    stderr.writeln('${error.message}\n$help');
    exitCode = 64;
  } catch (error) {
    stderr.writeln(error);
    exitCode = 1;
  }
}

Future<void> run(String executable, List<String> args, Directory directory) async {
  final process = await Process.start(executable, args, workingDirectory: directory.path, mode: ProcessStartMode.inheritStdio);
  final code = await process.exitCode;
  if (code != 0) throw StateError('$executable ${args.join(' ')} failed ($code). Project is not verified.');
}

Future<void> verify(Directory directory) async {
  await run('flutter', ['pub', 'get'], directory);
  await run('dart', ['format', '--output=none', '--set-exit-if-changed', 'lib', 'test'], directory);
  await run('flutter', ['analyze', '--fatal-infos'], directory);
  await run('flutter', ['test'], directory);
}

Map<String, String> createOptions(List<String> args) {
  final result = <String, String>{'preset': 'minimal', 'org': 'com.example'};
  const allowed = ['name', 'org', 'output', 'preset'];
  for (var i = 0; i < args.length; i++) {
    final key = args[i];
    if (key == '--dry-run') {
      result['dry-run'] = 'true';
    } else if (key.startsWith('--') && allowed.contains(key.substring(2)) && i + 1 < args.length && !args[i + 1].startsWith('--')) {
      result[key.substring(2)] = args[++i];
    } else {
      throw FormatException('Invalid option: $key');
    }
  }
  final name = result['name'] ?? '';
  if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(name) || ['app_base', 'flutter', 'dart', 'test'].contains(name)) {
    throw const FormatException('Choose a valid, non-reserved snake_case project name.');
  }
  if (!RegExp(r'^[a-z][a-z0-9]*(\.[a-z][a-z0-9]*)+$').hasMatch(result['org']!)) throw const FormatException('Invalid organization identifier.');
  if (!['minimal', 'standard', 'enterprise'].contains(result['preset'])) throw const FormatException('Unknown preset.');
  if (result['output'] == null || result['output']!.isEmpty) throw const FormatException('--output is required; existing destinations are refused.');
  return result;
}

Future<void> createProject(List<String> args) async {
  final options = createOptions(args);
  final destination = Directory(options['output']!).absolute;
  if (FileSystemEntity.typeSync(destination.path, followLinks: false) != FileSystemEntityType.notFound) {
    throw StateError('Destination already exists: ${destination.path}. Choose a new directory.');
  }
  if (!destination.parent.existsSync()) throw StateError('Destination parent must already exist.');
  final name = options['name']!;
  final preset = options['preset']!;
  stdout.writeln('Create $preset app $name in ${destination.path}; no existing app files will be replaced.');
  if (options['dry-run'] == 'true') return;
  // Stage alongside the destination: failures never leave a half-created destination.
  final staging = destination.parent.createTempSync('.mobile-core-');
  try {
    await run('flutter', ['create', '--no-pub', '--empty', '--platforms', 'android,ios', '--org', options['org']!, '--project-name', name, staging.path], templateRoot);
    if (preset == 'minimal') {
      copyTemplates(Directory('${templateRoot.path}/tool/templates/presets/minimal'), staging, name);
    } else {
      copyTree(Directory('${templateRoot.path}/lib'), Directory('${staging.path}/lib'), name);
      copyFile(File('${templateRoot.path}/pubspec.yaml'), File('${staging.path}/pubspec.yaml'), name);
      copyFile(File('${templateRoot.path}/test/widget_test.dart'), File('${staging.path}/test/widget_test.dart'), name);
      copyTree(Directory('${templateRoot.path}/test/unit'), Directory('${staging.path}/test/unit'), name);
      if (preset == 'standard') {
        for (final env in ['dev', 'qas', 'pre']) {
          File('${staging.path}/lib/main_$env.dart').deleteSync();
        }
      }
    }
    copyFile(File('${templateRoot.path}/analysis_options.yaml'), File('${staging.path}/analysis_options.yaml'), name);
    copyFile(File('${templateRoot.path}/.fvmrc'), File('${staging.path}/.fvmrc'), name);
    // Use the same release-signing policy in generated Android projects.
    final gradle = File('${templateRoot.path}/android/app/build.gradle.kts').readAsStringSync();
    File('${staging.path}/android/app/build.gradle.kts').writeAsStringSync(gradle.replaceAll('com.example.mobile_core_template', '${options['org']}.$name'));
    if (preset == 'enterprise') {
      for (final workflow in ['ci.yml', 'release.yml', 'build_all_flavors.yml']) {
        final source = File('${templateRoot.path}/.github/workflows/$workflow');
        if (source.existsSync()) copyFile(source, File('${staging.path}/.github/workflows/$workflow'), name);
      }
    }
    writeJson(File('${staging.path}/$manifestName'), {
      'schema': 1,
      'name': name,
      'preset': preset,
      'templateVersion': File('${templateRoot.path}/.template-version').readAsStringSync().trim(),
      'features': <String, dynamic>{},
    });
    File('${staging.path}/README.md').writeAsStringSync('''# $name

Generated with mobile_core_template ($preset). Flutter 3.44.3 / Dart 3.12.2.
Run `flutter run`. No Firebase or API configuration is required for the starter.
For networking set `--dart-define=API_BASE_URL=https://your-real-api-host`.
Use the source template's `tool/mobile_core.dart` to add features or verify.
Commit changes before installing/removing features. Native Firebase setup is app-owned.
Source upgrades use reviewed Git diffs; generated apps are not enrolled in sealed-file sync.
Release signing requires android/key.properties; never commit keys or credentials.
''');
    await run('flutter', ['pub', 'get'], staging);
    await run('dart', ['format', 'lib', 'test'], staging);
    await verify(staging);
    if (destination.existsSync()) throw StateError('Destination appeared during generation; refusing to replace it.');
    staging.renameSync(destination.path);
    stdout.writeln('Created and verified ${destination.path}');
  } finally {
    if (staging.existsSync()) staging.deleteSync(recursive: true);
  }
}

String sortImports(String source) => source.replaceAllMapped(RegExp(r'(?:^import [^\n]+;\n)+', multiLine: true), (match) {
  final lines = match[0]!.trimRight().split('\n');
  int rank(String line) => line.contains("'dart:")
      ? 0
      : line.contains("'package:")
      ? 1
      : 2;
  lines.sort((a, b) {
    final order = rank(a).compareTo(rank(b));
    return order == 0 ? a.compareTo(b) : order;
  });
  return '${lines.join('\n')}\n';
});

void copyFile(File source, File destination, String name) {
  destination.parent.createSync(recursive: true);
  var content = source.readAsStringSync().replaceAll('package:app_base/', 'package:$name/').replaceAll('name: app_base\n', 'name: $name\n').replaceAll('{{name}}', name);
  if (destination.path.endsWith('.dart')) {
    content = sortImports(content);
  }
  destination.writeAsStringSync(content);
}

void copyTree(Directory source, Directory destination, String name) {
  for (final entity in source.listSync(recursive: true, followLinks: false)) {
    if (entity is Link) throw StateError('Template symlinks are not supported: ${entity.path}');
    if (entity is File) copyFile(entity, File('${destination.path}/${entity.path.substring(source.path.length + 1)}'), name);
  }
}

Map<String, String> renderedTemplates(Directory source, String name) {
  final files = <String, String>{};
  for (final entity in source.listSync(recursive: true, followLinks: false)) {
    if (entity is Link) throw StateError('Template symlinks are not supported.');
    if (entity is File && entity.path.endsWith('.tmpl')) {
      final relative = entity.path.substring(source.path.length + 1, entity.path.length - 5);
      var content = entity.readAsStringSync().replaceAll('{{name}}', name);
      if (relative.endsWith('.dart')) {
        content = sortImports(content);
      }
      files[relative] = content;
    }
  }
  return files;
}

void copyTemplates(Directory source, Directory destination, String name) {
  for (final entry in renderedTemplates(source, name).entries) {
    final file = File('${destination.path}/${entry.key}');
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(entry.value);
  }
}

void writeJson(File file, Map<String, dynamic> value) {
  file.writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(value)}\n');
}

Map<String, dynamic> readManifest() {
  final result = jsonDecode(File(manifestName).readAsStringSync()) as Map<String, dynamic>;
  if (result['schema'] != 1) throw StateError('Unsupported project manifest.');
  return result;
}

const featureNames = ['firebase', 'networking_dio'];
Map<String, dynamic> featureMetadata(String name) {
  if (!featureNames.contains(name)) throw FormatException('Unsupported feature: $name');
  return jsonDecode(File('${templateRoot.path}/tool/templates/features/$name/feature.json').readAsStringSync()) as Map<String, dynamic>;
}

String integrationSource(Iterable<String> names) {
  final imports = <String>[];
  final tasks = <String>[];
  for (final name in names) {
    final meta = featureMetadata(name);
    if (meta['import'] != '') imports.add("import '${meta['import']}';");
    if (meta['initialize'] != '') tasks.add('  ${meta['initialize']}');
  }
  return '// Managed by tool/mobile_core.dart. Put application startup tasks in bootstrap.\n'
      '${imports.join('\n')}${imports.isEmpty ? '' : '\n\n'}'
      'Future<void> initializeIntegrations() async {${tasks.isEmpty ? '' : '\n${tasks.join('\n')}\n'}}\n';
}

File projectFile(String path) {
  if (path.startsWith('/') || path.split('/').any((part) => part == '..' || part == '.git')) throw StateError('Unsafe managed path.');
  final file = File(path).absolute;
  FileSystemEntity entity = file;
  while (entity.path != Directory.current.absolute.path) {
    if (FileSystemEntity.isLinkSync(entity.path)) throw StateError('Refusing managed symlink: $path');
    final parent = entity.parent;
    if (parent.path == entity.path) throw StateError('Managed path escapes project.');
    entity = parent;
  }
  return file;
}

Future<void> featureCommand(List<String> args) async {
  if (args.length == 1 && args.first == 'list') {
    for (final name in featureNames) {
      stdout.writeln('$name: ${featureMetadata(name)['requirements']}');
    }
    return;
  }
  if (args.length < 2 || args.length > 3 || !['add', 'remove'].contains(args[0]) || (args.length == 3 && args[2] != '--dry-run')) {
    throw const FormatException('Use feature list or feature add|remove <name> [--dry-run].');
  }
  final name = args[1];
  final metadata = featureMetadata(name);
  final manifest = readManifest();
  final features = manifest['features'] as Map<String, dynamic>;
  final adding = args[0] == 'add';
  if (features.containsKey(name) == adding) {
    stdout.writeln('$name is already ${adding ? 'installed' : 'absent'}.');
    return;
  }
  if (name == 'networking_dio' && manifest['preset'] != 'minimal') throw StateError('Networking is already part of the standard/enterprise preset.');
  final packages = ((adding ? metadata['packages'] : (features[name] as Map<String, dynamic>)['packages']) as List<dynamic>).cast<String>();
  final files = adding
      ? renderedTemplates(Directory('${templateRoot.path}/tool/templates/features/$name'), manifest['name'] as String)
      : (features[name] as Map<String, dynamic>)['files'] as Map<String, dynamic>;
  const hooks = 'lib/app/integrations.dart';
  final hookFile = projectFile(hooks);
  // Compare formatted source, so normal formatting is not mistaken for customization.
  final expectedHook = features.isEmpty ? integrationSource([]) : manifest['integrationSource'] as String;
  if (hookFile.readAsStringSync() != expectedHook) throw StateError('Startup hooks were customized. Preserve them manually before changing features.');
  for (final entry in files.entries) {
    final file = projectFile(entry.key);
    if (adding ? file.existsSync() : (!file.existsSync() || file.readAsStringSync() != entry.value)) {
      throw StateError('Refusing to ${adding ? 'overwrite' : 'remove modified'} ${entry.key}');
    }
  }
  final pubspec = projectFile('pubspec.yaml');
  if (adding) {
    for (final package in packages) {
      if (RegExp('^  ${package.split(':').first}:', multiLine: true).hasMatch(pubspec.readAsStringSync())) {
        throw StateError('Dependency ${package.split(':').first} is already app-owned. Integrate manually.');
      }
    }
  }
  stdout.writeln('${args[0]} $name: ${files.keys.join(', ')}; packages: ${packages.join(', ')}');
  stdout.writeln(metadata['requirements']);
  if (args.contains('--dry-run')) return;
  final git = await Process.run('git', ['status', '--porcelain'], workingDirectory: Directory.current.path);
  if (git.exitCode != 0 || (git.stdout as String).trim().isNotEmpty) throw StateError('Commit the project in a clean Git working tree before changing features.');
  final snapshots = <String, List<int>?>{};
  for (final path in ['pubspec.yaml', 'pubspec.lock', manifestName, hooks, ...files.keys]) {
    final file = projectFile(path);
    snapshots[path] = file.existsSync() ? file.readAsBytesSync() : null;
  }
  try {
    if (adding) {
      for (final entry in files.entries) {
        final file = projectFile(entry.key);
        file.parent.createSync(recursive: true);
        file.writeAsStringSync(entry.value as String);
      }
      features[name] = {'files': files, 'packages': packages};
    } else {
      for (final path in files.keys) {
        projectFile(path).deleteSync();
      }
      features.remove(name);
    }
    hookFile.writeAsStringSync(integrationSource(features.keys));
    await run('flutter', ['pub', adding ? 'add' : 'remove', ...packages.map((package) => adding ? package : package.split(':').first)], Directory.current);
    await run('dart', ['format', hooks, ...files.keys.where((path) => adding && path.endsWith('.dart'))], Directory.current);
    await verify(Directory.current);
    if (adding) {
      features[name] = {
        'files': {for (final path in files.keys) path: projectFile(path).readAsStringSync()},
        'packages': packages,
      };
    }
    manifest['integrationSource'] = hookFile.readAsStringSync();
    writeJson(projectFile(manifestName), manifest);
  } catch (_) {
    for (final entry in snapshots.entries) {
      final file = projectFile(entry.key);
      if (entry.value == null) {
        if (file.existsSync()) file.deleteSync();
      } else {
        file.parent.createSync(recursive: true);
        file.writeAsBytesSync(entry.value!);
      }
    }
    stderr.writeln('Source, dependency files, and manifest restored. Run flutter pub get to refresh generated plugin metadata.');
    rethrow;
  }
  stdout.writeln('$name ${adding ? 'installed' : 'removed'} and verified. Review git diff. Native configuration remains app-owned.');
}
