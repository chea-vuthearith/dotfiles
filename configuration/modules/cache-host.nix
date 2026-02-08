{pkgs, ...}: {
  services.harmonia.enable = true;
  networking.firewall.allowedTCPPorts = [5000];
}
