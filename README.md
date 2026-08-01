# LeiOS Branding Metadata Package

This package (`leios.system.branding-meta-files`) provides the rolling-release
branding metadata for LeiOS.

It installs files under `/etc/leios/system/`, such as:

- `/etc/leios/system/version` — the current LeiOS rolling release version
- `/etc/leios/system/changelog` — release notes for the current version

During configuration it executes `/usr/share/leios/system/utils/base-files/install.sh`
if that script is present (it is provided by `leios.system.base-files`). This allows
`leios.system.base-files` to regenerate branding files such as `/etc/os-release`
without being rebuilt for every rolling release.

## Building

```bash
./scripts/build.sh <testing|stable> <version> <escaped_changelog_lines>
```

For example:

```bash
./scripts/build.sh stable 2026.08.001 "added leios.theme.plasmoids.digitalclock version 1.0.2\nadded leios.theme.grub-theme version 1.0.0"
```

