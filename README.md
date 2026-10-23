# organize-dl

[![ci](https://github.com/Ivanadrian31/organize/actions/workflows/ci.yml/badge.svg)](https://github.com/Ivanadrian31/organize/actions/workflows/ci.yml)
[![release](https://img.shields.io/github/v/release/Ivanadrian31/organize)](https://github.com/Ivanadrian31/organize/releases/latest)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Sort a downloads folder into category subfolders, by file extension.

```
$ organize-dl
invoice.pdf -> Documents/invoice.pdf
holiday.jpg -> Images/holiday.jpg
track.mp3 -> Music/track.mp3
Moved 3 files: Images 1, Documents 1, Music 1.
```

## What it does

`organize-dl` looks at the files sitting directly inside one directory
(`~/Downloads` by default) and moves each one into a subfolder chosen
from its extension:

| Folder | Extensions |
|---|---|
| `Images/` | jpg jpeg png gif bmp webp svg tif tiff heic avif |
| `Documents/` | pdf doc docx xls xlsx ppt pptx txt md rtf odt ods odp csv epub |
| `Music/` | mp3 wav flac aac ogg m4a opus wma |
| `Videos/` | mp4 mkv avi mov webm m4v wmv flv |
| `Archives/` | zip rar 7z tar gz bz2 xz tgz iso |
| `Others/` | anything else, including files with no extension |

Rules it never breaks:

- **Nothing is overwritten.** A name that is already taken gets a numeric
  suffix before the extension: `photo.jpg` → `photo_1.jpg` → `photo_2.jpg`.
  Compound archive extensions stay whole: `backup.tar.gz` → `backup_1.tar.gz`.
- **Nothing outside the directory is touched.** Subfolders, hidden files and
  symlinks are left alone.
- **Folders are created on demand.** A directory with only images gets only
  `Images/`, not six empty folders.
- **One bad file does not stop the run.** A file that cannot be moved is
  reported on stderr, the rest are still processed, and the exit status is 1.

## Which device holds the files

`--device` reports where the target directory lives: the block device, the
mount point, the filesystem and the free space, using `findmnt` and `df`.
It prints the report and exits, so no file is moved. It wins over
`--dry-run`.

```
$ organize-dl --device ~/Downloads
device: /dev/nvme0n1p2
mount: /
fstype: ext4
Filesystem      Size  Used Avail Use% Mounted on
/dev/nvme0n1p2  468G  312G  133G  71% /
```

## Install

### Debian package (Ubuntu 22.04 / 24.04)

Download `organize-dl_0.1.0_all.deb` from the
[latest release](https://github.com/Ivanadrian31/organize/releases/latest), then:

```sh
sudo apt install ./organize-dl_0.1.0_all.deb
```

Remove it again with `sudo apt remove organize-dl`.

### From source

```sh
git clone https://github.com/Ivanadrian31/organize.git
cd organize
sudo make install          # /usr/local/bin, man page, completion
make install PREFIX="$HOME/.local"   # no sudo
```

`sudo make uninstall` removes the installed files.

## Usage

```
organize-dl [OPTIONS] [DIRECTORY]

  -n, --dry-run   print the plan without moving anything
  --device        show the storage device, filesystem and free space
  -h, --help      show help
  -V, --version   show the version
  --              end of options, for a DIRECTORY starting with '-'
```

Options must come before `DIRECTORY`. The default is `~/Downloads`.

Exit status: `0` success, `1` at least one file could not be moved,
`2` invalid option or argument, `3` directory missing.

## Quickstart (Bahasa Indonesia)

```sh
sudo apt install ./organize-dl_0.1.0_all.deb

organize-dl --dry-run          # lihat rencananya dulu
organize-dl                    # rapikan ~/Downloads
organize-dl ~/Tugas            # folder lain
```

File di dalam folder dipindah ke `Images/`, `Documents/`, `Music/`,
`Videos/`, `Archives/`, atau `Others/`. Nama yang sudah ada tidak pernah
ditimpa — otomatis jadi `nama_1.ext`, `nama_2.ext`. Subfolder, file
tersembunyi, dan symlink tidak disentuh.

## Development

Everything runs inside Docker, so the host needs nothing but Docker:

```sh
# lint + test on both supported Ubuntu releases
docker run --rm -v "$PWD:/src" -w /src ubuntu:24.04 bash -c \
  'apt-get update -qq && apt-get install -y -qq bats shellcheck && make check'

# build the .deb and install it in fresh containers
docker run --rm -v "$PWD:/src" -w /src ubuntu:24.04 bash -c \
  'apt-get update -qq && apt-get install -y -qq bats shellcheck dpkg-dev make && make uji-pasang'
```

`make check` runs shellcheck and the bats suite. `make deb` builds
`dist/organize-dl_0.1.0_all.deb`. `make lint` runs lintian on it.

Releases are cut by pushing a tag: the `release` workflow builds the
package on `ubuntu-22.04` and attaches it to a new GitHub release.

## Limitations

- Not recursive: only the top level of the directory is read.
- No undo and no journal. Use `--dry-run` first if the folder matters.
- Extensions only; no MIME sniffing, so a renamed file lands by its name.
- The folder names are fixed and case sensitive (`Images/`, not `images/`).

## License

MIT, see [LICENSE](LICENSE).
