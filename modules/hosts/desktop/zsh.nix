{...}: {
  flake.modules.homeManager.host-desktop = {...}: {
    programs.zsh.shellAliases = {
      nsws = "nsw --option substituters 'http://192.168.100.108:5000' --option trusted-substituters 'http://192.168.100.108:5000' --option require-sigs false";
    };
  };
}
