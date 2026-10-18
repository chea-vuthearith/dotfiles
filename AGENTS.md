# Repository Guidelines

## Worktrees First (mandatory)
**Never work directly in the main worktree (`~/dotfiles`).** Before doing *any* work (first edit, `git switch`/`checkout`, `git add`, commit, rebase, stash, formatter run), worktree out:

- Create the worktree with the omp `herdr_worktree` tool (`branch: "<type>/<topic>"`, `base:` the parent PR's branch when stacking, else `origin/main`), end the turn, and resume in the new workspace. Never `git worktree add`, `herdr worktree create` or `/move` by hand.
- `~/dotfiles` is the deploy checkout: it stays on `main`, clean, and only ever moves by `git pull` (via `nsw`). Hot-reload symlinks point into it, so a branch checked out there goes live immediately.
- Read-only inspection (`git log`, `git show`, `nix eval`) from `~/dotfiles` is fine. Rewriting remote PR branches needs no checkout: `git replay --ref-action=print --onto <base> <range>`, then push the printed SHAs with `--force-with-lease`.
- If you find yourself in `~/dotfiles` with changes or off `main`, stop and move the work to a worktree before continuing.

## Project Overview
NixOS + home-manager configuration for one user (`kuro`) on three hosts: `laptop`, `desktop` (both workstation, Hyprland + DankMaterialShell) and `server` (headless old laptop). One flake, all hosts `x86_64-linux`, nixpkgs `nixos-unstable`.

## Architecture & Data Flow
Dendritic layout: **flake-parts + import-tree, one file per feature**.

```
flake.nix ─ import-tree ./modules ─► every modules/**/*.nix is a flake-parts module
  feature file ─► flake.modules.nixos.<profile>       (NixOS module)
               └► flake.modules.homeManager.<profile> (home-manager module for kuro)
  modules/hosts/<h>/default.nix ─► hosts.<h>.profiles = ["base" "desktop"]
  modules/flake/hosts.nix ─► nixosConfigurations.<h> = nixosSystem {
        modules of every profile in hosts.<h>.profiles ++ ["host-<h>"],
        home-manager.users.kuro.imports = matching homeManager modules }
```

- Profiles: `base` (all hosts), `desktop` (laptop + desktop), `host-<name>` (one host). Missing profile/class combos are skipped silently.
- A feature owns **everything** about itself in one file, across classes and profiles: packages, overlay, `nix.settings` caches, firewall ports, user groups, HM config, aliases. Example: `modules/base/aria2.nix` publishes `homeManager.base` (CLI), `nixos.desktop` (daemon + `aria2` group) and `homeManager.desktop` (secret, symlink).
- Never define the same feature in two files or per host when it can be shared. Host files hold only real differences (hardware, monitors, IPs, power).
- Flake-level options (`modules/flake/meta.nix`): `config.username` (`"kuro"`), `config.repoDir` (`/home/kuro/dotfiles`). Read them in the **outer** function.

## Key Directories
- `modules/flake/` – scaffolding: `flake-parts.nix`, `meta.nix` (options), `hosts.nix` (host builder, `lib.toLocal`).
- `modules/base/` – every host: nix settings, users/sudo, cli, zsh, nvim, git, ssh, tailscale, herdr, ai (omp/claude/opencode), `langs/*` (toolchains + LSPs).
- `modules/desktop/` – workstation profile: hyprland (`conf/*.lua`), DMS shell (`shell.nix`), stylix theme, ghostty, zed, yazi, xdg, sound, keep-awake.
- `modules/hosts/<h>/` – `default.nix` (profiles + `_hardware-configuration.nix` import) and host-only modules.
- `scripts/maintain.sh` – manual helper; `wallpapers/` – stylix image.

## Development Commands
```sh
# build a host (no --impure; hardware configs are in-repo)
nix build --no-link .#nixosConfigurations.<laptop|desktop|server>.config.system.build.toplevel
# fail on any evaluation warning
nix eval --no-eval-cache --option abort-on-warn true --raw .#nixosConfigurations.<h>.config.system.build.toplevel.drvPath
# inspect a merged value
nix eval --json .#nixosConfigurations.<h>.config.users.users.kuro.extraGroups
nix eval .#nixosConfigurations.<h>.config.home-manager.users.kuro.programs.zsh.shellAliases.nsw
# deploy (zsh aliases from modules/base/zsh/default.nix)
nsw    # git pull; nixos-rebuild switch --sudo --flake ~/dotfiles#<hostname>
nswu   # nix flake update + nsw --upgrade
nsws   # nsw via the other workstation's LAN harmonia cache (modules/hosts/{laptop,desktop}/zsh.nix)
# format
alejandra -q modules   # Nix
stylua <file.lua>      # Lua (config: modules/base/nvim/conf/stylua.toml)
```
There is no `formatter`, `devShell` or `checks` output; `nix fmt` errors.

## Code Conventions & Common Patterns
- Feature module shape:
  ```nix
  {config, inputs, ...}: let inherit (config) username; in {   # flake-parts scope
    flake.modules.nixos.base = {pkgs, ...}: { ... };           # NixOS scope
    flake.modules.homeManager.base = {pkgs, osConfig, ...}: { ... };  # HM scope
  }
  ```
  Use `{...}:` when no flake-scope args are needed. Files are named after the feature (`tailscale.nix`, `nvim/default.nix` with assets alongside).
- Overlays live with their feature (`nixpkgs.overlays` in `ai`, `herdr`, `hyprland`, `theme`); use `final.stdenv.hostPlatform.system`, never `pkgs.system` (deprecated, warns).
- User groups are appended by the owning feature: `users.users.${username}.extraGroups = ["docker"];`.
- HM reads host facts via `osConfig` (e.g. `osConfig.networking.hostName`).
- Host-specific opt-out: `lib.mkForce` in `modules/hosts/<h>/` (e.g. `server/agent.nix` disables keychain/ssh-agent to keep the forwarded agent).
- Hot-reload configs: `config.lib.file.mkOutOfStoreSymlink (lib.toLocal ./conf)` links into the `~/dotfiles` checkout (nvim `conf/`, hypr `conf/`, zed, herdr `config.toml`). Edits in a worktree go live only after merge + `nsw`; verify them beforehand through build output. Everything else (`builtins.readFile`, `./file` sources, zsh `*.sh` snippets) needs `nsw`.
- Files herdr/apps rewrite are copied by `home.activation`, not symlinked (`base/herdr/machines.nix`).
- herdr is patched (`base/herdr/session-machines.patch`) so saved SSH machines are per local session: `default` uses `~/.local/state/herdr/client/endpoints.json`, others `client/sessions/<name>/endpoints.json`. Declare them in the `sessions` attrset of `base/herdr/machines.nix`; re-check the patch when bumping the `herdr` input.
- Files prefixed `_` are not imported by import-tree (`_hardware-configuration.nix`).
- zsh snippets (`base/zsh/{plugins,zshrc,keys}.sh`) are concatenated into `initContent`; guard optional tools: `if (( $+commands[wl-copy] )); then ... fi`.
- Hyprland is configured in **Lua** (`modules/desktop/hyprland/conf/{general,keybinds,rules,auto}.lua`, tabs). API `hl.bind(keys, hl.dsp.*, opts)`; stubs at `${pkgs.hyprland}/share/hypr/stubs/hl.meta.lua` (wired via generated `.luarc.json`), but bind opts are whatever `hlBind` reads in Hyprland's `src/config/lua/bindings/LuaBindingsToplevel.cpp` (stubs omit `mouse`, `auto_consuming`). Feature-owned binds go in the feature's Nix file via `wayland.windowManager.hyprland.extraLuaFiles.<name>.content` (see `desktop/keep-awake.nix`). Gotchas: repeat flag is `repeating` (not `repeatable`); keyboard resize needs `relative = true`.

## Important Files
- `flake.nix` – inputs only; outputs = `mkFlake (import-tree ./modules)`.
- `modules/flake/hosts.nix` – how profiles become `nixosConfigurations`; defines `lib.toLocal`.
- `modules/hosts/<h>/default.nix` – host profile list.
- `modules/base/nix.nix` – substituters, gc/optimise, unfree.
- `modules/base/zsh/default.nix` – `nsw`/`nswu`.
- `modules/desktop/shell.nix` – DMS settings (idle/lock/suspend).
- `modules/base/ai/` – omp (`programs.omp` from the `omp` flake, package from nixpkgs), custom tools, `APPEND_SYSTEM.md`, agent skills (`skills/`, upstream `herdr` + `herdr-team` with `herdr-label`/`herdr-name`/`herdr-msg` helpers) for omp, Claude Code and opencode.

## Runtime/Tooling Preferences
- Nix flakes only; never `--impure`, never `/etc/nixos` imports.
- `secrets` input is a **private** git+ssh flake (`inputs.secrets.{sshConfig,sopsFile}`); evaluation needs the user's SSH agent, which is why `nsw` builds as the user with `--sudo`. On remote hosts use `ssh -A`.
- Secrets use **sops-nix** (`modules/base/secrets.nix`): `secrets.yaml` (age-encrypted, recipients in its `.sops.yaml`) lives in the secrets repo and is decrypted to `/run/secrets/<name>` on activation. Each feature declares its own `sops.secrets.<name>` and reads `config.sops.secrets.<name>.path` (aria2, server harmonia/hindsight). Edit with `sops secrets.yaml` (admin key `~/.config/sops/age/keys.txt`, backed up in Bitwarden). Per-host key `/var/lib/sops-nix/key.txt` is the only per-host bootstrap: create with `age-keygen`, add its public key to `.sops.yaml`, `sops updatekeys secrets.yaml`, bump the lock.
- Fresh machine (no GitHub SSH yet): `scripts/bootstrap.sh <host>` (installed system) or `scripts/bootstrap.sh <host> --install /mnt` (installer ISO) overrides the input with `bootstrap/secrets-stub` (`sshConfig = ""`, empty `secrets.yaml`, `bootstrap = true`; lock file untouched). `secrets.nix` then skips sops validation/decryption, so sops consumers stay down until the per-host key is set up and a real `nsw` runs. Keep the stub's attributes in sync with every `inputs.secrets.*` use.
- Hand-placed by choice, never committed or in sops: `/etc/wireguard/wg0.conf`, `/var/lib/tailscale/authkey` (rotating; only needed while logged out).
- Remote access is Tailscale SSH (MagicDNS names `laptop`, `desktop`, `server`); no OpenSSH server is configured.
- New files must be `git add`ed before flake evaluation sees them.
- `hyprctl` from a nix shell may need `env -u LD_LIBRARY_PATH hyprctl ...`; test dispatchers live with `hyprctl dispatch 'hl.dsp.window.resize({x = -100, y = 0, relative = true})'`.
- Work lands as stacked draft PRs (`gh stack`), one worktree and one concern per branch.

## Testing & QA
No tests, CI or `checks`. Before pushing:
1. Build all three hosts (command above); a change in `base/` affects every host.
2. Run the `abort-on-warn` eval for each host; keep warnings at zero.
3. Spot-check merged values with `nix eval` (groups, aliases, services) when moving options between files.
4. Exercise runtime behaviour where possible (`hyprctl dispatch`, built `home-files` under `nix build ...home-manager.users.kuro.home-files`).
