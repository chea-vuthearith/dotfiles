{...}: let
  port = 4242;
  # Keyboard + mouse only (lan-mouse shares nothing else). Exactly one machine owns the input
  # at a time; SUPER+X on whichever machine currently has it hands it to the other one.
  # `position` is only the screen edge lan-mouse hands over at (we warp the cursor onto it).
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
    # Peer has no hostname on purpose: lan-mouse would resolve it through MagicDNS to a
    # Tailscale address. `kvm` fills in the LAN IP found via mDNS instead.
    config = toml.generate "lan-mouse.toml" {
      inherit port;
      # While input goes to the peer, the local Hyprland never sees SUPER+X, so lan-mouse
      # catches it as the release bind (X is not forwarded); kvm-release then deactivates.
      release_bind = ["KeyLeftMeta" "KeyX"];
      authorized_fingerprints.${(peers.${self.peer}).fingerprint} = self.peer;
      clients = [{inherit (self) position;}];
    };
    kvm = pkgs.writeShellApplication {
      name = "kvm";
      runtimeInputs = with pkgs; [pkgs.lan-mouse avahi iproute2 coreutils gnugrep gawk jq libnotify hyprland wlrctl];
      text = ''
        peer=${self.peer}
        notify() { notify-send -a "KVM" "$@" & }
        # Where the cursor was when input left this machine; put back when it returns.
        saved="''${XDG_RUNTIME_DIR:?}/kvm-cursor"
        # Touched by the lan-mouse service the moment capture enters the peer.
        entered="$XDG_RUNTIME_DIR/kvm-entered"
        warp() { hyprctl dispatch "hl.dsp.cursor.move({ x = $1, y = $2 })" >/dev/null; }
        # lan-mouse assigns the single configured client handle; read it back.
        id=$(lan-mouse cli list | awk -F'[ :]' '/^id /{print $2; exit}')
        [ -n "$id" ] || { notify "KVM unavailable" "lan-mouse is not running"; exit 1; }
        active() { lan-mouse cli list | grep -q 'active: true'; }

        case "''${1:-}" in
          # Input came back (SUPER+X on the peer side, or the pointer left the peer): put the
          # cursor back first (that is what you see), then disarm the edge so only SUPER+X
          # hands over again.
          off)
            if [ -e "$saved" ]; then
              read -r x y <"$saved"
              warp "$x" "$y"
              rm -f "$saved"
            fi
            active || exit 0
            lan-mouse cli deactivate "$id"
            notify "KVM" "Keyboard and mouse back on this machine"
            exit 0
            ;;
          "") ;;
          *) echo "usage: kvm [off]" >&2; exit 2 ;;
        esac

        ip=$(avahi-resolve-host-name -4 "$peer.local" 2>/dev/null | awk '{print $2}')
        # Directly connected (no gateway), not via Tailscale/WireGuard: same physical LAN.
        route=$(ip route get "''${ip:-0.0.0.0}" 2>/dev/null || true)
        if [ -z "$ip" ] || grep -qE ' via |dev (tailscale0|wg0) ' <<<"$route"; then
          notify "KVM unavailable" "$peer is off or not on this network"
          exit 1
        fi

        hyprctl cursorpos | tr -d , >"$saved"
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
        # lan-mouse hands keyboard and mouse over when pointer *motion* crosses its edge
        # barrier; a warp alone never triggers it (Hyprland only checks barriers on relative
        # motion). So park the cursor next to the edge and push it across with a virtual
        # pointer. The barrier appears a few ms after activation: retry until lan-mouse reports
        # the handover (at most ~0.5 s).
        for _ in $(seq 25); do
          warp "$x" "$y"
          wlrctl pointer move ${
          if self.position == "left"
          then "-4"
          else "4"
        } 0
          sleep 0.02
          [ -e "$entered" ] && break
        done
        notify "KVM" "Keyboard and mouse on $peer, SUPER+X to take them back"
      '';
    };
  in {
    home.packages = [kvm];
    xdg.configFile."lan-mouse/config.toml".source = config;

    wayland.windowManager.hyprland.extraLuaFiles.kvm.content = ''
      hl.bind("SUPER + X", hl.dsp.exec_cmd("kvm"))
    '';

    # Always listening so the peer can take over this machine once *it* toggles on. The daemon's
    # log is read in-process (journalctl -f added ~0.5 s): when input returns, `kvm off` restores
    # the cursor and disarms; when capture enters the peer, `kvm` stops warping.
    systemd.user.services.lan-mouse = {
      Unit = {
        Description = "lan-mouse software KVM";
        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target"];
      };
      Service = {
        ExecStart = toString (pkgs.writeShellScript "lan-mouse-kvm" ''
          set -o pipefail
          ${lib.getExe pkgs.lan-mouse} daemon 2>&1 | while IFS= read -r line; do
            printf '%s\n' "$line"
            case "$line" in
              *"releasing capture: release-bind pressed"* | *"releasing capture: left remote"*)
                ${lib.getExe kvm} off &
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
