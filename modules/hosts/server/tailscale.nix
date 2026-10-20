{lib, ...}: {
  # Advertise the home LAN to the tailnet so remote devices can reach `server`
  # (and, via it, the LAN IPs that .internal records point to).
  # Admin still has to approve the route / disable key expiry in the Tailscale
  # admin console -- see the plan's manual steps.
  flake.modules.nixos.host-server = {...}: {
    services.tailscale = {
      # "server" turns on IP forwarding and accepts routes (base sets "client").
      useRoutingFeatures = lib.mkForce "server";
      extraSetFlags = [
        "--advertise-routes=192.168.0.0/24"
      ];
    };
  };
}
