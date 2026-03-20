{pkgs, ...}: {
  services.harmonia.cache.enable = true;
  networking.firewall.allowedTCPPorts = [5000];
}
