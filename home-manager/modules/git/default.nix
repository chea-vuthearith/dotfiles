{pkgs, ...}: {
  home.packages = with pkgs; [git-lfs gh];
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "chea-vuthearith";
        email = "cheavuthearith0@gmail.com";
      };
      core.excludesfile = builtins.toString ./gitignore;
      credential."https://github.com".helper = "!${pkgs.coreutils}/bin/env gh auth git-credential";
      credential."https://gist.github.com".helper = "!${pkgs.coreutils}/bin/env gh auth git-credential";
      safe.directory = "*";
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;
      rerere.enabled = true;
    };
  };
}
