---
name: constos-development
description: Gunakan saat mengubah atau meninjau profil ISO, staging desktop, installer, capture, daemon, packaging, atau dokumentasi ConstOS untuk menentukan jalur implementasi, verifikasi, dan pembaruan dokumen yang relevan.
---

# Pengembangan ConstOS

## Konteks yang dibaca

Path kode di bawah relatif terhadap root repositori. Baca [AGENTS.md](../../../AGENTS.md), [roadmap](../../../implementation_plan.md), dan [arsitektur](../../../docs/architecture.md). Untuk build/live boot, baca [panduan build](../../../docs/build-guide.md). Jangan menduplikasi status fitur atau daftar perintah instalasi paket ke skill ini.

## 1. Tentukan jalur efektif

- Untuk ISO, buka `iso/buildiso.sh`, profil, manifest, dan overlay yang terdampak. Cocokkan file sumber dengan hasil staging; jangan mengedit `iso/work/` atau `iso/out/` sebagai perbaikan permanen.
- Untuk desktop live, periksa file yang disalin script. Saat skill ini ditulis, entry Hyprland yang di-stage adalah `desktop/hypr/hyprland.lua`; konfigurasi `.conf` lama bukan bukti jalur aktif. Jika script berubah, ikuti implementasi dan perbarui prosedur ini.
- Untuk installed target, ikuti konfigurasi installer dan paket pemilik. Jangan menganggap seluruh overlay live boleh disalin ke disk.
- Untuk capture, periksa jalur screenshot, recorder, dan editor yang benar-benar terpasang; cocokkan kemampuan aktual dengan status serta acceptance di roadmap. Jangan memakai izin computer use sebagai jalan pintas.
- Untuk daemon dan packaging, temukan sumber serta konsumen yang benar-benar dipakai sebelum menambah protokol, menyalin collector, atau mengganti executable.

## 2. Pilih pemeriksaan yang sesuai

| Perubahan | Pemeriksaan minimum |
| --- | --- |
| Markdown saja | Tautan lokal/anchor, code fence, referensi lama, kesesuaian status/rencana, dan dampak dokumen menurut AGENTS.md. Tidak memerlukan build ISO. |
| Shell build/staging | Pemeriksaan sintaks shell yang diubah, jalankan staging, lalu periksa file/permission/symlink yang terdampak. Staging bukan bukti boot. |
| Manifest, kernel, initramfs, boot, atau service live | Build di Linux dan boot QEMU/OVMF sesuai panduan; amati normal boot, console fallback, dan jalur yang berubah. |
| UI, keybind, tema, widget, atau portal | Interaksi pada sesi Wayland target: fokus/keyboard, aksi nyata, cancel/error, dan monitor/scale yang relevan. Screenshot hasil render harus cocok dengan build yang diuji. |
| Screenshot atau recorder | Jalankan alur pengguna, periksa isi clipboard/hasil gambar, buka serta putar rekaman video/audio. Uji sumber, Stop/cancel/denied, dan kasus lifecycle/failure yang diubah sesuai fase 07A. |
| Installer, storage, update, atau recovery | Gunakan disk VM uji, instalasi/reboot tanpa ISO, periksa target, lalu jalankan update/recovery yang diubah. Pastikan identitas disk sebelum operasi destruktif. |
| Collector, IPC, helper, atau sandbox | Jalankan klien/skenario nyata dengan user biasa; cocokkan output dengan sumber sistem dan periksa batas izin. Uji penolakan serta penghentian akses yang terdampak. |

Gunakan command serta prasyarat build dari panduan, bukan salinan resep yang bisa tertinggal. Jangan mengklaim boot/hardware/codec/portal lulus berdasarkan manifest atau exit code saja. Jika runtime target tidak tersedia, selesaikan pemeriksaan yang mungkin dan sebutkan batasnya; jangan mencentang acceptance runtime.

## 3. Simpan bukti yang tepat

Catat identitas build, versi penting, profil VM/perangkat, skenario, hasil aktual, dan lokasi log/media yang sudah diperiksa privasinya. Pisahkan bukti live, installed, dan hardware fisik. Gunakan hasil baru untuk memperbarui status roadmap; jangan menghapus bukti lama hanya karena target desain berubah.

Bukti media untuk capture harus memperlihatkan sumber/isi yang benar serta hasil playback, bukan hanya ukuran berkas. Bukti UI harus mencakup aksi dan state setelah aksi. Jangan memasukkan media pribadi, clipboard, token, ISO, atau model ke Git.

## 4. Tutup perubahan beserta dokumennya

Ikuti matriks pembaruan di AGENTS.md. Perilaku publik masuk README/panduan, status dan bukti masuk roadmap, kontrak komponen masuk arsitektur, command build masuk panduan build, dan perubahan prosedur ini masuk skill. `SKILLS.md` berubah hanya jika katalog/trigger/lokasi skill berubah; AGENTS.md berubah jika aturan kerja berubah.

Periksa kembali tautan jika file dipindah, hapus instruksi lama yang sudah digantikan, dan sebutkan verifikasi yang benar-benar dijalankan. File skill bukan catatan progres dan bukan jaminan otomatisasi klien.
