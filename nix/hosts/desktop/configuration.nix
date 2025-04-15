{ inputs, config, pkgs, ... }:

{
  imports = [ ../../configuration.nix ../../rocm.nix ];

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = { kuro = import ./home.nix; };
  };

}
