# ConstOS Local Pacman Repository

Direktori ini berfungsi sebagai repositori pacman lokal untuk menampung paket biner `.pkg.tar.zst` yang dibuat khusus untuk ConstOS sebelum dibakar ke dalam file ISO.

## Cara Menggunakan:

1. Letakkan paket biner pacman hasil build di folder ini, misalnya:
   * `const-harness-desktop-0.0.2-1-x86_64.pkg.tar.zst`
2. Jalankan perintah pembuatan database repositori:
   ```bash
   repo-add constos.db.tar.zst *.pkg.tar.zst
   ```
3. File database `constos.db.tar.zst` dan symlink `constos.db` akan terbuat secara otomatis.
4. Skrip build Archiso (`iso/buildiso.sh`) akan membaca repositori ini sesuai konfigurasi di `iso/pacman.conf`.
