#!/usr/bin/env bash
#
# Initialize a new plugin from the ShiftWeb Plugin Starter.
#
# Usage:
#   ./scripts/init-plugin.sh "Plugin Name" [slug] [Namespace]
#
# Optional overrides via environment variables:
#   DESCRIPTION, AUTHOR, AUTHOR_URI, PLUGIN_URI
#
set -euo pipefail

NAME="${1:?Plugin name required. Usage: ./scripts/init-plugin.sh \"Plugin Name\"}"
SLUG="${2:-}"
NS="${3:-}"
DESCRIPTION="${DESCRIPTION:-A custom WordPress plugin by ShiftWeb.}"
AUTHOR="${AUTHOR:-ShiftWeb}"
AUTHOR_URI="${AUTHOR_URI:-https://shiftweb.com}"
PLUGIN_URI="${PLUGIN_URI:-https://shiftweb.com}"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

if [ -z "$SLUG" ]; then
	SLUG="$(printf '%s' "$NAME" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//')"
fi
if [ -z "$NS" ]; then
	# Drop a leading "shiftweb" word so a ShiftWeb-prefixed name gives
	# ShiftWeb\Core, not the redundant ShiftWeb\ShiftwebCore. Whole-word match,
	# so "shiftwebby-thing" is left alone.
	REST="$SLUG"
	case "$SLUG" in
		shiftweb) REST="" ;;
		shiftweb-*) REST="${SLUG#shiftweb-}" ;;
	esac
	if [ -n "$REST" ]; then
		STUDLY="$(printf '%s' "$REST" | sed -E 's/(^|-)([a-z])/\U\2/g')"
		NS="ShiftWeb\\${STUDLY}"
	else
		NS="ShiftWeb"
	fi
fi

PREFIX="$(printf '%s' "$SLUG" | tr '-' '_')"
CONSTANT="$(printf '%s' "$PREFIX" | tr '[:lower:]' '[:upper:]')"
NS_JSON="$(printf '%s' "$NS" | sed 's/\\/\\\\/g')"
YEAR="$(date +%Y)"

export NAME SLUG NS PREFIX CONSTANT NS_JSON YEAR DESCRIPTION AUTHOR AUTHOR_URI PLUGIN_URI

find "$ROOT" -type f \
	-not -path "*/.git/*" \
	-not -path "*/vendor/*" \
	-not -path "*/node_modules/*" \
	-not -path "*/scripts/*" \
	-not -name "README.md" \
	-not -name "*.png" -not -name "*.jpg" -not -name "*.jpeg" \
	-not -name "*.gif" -not -name "*.ico" \
	-print0 | while IFS= read -r -d '' file; do
	perl -0777 -pi -e '
		my %t = (
			"{{PLUGIN_NAMESPACE_JSON}}" => $ENV{NS_JSON},
			"{{PLUGIN_NAMESPACE}}"      => $ENV{NS},
			"{{PLUGIN_DESCRIPTION}}"    => $ENV{DESCRIPTION},
			"{{PLUGIN_AUTHOR_URI}}"     => $ENV{AUTHOR_URI},
			"{{PLUGIN_AUTHOR}}"         => $ENV{AUTHOR},
			"{{PLUGIN_CONSTANT}}"       => $ENV{CONSTANT},
			"{{PLUGIN_PREFIX}}"         => $ENV{PREFIX},
			"{{PLUGIN_NAME}}"           => $ENV{NAME},
			"{{PLUGIN_SLUG}}"           => $ENV{SLUG},
			"{{TEXT_DOMAIN}}"           => $ENV{SLUG},
			"{{PLUGIN_URI}}"            => $ENV{PLUGIN_URI},
			"{{YEAR}}"                  => $ENV{YEAR},
		);
		for my $k ( sort { length($b) <=> length($a) } keys %t ) {
			my $q = quotemeta($k);
			s/$q/$t{$k}/g;
		}
	' "$file"
done

mv "$ROOT/plugin-name.php" "$ROOT/${SLUG}.php"

echo ""
echo "Initialized: $NAME"
echo "  Slug:      $SLUG"
echo "  Namespace: $NS"
echo "  Main file: ${SLUG}.php"
echo ""
echo "Next: composer install, then fill out INTAKE.md."
echo "To ship a release, run ./scripts/build-zip.sh (outputs to /dist)."
echo "You can delete README.md and scripts/init-plugin.* once you are set up."
