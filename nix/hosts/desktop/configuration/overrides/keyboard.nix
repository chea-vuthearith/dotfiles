{ ... }: {
  boot.kernelModules = [ "hid_apple" ];
  boot.extraModprobeConfig = ''
    options hid_apple fnmode=2
  '';
}
