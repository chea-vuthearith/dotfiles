{pkgs, ...}: {
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  environment.defaultPackages = with pkgs; [
    vulkan-tools
  ];
}
