# Build dan uji ConstOS Live

Profil awal menargetkan **x86_64 UEFI** dengan GRUB, kernel CachyOS BORE, dan Hyprland. Gunakan VM dengan Secure Boot dimatikan. Sumber tema boot/login, desktop live, serta installer online disiapkan untuk diuji bersama. Keberadaan konfigurasi bukan bukti instalasi/recovery lulus; ikuti [pengujian terpadu](acceptance-guide.md) dan status di roadmap. Harness tidak diperlukan.

## Siapkan host build

Clone repo di filesystem Linux pada host CachyOS x86_64 agar symlink systemd ikut terpasang. Pasang perkakas dan siapkan kepercayaan paket sebelum build.

```bash
sudo pacman -Syu --needed archiso base-devel git python cachyos-keyring archlinux-keyring grub squashfs-tools dosfstools mtools libisoburn
sudo pacman-key --populate archlinux cachyos
```

Paket diambil dari repositori CachyOS x86_64 generik dan repositori Arch. Untuk host Arch, siapkan keyring CachyOS melalui [petunjuk upstream](https://github.com/CachyOS/linux-cachyos#installation) sebelum memakai profil ini.

**Blocker installer saat audit:** `cachyos-calamares 3.4.2-4` dan varian `next 3.4.2-13` masih meminta `libboost_python314.so.1.91.0`, sedangkan repo sekarang menyediakan Boost 1.92. Build/staging saja tidak mendeteksi ini. Jangan membuat symlink ABI atau downgrade parsial. Diperlukan paket Calamares yang dibangun terhadap dependensi repo yang sama; periksa `calamares --version` dalam sesi live sebelum pengujian wizard.

## Rakit profil dan ISO

Jalankan dari root repo. Staging dapat diperiksa tanpa hak root.

```bash
# Staging non-root juga membangun paket lokal ke direktori profil baru.
bash iso/buildiso.sh --stage-only
# Untuk build penuh, siapkan artefak sebagai user biasa sebelum sudo.
packages="$PWD/iso/out/packages-$(date -u +%Y%m%dT%H%M%SZ)"
bash packages/build-local.sh "$packages"
sudo bash iso/buildiso.sh --packages-dir "$packages" -v
```

Staging menyalin profil Archiso dan memanggil `desktop/install.sh`, `iso/install-boot.sh ROOT live`, serta `installer/install.sh`. Desktop diletakkan di `/etc/skel/.config` untuk akun live; tema dan launcher dipasang pada path sistem. Dua paket target dan checksum disertakan di `/usr/share/constos/packages`, bukan sebagai repositori sementara pada target. `SOURCE_SHA256SUMS` diperiksa terhadap sumber checkout agar paket lama tidak diam-diam dipasangkan dengan overlay baru. Setiap run memakai direktori kerja baru di `iso/work/`. `-w DIR`, `-o DIR`, dan `--packages-dir DIR` mengubah lokasi kerja, output, serta input paket. ISO muncul di `iso/out/constos-*.iso` secara default. `makepkg` tidak dijalankan sebagai root; staging root juga memerlukan artefak yang sudah dibuat.

## Ekspor logo

`assets/const-logo.svg` adalah satu master simbol Const. Sesudah mengubahnya, regenerasikan ekspor menggunakan Python 3 dan `rsvg-convert` dari paket `librsvg`:

```bash
python3 assets/export-logo.py
```

Commit master beserta hasil di `assets/exports/`: PNG RGBA 160×160 untuk GRUB/Plymouth, SVG hitam untuk surface terang, dan SVG badge untuk ikon aplikasi. SDDM memakai master SVG langsung; installer mengambil varian sesuai surface. Jangan mengganti file logo di hasil staging secara manual atau mengedit ekspor sebagai sumber kedua. Periksa [manifest aset](../assets/manifest.json) saat mengubah asal, izin, atau pemakaian.

Build biasa tidak memerlukan renderer karena memakai ekspor yang sudah dikomit. Setelah logo berubah, bangun ulang paket lokal dan ISO: ISO yang sudah dibuat sebelumnya tetap memuat logo lama. Render SVG/staging bukan bukti logo sudah terlihat saat boot.


## Build tercatat dan smoke Live UEFI

Runner di `tests/live/` menguji ISO tanpa menambah service, SSH, atau konfigurasi khusus tes ke image. Host menjalankan QEMU sebagai user biasa, membuka dua VM tanpa disk terpasang, memilih entri GRUB melalui keyboard, lalu menjalankan probe dari Foot atau TTY. HTTP loopback host hanya menyajikan probe dan menerima hasil melalui jaringan user-mode QEMU; server ditutup setelah tes.

Tambahkan perkakas pada host Linux yang sudah disiapkan di atas:

```bash
sudo pacman -Syu --needed git python qemu-system-x86 \
  qemu-hw-display-virtio-gpu qemu-hw-display-virtio-vga \
  edk2-ovmf tesseract tesseract-data-eng
```

Paket QEMU Arch bersifat modular: kedua modul virtio di atas diperlukan untuk profil grafis runner; `qemu-system-x86` saja tidak cukup.

Gunakan checkout Git bersih, termasuk tanpa berkas untracked di luar path ignored. Wrapper menolak checkout Windows yang kehilangan symlink; ia tidak merekonstruksi symlink atau mengubah konfigurasi Git global. Build memerlukan root, tetapi smoke tidak. Direktori output harus baru dan parent-nya sudah ada; artefak yang sudah ada tidak ditimpa.

```bash
mkdir -p iso/out
build="$PWD/iso/out/live-$(date -u +%Y%m%dT%H%M%SZ)"
packages="${build}-packages"
bash packages/build-local.sh "$packages"
sudo -n bash tests/live/build.sh --output "$build" --packages-dir "$packages"
iso=$(python3 -c 'import json,pathlib,sys; p=pathlib.Path(sys.argv[1]); print(p/json.loads((p/"build.json").read_text())["iso_filename"])' "$build")
python3 tests/live/uefi_smoke.py \
  --iso "$iso" --build-evidence "$build/build.json" \
  --ovmf-code /usr/share/edk2/x64/OVMF_CODE.4m.fd \
  --ovmf-vars /usr/share/edk2/x64/OVMF_VARS.4m.fd \
  --output "${build}-smoke"
```

Path firmware mengikuti [paket Arch edk2-ovmf](https://archlinux.org/packages/extra/any/edk2-ovmf/files/). Gunakan pasangan CODE/VARS non-Secure-Boot yang cocok dari host, bukan firmware `secboot`. Runner menyalin template VARS ke direktori bukti; template asli tidak ditulis. Default Linux mensyaratkan akses baca/tulis `/dev/kvm`; tidak ada fallback otomatis ke TCG. `--accelerator whpx` digunakan untuk smoke pada host Windows; `--accelerator tcg` menyediakan diagnosis emulasi eksplisit. TCG bertingkat belum lulus; lihat batas bukti di roadmap. Naikkan `--timeout` dari default 300 detik per cold boot bila diperlukan untuk diagnosis. VM memakai 4 vCPU, 6 GiB RAM, dan grafis virtio. Tesseract dengan model `eng` mengenali menu sebelum input keyboard; kegagalan OCR menggagalkan tes, bukan melewati GRUB.

### Pemeriksaan dan artefak

| Jalur | Bukti yang diperiksa |
| --- | --- |
| Build Linux | SHA checkout bersih sebelum/sesudah build, checksum paket lokal dan sumbernya, seluruh symlink overlay yang terlacak tetap symlink saat staging, versi paket host, log Archiso, satu ISO beserta SHA-256. |
| Desktop | UEFI dan kernel BORE, identitas ConstOS, akun `liveuser` non-root, symlink systemd, nol unit gagal, SDDM aktif, sesi Wayland aktual, Waybar terpetakan dan tidak ada config error. `Super+Enter`, `Super+Space`, dan `Super+E` harus menghasilkan Foot aktif, surface Wofi, dan window Thunar. |
| Jaringan/ZRAM | NetworkManager aktif, IPv4 dan lease DHCP pada interface non-loopback, serta perangkat ZRAM aktif sebagai swap dengan algoritme `zstd`. Ini bukan uji internet atau Wi-Fi fisik. |
| Console fallback | Cold boot entri kedua dengan `systemd.unit=multi-user.target`, SDDM tidak aktif, controlling terminal `/dev/tty1`, dan `sudo -n journalctl -b` membaca entri dengan boot ID yang sesuai. |

`build.json`, `build.log`, `staging.log`, `host-packages.txt`, checksum, dan ISO berada di direktori build. Direktori smoke menyimpan `summary.json`, report per boot termasuk daftar paket guest, perintah/versi QEMU, hash firmware dan runner/probe, screenshot GRUB/desktop/launcher/Thunar/TTY, serta log kegagalan. Exit nonzero atau `ok: false` memblokir penerimaan. Output yang ada tidak dihapus untuk mencoba ulang; pilih direktori baru.

Untuk menguji ISO yang sudah ada, jalankan runner tanpa `--build-evidence`; hasilnya mencatat checksum tetapi **tidak mengklaim SHA sumber build**. Jika metadata diberikan, nama/checksum ISO, keberhasilan build, dan identitas checkout bersih harus cocok sebelum VM dijalankan.

Periksa screenshot secara visual sebelum mencentang acceptance. Runner belum menguji audio, portal, lock/logout, screenshot pengguna, instalasi, perangkat fisik, tema, atau kualitas render di berbagai skala. Simpan bukti hanya dari VM uji tanpa data pribadi; periksa dan redaksi sebelum membagikannya. Jangan commit ISO, salinan NVRAM, atau cache build.

### Workflow Linux tepercaya

`.github/workflows/live-uefi.yml` menyediakan `workflow_dispatch`, bukan eksekusi PR otomatis pada host berhak sudo. Siapkan runner khusus/sekali pakai berlabel `self-hosted`, `Linux`, `X64`, `constos-build` dengan prasyarat di panduan ini, keyring tepercaya, akses baca/tulis `/dev/kvm` untuk user runner, dan `sudo -n` untuk build. Jangan gunakan mesin kerja yang menyimpan data pribadi atau kredensial penandatanganan.

Isi repository variables `CONSTOS_OVMF_CODE` dan `CONSTOS_OVMF_VARS` dengan path firmware host. Jalankan workflow hanya pada ref yang sudah ditinjau. Checkout memakai `clean: true`; workspace runner bukan tempat menyimpan pekerjaan pengguna. Workflow membangun ISO, menjalankan smoke sebagai user biasa, dan mengunggah diagnostik selama 7 hari meskipun gagal; ISO, cache build, dan NVRAM tidak diunggah. Keberadaan workflow bukan bukti job GitHub sudah lulus; status eksekusi dicatat di roadmap.

## Pemeriksaan manual tambahan

Untuk diagnosis interaktif, boot ISO dengan profil VM yang sama. Periksa dua entri GRUB, tiga shortcut di atas, `uname -r`, `systemctl --failed`, `nmcli general status`, `zramctl`, serta `journalctl -b` dari console fallback. Gunakan skenario fase 02 roadmap untuk audio, file/MIME, lock/logout, screenshot, dan portal; kelulusan runner tidak menggantikan skenario tersebut.

Regresi batas disk dan arsip preflight dapat dijalankan tanpa root dan tanpa perangkat blok:

```bash
python3 -m unittest discover -s tests/installer -p 'test_*.py'
```

Tes ini bukan bukti instalasi penuh. Runner Live UEFI sekarang juga memanggil `calamares --version` pada sesi desktop untuk mendeteksi binary/library gagal sebelum menerima ISO; kelulusan runner lama sebelum gate ini ditambahkan tidak membuktikan installer siap.

## Pengujian terpadu dan recovery tema

Gunakan [panduan pengujian terpadu](acceptance-guide.md) untuk tema GRUB/Plymouth/SDDM, screenshot/cancel, audio/portal, login ulang, serta instalasi pada disk virtual baru dan reboot tanpa ISO. Skenario itu tidak dicentang hanya karena runner baseline lulus.

Tema greeter dapat dipulihkan dari TTY dengan memasang konfigurasi stock yang disertakan sumber boot, lalu restart SDDM. Restart memutus sesi grafis: simpan pekerjaan terlebih dahulu. Palet boot/greeter statis dan tidak membaca wallpaper pengguna. Opsi aksen manual/adaptif pada Settings masih berupa rancangan di `design.md`, bukan bagian dari integrasi ini.
