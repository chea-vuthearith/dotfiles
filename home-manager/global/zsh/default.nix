{
  pkgs,
  config,
  ...
}: {
  programs = {
    zsh = {
      enable = true;
      history = {
        size = 10000;
        append = true;
        share = true;
        ignoreSpace = true;
        ignoreAllDups = true;
        saveNoDups = true;
        ignoreDups = true;
        findNoDups = true;
      };
      plugins = [
        {
          name = "zinit";
          src = pkgs.zinit;
          file = "share/zinit/zinit.zsh";
        }
      ];
      shellAliases = {
        wgu = "sudo systemctl start wg-quick-wg0.service";
        wgd = "sudo systemctl stop wg-quick-wg0.service";
        nswu = "nix flake update --flake ~/dotfiles && nsw --upgrade";
      };
      dotDir = "${config.xdg.configHome}/zsh";
      initContent = ''
        ${builtins.readFile ./plugins.sh}
        ${builtins.readFile ./zshrc.sh}
        ${builtins.readFile ./keys.sh}
      '';
    };
  };
}
