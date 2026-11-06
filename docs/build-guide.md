# Panduan Build ISO ConstOS

Dokumen ini memandu langkah-langkah membangun file image bootable (`.iso`) ConstOS menggunakan lingkungan Arch Linux atau CachyOS.

---

## 1. Prasyarat Lingkungan Build

Build ISO menggunakan perangkat lunak **archiso**. Anda memerlukan mesin fisik atau Virtual Machine (VM) yang menjalankan Arch Linux atau CachyOS.

### Instalasi Dependensi Build (di host Arch/CachyOS):

```bash
sudo pacman -Syu --needed archiso git squashfs-tools grub dosfstools mtools libisoburn
```

Pastikan ruang penyimpanan mencukupi: minimal **20 GB ruang kosong** di partisi build.

---

## 2. Struktur Repositori Build

Direktori `iso/` memuat seluruh resep ISO:
* `iso/profiledef.sh`: Metadata profil distro ConstOS.
* `iso/pacman.conf`: Repositori mirror CachyOS v3/v4 dan repositori lokal `[constos-local]`.
* `iso/packages.x86_64`: Daftar paket yang dipasang di ISO.
* `iso/airootfs/`: Overlay root filesystem yang disalin langsung ke sistem live.

---

## 3. Menyiapkan Paket Const Harness (Lokal)

Sebelum membakar ISO, pastikan paket `const-harness-desktop` sudah dibuild dan dimasukkan ke database lokal:

```bash
# 1. Dari direktori paket Const Harness di monorepo:
# pnpm --filter @const/harness-desktop package:linux:pacman

# 2. Salin biner .pkg.tar.zst ke packages/local-repo/
cp /path/to/const-harness-desktop-*.pkg.tar.zst packages/local-repo/

# 3. Masuk ke folder local-repo dan buat database pacman:
cd packages/local-repo
repo-add constos.db.tar.zst *.pkg.tar.zst
cd ../..
```

---

## 4. Menjalankan Proses Build ISO

Jalankan perintah build menggunakan skrip `iso/buildiso.sh`:

```bash
cd iso
sudo ./buildiso.sh -v -w work -o out
```

* `-v`: Mode verbose (menampilkan log rincian instalasi paket).
* `-w work`: Direktori kerja sementara tempat ekstraksi squashfs.
* `-o out`: Direktori tujuan output file `.iso`.

Setelah proses selesai, file image akan berada di:
`iso/out/constos-<tanggal>-x86_64.iso`

---

## 5. Menguji File ISO

### Menguji dengan QEMU:

```bash
qemu-system-x86_64 \
    -enable-kvm \
    -m 4G \
    -smp 4 \
    -cpu host \
    -vga virtio \
    -display sdl,gl=on \
    -cdrom iso/out/constos-*.iso
```

### Menguji dengan VirtualBox:
1. Buat VM baru bertipe **Linux** -> **Arch Linux (64-bit)**.
2. Alokasikan RAM minimal 4 GB dan 2-4 vCPU.
3. Aktifkan **EFI (special OSes only)** di pengaturan System -> Motherboard.
4. Pasang file `.iso` di virtual optical drive dan mulai booting.
