{...}: {
  # gh attach: uploads PR images/videos to user-attachments (sudosubin/gh-attach, not in nixpkgs)
  flake.modules.nixos.base.nixpkgs.overlays = [
    (final: _: {
      gh-attach = (final.buildGoModule.override {go = final.go_1_27;}) rec {
        pname = "gh-attach";
        version = "0.5.1";
        src = final.fetchFromGitHub {
          owner = "sudosubin";
          repo = "gh-attach";
          tag = "v${version}";
          hash = "sha256-mXTFqv56y2pwITgVJKuCOuHDZK6F65UU18pN3iz62+I=";
        };
        vendorHash = "sha256-CPlH6NNmBFpoav7vmPbS7P3LbQXNXpQVIP2BIW3XajI=";
        subPackages = ["cmd/gh-attach"];
        meta = {
          description = "GitHub CLI extension that uploads and downloads GitHub attachments";
          homepage = "https://github.com/sudosubin/gh-attach";
          license = final.lib.licenses.mit;
          mainProgram = "gh-attach";
        };
      };
    })
  ];
  flake.modules.homeManager.base = {
    pkgs,
    config,
    ...
  }: {
    home.packages = [pkgs.git-lfs];
    programs.gh = {
      enable = true;
      # gh stack: stacked PRs (github/gh-stack), used by the gh-stack agent skill;
      # gh attach: PR images/videos (sudosubin/gh-attach), used by the gh-attach and pr-description skills
      extensions = [pkgs.gh-stack pkgs.gh-attach];
      # the credential helpers below stay explicit
      gitCredentialHelper.enable = false;
      settings = {
        git_protocol = "https";
        aliases.co = "pr checkout";
      };
    };
    # replaces the config.yml gh wrote by hand (same settings)
    xdg.configFile."gh/config.yml".force = true;
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
  # gh attach falls back to browser cookies when the gh token is rejected; Brave Origin keeps
  # its profiles outside gh-attach's default Brave path. Profiles without a github.com session are skipped.
  flake.modules.homeManager.desktop = {
    pkgs,
    config,
    ...
  }: {
    xdg.configFile."gh/attach.yml".source = (pkgs.formats.yaml {}).generate "gh-attach.yml" {
      browsers = map (profile: {
        browser = "brave";
        profile = "${config.xdg.configHome}/BraveSoftware/Brave-Origin/${profile}";
      }) ["Default" "Profile 1"];
    };
  };
}
