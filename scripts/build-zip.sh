#!/usr/bin/env bash
#
# Build a production-ready plugin zip in /dist.
#
# Copies the plugin to a staging folder, installs runtime-only Composer
# dependencies (which also generates the autoloader the plugin needs for its own
# classes), strips development files, and packages the result as
# dist/<slug>-<version>.zip with the slug as the top-level folder, ready to
# upload via Plugins > Add New > Upload Plugin.
#
# Run "composer check" first so you never ship a failing build.
#
# Usage:
#   ./scripts/build-zip.sh [slug]
#
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SLUG="${1:-}"

# Locate the main plugin file (the root .php that carries the plugin header).
if [ -z "$SLUG" ]; then
	MAIN="$(grep -l "Plugin Name:" "$ROOT"/*.php 2>/dev/null | head -1 || true)"
	if [ -z "$MAIN" ]; then
		echo "Could not find the main plugin file. Run the init script first, or pass a slug." >&2
		exit 1
	fi
	SLUG="$(basename "$MAIN" .php)"
else
	MAIN="$ROOT/$SLUG.php"
fi

VERSION="$(grep -m1 -i "Version:" "$MAIN" | sed -E 's/.*Version:[[:space:]]*//' | tr -d '\r' | xargs || true)"
VERSION="${VERSION:-0.0.0}"

echo "Building $SLUG $VERSION..."

BUILD="$ROOT/build"
STAGING="$BUILD/$SLUG"
rm -rf "$BUILD"
mkdir -p "$STAGING"

# Files and folders that never ship to production.
EXCLUDE=(.git .github .claude node_modules vendor tests scripts build dist \
	.gitignore .gitattributes .editorconfig CLAUDE.md INTAKE.md README.md \
	phpcs.xml.dist phpstan.neon.dist phpunit.xml.dist)

shopt -s dotglob
for item in "$ROOT"/*; do
	name="$(basename "$item")"
	skip=false
	for e in "${EXCLUDE[@]}"; do
		if [ "$name" = "$e" ]; then
			skip=true
			break
		fi
	done
	if [ "$skip" = false ]; then
		cp -r "$item" "$STAGING/"
	fi
done
shopt -u dotglob

# Install runtime dependencies and build the optimized autoloader.
( cd "$STAGING" && composer install --no-dev --optimize-autoloader --no-interaction --no-progress )

# composer files are only needed for the build, not at runtime.
rm -f "$STAGING/composer.json" "$STAGING/composer.lock"

# Zip from the build root so the archive keeps the <slug>/ folder at its root.
mkdir -p "$ROOT/dist"
ZIP="$ROOT/dist/$SLUG-$VERSION.zip"
rm -f "$ZIP"
( cd "$BUILD" && zip -rq "$ZIP" "$SLUG" )

rm -rf "$BUILD"

echo ""
echo "Built: dist/$SLUG-$VERSION.zip"
echo "Upload it via Plugins > Add New > Upload Plugin."
