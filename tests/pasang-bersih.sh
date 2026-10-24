#!/usr/bin/env bash
# Clean-install test: install the built .deb in a fresh Ubuntu container,
# exercise the binary, then remove the package again.
#
# Usage: bash tests/pasang-bersih.sh [IMAGE...]
set -euo pipefail

repo=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
images=("$@")
if ((${#images[@]} == 0)); then
	images=(ubuntu:22.04 ubuntu:24.04)
fi

deb=$(find "$repo/dist" -maxdepth 1 -name 'organize_*_all.deb' -print -quit 2>/dev/null || true)
if [[ -z $deb ]]; then
	printf 'pasang-bersih: no .deb in %s/dist, run "make deb" first\n' "$repo" >&2
	exit 1
fi

# git-bash hands Docker a POSIX path the daemon cannot mount; convert it.
mount_src=$repo/dist
if command -v cygpath >/dev/null 2>&1; then
	mount_src=$(cygpath -m "$mount_src")
fi

for img in "${images[@]}"; do
	printf '==> %s\n' "$img"
	docker run --rm -e DEBIAN_FRONTEND=noninteractive \
		-v "$mount_src:/deb:ro" "$img" bash -euo pipefail -c '
		apt-get update -qq
		dpkg -i /deb/organize_*_all.deb >/dev/null
		test "$(organize --version)" = "organize 0.2.0"
		# The wrapper is installed too and reports the same version.
		test "$(organize-dl --version 2>/dev/null)" = "organize 0.2.0"
		# The official Ubuntu images exclude /usr/share/man via dpkg path-exclude,
		# so the man page is verified in the package payload instead.
		dpkg-deb -c /deb/organize_*_all.deb | grep -q "usr/share/man/man1/organize.1.gz"
		dpkg-deb -c /deb/organize_*_all.deb | grep -q "usr/share/man/man1/organize-dl.1.gz"
		test -f /usr/share/bash-completion/completions/organize

		mkdir -p /tmp/dl
		touch /tmp/dl/a.jpg /tmp/dl/b.pdf /tmp/dl/c.mp3 /tmp/dl/d.mp4 \
			/tmp/dl/e.zip /tmp/dl/f.xyz /tmp/dl/g.part
		out=$(organize /tmp/dl)
		printf "%s\n" "$out"
		summary=$(printf "%s\n" "$out" | tail -n 1)
		test "$summary" = "Moved 6 files: Images 1, Documents 1, Music 1, Videos 1, Archives 1, Others 1."
		test -f /tmp/dl/Images/a.jpg
		test -f /tmp/dl/Documents/b.pdf
		test -f /tmp/dl/Music/c.mp3
		test -f /tmp/dl/Videos/d.mp4
		test -f /tmp/dl/Archives/e.zip
		test -f /tmp/dl/Others/f.xyz
		test -f /tmp/dl/g.part

		# The default directory is the current one.
		mkdir -p /tmp/cwd
		cd /tmp/cwd
		touch h.jpg
		test "$(organize)" = "h.jpg -> Images/h.jpg
Moved 1 file: Images 1."
		test -f /tmp/cwd/Images/h.jpg

		# A category option narrows the run.
		mkdir -p /tmp/sel
		touch /tmp/sel/i.jpg /tmp/sel/j.pdf
		organize --images /tmp/sel >/dev/null
		test -f /tmp/sel/Images/i.jpg
		test -f /tmp/sel/j.pdf

		# Preview moves nothing.
		mkdir -p /tmp/prev
		touch /tmp/prev/k.jpg
		test "$(organize --preview /tmp/prev)" = "[preview] k.jpg -> Images/k.jpg
1 file would be moved: Images 1."
		test -f /tmp/prev/k.jpg

		# A system directory is refused with exit code 4.
		set +e
		organize /etc >/dev/null 2>&1
		rc=$?
		set -e
		test "$rc" -eq 4

		apt-get remove -y organize >/dev/null
		# bash keeps a removed path in its command hash, so clear it first.
		hash -r
		test ! -e /usr/bin/organize
		test ! -e /usr/bin/organize-dl
		if command -v organize >/dev/null || command -v organize-dl >/dev/null; then
			printf "still on PATH after removal\n" >&2
			exit 1
		fi
		printf "ok\n"
	'
done
