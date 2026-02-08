{username, ...}: {
  services.openssh = {
    enable = true;
    ports = [99];
    settings = {
      PasswordAuthentication = false;
      AllowUsers = [username];
      PermitRootLogin = "no";
    };
  };
  networking.firewall.allowedTCPPorts = [99];
}
