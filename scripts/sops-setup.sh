#!/usr/bin/env bash
# Install the shared sops age key on this host and check it decrypts the pinned secrets.yaml.
#
#   scripts/sops-setup.sh             # key from ~/.config/sops/age/keys.txt, else paste it (from Bitwarden)
#   scripts/sops-setup.sh <key-file>  # key from a file
#   scripts/sops-setup.sh --user      # also copy the key to ~/.config/sops/age/keys.txt (to edit secrets here)
#
# Then run `nsw`. Needs the real secrets input (GitHub SSH), not the bootstrap stub.
set -euo pipefail

if ! command -v sops >/dev/null || ! command -v age-keygen >/dev/null; then
	exec nix shell nixpkgs#sops nixpkgs#age -c "$0" "$@"
fi

repo=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
host_key=/var/lib/sops-nix/key.txt
user_key=${XDG_CONFIG_HOME:-$HOME/.config}/sops/age/keys.txt

copy_user=false
src=
for arg in "$@"; do
	case $arg in
	--user) copy_user=true ;;
	-h | --help)
		sed -n '2,8p' "$0"
		exit 0
		;;
	*) src=$arg ;;
	esac
done

if [[ -z $src && -r $user_key ]]; then
	src=$user_key
fi
if [[ -n $src ]]; then
	key=$(<"$src")
else
	echo "Paste the age secret key (AGE-SECRET-KEY-...), then Ctrl-D:" >&2
	key=$(cat)
fi
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

if $copy_user && [[ ${src:-} != "$user_key" ]]; then
	install -D -m600 /dev/stdin "$user_key" <<<"$key"
	echo "installed $user_key" >&2
fi

echo "done; run nsw" >&2
