{...}: {
  programs.zsh.shellAliases = {
    nsw = "git -C ~/dotfiles pull; nh os switch ~/dotfiles -H=laptop --impure";
    nsws = "nsw -- --option substituters 'http://192.168.100.74:5000' --option require-sigs false";
  };
}
