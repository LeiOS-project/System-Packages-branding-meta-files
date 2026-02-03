#!/bin/bash

set -e

# check if version argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <version>"
  exit 1
fi

rm -f debian/changelog

# Create a temporary changelog with the version you want
cat > debian/changelog <<EOF
leios-branding-meta-files ($1) stable; urgency=medium

  * Build for version $1

 -- Linus Fischer <leicraft@leicraftmc.de>  $(date -R)

EOF

# Build
INSERT_LEIOS_RELEASE=$(echo $1) dpkg-buildpackage -us -uc

# Cleanup
rm -f debian/changelog

mkdir -p ./build/
mv ../leios-branding-meta-files_* ./build/