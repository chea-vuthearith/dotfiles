{
  pkgs,
  inputs,
  ...
}: let
  inherit (pkgs.stdenv.hostPlatform) system;
  bravePkgs = import inputs.brave-origin-nixpkgs {
    inherit system;
  };
  overlay = final: prev: {
    tela-circle-icon-theme = prev.tela-circle-icon-theme.overrideAttrs (oldAttrs: {
      src = prev.fetchFromGitHub {
        owner = "vinceliuice";
        repo = "tela-circle-icon-theme";
        rev = "bdb616e4cb0cf61fc6bd52a42af9c07261015b21";
        sha256 = "sha256-3vqFK+yyk3EJwEpeKY92CHpFKLbXWDu1W3IDGl93VDo=";
      };
    });

    inherit (bravePkgs) brave-origin;
    inherit (inputs.caelestia-shell.packages.${system}) caelestia-shell;
    inherit (inputs.caelestia-cli.packages.${system}) caelestia-cli;

    inherit (inputs.hyprland.packages.${system}) hyprland;
    inherit (inputs.apple-fonts.packages.${system}) sf-pro-nerd;

    # hyprlandPlugins =
    #   prev.hyprlandPlugins
    #   // {
    # inherit (inputs.hyprsplit.packages.${system}) hyprsplit;
    # inherit (inputs.hyprtasking.packages.${system}) hyprtasking;
    # inherit (inputs.hypr-dynamic-cursors.packages.${system}) hypr-dynamic-cursors;
    # };
  };
in {
  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      overlay
    ];
  };
}
