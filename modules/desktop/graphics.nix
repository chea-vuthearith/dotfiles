{config, ...}: {
  flake.modules.nixos.desktop = {pkgs, ...}: {
    users.users.${config.username}.extraGroups = ["video"];
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
    environment.defaultPackages = with pkgs; [
      vulkan-tools
      mesa
    ];
  };
}
