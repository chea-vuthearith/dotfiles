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

Partition, format and mount the target at `/mnt` as usual, then:

```sh
nix-shell -p git
git clone https://github.com/chea-vuthearith/dotfiles.git /tmp/dotfiles
cd /tmp/dotfiles
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

`nixos-install` asks for the root password at the end. Set kuro's password too, then reboot:

```sh
nixos-enter --root /mnt -c 'passwd kuro'
reboot
```

If NixOS is already installed (any config), clone the repo and run `scripts/bootstrap.sh <host>` instead.
That runs `nixos-rebuild switch`.

## 2. First boot

Log in as `kuro` and move the checkout to where the config expects it (`repoDir`; hot-reload symlinks point
there):

```sh
git clone https://github.com/chea-vuthearith/dotfiles.git ~/dotfiles
```

If you changed hardware config or host files in `/tmp/dotfiles` during the install, copy them over. That
copy is gone after the reboot, so commit them from the installer or redo step 1's generation here with
`nixos-generate-config --show-hardware-config`.

## 3. sops host key

Every host decrypts `secrets.yaml` with its own age key at `/var/lib/sops-nix/key.txt`:

```sh
sudo mkdir -p /var/lib/sops-nix
sudo age-keygen -o /var/lib/sops-nix/key.txt
sudo age-keygen -y /var/lib/sops-nix/key.txt   # public key: age1...
```

On a machine that holds the admin key (`~/.config/sops/age/keys.txt`, backed up in Bitwarden), in a
checkout of the secrets repo:

1. Add the public key to the recipients in `.sops.yaml`.
2. `sops updatekeys secrets.yaml`, commit, push.

## 4. Switch to the real config

Back on the new host:

```sh
cd ~/dotfiles
nix flake update secrets   # pick up the re-encrypted secrets.yaml
nsw
```

`nsw` builds as you with `--sudo`, so it uses your SSH agent to fetch the secrets repo. Check:

```sh
ls /run/secrets/                   # decrypted secrets for this host
systemctl --failed
```

Commit and push the `flake.lock` bump (and any new host files) through a PR, as usual.
