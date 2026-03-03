{pkgs, ...}: {
  virtualisation = {
    libvirtd.enable = true;
    spiceUSBRedirection.enable = true;
    docker = {
      extraPackages = [pkgs.docker-buildx];
      enable = true;
      enableOnBoot = false;
    };
  };
  security.polkit.enable = true;
}
