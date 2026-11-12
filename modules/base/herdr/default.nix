{inputs, ...}: {
  flake.modules.nixos.base = {...}: {
    nixpkgs.overlays = [
      (final: _prev: {
        herdr = inputs.herdr.packages.${final.stdenv.hostPlatform.system}.herdr.overrideAttrs (o: {
          # saved machines per local session (machines.nix); upstream keeps one global list
          patches = (o.patches or []) ++ [./session-machines.patch];
        });
      })
    ];
  };
  flake.modules.homeManager.base = {
    pkgs,
    lib,
    config,
    ...
  }: let
    pluginsDir = "${config.xdg.configHome}/herdr/plugins/github";

    mkPlugin = {
      owner,
      repo,
      rev,
      sha256,
      dirName,
    }: let
      src = pkgs.fetchFromGitHub {inherit owner repo rev sha256;};
      manifest = fromTOML (builtins.readFile "${src}/herdr-plugin.toml");
      pluginDir = "${pluginsDir}/${dirName}";
    in {
      json =
        (removeAttrs manifest ["id"])
        // {
          plugin_id = manifest.id;
          manifest_path = "${pluginDir}/herdr-plugin.toml";
          plugin_root = pluginDir;
          enabled = true;
          source = {
            kind = "github";
            inherit owner repo;
            resolved_commit = rev;
            managed_path = pluginDir;
            installed_unix_ms = 0;
          };
        };
      xdgFiles = {
        "herdr/plugins/github/${dirName}".source = src;
      };
    };

    # For plugins shipping a prebuilt binary via GitHub Releases.
    # Fetches source (for the manifest) + the release tarball, merges them into
    # a single derivation with the binary at bin/<name> so herdr can invoke it.
    mkBinaryPlugin = {
      owner,
      repo,
      rev,
      sha256,
      binaryUrl,
      binarySha256,
      dirName,
    }: let
      src = pkgs.fetchFromGitHub {inherit owner repo rev sha256;};
      binTar = pkgs.fetchurl {
        url = binaryUrl;
        sha256 = binarySha256;
      };
      pluginSrc = pkgs.runCommand "herdr-${dirName}-plugin" {} ''
        cp -r ${src} $out
        chmod -R u+w $out
        mkdir -p $out/bin
        tar -xzf ${binTar} -C $out/bin
        chmod +x $out/bin/*
      '';
      manifest = fromTOML (builtins.readFile "${src}/herdr-plugin.toml");
      pluginDir = "${pluginsDir}/${dirName}";
    in {
      json =
        (removeAttrs manifest ["id"])
        // {
          plugin_id = manifest.id;
          manifest_path = "${pluginDir}/herdr-plugin.toml";
          plugin_root = pluginDir;
          enabled = true;
          source = {
            kind = "github";
            inherit owner repo;
            resolved_commit = rev;
            managed_path = pluginDir;
            installed_unix_ms = 0;
          };
        };
      xdgFiles = {
        "herdr/plugins/github/${dirName}".source = pluginSrc;
      };
    };

    plugins = [
      (mkPlugin {
        owner = "freethinkel";
        repo = "herdr-plugin-git-worktree-hooks";
        rev = "3c0257b5223f6e7bdaec3623824a6c58c6eee1cd";
        sha256 = "sha256-wkfVKTxZYjy2Qf0WBHLJzLxXpAEbx5AASdmk/gpdWOU=";
        dirName = "freethinkel.worktree-hooks";
      })
      (mkPlugin {
        owner = "lmilojevicc";
        repo = "herdr-splits.nvim";
        rev = "c58bfdf01520845583e0033c11c56fc9d21a5424";
        sha256 = "sha256-tiYFNZh0z8aLVzf56+Z/xo0lFvbztReG9oiXy19dv6s=";
        dirName = "herdr-splits";
      })
      (mkBinaryPlugin {
        owner = "cupsadarius";
        repo = "herdr-pr-glance";
        rev = "7c2146b28f60aa2dfc5e544b353f43e1a4c5441c";
        sha256 = "1zvalka6hgcjzr4cs4f1rcnfdh52g77kcaq39gzsql5vl6dch9c9";
        binaryUrl = "https://github.com/cupsadarius/herdr-pr-glance/releases/download/v0.1.2/herdr-pr-glance_0.1.2_linux_amd64.tar.gz";
        binarySha256 = "1li1vwixphi40lanlpfwlc9csp9n1i075g8xy19rz0cg7xxpa3hb";
        dirName = "glance.pr";
      })
      (mkPlugin {
        owner = "wg1k";
        repo = "live-sync-panes";
        rev = "bd3120a952e92e3313182ed306bcba3863bd0746";
        sha256 = "sha256-jmhJJhP4TRpi8ZLVlgDjXx6mpBzdY4zie/tyCVqdJjU=";
        dirName = "live-sync-panes";
      })
    ];

    pluginsJson = builtins.toJSON (map (p: p.json) plugins);
    pluginsXdg = lib.foldl' (acc: p: acc // p.xdgFiles) {} plugins;
  in {
    home.packages = [
      pkgs.herdr
      # popup behind prefix+tab / prefix+w in config.toml
      (pkgs.writeShellApplication {
        name = "herdr-chord";
        runtimeInputs = [pkgs.herdr pkgs.jq];
        text = builtins.readFile ./chord.sh;
      })
      # fuzzy worktree picker behind prefix+g in config.toml
      (pkgs.writeShellApplication {
        name = "herdr-worktree";
        runtimeInputs = [pkgs.herdr pkgs.jq pkgs.git pkgs.fzf pkgs.gawk];
        text = builtins.readFile ./worktree.sh;
      })
      # move omp sessions to another machine (prefix+m / prefix+shift+m in config.toml);
      # omp itself comes from PATH (programs.omp)
      (pkgs.writeShellApplication {
        name = "herdr-ship";
        runtimeInputs = [pkgs.herdr pkgs.jq pkgs.git pkgs.rsync pkgs.openssh pkgs.procps pkgs.util-linux];
        text = builtins.readFile ./ship.sh;
      })
      # herdr-ship's receiving end runs rsync from the login PATH
      pkgs.rsync
    ];

    programs.zsh.shellAliases = {
      h = "herdr";
      hp = "herdr session attach personal";
    };

    programs.zsh.initContent = lib.mkOrder 1500 ''
      hr() { herdr --remote "$@" }
      compdef hr=ssh
    '';

    xdg.configFile =
      pluginsXdg
      // {
        "herdr/config.toml".source = config.lib.file.mkOutOfStoreSymlink (lib.toLocal ./config.toml);
        "herdr/plugins.json".text = pluginsJson;
        "herdr/plugins/config/freethinkel.worktree-hooks/config.yml".source =
          config.lib.file.mkOutOfStoreSymlink (lib.toLocal ./plugins/freethinkel.worktree-hooks/config.yml);
      };
  };
}
