{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.nixos-hardware.nixosModules.common-gpu-intel
  ];

  environment.systemPackages = with pkgs; [
    vulkan-tools
    mesa
  ];

  hardware.intelgpu = {
    driver = "xe";
    vaapiDriver = "intel-media-driver";
  };
}
