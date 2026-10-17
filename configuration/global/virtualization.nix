{pkgs, ...}: {
  virtualisation = {
    spiceUSBRedirection.enable = true;
    docker = {
      extraPackages = [pkgs.docker-buildx];
      enable = true;
      enableOnBoot = false;
    };
  };
  security.polkit.enable = true;
}
