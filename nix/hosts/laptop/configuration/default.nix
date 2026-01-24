{ inputs, config, pkgs, username, ... }: {
  imports = [
    ./overrides/power.nix
    ./overrides/hardware.nix
    ./overrides/cache-client.nix
  ];
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = { ${username} = import ../home-manager; };
  };

}

