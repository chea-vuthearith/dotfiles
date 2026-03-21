{pkgs, ...}: {
  services = {xserver.videoDrivers = ["modesetting"];};
  hardware.graphics.enable = true;
  boot.kernelParams = ["amdgpu.ppfeaturemask=0xffffffff"];

  systemd.packages = [pkgs.lact];
  systemd.services.lactd.wantedBy = ["multi-user.target"];

  hardware.graphics.extraPackages = with pkgs; [
    rocmPackages.clr.icd
    rocmPackages.rocminfo
    rocmPackages.hipblas
  ];

  environment = {
    sessionVariables = {HSA_OVERRIDE_GFX_VERSION = "10.3.1";};
    systemPackages = with pkgs; [lact clinfo];
  };
}
