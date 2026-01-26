{ ... }: {
  programs.zsh.shellAliases = {
    nsw =
      "git -C ~/dotfiles pull; sudo nixos-rebuild switch --flake ~/dotfiles/nix#desktop --impure";
    nsws = "nsw --option substituters 'http://192.168.100.108:5000'";
  };
}
