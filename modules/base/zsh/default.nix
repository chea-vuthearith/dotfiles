{...}: {
  flake.modules.nixos.base = {...}: {
    programs.zsh.enableGlobalCompInit = false;
  };
  flake.modules.homeManager.base = {
    pkgs,
    config,
    osConfig,
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
          nsw = "git -C ~/dotfiles pull; sudo nixos-rebuild switch --flake ~/dotfiles#${osConfig.networking.hostName} --impure";
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
  };
}
