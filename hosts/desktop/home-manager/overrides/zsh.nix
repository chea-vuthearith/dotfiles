{...}: {
  programs.zsh.shellAliases = {
    nsw = "git -C ~/dotfiles pull; sudo nixos-rebuild switch --flake ~/dotfiles#desktop --impure";
    nsws = "nsw --option substituters 'http://192.168.100.108:5000' --option trusted-substituters 'http://192.168.100.108:5000' --option require-sigs false";
  };
}
