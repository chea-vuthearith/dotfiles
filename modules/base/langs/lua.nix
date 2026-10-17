{...}: {
  flake.modules.homeManager.base = {pkgs, ...}: {
    home.packages = with pkgs; [
      lua
      lua-language-server
      stylua
    ];
  };
}
