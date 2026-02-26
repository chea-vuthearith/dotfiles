{pkgs, ...}: {
  hardware.i2c.enable = true;
  programs.gpu-screen-recorder.enable = true;
  environment.systemPackages = with pkgs; [
    gpu-screen-recorder
  ];
}
