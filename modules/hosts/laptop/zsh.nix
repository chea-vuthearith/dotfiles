{...}: {
  flake.modules.homeManager.host-laptop = {...}: {
    programs.zsh.shellAliases = {
      nsws = "nsw --option substituters 'http://192.168.100.74:5000' --option trusted-substituters 'http://192.168.100.74:5000' --option require-sigs false";
    };
  };
}
