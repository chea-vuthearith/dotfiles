{...}: {
  # mDNS: `<host>.local` resolves only over multicast on the local link, never through
  # Tailscale (tailscale0 has no multicast), so a successful lookup means "same LAN, peer up".
  # Used by the LAN store mesh (base/binary-cache.nix).
  flake.modules.nixos.base = {
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      # Publish/resolve on the physical LAN only: otherwise the server announced its
      # docker0 bridge (172.17.0.1) as server.local, unreachable from the peers.
      denyInterfaces = ["docker0" "tailscale0" "wg0"];
      publish = {
        enable = true;
        addresses = true;
      };
    };
  };
}
