#!/bin/bash

set -e

# Usage: ./scripts/build.sh <testing|stable> <version> <escaped_changelog_lines>
# Example:
#   ./scripts/build.sh stable 2026.08.001 "added leios.theme.plasmoids.digitalclock version 1.0.2\\nadded leios.theme.grub-theme version 1.0.0"

if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <testing|stable> <version> [escaped_changelog_lines]"
  exit 1
fi

DIST="$1"
VERSION="$2"
CHANGELOG_LINES="${3:-}"

if [ "$DIST" != "testing" ] && [ "$DIST" != "stable" ]; then
  echo "Error: distribution must be 'testing' or 'stable'"
  exit 1
fi

rm -f debian/changelog

# Build the changelog body from the escaped input. Lines separated by \n become
# separate "  * <line>" changelog entries.
CHANGELOG_BODY=""
if [ -n "$CHANGELOG_LINES" ]; then
  # Interpret backslash escapes (e.g. \\n) and turn every resulting line into a
  # changelog bullet. Use a temporary file instead of process substitution for
  # better POSIX-shell compatibility.
  TMP_LINES=$(mktemp)
  trap 'rm -f "$TMP_LINES"' EXIT
  printf '%b' "$CHANGELOG_LINES" > "$TMP_LINES"
  while IFS= read -r line || [ -n "$line" ]; do
    CHANGELOG_BODY="${CHANGELOG_BODY}  * ${line}
"
  done < "$TMP_LINES"
else
  CHANGELOG_BODY="  * Rolling release ${VERSION}\n"
fi

# Write the temporary debian changelog
printf 'leios.system.branding-meta-files (%s) %s; urgency=medium\n\n%s -- LeiOS Project Team <support@leios.dev>  %s\n\n' \
  "$VERSION" "$DIST" "$CHANGELOG_BODY" "$(date -R)" > debian/changelog

# Update the version metadata file
echo "${VERSION}" > data/leios_version

# Generate a per-release changelog in data as well
printf 'leios.system.branding-meta-files (%s) %s; urgency=medium\n\n%s -- LeiOS Project Team <support@leios.dev>  %s\n' \
  "$VERSION" "$DIST" "$CHANGELOG_BODY" "$(date -R)" > data/changelog

# Build
dpkg-buildpackage -us -uc -b

# Cleanup temporary debian changelog only; keep data files
rm -f debian/changelog

