#!/usr/bin/env bash
# Usage: ./scripts/add_module.sh <module_name>
# Scaffolds a new feature module with clean Model, Repository, ViewModel, and View.
set -euo pipefail

MODULE="${1:-}"
[[ -n "$MODULE" ]] || { echo "Usage: $0 <module_name>"; exit 1; }
[[ "$MODULE" =~ ^[a-z][a-z0-9_]*$ ]] || { echo "Module name must be snake_case (e.g. auth, user_profile)."; exit 1; }

FORCE="${2:-}"
[[ $# -le 2 && ( -z "$FORCE" || "$FORCE" == "--force" ) ]] || { echo "Usage: $0 <module_name> [--force]" >&2; exit 1; }

# Determine the project package name from pubspec.yaml
if [[ -f "pubspec.yaml" ]]; then
  PKG_NAME="$(grep -E '^name:[[:space:]]*' pubspec.yaml | head -n1 | awk '{print $2}')"
else
  PKG_NAME="app_base"
fi

# Convert snake_case module name to PascalCase (portable across bash 3.2 / macOS / Linux)
PASCAL_NAME="$(perl -e 'print join("", map { ucfirst } split(/_/, $ARGV[0]))' "$MODULE")"

[[ ! -L lib && ! -L lib/modules ]] || { echo "Refusing symlinked module parent." >&2; exit 1; }
BASE="lib/modules/$MODULE"
[[ -f pubspec.yaml && -f lib/register.dart ]] || { echo "Run in a standard or enterprise project root." >&2; exit 1; }
if [[ -e "$BASE" || -L "$BASE" ]]; then
  if [[ "$FORCE" == "--force" ]]; then
    mkdir -p .module-backups
    [[ ! -L .module-backups ]] || { echo "Refusing symlinked backup directory." >&2; exit 1; }
    BACKUP="$(mktemp ".module-backups/${MODULE}.XXXXXX")"
    tar -czf "$BACKUP" -C lib/modules "$MODULE"
    echo "Existing module backed up to $BACKUP"
    rm -rf "$BASE"
  else
    echo "Refusing to overwrite existing module: $BASE (pass --force to overwrite)" >&2
    exit 1
  fi
fi
mkdir -p "$BASE/models" "$BASE/repository" "$BASE/view_models" "$BASE/views"

# Module barrel export
cat > "$BASE/$MODULE.dart" <<EOF
export 'models/${MODULE}_model.dart';
export 'repository/${MODULE}_repository.dart';
export 'view_models/${MODULE}_view_model.dart';
export 'views/${MODULE}_view.dart';
EOF

# Model
cat > "$BASE/models/${MODULE}_model.dart" <<EOF
class ${PASCAL_NAME}Model {
  const ${PASCAL_NAME}Model();
}
EOF

# Repository
cat > "$BASE/repository/${MODULE}_repository.dart" <<EOF
abstract class ${PASCAL_NAME}Repository {
  // TODO: define ${PASCAL_NAME} repository interface
}

class ${PASCAL_NAME}RepositoryImpl implements ${PASCAL_NAME}Repository {
  const ${PASCAL_NAME}RepositoryImpl();
}
EOF

# ViewModel
cat > "$BASE/view_models/${MODULE}_view_model.dart" <<EOF
import 'package:${PKG_NAME}/register.dart';

import '../repository/${MODULE}_repository.dart';

class ${PASCAL_NAME}ViewModel extends CoreViewModel {
  ${PASCAL_NAME}ViewModel(this._repo);
  // ignore: unused_field
  final ${PASCAL_NAME}Repository _repo;
}
EOF

# View
cat > "$BASE/views/${MODULE}_view.dart" <<EOF
import 'package:${PKG_NAME}/register.dart';

import '../repository/${MODULE}_repository.dart';
import '../view_models/${MODULE}_view_model.dart';

class ${PASCAL_NAME}View extends StatelessWidget {
  const ${PASCAL_NAME}View({super.key});

  @override
  Widget build(BuildContext context) {
    return CoreView<${PASCAL_NAME}ViewModel>(
      model: ${PASCAL_NAME}ViewModel(locator<${PASCAL_NAME}Repository>()),
      builder: (context, vm, _) => Scaffold(
        appBar: AppBar(title: const Text('${PASCAL_NAME}')),
        body: const SizedBox.shrink(),
      ),
    );
  }
}
EOF

echo "✓ Created lib/modules/$MODULE/"
find "$BASE" -type f | sort

printf 'Register %sRepository in lib/app/di/register_app.dart and add its route in lib/routes/app_router.dart.\n' "$PASCAL_NAME"
