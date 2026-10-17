{username, ...}: let
  # Root-only, outside the world-readable nix store. Create once per host:
  #   sudo install -m600 /dev/stdin /var/lib/tailscale/authkey <<< 'tskey-auth-...'
  authKeyFile = "/var/lib/tailscale/authkey";
in {
  services.tailscale = {
    enable = true;
    openFirewall = true; # UDP 41641 for direct (non-DERP) connections
    useRoutingFeatures = "client"; # loose rp_filter so exit nodes/subnet routes work
    inherit authKeyFile; # tailscaled-autoconnect runs `tailscale up` whenever logged out
    extraSetFlags = [
      "--operator=${username}" # run `tailscale` without sudo
      "--ssh" # Tailscale SSH server, authorized by tailnet ACLs
    ];
  };

  # Skip autoconnect (instead of failing on boot) until the key is placed.
  systemd.services.tailscaled-autoconnect.unitConfig.ConditionPathExists = authKeyFile;

  networking = {
    firewall.trustedInterfaces = ["tailscale0"];
    networkmanager.unmanaged = ["tailscale0"];
  };
}
