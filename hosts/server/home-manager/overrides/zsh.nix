{...}: {
  programs.zsh.shellAliases = {
    nsw = "git -C ~/dotfiles pull; sudo nixos-rebuild switch --flake ~/dotfiles#server --impure";
  };
}
