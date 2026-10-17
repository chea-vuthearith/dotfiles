{config, ...}: {
  flake.modules.nixos.base = {pkgs, ...}: {
    users.users.${config.username}.extraGroups = ["docker"];
    virtualisation = {
      spiceUSBRedirection.enable = true;
      docker = {
        extraPackages = [pkgs.docker-buildx];
        enable = true;
        enableOnBoot = false;
      };
    };
    security.polkit.enable = true;
  };
}
