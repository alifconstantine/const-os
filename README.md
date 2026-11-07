<div align="center">

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="assets/const-logo.svg"/>
  <img src="assets/exports/const-logo-black.svg" alt="ConstOS — simbol Const" width="160"/>
</picture>

# ConstOS

**Distribusi Linux berbasis CachyOS dengan Hyprland**

[![Arch Linux](https://img.shields.io/badge/Base-CachyOS%20%28Arch%29-1793d1?logo=arch-linux&logoColor=white)](#)
[![Compositor](https://img.shields.io/badge/Compositor-Hyprland%20Wayland-00a8ff)](#)
[![Scheduler](https://img.shields.io/badge/Kernel-BORE%20Scheduler-ff4757)](#)
[![License](https://img.shields.io/badge/License-GPLv3-green)](#)

</div>

---

## Tentang ConstOS

ConstOS adalah distribusi Linux berbasis CachyOS untuk pengembangan perangkat lunak dan penggunaan desktop sehari-hari. Profil live awal menargetkan x86_64 UEFI dengan kernel CachyOS BORE, Hyprland, Waybar, dan swap ZRAM. Const Harness adalah integrasi yang direncanakan untuk edisi berikutnya.

---

## Arsitektur dan status pengembangan

Arsitektur komponen, batas izin, dan pemisahan profil live dari sistem terpasang dijelaskan di [docs/architecture.md](docs/architecture.md). Status berikut membedakan konfigurasi yang tersedia dari integrasi yang masih perlu dibuktikan.

| Komponen | Status |
| :--- | :--- |
| Kernel dan proses | Manifest live memilih kernel CachyOS BORE. Prototipe `constd` membaca load average dan sampel state proses. |
| Boot dan login | Sumber tema GRUB, Plymouth, dan SDDM memakai palet hitam/putih/biru. Penerimaan tema dan jalur fallback dicatat terpisah dari bukti boot baseline. |
| Memori dan ZRAM | Overlay live mengatur `zram-generator` dengan `zstd`, `vm.swappiness = 100`, dan `vm.vfs_cache_pressure = 50`. |
| Storage dan installer | Backend UEFI disk kosong serta konfigurasi Btrfs/Snapper terbukti di VM. Calamares lokal API 3.4 telah dibangun ulang dan lulus uji: wizard, cancel aman, instalasi Btrfs/@/@home/@snapshots, reboot tanpa ISO (order=c), SDDM, dan login akun baru berfungsi dengan 0 unit gagal. Rollback bootloader dan hardware fisik masih perlu diuji. Detail di roadmap. |
| Telemetri dan integrasi Harness | `constd` punya prototipe HTTP GET/JSON. Integrasi dengan Harness dan transport MCP masih direncanakan. |
| Sandbox dan izin | Ada wrapper Bubblewrap yang menolak eksekusi saat `bwrap` tidak tersedia. Kebijakan akses dan integrasi agen masih perlu diuji. |
| Screenshot dan rekaman | Print, Alt+Print, launcher, serta Waybar memakai satu helper screenshot area/seluruh desktop dengan clipboard dan cancel. Dukungan runtime mengikuti bukti di roadmap; preview/anotasi serta recorder tetap di fase 07A. |
| Shell, widget, dan aset | Konfigurasi desktop serta logo tersedia. Shell/Settings terpadu, katalog widget, aksesibilitas, dan pipeline aset masih dalam pengembangan. |

---

## Struktur Repositori

```text
ConstOS/
├── assets/                        # Logo dan aset visual ConstOS
├── docs/                          # Arsitektur distro & panduan teknis
│   ├── architecture.md            # Arsitektur, batas komponen, dan izin
│   ├── build-guide.md             # Build ISO di lingkungan Arch/CachyOS
│   └── acceptance-guide.md        # Uji terpadu boot, desktop, dan instalasi
├── iso/                           # Mesin build ISO (Archiso + CachyOS profile)
│   ├── buildiso.sh                # Skrip utama generator ISO
│   ├── profiledef.sh              # Metadata ISO ConstOS
│   ├── pacman.conf                # Repositori paket CachyOS dan Arch
│   ├── packages.x86_64            # Manifest paket sesi live
│   └── airootfs/                  # Root filesystem overlay
│       ├── etc/os-release         # Identitas resmi ConstOS
│       ├── etc/systemd/zram-generator.conf
│       ├── etc/sysctl.d/99-constos-memory.conf
│       └── usr/local/bin/const-sandbox
├── desktop/                       # Konfigurasi antarmuka Hyprland
│   ├── hypr/                      # Konfigurasi Hyprland
│   ├── waybar/                    # Status bar dan metrik desktop
│   └── wofi/                      # App launcher
├── installer/                     # Launcher, konfigurasi, dan backend Calamares UEFI
├── daemons/
│   └── constd/                    # Prototipe monitor /proc dan /sys
└── packages/                      # Paket core/desktop dan resep Const Harness
```

---

## Cara Membangun ISO

Lihat panduan lengkap di [docs/build-guide.md](docs/build-guide.md).

```bash
packages="$PWD/iso/out/packages-$(date -u +%Y%m%dT%H%M%SZ)"
calamares="${packages}-calamares"
bash packages/build-local.sh "$packages"
bash packages/build-calamares.sh "$calamares"
bash iso/buildiso.sh --stage-only --packages-dir "$packages" --calamares-dir "$calamares"
sudo bash iso/buildiso.sh --packages-dir "$packages" --calamares-dir "$calamares" -v
```

---

## Pengembangan

ConstOS dikembangkan oleh Alif Constantine. Urutan integrasi, target rilis, dan kriteria verifikasi ada di [roadmap pengembangan](implementation_plan.md).

Arah visual ditetapkan di [design.md](design.md): dasar hitam/putih, aksen biru yang dapat diganti, serta rancangan tema yang mengikuti wallpaper. Dokumen ini menjadi acuan desain; pemilih aksen, generator palet, dan Settings tersebut belum diimplementasikan.

Baseline ISO live sudah dibangun di Linux dan diuji di VM UEFI. Bukti itu tidak otomatis berlaku untuk integrasi tema/desktop/installer berikutnya. Gunakan [panduan pengujian terpadu](docs/acceptance-guide.md) untuk memeriksa alur baru dari boot sampai instalasi disk kosong dan reboot tanpa ISO; status aktual ada di roadmap.

Runner smoke Live UEFI dan workflow Linux manual tersedia untuk mengulang pemeriksaan dua entri GRUB, tiga shortcut, jaringan, ZRAM, dan jurnal TTY. Cara menjalankan serta batas buktinya ada di [panduan build](docs/build-guide.md#build-tercatat-dan-smoke-live-uefi); hasil eksekusi dicatat di roadmap, terpisah dari kesiapan workflow CI.

Panduan kontribusi agen ada di [AGENTS.md](AGENTS.md), dan prosedur kerja proyek diindeks di [SKILLS.md](SKILLS.md). Perubahan yang memengaruhi perilaku, arsitektur, atau cara kerja harus menyertakan pembaruan dokumen yang relevan; detail aturannya ada di AGENTS.md.

---

## Lisensi

Proyek ini dirilis di bawah lisensi [GPLv3](https://www.gnu.org/licenses/gpl-3.0.html). Komponen Const Harness dilisensikan secara terpisah.
