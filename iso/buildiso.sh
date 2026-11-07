#!/usr/bin/env bash
set -euo pipefail

iso_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
repo_dir=$(dirname -- "$iso_dir")
work_dir="$iso_dir/work"
out_dir="$iso_dir/out"
stage_only=false
packages_dir=
options=()

usage() {
    printf '%s\n' 'Usage: buildiso.sh [-v] [-w work_dir] [-o out_dir] [--packages-dir DIR] [--stage-only]'
}

die() {
    printf 'ConstOS build: %s\n' "$*" >&2
    exit 1
}

while (( $# )); do
    case "$1" in
        -h|--help) usage; exit 0 ;;
        -v) options+=(-v); shift ;;
        -w|-o|--packages-dir)
            [[ -n ${2:-} && $2 != -* ]] || die "$1 requires a directory"
            case "$1" in
                -w) work_dir=$2 ;;
                -o) out_dir=$2 ;;
                --packages-dir) packages_dir=$2 ;;
            esac
            shift 2
            ;;
        --stage-only) stage_only=true; shift ;;
        *) usage >&2; die "unknown argument: $1" ;;
    esac
done

if [[ -n $packages_dir ]]; then
    packages_dir=$(cd -- "$packages_dir" && pwd)
elif (( EUID == 0 )); then
    die 'build local packages as an ordinary user first; pass --packages-dir DIR'
fi

if ! "$stage_only"; then
    [[ $(uname -s) == Linux && $(uname -m) == x86_64 ]] || die 'build on an x86_64 Linux host'
    command -v mkarchiso >/dev/null || die 'install archiso on the build host'
    (( EUID == 0 )) || die 'run the ISO build as root'
    [[ -f /usr/share/pacman/keyrings/cachyos.gpg ]] || die 'install the CachyOS keyring on the build host'
    for link in default.target display-manager.service multi-user.target.wants/NetworkManager.service; do
        [[ -L "$iso_dir/airootfs/etc/systemd/system/$link" ]] || die "expected a Linux checkout with symlinks: $link"
    done
fi

mkdir -p -- "$work_dir"
work_dir=$(cd -- "$work_dir" && pwd)
profile=$(mktemp -d -- "$work_dir/profile.XXXXXX")

cp -a -- "$iso_dir"/{profiledef.sh,packages.x86_64,pacman.conf,grub,airootfs} "$profile/"
install -m 0644 -- "$repo_dir/assets/exports/const-logo-boot.png" "$profile/grub/constos/logo.png"
root="$profile/airootfs"
install -m 0644 -- "$profile/pacman.conf" "$root/etc/pacman.conf"

# Kedua profil memakai sumber desktop/boot yang sama, bukan salinan konfigurasi.
bash "$repo_dir/desktop/install.sh" "$root"
bash "$iso_dir/install-boot.sh" "$root" live
bash "$repo_dir/installer/install.sh" "$root"

if [[ -z $packages_dir ]]; then
    packages_dir="$profile/local-packages"
    bash "$repo_dir/packages/build-local.sh" "$packages_dir"
fi
[[ -f $packages_dir/SHA256SUMS && -f $packages_dir/SOURCE_SHA256SUMS ]] ||
    die 'local packages require SHA256SUMS and SOURCE_SHA256SUMS'
(
    cd -- "$repo_dir"
    sha256sum --check --strict "$packages_dir/SOURCE_SHA256SUMS"
)
(
    cd -- "$packages_dir"
    sha256sum --check --strict SHA256SUMS
)
package_root="$root/usr/share/constos/packages"
install -d -- "$package_root"
shopt -s nullglob
for name in constos-core constos-desktop; do
    artifacts=("$packages_dir/$name"-*.pkg.tar.zst)
    (( ${#artifacts[@]} == 1 )) || die "expected one $name package"
    install -m 0644 -- "${artifacts[0]}" "$package_root/"
done
install -m 0644 -- "$packages_dir/SHA256SUMS" "$packages_dir/SOURCE_SHA256SUMS" "$package_root/"

printf 'Staged ConstOS profile: %s\n' "$profile"
if "$stage_only"; then
    exit 0
fi

mkdir -p -- "$out_dir"
# mkarchiso caches build steps in its work directory. Each run gets a fresh one.
mkarchiso_work=$(mktemp -d -- "$work_dir/mkarchiso.XXXXXX")
exec mkarchiso "${options[@]}" -w "$mkarchiso_work" -o "$out_dir" "$profile"
