{...}: let
  port = 4242;
  # Each workstation shares its keyboard/mouse with the other one. `position` is where the
  # peer sits relative to this machine's screens.
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
  # mDNS: `<host>.local` resolves only over multicast on the local link, never through
  # Tailscale (tailscale0 has no multicast), so a successful lookup means "same LAN, peer up".
  flake.modules.nixos.desktop = {
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      publish = {
        enable = true;
        addresses = true;
      };
    };
    networking.firewall.allowedUDPPorts = [port];
  };

  flake.modules.homeManager.desktop = {
    pkgs,
    lib,
    osConfig,
    ...
  }: let
    self = peers.${osConfig.networking.hostName};
    toml = pkgs.formats.toml {};
    # Peer has no hostname on purpose: lan-mouse would resolve it through MagicDNS to a
    # Tailscale address. `kvm toggle` fills in the LAN IP found via mDNS instead.
    config = toml.generate "lan-mouse.toml" {
      inherit port;
      release_bind = ["KeyLeftCtrl" "KeyLeftShift" "KeyLeftMeta" "KeyLeftAlt"];
      authorized_fingerprints.${(peers.${self.peer}).fingerprint} = self.peer;
      clients = [{inherit (self) position;}];
    };
    kvm = pkgs.writeShellApplication {
      name = "kvm";
      runtimeInputs = with pkgs; [pkgs.lan-mouse avahi iproute2 gnugrep gawk libnotify];
      text = ''
        peer=${self.peer}
        notify() { notify-send -a "KVM" "$@"; }
        # lan-mouse assigns the single configured client handle; read it back.
        id=$(lan-mouse cli list | awk -F'[ :]' '/^id /{print $2; exit}')
        [ -n "$id" ] || { notify "KVM unavailable" "lan-mouse is not running"; exit 1; }

        if lan-mouse cli list | grep -q 'active: true'; then
          lan-mouse cli deactivate "$id"
          notify "KVM off" "Input stays on this machine"
          exit 0
        fi

        ip=$(avahi-resolve-host-name -4 "$peer.local" 2>/dev/null | awk '{print $2}')
        # Directly connected (no gateway), not via Tailscale/WireGuard: same physical LAN.
        route=$(ip route get "''${ip:-0.0.0.0}" 2>/dev/null || true)
        if [ -z "$ip" ] || grep -qE ' via |dev (tailscale0|wg0) ' <<<"$route"; then
          notify "KVM unavailable" "$peer is off or not on this network"
          exit 1
        fi

        lan-mouse cli set-ips "$id" "$ip"
        lan-mouse cli activate "$id"
        notify "KVM on" "Move the pointer ${self.position} to control $peer ($ip)"
      '';
    };
  in {
    home.packages = [kvm];
    xdg.configFile."lan-mouse/config.toml".source = config;

    wayland.windowManager.hyprland.extraLuaFiles.kvm.content = ''
      hl.bind("SUPER + X", hl.dsp.exec_cmd("kvm"))
    '';

    # Always listening so the peer can take over this machine once *it* toggles on.
    systemd.user.services.lan-mouse = {
      Unit = {
        Description = "lan-mouse software KVM";
        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target"];
      };
      Service = {
        ExecStart = "${lib.getExe pkgs.lan-mouse} daemon";
        Restart = "on-failure";
      };
      Install.WantedBy = ["graphical-session.target"];
    };
  };
}
