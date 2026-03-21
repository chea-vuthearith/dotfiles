{inputs, ...}: {
  imports = [
    inputs.nixos-hardware.nixosModules.common-gpu-intel
  ];

  hardware.intelgpu = {
    driver = "xe";
    vaapiDriver = "intel-media-driver";
  };
}
