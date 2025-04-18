{ inputs, config, pkgs, ... }:

{
  imports = [ ../../configuration.nix ./rocm.nix ./rgb.nix ];

  boot = {
    kernelModules = [ "hid_apple" ];
    extraModprobeConfig = ''
      options hid_apple fnmode=2
    '';
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = { kuro = import ./home.nix; };
  };

}
