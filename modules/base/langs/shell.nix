{...}: {
  flake.modules.homeManager.base = {pkgs, ...}: {
    home.packages = with pkgs; [
      bash-language-server
      shellcheck
      shfmt
    ];
  };
}
