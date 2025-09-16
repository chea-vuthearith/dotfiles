{ lib, pkgs, config, ... }: {

  packages = with pkgs; [ bitwarden-cli keyutils ];

  programs.qutebrowser = {
    enable = true;
    package =
      ((pkgs.qutebrowser.override { enableWideVine = true; }).overrideAttrs
        (prev:
          let
            bw = builtins.path {
              path =
                "${config.home.homeDirectory}/dotfiles/qutebrowser/userscripts/bw";
            };
          in {
            postInstall = ''
              cp ${bw} $out/share/qutebrowser/userscripts/bw
            '' + (prev.postInstall or "");
          }));
    loadAutoconfig = true;
    extraConfig = lib.fileContents
      "${config.home.homeDirectory}/dotfiles/qutebrowser/config.py";
  };
}
