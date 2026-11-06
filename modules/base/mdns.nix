{...}: {
  # mDNS: `<host>.local` resolves only over multicast on the local link, never through
  # Tailscale (tailscale0 has no multicast), so a successful lookup means "same LAN, peer up".
  # Used by the LAN store mesh (base/binary-cache.nix).
  flake.modules.nixos.base = {
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      publish = {
        enable = true;
        addresses = true;
      };
    };
  };
}
