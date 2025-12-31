{ inputs, config, pkgs, username, ... }: {
  imports = [ ./overrides/power.nix ./overrides/hardware.nix ];
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = { ${username} = import ../home-manager/home.nix; };
  };

}

