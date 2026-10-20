{
  # Central DNS for the LAN/tailnet: one place to name services.
  # Answers *.internal locally and forwards nothing: a lookup outside .internal
  # fails loudly (NXDOMAIN), which isolates DNS problems instead of hiding them.
  # Reachable on the LAN IP (router DHCP) and the tailnet IP (Tailscale split DNS);
  # Tailscale routes only the `internal` domain here, so public DNS never transits.
  flake.modules.nixos.host-server = {...}: let
    # Reserved on the router (DHCP reservation).
    lanIp = "192.168.0.19";
    tailnetIp = "100.93.89.8";
    # Single source of truth for service names. A record carries no port, so both
    # names point at this host; Caddy (caddy.nix) routes by Host on :80/:443.
    records = {
      frigate = lanIp;
      hindsight = lanIp;
    };
  in {
    services.dnsmasq = {
      enable = true;
      resolveLocalQueries = false; # never touch the host's own /etc/resolv.conf
      settings = {
        # Listen on the LAN (router hands this out) and the tailnet (split DNS).
        listen-address = [lanIp tailnetIp];
        bind-interfaces = true; # only the addresses above, not the wildcard
        no-resolv = true; # no upstream from /etc/resolv.conf
        # No `server`-forwarding: non-.internal queries return NXDOMAIN on purpose.
        address = map (name: "/${name}.internal/${records.${name}}") (builtins.attrNames records);
      };
    };

    # DNS from the LAN and the tailnet only.
    networking.firewall.extraInputRules = ''
      ip saddr 192.168.0.0/24 tcp dport 53 accept
      ip saddr 192.168.0.0/24 udp dport 53 accept
      ip saddr 100.64.0.0/10 tcp dport 53 accept
      ip saddr 100.64.0.0/10 udp dport 53 accept
    '';

    # dnsmasq can only bind addresses that already exist; wait for the tailnet.
    systemd.services.dnsmasq = {
      after = ["tailscaled.service"];
      wants = ["tailscaled.service"];
    };
  };
}
