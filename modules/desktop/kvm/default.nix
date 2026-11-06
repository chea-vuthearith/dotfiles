{...}: let
  port = 4242;
  # Keyboard + mouse only (lan-mouse shares nothing else).
  # While the KVM is on, exactly one machine (the owner) gets *every* keyboard and mouse: the
  # other machine captures its own local input and forwards it to the owner.
  # - SUPER+X (from any keyboard, so it lands on the owner): the owner starts forwarding to
  #   the peer; the peer, entered by it, stops forwarding. Ownership flips.
  # - SUPER+SHIFT+X: KVM off; nobody forwards, each machine uses its own devices again.
  # Each machine's cursor returns to where it was when that machine lost control.
  # Only keybinds switch: screen edges never do (patched, see `lan-mouse` below).
  # `position` is only the side lan-mouse's internal barrier sits on; `kvm` crosses it with a
  # virtual pointer.
  # `fingerprint` is the sha256 of *this* host's ~/.config/lan-mouse/lan-mouse.pem (generated
  # by lan-mouse on first run; the peer authorizes it). If that file is ever deleted, update with
  #   openssl x509 -in ~/.config/lan-mouse/lan-mouse.pem -outform der | sha256sum
  # (colon-separated).
  peers = {
    laptop = {
      peer = "desktop";
      position = "right";
      fingerprint = "cc:f0:5c:b9:9b:c0:81:e5:9f:34:fc:0f:52:89:f2:31:29:67:24:a2:3d:e2:04:a9:ba:0f:4c:7f:42:a2:ba:29";
    };
    desktop = {
      peer = "laptop";
      position = "left";
      fingerprint = "d4:ac:ad:7f:40:07:45:70:92:93:22:fe:07:e0:d2:3e:58:b0:03:03:ce:2c:13:c1:f2:89:5a:ea:0a:5c:d8:72";
    };
  };
in {
  # Peer discovery uses mDNS from base/mdns.nix: `<host>.local` never resolves via Tailscale.
  flake.modules.nixos.desktop.networking.firewall.allowedUDPPorts = [port];

  flake.modules.homeManager.desktop = {
    pkgs,
    lib,
    osConfig,
    ...
  }: let
    self = peers.${osConfig.networking.hostName};
    toml = pkgs.formats.toml {};
    lan-mouse = pkgs.lan-mouse.overrideAttrs (old: {
      patches =
        (old.patches or [])
        ++ [
          # The controlled machine's pointer reaching the edge no longer hands control back.
          ./no-edge-return.patch
          # Deactivating the client being forwarded to releases cleanly (key-ups + Leave)
          # instead of leaving input grabbed; `kvm off` relies on it.
          ./release-on-deactivate.patch
        ];
    });
    # Peer has no hostname on purpose: lan-mouse would resolve it through MagicDNS to a
    # Tailscale address. `kvm` fills in the LAN IP found via mDNS instead.
    config = toml.generate "lan-mouse.toml" {
      inherit port;
      # Emergency escape on the forwarding machine only (default chord); normal use is SUPER+X.
      release_bind = ["KeyLeftCtrl" "KeyLeftShift" "KeyLeftMeta" "KeyLeftAlt"];
      authorized_fingerprints.${(peers.${self.peer}).fingerprint} = self.peer;
      clients = [{inherit (self) position;}];
    };
    kvm = pkgs.writeShellApplication {
      name = "kvm";
      runtimeInputs = with pkgs; [lan-mouse systemd iproute2 coreutils gnugrep gawk jq libnotify hyprland wlrctl];
      text = ''
        peer=${self.peer}
        notify() { notify-send -a "KVM" "$@" & }
        # Where the cursor was when this machine lost control; put back when it regains it.
        saved="''${XDG_RUNTIME_DIR:?}/kvm-cursor"
        # Touched by the lan-mouse service the moment we start forwarding to the peer.
        entered="$XDG_RUNTIME_DIR/kvm-entered"
        warp() { hyprctl dispatch "hl.dsp.cursor.move({ x = $1, y = $2 })" >/dev/null; }
        # lan-mouse assigns the single configured client handle; read it back.
        id=$(lan-mouse cli list | awk -F'[ :]' '/^id /{print $2; exit}')
        [ -n "$id" ] || { notify "KVM unavailable" "lan-mouse is not running"; exit 1; }
        active() { lan-mouse cli list | grep -q 'active: true'; }

        # Stop forwarding and put the cursor back. Called repeatedly by the service (one log
        # line per Enter packet), so only the first caller restores.
        back() {
          if mv "$saved" "$saved.$$" 2>/dev/null; then
            read -r x y <"$saved.$$"
            rm -f "$saved.$$"
            warp "$x" "$y"
          fi
          if active; then lan-mouse cli deactivate "$id"; fi
        }

        # Start forwarding this machine's keyboard and mouse to the peer. Entering the peer
        # also makes the peer stop forwarding to us (lan-mouse releases on incoming Enter).
        forward() {
          ip=$(resolvectl query -4 --protocol=mdns --legend=no "$peer.local" 2>/dev/null | awk '{print $2; exit}')
          # Directly connected (no gateway), not via Tailscale/WireGuard: same physical LAN.
          route=$(ip route get "''${ip:-0.0.0.0}" 2>/dev/null || true)
          if [ -z "$ip" ] || grep -qE ' via |dev (tailscale0|wg0) ' <<<"$route"; then
            return 1
          fi

          [ -e "$saved" ] || hyprctl cursorpos | tr -d , >"$saved"
          read -r x y < <(hyprctl monitors -j | jq -r '
            map({l: .x, r: (.x + .width / .scale), y: (.y + .height / .scale / 2)})
            | ${
          if self.position == "left"
          then ''min_by(.l) | "\(.l + 1 | floor) \(.y | floor)"''
          else ''max_by(.r) | "\(.r - 1 | floor) \(.y | floor)"''
        }')
          rm -f "$entered"
          lan-mouse cli set-ips "$id" "$ip"
          lan-mouse cli activate "$id"
          # lan-mouse starts forwarding when pointer *motion* crosses its barrier; a warp alone
          # never triggers it (Hyprland only checks barriers on relative motion). So park the
          # cursor next to it and push it across with a virtual pointer. The barrier appears a
          # few ms after activation: retry until lan-mouse reports it (at most ~0.5 s).
          for _ in $(seq 25); do
            warp "$x" "$y"
            wlrctl pointer move ${
          if self.position == "left"
          then "-4"
          else "4"
        } 0
            sleep 0.02
            [ -e "$entered" ] && return 0
          done
          back
          return 1
        }

        case "''${1:-}" in
          # SUPER+X: runs on the owner (every keyboard goes there); give ownership to the peer.
          "")
            if forward; then
              notify "KVM" "All keyboards and mice now control $peer"
            else
              notify "KVM unavailable" "$peer is off or not on this network"
            fi
            ;;
          # SUPER+SHIFT+X: KVM off. Entering the peer makes it stop forwarding to us; then we
          # stop forwarding too (patched deactivate releases cleanly).
          off)
            forward || true
            back
            notify "KVM off" "Each machine uses its own keyboard and mouse"
            ;;
          # From the service: the peer entered us (it is now the forwarder) or the emergency
          # release chord was pressed.
          back) back ;;
          *) echo "usage: kvm [off]" >&2; exit 2 ;;
        esac
      '';
    };
  in {
    home.packages = [kvm];
    xdg.configFile."lan-mouse/config.toml".source = config;

    wayland.windowManager.hyprland.extraLuaFiles.kvm.content = ''
      hl.bind("SUPER + X", hl.dsp.exec_cmd("kvm"))
      hl.bind("SUPER + SHIFT + X", hl.dsp.exec_cmd("kvm off"))
    '';

    # Always listening, so the peer can forward to this machine. The daemon's log is read
    # in-process (journalctl -f added ~0.5 s) to react to handovers immediately.
    systemd.user.services.lan-mouse = {
      Unit = {
        Description = "lan-mouse software KVM";
        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target"];
      };
      Service = {
        ExecStart = toString (pkgs.writeShellScript "lan-mouse-kvm" ''
          set -o pipefail
          ${lib.getExe lan-mouse} daemon 2>&1 | while IFS= read -r line; do
            printf '%s\n' "$line"
            case "$line" in
              *"entered this device"* | *"releasing capture: release-bind pressed"*)
                ${lib.getExe kvm} back &
                ;;
              *"entering client"*) : >"$XDG_RUNTIME_DIR/kvm-entered" ;;
            esac
          done
        '');
        Restart = "on-failure";
      };
      Install.WantedBy = ["graphical-session.target"];
    };
  };
}
