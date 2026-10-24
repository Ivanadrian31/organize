#!/usr/bin/env bats

load helper

setup() {
	DL=$(mktemp -d)
}

teardown() {
	rm -rf "$DL"
}

@test "images are moved to Images" {
	buat "$DL" a.jpg b.png
	run "$BIN" "$DL"
	[ "$status" -eq 0 ]
	assert_file "$DL/Images/a.jpg"
	assert_file "$DL/Images/b.png"
	assert_absent "$DL/a.jpg"
}

@test "documents are moved to Documents" {
	buat "$DL" a.pdf b.docx
	run "$BIN" "$DL"
	[ "$status" -eq 0 ]
	assert_file "$DL/Documents/a.pdf"
	assert_file "$DL/Documents/b.docx"
}

@test "music is moved to Music" {
	buat "$DL" a.mp3 b.flac
	run "$BIN" "$DL"
	[ "$status" -eq 0 ]
	assert_file "$DL/Music/a.mp3"
	assert_file "$DL/Music/b.flac"
}

@test "videos are moved to Videos" {
	buat "$DL" a.mp4 b.mkv
	run "$BIN" "$DL"
	[ "$status" -eq 0 ]
	assert_file "$DL/Videos/a.mp4"
	assert_file "$DL/Videos/b.mkv"
}

@test "archives are moved to Archives" {
	buat "$DL" a.zip b.7z
	run "$BIN" "$DL"
	[ "$status" -eq 0 ]
	assert_file "$DL/Archives/a.zip"
	assert_file "$DL/Archives/b.7z"
}

@test "unknown extension goes to Others" {
	buat "$DL" notes.xyz
	run "$BIN" "$DL"
	[ "$status" -eq 0 ]
	assert_file "$DL/Others/notes.xyz"
}

@test "file without extension goes to Others" {
	buat "$DL" README
	run "$BIN" "$DL"
	[ "$status" -eq 0 ]
	assert_file "$DL/Others/README"
}

@test "uppercase extension is recognised" {
	buat "$DL" FOTO.JPG
	run "$BIN" "$DL"
	[ "$status" -eq 0 ]
	assert_file "$DL/Images/FOTO.JPG"
}

@test "no argument uses the current directory" {
	buat "$DL" a.jpg b.pdf
	cd "$DL"
	run "$BIN"
	[ "$status" -eq 0 ]
	assert_file "$DL/Images/a.jpg"
	assert_file "$DL/Documents/b.pdf"
}

@test "preview prints the plan and moves nothing" {
	buat "$DL" a.jpg
	run "$BIN" --preview "$DL"
	[ "$status" -eq 0 ]
	[ "$output" = "[preview] a.jpg -> Images/a.jpg
1 file would be moved: Images 1." ]
	assert_file "$DL/a.jpg"
	assert_absent "$DL/Images"
}

@test "preview short flag works" {
	buat "$DL" a.jpg
	run "$BIN" -p "$DL"
	[ "$status" -eq 0 ]
	[[ $output == '[preview] a.jpg -> Images/a.jpg'* ]]
	assert_file "$DL/a.jpg"
}

@test "preview combined with a category only shows that category" {
	buat "$DL" a.jpg b.pdf c.mp3
	run "$BIN" --preview --images "$DL"
	[ "$status" -eq 0 ]
	[ "$output" = "[preview] a.jpg -> Images/a.jpg
1 file would be moved: Images 1." ]
}

@test "a category option moves only that category" {
	buat "$DL" a.jpg b.pdf c.mp3
	run "$BIN" --images "$DL"
	[ "$status" -eq 0 ]
	assert_file "$DL/Images/a.jpg"
	assert_file "$DL/b.pdf"
	assert_file "$DL/c.mp3"
	assert_absent "$DL/Documents"
	assert_absent "$DL/Music"
}

@test "several category options can be combined" {
	buat "$DL" a.jpg b.pdf c.mp3
	run "$BIN" --images --documents "$DL"
	[ "$status" -eq 0 ]
	assert_file "$DL/Images/a.jpg"
	assert_file "$DL/Documents/b.pdf"
	assert_file "$DL/c.mp3"
	assert_absent "$DL/Music"
}

@test "others option moves only unclassified files" {
	buat "$DL" a.jpg b.xyz
	run "$BIN" --others "$DL"
	[ "$status" -eq 0 ]
	assert_file "$DL/Others/b.xyz"
	assert_file "$DL/a.jpg"
	assert_absent "$DL/Images"
}

@test "collision gets _1 and then _2" {
	buat "$DL" a.jpg
	run "$BIN" "$DL"
	[ "$status" -eq 0 ]
	buat "$DL" a.jpg
	run "$BIN" "$DL"
	[ "$status" -eq 0 ]
	buat "$DL" a.jpg
	run "$BIN" "$DL"
	[ "$status" -eq 0 ]
	assert_file "$DL/Images/a.jpg"
	assert_file "$DL/Images/a_1.jpg"
	assert_file "$DL/Images/a_2.jpg"
}

@test "compound extension keeps its tail" {
	buat "$DL" backup.tar.gz
	mkdir -p "$DL/Archives"
	buat "$DL/Archives" backup.tar.gz
	run "$BIN" "$DL"
	[ "$status" -eq 0 ]
	assert_file "$DL/Archives/backup_1.tar.gz"
	assert_absent "$DL/Archives/backup.tar_1.gz"
}

@test "hidden files are skipped" {
	buat "$DL" .secret.jpg
	run "$BIN" "$DL"
	[ "$status" -eq 0 ]
	assert_file "$DL/.secret.jpg"
	assert_absent "$DL/Images"
}

@test "subdirectories are skipped" {
	mkdir -p "$DL/sub"
	buat "$DL" a.jpg
	run "$BIN" "$DL"
	[ "$status" -eq 0 ]
	assert_dir "$DL/sub"
	assert_file "$DL/Images/a.jpg"
}

@test "symlinks are skipped" {
	: >"$DL/real.jpg"
	ln -s "$DL/real.jpg" "$DL/link.jpg"
	run "$BIN" "$DL"
	[ "$status" -eq 0 ]
	[ -L "$DL/link.jpg" ]
	assert_file "$DL/Images/real.jpg"
	assert_absent "$DL/Images/link.jpg"
}

@test "partial downloads are skipped" {
	buat "$DL" a.part b.crdownload c.download d.tmp e.filepart
	run "$BIN" "$DL"
	[ "$status" -eq 0 ]
	[ "$output" = "Moved 0 files." ]
	assert_file "$DL/a.part"
	assert_file "$DL/b.crdownload"
	assert_file "$DL/c.download"
	assert_file "$DL/d.tmp"
	assert_file "$DL/e.filepart"
	assert_absent "$DL/Others"
}

@test "partial downloads stay put even with others" {
	buat "$DL" a.part b.xyz
	run "$BIN" --others "$DL"
	[ "$status" -eq 0 ]
	assert_file "$DL/a.part"
	assert_file "$DL/Others/b.xyz"
}

@test "a system directory is refused with exit 4" {
	buat "$DL" a.jpg
	run "$BIN" /etc
	[ "$status" -eq 4 ]
	[[ $output == *'refusing to work on'* ]]
}

@test "the home directory is refused with exit 4" {
	buat "$DL" a.jpg
	cd "$DL"
	run env HOME="$DL" "$BIN"
	[ "$status" -eq 4 ]
	[[ $output == *'system directory'* ]]
	assert_file "$DL/a.jpg"
	assert_absent "$DL/Images"
}

@test "the root of a git repository is refused with exit 4" {
	mkdir -p "$DL/.git"
	buat "$DL" a.jpg
	run "$BIN" "$DL"
	[ "$status" -eq 4 ]
	[[ $output == *'git repository'* ]]
	assert_file "$DL/a.jpg"
	assert_absent "$DL/Images"
}

@test "a subdirectory of a git repository is still processed" {
	mkdir -p "$DL/.git" "$DL/sub"
	buat "$DL/sub" a.jpg
	run "$BIN" "$DL/sub"
	[ "$status" -eq 0 ]
	assert_file "$DL/sub/Images/a.jpg"
}

@test "device still works on a refused directory" {
	run "$BIN" --device /etc
	[ "$status" -eq 0 ]
	[[ $output == *'device:'* ]]
}

@test "custom directory argument is used" {
	local lain
	lain=$(mktemp -d)
	buat "$lain" x.pdf
	run "$BIN" "$lain"
	[ "$status" -eq 0 ]
	assert_file "$lain/Documents/x.pdf"
	rm -rf "$lain"
}

@test "missing directory exits 3" {
	run "$BIN" "$DL/nope"
	[ "$status" -eq 3 ]
	[[ $output == *'not found'* ]]
}

@test "unknown option exits 2" {
	run "$BIN" --bogus
	[ "$status" -eq 2 ]
	[[ $output == *'unknown option'* ]]
}

@test "dry-run points at preview" {
	run "$BIN" --dry-run "$DL"
	[ "$status" -eq 2 ]
	[[ $output == *'is now --preview'* ]]
}

@test "double dash allows a directory starting with a dash" {
	local aneh="$DL/-incoming"
	mkdir -p "$aneh"
	buat "$aneh" a.jpg
	run "$BIN" -- "$aneh"
	[ "$status" -eq 0 ]
	assert_file "$aneh/Images/a.jpg"
}

@test "second run moves nothing and exits 0" {
	buat "$DL" a.jpg
	run "$BIN" "$DL"
	[ "$status" -eq 0 ]
	run "$BIN" "$DL"
	[ "$status" -eq 0 ]
	[ "$output" = "Moved 0 files." ]
}

@test "summary counts each category" {
	buat "$DL" a.jpg b.png c.pdf d.mp3 e.mp4 f.zip g.xyz
	run "$BIN" "$DL"
	[ "$status" -eq 0 ]
	[[ ${lines[-1]} == "Moved 7 files: Images 2, Documents 1, Music 1, Videos 1, Archives 1, Others 1." ]]
}

@test "a blocked category directory is reported and exits 1" {
	ln -s /nonexistent "$DL/Images"
	buat "$DL" a.jpg
	run "$BIN" "$DL"
	[ "$status" -eq 1 ]
	[[ $output == *'cannot create directory'* ]]
	assert_file "$DL/a.jpg"
}

@test "an existing directory named like the file is not overwritten" {
	buat "$DL" a.jpg
	mkdir -p "$DL/Images/a.jpg"
	run "$BIN" "$DL"
	[ "$status" -eq 0 ]
	assert_dir "$DL/Images/a.jpg"
	assert_file "$DL/Images/a_1.jpg"
}

@test "device reports the storage device of the directory" {
	buat "$DL" a.jpg
	run "$BIN" --device "$DL"
	[ "$status" -eq 0 ]
	[[ $output == *device:* ]]
	[[ $output == *mount:* ]]
	[[ $output == *fstype:* ]]
	[[ $output == *Filesystem* ]]
	assert_file "$DL/a.jpg"
	assert_absent "$DL/Images"
}

@test "device with a missing directory exits 3" {
	run "$BIN" --device "$DL/nope"
	[ "$status" -eq 3 ]
}

@test "the wrapper warns and still moves files" {
	buat "$DL" a.jpg
	run "$BIN_DL" "$DL"
	[ "$status" -eq 0 ]
	[[ ${lines[0]} == *'deprecated'* ]]
	assert_file "$DL/Images/a.jpg"
}

@test "the wrapper turns dry-run into preview" {
	buat "$DL" a.jpg
	run "$BIN_DL" --dry-run "$DL"
	[ "$status" -eq 0 ]
	[[ $output == *'[preview] a.jpg -> Images/a.jpg'* ]]
	assert_file "$DL/a.jpg"
	assert_absent "$DL/Images"
}

@test "the wrapper reports the version of organize" {
	run "$BIN_DL" --version
	[ "$status" -eq 0 ]
	[[ $output == *'organize 0.2.0'* ]]
}
