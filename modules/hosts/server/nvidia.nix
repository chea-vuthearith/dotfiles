{...}: {
  # MSI GL63 8RD: Intel UHD 630 (PCI 00:02.0) drives the panel; the
  # GTX 1050 Ti Mobile (GP107, Pascal, sm_61, 4 GB, PCI 01:00.0) is a
  # display-less 3D controller used headless for CUDA compute only.
  flake.modules.nixos.host-server = {...}: {
    # Selects the proprietary driver (and blacklists nouveau); does not enable X.
    services.xserver.videoDrivers = ["nvidia"];
    # Exposes libcuda/libnvidia-ml under /run/opengl-driver/lib.
    hardware.graphics.enable = true;

    hardware.nvidia = {
      # 590+ dropped Pascal; 580 is NVIDIA's long-term branch for Maxwell-Volta.
      branch = "legacy_580";
      # Open kernel modules need Turing or newer.
      open = false;
      # Pascal has no GSP; skip shipping its firmware.
      gsp.enable = false;
      nvidiaSettings = false;
      # Keeps the driver initialised without a display, so CUDA jobs don't pay
      # GPU init on every launch.
      nvidiaPersistenced = true;
    };

    # nixpkgs builds CUDA for 7.5+ by default and CUDA 13 dropped sm_61, so
    # CUDA packages added to this host must target 6.1 and stay on cudaPackages_12
    # (cudaPackages_13 fails eval with this setting).
    nixpkgs.config.cudaCapabilities = ["6.1"];
  };
}
