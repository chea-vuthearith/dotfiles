{...}: {
  flake.modules.nixos.host-laptop = {...}: {
    hardware.intelgpu = {
      driver = "xe";
      vaapiDriver = "intel-media-driver";
    };
  };
}
