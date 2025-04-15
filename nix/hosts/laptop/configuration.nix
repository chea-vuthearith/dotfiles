{ inputs, config, pkgs, ... }:

{
  imports = [ ../../configuration.nix ];

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = { kuro = import ./home.nix; };
  };

  services.uponit.enable = true;

}

