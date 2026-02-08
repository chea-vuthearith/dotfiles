{
  inputs,
  username,
  lib,
  ...
}: {
  imports = lib.collectModules ./overrides;
  home-manager = {
    extraSpecialArgs = {
      inherit inputs;
    };
    users = {${username} = import ../home-manager;};
  };
  programs.nh.flake = "/home/${username}/dotfiles#laptop";
}
