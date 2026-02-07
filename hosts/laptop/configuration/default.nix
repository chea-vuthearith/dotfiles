{
  inputs,
  config,
  pkgs,
  username,
  ...
}: {
  imports = [./overrides/power.nix ./overrides/hardware.nix ./overrides/boot.nix];
  home-manager = {
    extraSpecialArgs = {inherit inputs;};
    users = {${username} = import ../home-manager;};
  };
}
