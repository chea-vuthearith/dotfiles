{lib, ...}: {
  imports =
    [
      ../../../home-manager/modules/git
      ../../../home-manager/modules/ssh.nix
      ../../../home-manager/modules/direnv.nix
      ../../../home-manager/modules/starship.nix
      ../../../home-manager/modules/zsh
      ../../../home-manager/modules/herdr
      ../../../home-manager/modules/nvim
      ../../../home-manager/modules/ai
      ../../../home-manager/modules/langs
    ]
    ++ lib.collectModules ./overrides;
}
