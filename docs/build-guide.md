# Build dan uji ConstOS Live

Profil awal menargetkan **x86_64 UEFI** dengan GRUB, kernel CachyOS BORE, dan Hyprland. Gunakan VM dengan Secure Boot dimatikan. Profil ini berfokus pada sesi live. Calamares, instalasi ke disk, dan paket Harness masih dalam pengembangan.

## Siapkan host build

Clone repo di filesystem Linux pada host CachyOS x86_64 agar symlink systemd ikut terpasang. Pasang perkakas dan siapkan kepercayaan paket sebelum build.

```bash
sudo pacman -Syu --needed archiso cachyos-keyring archlinux-keyring grub squashfs-tools dosfstools mtools libisoburn
sudo pacman-key --populate archlinux cachyos
```

Paket diambil dari repositori CachyOS x86_64 generik dan repositori Arch. Untuk host Arch, siapkan keyring CachyOS melalui [petunjuk upstream](https://github.com/CachyOS/linux-cachyos#installation) sebelum memakai profil ini.

## Rakit profil dan ISO

Jalankan dari root repo. Staging dapat diperiksa tanpa hak root.

```bash
bash iso/buildiso.sh --stage-only
sudo bash iso/buildiso.sh -v
```

Staging menyalin profil Archiso, menyiapkan konfigurasi pacman untuk sesi live, dan menaruh konfigurasi desktop di `/etc/skel/.config` untuk akun `liveuser`. Setiap run memakai direktori kerja baru di `iso/work/`. `-w DIR` dan `-o DIR` mengubah lokasi kerja dan output. ISO muncul di `iso/out/constos-*.iso` secara default.

## Smoke test di VM

Siapkan VM x86_64 dengan firmware UEFI, 4 vCPU, 6 GiB RAM, dan akselerasi grafis virtio jika tersedia. Boot ISO lalu cek:

1. GRUB menampilkan **ConstOS Live (CachyOS BORE)**, lalu SDDM masuk ke Hyprland sebagai `liveuser`.
2. Waybar muncul. `Super+Enter` membuka Foot, `Super+Space` membuka Wofi, dan `Super+E` membuka Thunar.
3. Jalankan `uname -r`, `systemctl --failed`, `nmcli general status`, dan `zramctl`. Catat kernel aktif, unit gagal, konektivitas, dan status ZRAM.
4. Reboot dan pilih **ConstOS Live (console fallback)**. Pastikan TTY bisa dipakai untuk mengambil log dengan `journalctl -b`.
