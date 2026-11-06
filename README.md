<div align="center">

<img src="assets/const-logo-dark.png" alt="ConstOS Logo" width="320"/>

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
| Memori dan ZRAM | Overlay live mengatur `zram-generator` dengan `zstd`, `vm.swappiness = 100`, dan `vm.vfs_cache_pressure = 50`. |
| Storage dan recovery | Perkakas Btrfs dan Snapper masuk manifest. Penataan subvolume dan recovery pada sistem terpasang masih dalam pengembangan. |
| Telemetri dan integrasi Harness | `constd` punya prototipe HTTP GET/JSON. Integrasi dengan Harness dan transport MCP masih direncanakan. |
| Sandbox dan izin | Ada wrapper Bubblewrap yang menolak eksekusi saat `bwrap` tidak tersedia. Kebijakan akses dan integrasi agen masih perlu diuji. |
| Screenshot dan rekaman | Shortcut serta aksi Waybar untuk screenshot tersedia, tetapi belum tercatat teruji. Preview/anotasi, rekaman video, dan rekaman audio direncanakan di fase 07A roadmap. |
| Shell, widget, dan aset | Konfigurasi desktop serta logo tersedia. Shell/Settings terpadu, katalog widget, aksesibilitas, dan pipeline aset masih dalam pengembangan. |

---

## Struktur Repositori

```text
ConstOS/
├── assets/                        # Logo dan aset visual ConstOS
├── docs/                          # Arsitektur distro & panduan teknis
│   ├── architecture.md            # Arsitektur, batas komponen, dan izin
│   └── build-guide.md             # Panduan build ISO di lingkungan Arch/CachyOS
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
├── installer/                     # Rancangan konfigurasi dan branding Calamares
├── daemons/
│   └── constd/                    # Prototipe monitor /proc dan /sys
└── packages/                      # Packaging pacman untuk Const Harness (.pkg.tar.zst)
```

---

## Cara Membangun ISO

Lihat panduan lengkap di [docs/build-guide.md](docs/build-guide.md).

```bash
bash iso/buildiso.sh --stage-only
sudo bash iso/buildiso.sh -v
```

---

## Pengembangan

ConstOS dikembangkan oleh Alif Constantine. Urutan integrasi, target rilis, dan kriteria verifikasi ada di [roadmap pengembangan](implementation_plan.md).

ISO live sudah dibangun di Linux dan diuji di VM UEFI. Boot ke Hyprland, launcher, terminal, pengelola berkas, jaringan, ZRAM, dan console fallback berfungsi. Fokus berikutnya adalah Boot UI dan jalur instalasi ke disk.

Panduan kontribusi agen ada di [AGENTS.md](AGENTS.md), dan prosedur kerja proyek diindeks di [SKILLS.md](SKILLS.md). Perubahan yang memengaruhi perilaku, arsitektur, atau cara kerja harus menyertakan pembaruan dokumen yang relevan; detail aturannya ada di AGENTS.md.

---

## Lisensi

Proyek ini dirilis di bawah lisensi [GPLv3](https://www.gnu.org/licenses/gpl-3.0.html). Komponen Const Harness dilisensikan secara terpisah.
