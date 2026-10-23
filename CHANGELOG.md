# Changelog

All notable changes to this project are documented here. The format is
based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and this
project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-10-23

### Added

- Move files from one directory into `Images`, `Documents`, `Music`,
  `Videos`, `Archives` and `Others`, chosen from the file extension.
- `--dry-run` to print the plan without moving anything.
- Numeric suffix on collisions (`photo_1.jpg`), never overwriting.
- Compound archive extensions kept whole (`backup_1.tar.gz`).
- Debian package, man page and bash completion.
