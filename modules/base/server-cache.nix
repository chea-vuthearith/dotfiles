let
  # Not harmonia's default 5000: the server's Frigate nginx binds 127.0.0.1:5000.
  cachePort = 5080;
in {
  # Server serves its store over harmonia, signed with sops `harmonia-key`.
  # Key made with: nix-store --generate-binary-cache-key server-1 key key.pub
  flake.modules.nixos.host-server = {config, ...}: {
    sops.secrets.harmonia-key = {};
    services.harmonia.cache = {
      signKeyPaths = [config.sops.secrets.harmonia-key.path];
      settings.bind = "[::]:${toString cachePort}";
    };
    networking.firewall.allowedTCPPorts = [cachePort];
  };

  # Workstations substitute from the server's cache but build locally: offloaded
  # builds ran the server (Frigate, Ollama, Hindsight) out of RAM.
  flake.modules.nixos.desktop = {
    nix.settings = {
      extra-substituters = ["http://server:${toString cachePort}"];
      extra-trusted-public-keys = ["server-1:fEDN/SamiRBT+SbeNiVEbpng9uAPkjSAgGPYjCtKb84="];
      # Server offline: give up quickly and fetch/build elsewhere.
      connect-timeout = 5;
      fallback = true;
    };
  };
}
