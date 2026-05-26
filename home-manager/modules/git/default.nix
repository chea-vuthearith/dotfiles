{pkgs, ...}: {
  home.packages = with pkgs; [git-lfs gh];
  # programs.zsh.shellAliases = {
  #   nvimdiff = "nvim -d"; # for git config, since it only recognizes nvimdiff
  # };
  programs.git = {
    enable = true;
    lfs.enable = true;
    signing.format = null;
    settings = {
      user = {
        name = "chea-vuthearith";
        email = "cheavuthearith0@gmail.com";
      };
      core.excludesfile = toString ./gitignore;
      credential = {
        "https://github.com".helper = "!${pkgs.gh}/bin/gh auth git-credential";
        "https://gist.github.com".helper = "!${pkgs.gh}/bin/gh auth git-credential";
      };
      safe.directory = "*";
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;
      rerere.enabled = true;
      diff = {
        tool = "nvimdiff";
      };
      difftool.prompt = false;
      merge = {
        tool = "nvimdiff";
        # conflictstyle = "zdiff3";
      };
      mergetool = {
        nvimdiff = {
          layout = "LOCAL,REMOTE / MERGED";
          trustExitCode = true;
        };
        keepBackup = false;
        prompt = false;
      };
    };
  };
}
