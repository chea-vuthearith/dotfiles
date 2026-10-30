{...}: {
  flake.modules.homeManager.base = {pkgs, config, ...}: {
    home.packages = with pkgs; [git-lfs gh];
    programs.git = {
      enable = true;
      lfs.enable = true;
      # SSH key: signs every commit and tag (GitHub "Verified"; RSN release tags via scripts/release.sh)
      signing = {
        format = "ssh";
        key = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
        signByDefault = true;
      };
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
  };
}
