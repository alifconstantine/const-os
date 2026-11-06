# ConstOS Local Pacman Repository

Direktori ini berfungsi sebagai repositori pacman lokal untuk menampung paket biner `.pkg.tar.zst` yang dibuat khusus untuk ConstOS sebelum dibakar ke dalam file ISO.

## Cara Menggunakan:

1. Letakkan paket biner pacman hasil build di folder ini, misalnya:
   * `const-harness-desktop-0.0.2-1-x86_64.pkg.tar.zst`
2. Jalankan perintah pembuatan database repositori:
   ```bash
   repo-add constos-local.db.tar.zst *.pkg.tar.zst
   ```
3. File database `constos-local.db.tar.zst` dan symlink `constos-local.db` akan terbuat secara otomatis.

Profil live saat ini dapat dibangun tanpa repositori lokal. Aktifkan repositori ini saat paket Harness sudah memuat binary yang dapat dijalankan.
