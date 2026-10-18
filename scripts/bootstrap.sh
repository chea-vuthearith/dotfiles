#!/usr/bin/env bash
# Build/install a host without the private `secrets` input (no GitHub SSH access yet).
# The stub in bootstrap/secrets-stub leaves the SSH work-host config empty and skips sops
# (see modules/base/secrets.nix); afterwards set up /var/lib/sops-nix/key.txt and run `nsw`.
#
#   scripts/bootstrap.sh <host>                # on an installed system: nixos-rebuild switch
#   scripts/bootstrap.sh <host> --install /mnt # from the installer ISO: nixos-install --root /mnt
set -euo pipefail

usage() {
	echo "usage: $0 <laptop|desktop|server> [--install <root>]" >&2
	exit 1
}

[[ $# -ge 1 ]] || usage
host=$1
shift

repo=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
flags=(
	--flake "$repo#$host"
	--override-input secrets "path:$repo/bootstrap/secrets-stub"
	--no-write-lock-file
	--option extra-experimental-features "nix-command flakes"
)

case ${1:-} in
"") exec sudo nixos-rebuild switch "${flags[@]}" ;;
--install)
	[[ $# -eq 2 ]] || usage
	exec sudo nixos-install --root "$2" "${flags[@]}"
	;;
*) usage ;;
esac
