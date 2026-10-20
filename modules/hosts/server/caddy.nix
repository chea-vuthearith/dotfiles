{
  # Portless URLs for the .internal names: Caddy terminates :80/:443 and routes
  # by Host header. A DNS record carries no port, so frigate/hindsight share the
  # server's IP and are separated here.
  #   frigate.internal   -> Frigate  (:5000)
  #   hindsight.internal -> Hindsight web UI (:9999), tailnet-only upstream
  # HTTPS uses Caddy's internal CA (no public cert possible for .internal):
  # install Caddy's root once per client -- see the plan's "trust the CA" step.
  flake.modules.nixos.host-server = {...}: let
    # Hindsight publishes its ports on the tailnet IP (hindsight.nix), not loopback,
    # so Caddy proxies to that address; the host itself can reach it.
    tailnetIp = "100.93.89.8";
  in {
    services.caddy = {
      enable = true;
      openFirewall = true; # :80 and :443
      virtualHosts = {
        "frigate.internal".extraConfig = ''
          tls internal
          reverse_proxy 127.0.0.1:5000
        '';
        "hindsight.internal".extraConfig = ''
          tls internal
          reverse_proxy ${tailnetIp}:9999
        '';
      };
    };
  };
}
