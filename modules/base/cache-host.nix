{...}: {
  flake.modules.nixos.base = {pkgs, ...}: {
    services.harmonia.cache.enable = true;
    networking.firewall.allowedTCPPorts = [5000];
  };
}
