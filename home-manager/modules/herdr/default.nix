{
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
  ];

  pluginsJson = builtins.toJSON (map (p: p.json) plugins);
  pluginsXdg = lib.foldl' (acc: p: acc // p.xdgFiles) {} plugins;
in {
  home.packages = [pkgs.herdr];

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
}
