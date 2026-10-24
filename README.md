<p align="center">
  <img src="assets/banner.svg" alt="Banner organize: sebuah kotak huruf (type case) dengan enam kompartemen berlabel Images, Documents, Music, Videos, Archives dan Others, masing-masing memuat contoh ekstensi berkas yang dipindah ke dalamnya" width="100%">
</p>

<p align="center">
  <a href="https://github.com/Ivanadrian31/organize/releases/latest"><img src="https://img.shields.io/github/v/release/Ivanadrian31/organize" alt="Rilis terbaru"></a>
  <a href="https://github.com/Ivanadrian31/organize/actions/workflows/ci.yml"><img src="https://github.com/Ivanadrian31/organize/actions/workflows/ci.yml/badge.svg" alt="Status CI: passing"></a>
  <img src="https://img.shields.io/badge/Ubuntu-22.04%20%7C%2024.04-orange?logo=ubuntu" alt="Ubuntu 22.04 dan 24.04">
  <img src="https://img.shields.io/badge/bash-4.2%2B-green?logo=gnubash" alt="Bash 4.2 atau lebih baru">
  <a href="LICENSE"><img src="https://img.shields.io/github/license/Ivanadrian31/organize" alt="Lisensi MIT"></a>
</p>

<p align="center"><b>Menyusun berkas di satu folder ke subfolder kategorinya, tanpa pernah menimpa berkas yang sudah ada.</b></p>

<p align="center">Skrip bash untuk Ubuntu 22.04 dan 24.04, distribusi Debian, tanpa dependensi baru.</p>

<p align="center">
  <a href="#fitur">Fitur</a> ·
  <a href="#instalasi">Instalasi</a> ·
  <a href="#penggunaan">Penggunaan</a> ·
  <a href="#cara-kerja">Cara kerja</a> ·
  <a href="#pengembangan">Pengembangan</a> ·
  <a href="#rilis">Rilis</a> ·
  <a href="#troubleshooting">Troubleshooting</a> ·
  <a href="#kontributor">Kontributor</a> ·
  <a href="#lisensi">Lisensi</a>
</p>

---

## Fitur

- **Menyusun berdasarkan ekstensi.** Setiap berkas reguler di level teratas folder dipindah ke `Images/`, `Documents/`, `Music/`, `Videos/`, `Archives/`, atau `Others/` sesuai ekstensinya.
- **Tidak pernah menimpa.** Kalau nama berkas sudah ada di subfolder tujuan, program memakai nama berikutnya yang kosong: `photo.jpg` menjadi `photo_1.jpg`, lalu `photo_2.jpg`. Ekstensi majemuk tetap utuh, jadi `backup.tar.gz` menjadi `backup_1.tar.gz`, bukan `backup.tar_1.gz`.
- **Pratinjau dulu.** `--preview` menampilkan rencana tanpa memindahkan satu berkas pun, dan bisa digabung dengan flag kategori.
- **Satu kategori saja.** `--images`, `--documents`, `--music`, `--videos`, `--archives`, dan `--others` membatasi run ke kategori yang disebut. Beberapa flag boleh dipakai bersamaan.
- **Menolak folder yang salah.** Direktori sistem dan root repo git ditolak dengan kode keluar `4`, jadi run yang salah tidak bisa menyebarkan berkas sistem ke `Others/`.
- **Melewati unduhan yang belum selesai.** Berkas `.part`, `.crdownload`, `.download`, `.tmp`, dan `.filepart` tidak pernah dipindahkan, karena pengunduh masih menulis ke berkas itu.
- **Tidak menyentuh apa pun di luar folder target.** Subfolder, berkas tersembunyi, dan symlink dibiarkan apa adanya.
- **Folder dibuat sesuai kebutuhan.** Folder yang hanya berisi gambar berakhir dengan satu subfolder `Images/`, bukan enam folder kosong.
- **Melihat perangkat penyimpanan.** `--device` melaporkan block device, mount point, filesystem, dan ruang kosong di belakang folder target, lalu berhenti tanpa memindahkan berkas.
- **Tanpa dependensi baru.** Hanya bash, `findmnt`, dan `df` dari paket yang sudah ada di Ubuntu.

### Kategori dan ekstensi

| Folder | Ekstensi |
|---|---|
| `Images/` | jpg jpeg png gif bmp webp svg tif tiff heic avif |
| `Documents/` | pdf doc docx xls xlsx ppt pptx txt md rtf odt ods odp csv epub |
| `Music/` | mp3 wav flac aac ogg m4a opus wma |
| `Videos/` | mp4 mkv avi mov webm m4v wmv flv |
| `Archives/` | zip rar 7z tar gz bz2 xz tgz iso |
| `Others/` | semua berkas lain, termasuk berkas tanpa ekstensi |

---

## Instalasi

### Paket Debian (Ubuntu 22.04 dan 24.04)

Unduh `organize_0.2.0_all.deb` dari
[rilis terbaru](https://github.com/Ivanadrian31/organize/releases/latest), lalu:

```sh
sudo apt install ./organize_0.2.0_all.deb
```

Paket ini memasang `/usr/bin/organize`, pembungkus `/usr/bin/organize-dl`, man
page ke `/usr/share/man`, dan completion bash ke
`/usr/share/bash-completion/completions`.

Copot dengan `sudo apt remove organize`.

### Memperbarui dari 0.1.0

Paket 0.2.0 bernama `organize` dan menyatakan `Replaces` serta `Conflicts`
terhadap `organize-dl`, jadi memasangnya mencabut paket lama secara otomatis:

```sh
sudo apt install ./organize_0.2.0_all.deb
```

Tidak perlu mencopot `organize-dl` lebih dulu. Setelah itu perintahnya berubah
dari `organize-dl` menjadi `organize`; nama lama tetap bekerja sebagai
pembungkus yang mencetak peringatan.

### Dari source

```sh
git clone https://github.com/Ivanadrian31/organize.git
cd organize
sudo make install
```

`sudo make install` menaruh berkas di `/usr/local`. Tanpa sudo:

```sh
make install PREFIX="$HOME/.local"
```

`sudo make uninstall` menghapus berkas yang terpasang.

---

## Penggunaan

```
organize [OPTIONS] [DIRECTORY]

  -p, --preview   print the plan without moving anything
  --images        only handle Images
  --documents     only handle Documents
  --music         only handle Music
  --videos        only handle Videos
  --archives      only handle Archives
  --others        only handle Others
  --device        show the storage device, filesystem and free space
  -h, --help      show help
  -V, --version   show the version
  --              end of options; use before a DIRECTORY starting with '-'
```

Opsi harus ditulis sebelum `DIRECTORY`. Tanpa `DIRECTORY`, targetnya direktori
kerja saat ini. Tanpa flag kategori, keenam kategori diproses.

| Kode keluar | Arti |
|---|---|
| `0` | semua berkas berhasil dipindahkan, atau memang tidak ada yang perlu dipindahkan |
| `1` | ada berkas yang gagal dipindahkan; berkas lain tetap diproses |
| `2` | opsi atau argumen tidak valid |
| `3` | `DIRECTORY` tidak ada atau bukan direktori |
| `4` | `DIRECTORY` adalah direktori sistem atau root repo git |

### Menyusun folder yang sedang dibuka

```sh
organize
```

Contoh keluaran dari run nyata, dengan `Documents/invoice.pdf` dan
`Archives/backup.tar.gz` yang sudah ada sebelumnya sehingga kedua berkas baru
disimpan dengan akhiran `_1`:

```
backup.tar.gz -> Archives/backup_1.tar.gz
clip.mp4 -> Videos/clip.mp4
draft.xyz -> Others/draft.xyz
holiday.jpg -> Images/holiday.jpg
invoice.pdf -> Documents/invoice_1.pdf
notes -> Others/notes
report.pdf -> Documents/report.pdf
track.mp3 -> Music/track.mp3
Moved 8 files: Images 1, Documents 2, Music 1, Videos 1, Archives 1, Others 2.
```

Berkas `photo.part` yang ada di folder yang sama tidak ikut dipindahkan dan
tetap di tempatnya.

### Melihat rencana lebih dulu

```sh
organize --preview /path/ke/folder
```

```
[preview] holiday.jpg -> Images/holiday.jpg
[preview] invoice.pdf -> Documents/invoice.pdf
[preview] track.mp3 -> Music/track.mp3
3 files would be moved: Images 1, Documents 1, Music 1.
```

### Satu kategori saja

```sh
organize --images
organize --documents --archives ~/Tugas
```

Hanya kategori yang disebut yang dipindahkan; berkas kategori lain tetap di
level teratas folder.

### Folder lain

```sh
organize ~/Tugas
organize -- -incoming
```

### Melihat perangkat penyimpanan

```sh
organize --device ~/Downloads
```

Keluaran di bawah ini diambil dari container Linux di atas block device ext4
sungguhan, bukan dari filesystem container:

```
device: /dev/sdd[/data/docker/volumes/organize-readme-demo/_data]
mount: /root/Downloads
fstype: ext4
Filesystem      Size  Used Avail Use% Mounted on
/dev/sdd       1007G   11G  945G   2% /root/Downloads
```

### Folder yang ditolak

Direktori sistem dan root repo git ditolak sebelum ada berkas yang dipindahkan:

```
organize: refusing to work on "/etc": it is a system directory
```

```
organize: refusing to work on "/home/bima/proyek": it is the root of a git repository
```

Pencocokan dilakukan persis pada path yang sudah diresolusikan, jadi `$HOME`
ditolak tetapi `$HOME/Downloads` tetap boleh, dan subfolder di dalam repo juga
tetap boleh.

Folder target yang tidak ada menghasilkan pesan galat dan kode keluar `3`:

```
organize: directory "/root/TidakAda" not found
```

---

## Cara kerja

`organize` membaca isi direktori target, memetakan tiap nama berkas ke satu
kategori, lalu memindahkannya ke subfolder kategori itu.

```mermaid
flowchart TD
    A["organize DIRECTORY"] --> B{"DIRECTORY ada?"}
    B -- tidak --> Z["Keluar dengan kode 3"]
    B -- ya --> C{"--device?"}
    C -- ya --> D["Cetak device, mount, fstype, df"]
    D --> E["Keluar dengan kode 0"]
    C -- tidak --> F{"Direktori sistem atau root repo git?"}
    F -- ya --> Y["Cetak penolakan, keluar dengan kode 4"]
    F -- tidak --> G["Baca berkas reguler di level teratas"]
    G --> H["Pecah nama jadi dasar dan ekstensi"]
    H --> I{"Unduhan sebagian?"}
    I -- ya --> G
    I -- tidak --> J["Petakan ekstensi ke kategori"]
    J --> K{"Kategori dipilih?"}
    K -- tidak --> G
    K -- ya --> L{"--preview?"}
    L -- ya --> M["Cetak rencana, jangan pindahkan"]
    L -- tidak --> N["Buat subfolder kategori bila belum ada"]
    N --> O{"Nama tujuan sudah dipakai?"}
    O -- ya --> P["Tambahkan akhiran _1, _2, seterusnya"]
    O -- tidak --> Q["Pindahkan berkas"]
    P --> Q
    M --> R{"Ada yang gagal?"}
    Q --> R
    R -- ya --> S["Cetak galat di stderr, lanjutkan berkas lain"]
    R -- tidak --> T["Cetak ringkasan jumlah berkas per kategori"]
    S --> U["Keluar dengan kode 1"]
    T --> V["Keluar dengan kode 0"]
```

Berkas diproses menurut urutan byte nama berkasnya, sehingga run dengan isi
folder yang sama selalu menghasilkan hasil yang sama.

---

## Pengembangan

Semua pemeriksaan berjalan di dalam Docker, jadi mesin pembuat hanya butuh
Docker.

| Perintah | Yang dikerjakan |
|---|---|
| `make versi` | memastikan versi di empat tempat sama |
| `make check` | shellcheck pada severity style, lalu seluruh test bats |
| `make man` | membangun man page tanpa peringatan |
| `make deb` | membangun `dist/organize_0.2.0_all.deb` |
| `make lint` | menjalankan lintian pada paket yang dibangun |
| `make uji-pasang` | memasang paket di container Ubuntu yang bersih lalu mengujinya |

Gate lengkap, di dua rilis Ubuntu yang didukung:

```sh
docker run --rm -v "$(cygpath -m "$PWD"):/src" -w /src ubuntu:24.04 bash -c \
  'apt-get update -qq >/dev/null 2>&1 && apt-get install -y -qq bats shellcheck make groff-base lintian dpkg-dev >/dev/null 2>&1 && chmod +x bin/organize bin/organize-dl tests/pasang-bersih.sh && make versi check man deb lint'

docker run --rm -v "$(cygpath -m "$PWD"):/src" -w /src ubuntu:22.04 bash -c \
  'apt-get update -qq >/dev/null 2>&1 && apt-get install -y -qq bats shellcheck make groff-base lintian dpkg-dev >/dev/null 2>&1 && chmod +x bin/organize bin/organize-dl tests/pasang-bersih.sh && make versi check man deb lint'

bash tests/pasang-bersih.sh
```

Di Linux, `$(cygpath -m "$PWD")` tidak diperlukan dan cukup menulis
`-v "$PWD:/src"`.

Test bats ada di `tests/organize.bats`, helper-nya di `tests/helper.bash`, dan
test pemasangan bersih di `tests/pasang-bersih.sh`.

---

## Rilis

Versi hidup di empat tempat dan harus selalu sama: `VERSION` di `Makefile`,
`VERSION` di `bin/organize`, `Version:` di `debian/control`, dan baris pertama
`debian/changelog`. `make versi` memeriksa keempatnya.

Rilis dimulai dari tag beranotasi:

```sh
git tag -a v0.2.0 -m "v0.2.0"
git push origin v0.2.0
```

Workflow `release` membangun paket di `ubuntu-22.04` lalu menempelkannya ke
rilis GitHub yang baru.

---

## Troubleshooting

| Masalah | Solusi |
|---|---|
| `organize: command not found` | Paket belum terpasang. Jalankan `sudo apt install ./organize_0.2.0_all.deb`, atau tambahkan `/usr/local/bin` ke `PATH`. |
| `organize: directory "..." not found` | Folder target tidak ada atau bukan direktori. Cek jalurnya; kode keluar untuk kondisi ini adalah `3`. |
| `organize: refusing to work on "..."` | Folder itu direktori sistem atau root repo git. Pindah ke subfolder yang ingin dirapikan, atau sebutkan folder lain sebagai `DIRECTORY`. Kode keluarnya `4`. |
| `organize: option "--dry-run" was renamed` | Nama lama sudah diganti. Pakai `--preview` atau `-p`. Pembungkus `organize-dl` masih menerjemahkan `--dry-run`. |
| `organize: unknown option "..."` | Opsi harus ditulis sebelum `DIRECTORY`. Untuk folder yang namanya diawali `-`, pakai `organize -- -namafolder`. |
| `organize: cannot move "..."` | Berkas tidak bisa dipindahkan, mungkin karena permission atau berkas sedang dipakai. Pesan galat ditulis ke stderr, berkas lain tetap diproses, dan kode keluar menjadi `1`. |
| `organize: cannot create directory "..."` | Subfolder kategori tidak bisa dibuat. Periksa permission folder target. |
| Berkas `.part` tidak ikut dipindahkan | Itu disengaja. Berkas yang masih ditulis pengunduh dilewati, termasuk saat `--others` diberikan. |
| `--device` menampilkan `overlay` | Output itu berasal dari filesystem container, bukan disk yang sebenarnya. Jalankan flag ini di mesin yang memegang berkasnya. |
| Nama berkas mendapat akhiran angka | Nama itu sudah dipakai di subfolder tujuan, jadi program memilih nama berikutnya yang kosong. |
| Completion bash tidak aktif | completion terpasang di `/usr/share/bash-completion/completions`. Muat ulang shell, atau jalankan `source /usr/share/bash-completion/completions/organize`. |
| `make versi` gagal | Versi di empat tempat tidak sama. Jalankan `make versi` untuk melihat nilai masing-masing tempat. |

---

## Kontributor

| Nama | GitHub |
|---|---|
| Ivan Adrian Bhagaskara | [@Ivanadrian31](https://github.com/Ivanadrian31) |
| Bima Adji Kusuma | [@bimadji](https://github.com/bimadji) |

---

## Lisensi

MIT, lihat [LICENSE](LICENSE).
