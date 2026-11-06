#!/usr/bin/env bash
set -euo pipefail

iso_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
repo_dir=$(dirname -- "$iso_dir")
work_dir="$iso_dir/work"
out_dir="$iso_dir/out"
stage_only=false
options=()

usage() {
    printf '%s\n' 'Usage: buildiso.sh [-v] [-w work_dir] [-o out_dir] [--stage-only]'
}

die() {
    printf 'ConstOS build: %s\n' "$*" >&2
    exit 1
}

while (( $# )); do
    case "$1" in
        -h|--help) usage; exit 0 ;;
        -v) options+=(-v); shift ;;
        -w|-o)
            [[ -n ${2:-} && $2 != -* ]] || die "$1 requires a directory"
            case "$1" in
                -w) work_dir=$2 ;;
                -o) out_dir=$2 ;;
            esac
            shift 2
            ;;
        --stage-only) stage_only=true; shift ;;
        *) usage >&2; die "unknown argument: $1" ;;
    esac
done

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
root="$profile/airootfs"
install -m 0644 -- "$profile/pacman.conf" "$root/etc/pacman.conf"

# mkarchiso seeds liveuser's home from /etc/skel.
skel="$root/etc/skel/.config"
install -Dm644 -- "$repo_dir/desktop/hypr/hyprland.lua" "$skel/hypr/hyprland.lua"
for app in mako swaylock waybar wlogout wofi; do
    cp -a -- "$repo_dir/desktop/$app" "$skel/"
done

printf 'Staged ConstOS profile: %s\n' "$profile"
if "$stage_only"; then
    exit 0
fi

mkdir -p -- "$out_dir"
# mkarchiso caches build steps in its work directory. Each run gets a fresh one.
mkarchiso_work=$(mktemp -d -- "$work_dir/mkarchiso.XXXXXX")
exec mkarchiso "${options[@]}" -w "$mkarchiso_work" -o "$out_dir" "$profile"
