{...}: let
  port = 4242; # lan-mouse (UDP)
  controlPort = 4243; # owner-state sync between the two `kvm` instances (TCP)
  # Keyboard + mouse only (lan-mouse shares nothing else).
  # Both machines keep the same state `owner` = laptop | desktop | off and follow one rule:
  #   owner == me   -> don't forward (every keyboard/mouse ends up here)
  #   owner == peer -> forward this machine's keyboard/mouse to the peer
  #   off           -> don't forward
  # - SUPER+X: off -> the machine you pressed it on owns; on -> ownership flips.
  # - SUPER+SHIFT+X (or lan-mouse's emergency chord on the forwarding machine): off.
  # A change is written on both sides; the side that stops forwarding applies first, so the
  # two never forward at once. Peer unreachable -> off locally.
  # Each machine's cursor returns to where it was when it started forwarding.
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
  flake.modules.nixos.desktop.networking.firewall = {
    allowedUDPPorts = [port];
    # `kvm recv` drops anything not from the peer's mDNS-resolved LAN address.
    allowedTCPPorts = [controlPort];
  };

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
          # No edge capture for incoming connections: control only moves by keybind, and that
          # barrier shared the edge with our own client's, grabbing input to nowhere.
          ./no-incoming-capture.patch
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
      runtimeInputs = with pkgs; [lan-mouse systemd iproute2 coreutils gnugrep gawk jq libnotify hyprland wlrctl socat];
      text = ''
        me=${osConfig.networking.hostName}
        peer=${self.peer}
        notify() { notify-send -a "KVM" "$@" & }
        state="''${XDG_RUNTIME_DIR:?}/kvm-owner"
        # Where the cursor was when this machine started forwarding; restored when it stops.
        saved="$XDG_RUNTIME_DIR/kvm-cursor"
        # Touched by the lan-mouse service the moment forwarding to the peer starts.
        entered="$XDG_RUNTIME_DIR/kvm-entered"
        owner() { cat "$state" 2>/dev/null || echo off; }
        warp() { hyprctl dispatch "hl.dsp.cursor.move({ x = $1, y = $2 })" >/dev/null; }

        # Peer's LAN address via mDNS; fails unless it is directly connected (no gateway, not
        # Tailscale/WireGuard), i.e. on the same physical network.
        peer_ip() {
          local ip route
          ip=$(resolvectl query -4 --protocol=mdns --legend=no "$peer.local" 2>/dev/null | awk '{print $2; exit}')
          route=$(ip route get "''${ip:-0.0.0.0}" 2>/dev/null || true)
          [ -n "$ip" ] && ! grep -qE ' via |dev (tailscale0|wg0) ' <<<"$route" && echo "$ip"
        }

        # lan-mouse assigns the single configured client handle; read it back.
        client() { lan-mouse cli list | awk -F'[ :]' '/^id /{print $2; exit}'; }
        forwarding() { lan-mouse cli list | grep -q 'active: true'; }

        stop_forwarding() {
          if forwarding; then lan-mouse cli deactivate "$(client)"; fi
          if [ -e "$saved" ]; then
            read -r x y <"$saved"
            rm -f "$saved"
            warp "$x" "$y"
          fi
        }

        start_forwarding() {
          local ip id x y
          ip=$(peer_ip) || return 1
          id=$(client)
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
          return 1
        }

        # Write the state locally and make lan-mouse match it.
        apply() {
          echo "$1" >"$state"
          if [ "$1" = "$peer" ]; then
            forwarding || start_forwarding || { echo off >"$state"; stop_forwarding; return 1; }
          else
            stop_forwarding
          fi
        }

        # Tell the peer; succeeds only once it has applied the state.
        push() {
          local ip
          ip=$(peer_ip) || return 1
          [ "$(echo "apply $1" | socat -t2 -T2 - "TCP4:$ip:${toString controlPort}" 2>/dev/null)" = ok ]
        }

        set_owner() {
          if [ "$1" = "$peer" ]; then
            # We start forwarding: the peer stops first.
            push "$1" && apply "$1" && return 0
            apply off
            push off || true
            return 1
          fi
          # We stop forwarding (owner = me or off): locally first, then the peer.
          apply "$1"
          push "$1" && return 0
          [ "$1" = off ] && return 0
          apply off
          return 1
        }

        case "''${1:-}" in
          # SUPER+X
          "")
            case "$(owner)" in
              "$me") new=$peer ;;
              *) new=$me ;;
            esac
            if set_owner "$new"; then
              notify "KVM" "All keyboards and mice now control $new"
            else
              notify "KVM unavailable" "$peer is off or not on this network"
            fi
            ;;
          # SUPER+SHIFT+X, emergency chord, lan-mouse (re)start
          off)
            set_owner off
            [ "''${2:-}" = quiet ] || notify "KVM off" "Each machine uses its own keyboard and mouse"
            ;;
          # One request from the peer over the control port (socat sets SOCAT_PEERADDR).
          recv)
            read -r cmd arg
            [ "''${SOCAT_PEERADDR:-}" = "$(peer_ip || true)" ] || exit 1
            case "$cmd $arg" in
              "apply $me" | "apply $peer" | "apply off") apply "$arg" && echo ok ;;
            esac
            ;;
          status) owner ;;
          *) echo "usage: kvm [off|status]" >&2; exit 2 ;;
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

    # lan-mouse always runs so the peer can forward to this machine. Its log is read
    # in-process: the peer's Ack confirms forwarding started; any other capture release
    # (emergency chord, link to the owner lost) turns the KVM off. On (re)start the state is
    # reset to off on both sides so they never disagree.
    systemd.user.services.lan-mouse = {
      Unit = {
        Description = "lan-mouse software KVM";
        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target"];
        StartLimitIntervalSec = 0;
      };
      Service = {
        ExecStart = toString (pkgs.writeShellScript "lan-mouse-kvm" ''
          set -o pipefail
          (sleep 2; ${lib.getExe kvm} off quiet) &
          ${lib.getExe lan-mouse} daemon 2>&1 | while IFS= read -r line; do
            printf '%s\n' "$line"
            case "$line" in
              # The first crossing only opens the connection and is released ("not connected")
              # while "entering client" is still logged; the peer's Ack is the real handover.
              *"acknowledged the connection"*) : >"$XDG_RUNTIME_DIR/kvm-entered" ;;
              *"releasing capture: not connected"*) rm -f "$XDG_RUNTIME_DIR/kvm-entered" ;;
              # Logged on the receiving side for every Enter.
              *"entered this device"*) ;;
              *"releasing capture: "*) ${lib.getExe kvm} off & ;;
            esac
          done
        '');
        # A switch restarts this mid-activation and the daemon can die on a briefly missing
        # file; retry slowly forever instead of hitting the 5-in-10s start limit and staying down.
        Restart = "always";
        RestartSec = 3;
      };
      Install.WantedBy = ["graphical-session.target"];
    };

    # Receives owner-state changes from the peer.
    systemd.user.services.kvm-control = {
      Unit = {
        Description = "KVM owner-state listener";
        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target" "lan-mouse.service"];
      };
      Service = {
        ExecStart = "${lib.getExe pkgs.socat} TCP4-LISTEN:${toString controlPort},fork,reuseaddr EXEC:'${lib.getExe kvm} recv'";
        Restart = "always";
        RestartSec = 3;
      };
      Install.WantedBy = ["graphical-session.target"];
    };
  };
}
