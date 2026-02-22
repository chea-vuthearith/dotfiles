{
  pkgs,
  lib,
  ...
}: let
  fzf-zellij = pkgs.stdenv.mkDerivation {
    pname = "fzf-zellij";
    version = "1.0";
    src = pkgs.fetchFromGitHub {
      owner = "k-kuroguro";
      repo = "fzf-zellij";
      rev = "a2d3ded34544091b8400c152ed4a2b823f1a8b19";
      sha256 = "sha256-SHug3CKv8LC0b0BmljvotG8L6lS+S04G6AXBvd/wktU=";
    };
    buildPhase = ''
      mkdir -p $out/bin
      cp $src/bin/fzf-zellij $out/bin/fzf-zellij
    '';
  };
in {
  home.packages = [
    fzf-zellij
  ];
  programs.zsh.initContent = lib.mkOrder 1500 ''
    fzf() {
       case "$1" in
          --bash|--zsh|--fish|--version|-h|--help|--man)
             command fzf "$@"
             ;;
          *)
             fzf-zellij "$@"
             ;;
       esac
    }'';
  programs.zellij = {
    enable = true;
    extraConfig = builtins.readFile ./config.kdl;
  };
}
