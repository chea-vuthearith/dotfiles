#!/usr/bin/env bash
# Install the shared sops age key on this host and check it decrypts the pinned secrets.yaml.
#
#   scripts/sops-setup.sh             # paste the key (from Bitwarden), then Ctrl-D
#   scripts/sops-setup.sh <key-file>  # key from a file
#
# Then run `nsw`. Needs the real secrets input (GitHub SSH), not the bootstrap stub.
set -euo pipefail

if ! command -v sops >/dev/null || ! command -v age-keygen >/dev/null; then
	exec nix shell nixpkgs#sops nixpkgs#age -c "$0" "$@"
fi

repo=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
host_key=/var/lib/sops-nix/key.txt

case ${1:-} in
-h | --help)
	sed -n '2,7p' "$0"
	exit 0
	;;
"")
	echo "Paste the age secret key (AGE-SECRET-KEY-...), then Ctrl-D:" >&2
	key=$(cat)
	;;
*) key=$(<"$1") ;;
esac
[[ $key == *AGE-SECRET-KEY-* ]] || {
	echo "error: no AGE-SECRET-KEY in input" >&2
	exit 1
}

pub=$(age-keygen -y <<<"$key")
echo "public key: $pub" >&2

sops_file=$(nix eval --raw "$repo#nixosConfigurations.$(hostname).config.sops.defaultSopsFile")
if ! SOPS_AGE_KEY=$key sops -d "$sops_file" >/dev/null 2>&1; then
	echo "error: this key does not decrypt $sops_file (not a recipient in .sops.yaml)" >&2
	exit 1
fi

sudo install -D -m600 -o root -g root /dev/stdin "$host_key" <<<"$key"
echo "installed $host_key" >&2

echo "done; run nsw" >&2
