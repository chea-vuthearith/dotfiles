{config, ...}: let
  inherit (config) username;
in {
  flake.modules.nixos.base = {config, ...}: let
    authKeyFile = config.sops.secrets.tailscale-authkey.path;
  in {
    sops.secrets.tailscale-authkey = {};
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

    # Skip autoconnect (instead of failing on boot) until the host can decrypt the key.
    systemd.services.tailscaled-autoconnect.unitConfig.ConditionPathExists = authKeyFile;

    networking = {
      firewall.trustedInterfaces = ["tailscale0"];
      networkmanager.unmanaged = ["tailscale0"];
    };
  };
}
