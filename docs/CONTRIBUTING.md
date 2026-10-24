# Panduan kontribusi

Untuk cara memakai alatnya, lihat [README](../README.md).

## Lingkungan

Skrip menargetkan bash 4.2 dan berjalan di Ubuntu 22.04 dan 24.04. Semua
pemeriksaan berjalan di dalam Docker, jadi mesin yang mengerjakan perubahan
hanya butuh Docker.

## Pemeriksaan

| Perintah | Yang dikerjakan |
|---|---|
| `make versi` | memastikan versi di empat tempat sama |
| `make check` | shellcheck pada severity style, lalu seluruh test bats |
| `make man` | membangun man page tanpa peringatan |
| `make deb` | membangun `dist/organize_0.2.0_all.deb` |
| `make lint` | menjalankan lintian pada paket yang dibangun |
| `make uji-pasang` | memasang paket di container Ubuntu yang bersih lalu mengujinya |

Pemeriksaan lengkap, di dua rilis Ubuntu yang didukung:

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

## Kontributor

| Nama | GitHub |
|---|---|
| Ivan Adrian Bhagaskara | [@Ivanadrian31](https://github.com/Ivanadrian31) |
| Bima Adji Kusuma | [@bimadji](https://github.com/bimadji) |
