{...}: {
  # mDNS via systemd-resolved: `<host>.local` resolves only over multicast on the local
  # link, never through Tailscale (tailscale0 has no multicast), so a successful lookup
  # means "same LAN, peer up". Used by the LAN store mesh (base/binary-cache.nix) and
  # the KVM (desktop/kvm).
  #
  # resolved, not avahi + nss-mdns: nix resolves substituter hosts with DNS only (it never
  # loads nss-mdns), so `.local` must be answered by the DNS server in resolv.conf. With
  # resolved that is its 127.0.0.53 stub, which sends `.local` to mDNS only; before, the
  # query went to MagicDNS/the ISP, which answered desktop.local with a public IP.
  flake.modules.nixos.base = {
    services.resolved = {
      enable = true;
      settings.Resolve.MulticastDNS = true;
    };
    # Per link: only NetworkManager's connections (the physical LAN) publish and resolve;
    # docker0, tailscale0 and wg0 are not NM-managed, so they never join mDNS.
    networking.networkmanager.connectionConfig."connection.mdns" = 2;
    networking.firewall.allowedUDPPorts = [5353];
  };
}
