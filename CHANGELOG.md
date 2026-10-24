# Changelog

All notable changes to this project are documented here. The format is
based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and this
project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2026-10-24

### Changed

- The command is now `organize`. `organize-dl` remains as a deprecated
  wrapper that forwards its arguments, turns `--dry-run` into `--preview`,
  and warns on stderr.
- The default directory is the current directory instead of `~/Downloads`.
- `--dry-run` is now `--preview`, with `-p` as the short form.
- The Debian package is now named `organize` and replaces `organize-dl`.

### Added

- `--images`, `--documents`, `--music`, `--videos`, `--archives` and
  `--others` restrict a run to one or more categories.
- System directories and the root of a git repository are refused with
  exit code 4, so a stray run cannot scatter files that belong to the
  system or to a repository.
- Files a download manager is still writing (`.part`, `.crdownload`,
  `.download`, `.tmp`, `.filepart`) are always skipped.

Category folders and the extension mapping did not change, and neither did
the collision suffix or the handling of hidden files, subdirectories and
symlinks.

## [0.1.0] - 2026-10-23

### Added

- Move files from one directory into `Images`, `Documents`, `Music`,
  `Videos`, `Archives` and `Others`, chosen from the file extension.
- `--dry-run` to print the plan without moving anything.
- `--device` prints the storage device, mount point, filesystem and free
  space of the target directory.
- Numeric suffix on collisions (`photo_1.jpg`), never overwriting.
- Compound archive extensions kept whole (`backup_1.tar.gz`).
- Debian package, man page and bash completion.
