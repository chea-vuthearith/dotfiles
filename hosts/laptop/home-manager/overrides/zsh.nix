{pkgs, ...}: {
  programs.zsh.shellAliases = {
    nsw = "git -C ~/dotfiles pull; sudo nixos-rebuild switch --flake ~/dotfiles#laptop --impure";
    nsws = "nsw --option substituters 'http://192.168.100.74:5000'";
  };
}
