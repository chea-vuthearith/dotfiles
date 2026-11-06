let
  hosts = ["laptop" "desktop" "server"];
  # Not harmonia's default 5000: the server's Frigate nginx binds 127.0.0.1:5000.
  cachePort = 5080;
in {
  # Every host serves its store over harmonia and substitutes from the others, so a
  # path built or fetched on one host is never built again on another. LAN only: peers
  # are addressed as mDNS `<host>.local` (base/mdns.nix), which never resolves through
  # Tailscale, so away from the home LAN the lookups fail and nix skips them.
  # All sign with the one sops `harmonia-key`, so a single public key is trusted.
  # Key made with: nix-store --generate-binary-cache-key server-1 key key.pub
  flake.modules.nixos.base = {config, ...}: {
    sops.secrets.harmonia-key = {};
    services.harmonia.cache = {
      enable = true;
      signKeyPaths = [config.sops.secrets.harmonia-key.path];
      settings.bind = "[::]:${toString cachePort}";
    };
    networking.firewall.allowedTCPPorts = [cachePort];

    nix.settings = {
      # priority=20: ask peers before cache.numtide.com (30) and cache.nixos.org (40);
      # harmonia advertises 50, which put peers last. Set client-side so it applies on
      # switch, regardless of the peer's harmonia version or nix's cached nix-cache-info.
      extra-substituters =
        map (h: "http://${h}.local:${toString cachePort}?priority=20")
        (builtins.filter (h: h != config.networking.hostName) hosts);
      extra-trusted-public-keys = ["server-1:fEDN/SamiRBT+SbeNiVEbpng9uAPkjSAgGPYjCtKb84="];
      # A peer asleep or off this LAN: give up quickly and fetch/build elsewhere.
      connect-timeout = 5;
      fallback = true;
    };
  };
}
