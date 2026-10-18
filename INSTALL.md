# Installing a host

The `secrets` flake input (`git+ssh://git@github.com/chea-vuthearith/secrets.git`) is private, so a
fresh machine without a GitHub SSH key can't evaluate this flake. `scripts/bootstrap.sh` swaps in the
public stub `bootstrap/secrets-stub` (`sshConfig = ""`, empty `secrets.yaml`, `bootstrap = true`) and
leaves `flake.lock` untouched. With the stub, `modules/base/secrets.nix` declares the sops secrets but
doesn't validate or decrypt them. After the first real `nsw`, everything runs normally.

| Stays off until the real `nsw` | Why |
| --- | --- |
| Work SSH hosts (`~/.ssh/config` extras) | `sshConfig` comes from the secrets repo |
| aria2 RPC secret (desktop), harmonia + hindsight (server) | no sops decryption |

## 1. Install NixOS (installer ISO)

Partition, format and mount the target at `/mnt` as usual. Clone straight to where the installed system
expects the checkout (`repoDir` = `/home/kuro/dotfiles`). The nvim, hypr, zed and herdr configs are
out-of-store symlinks into it (`lib.toLocal`), so they only resolve if the checkout is there:

```sh
nix-shell -p git
mkdir -p /mnt/home/kuro
git clone https://github.com/chea-vuthearith/dotfiles.git /mnt/home/kuro/dotfiles
cd /mnt/home/kuro/dotfiles
```

**Existing host** (`laptop`, `desktop`, `server`): if the disks changed, regenerate the hardware config
and overwrite the committed one:

```sh
nixos-generate-config --root /mnt --show-hardware-config > modules/hosts/<host>/_hardware-configuration.nix
```

**New host**: create `modules/hosts/<host>/default.nix` with the profile list (copy
`modules/hosts/server/default.nix`; add `"desktop"` for a workstation), write the hardware config as above
into `modules/hosts/<host>/_hardware-configuration.nix`, and `git add` both (flakes ignore untracked files).

Install:

```sh
scripts/bootstrap.sh <host> --install /mnt
```

`nixos-install` asks for the root password at the end. Give the checkout to kuro (it was cloned as root),
set kuro's password, then reboot:

```sh
nixos-enter --root /mnt -c 'chown -R kuro:users /home/kuro && passwd kuro'
reboot
```

If NixOS is already installed (any config), clone to `~/dotfiles` and run `scripts/bootstrap.sh <host>`
instead. That runs `nixos-rebuild switch`.

## 2. First boot

Log in as `kuro`. The hot-reload symlinks already resolve because `~/dotfiles` exists. Commit any hardware
config or new host files later, once GitHub SSH works.

## 3. sops host key

Every host decrypts `secrets.yaml` with the same age key: the admin key, backed up in Bitwarden, which is
the only recipient in the secrets repo's `.sops.yaml`. Put it in place as root (nothing generates it):

```sh
sudo install -D -m600 /dev/stdin /var/lib/sops-nix/key.txt   # paste the key from Bitwarden, then Ctrl-D
nix-shell -p age --run 'sudo $(command -v age-keygen) -y /var/lib/sops-nix/key.txt'   # must print age1d73s…
```

To edit secrets on this machine too, copy it to `~/.config/sops/age/keys.txt` (mode 600).

## 4. Switch to the real config

Back on the new host:

```sh
cd ~/dotfiles
nix flake update secrets   # only if the secrets repo moved since the last lock bump
nsw
```

`nsw` builds as you with `--sudo`, so it uses your SSH agent to fetch the secrets repo. Check:

```sh
ls /run/secrets/                   # decrypted secrets for this host
systemctl --failed
```

Commit and push the `flake.lock` bump (and any new host files) through a PR, as usual.
