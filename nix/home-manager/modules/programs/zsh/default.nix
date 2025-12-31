{ pkgs, config, lib, ... }: {
  programs.zsh = {
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
      pysrc = "source .venv/bin/activate";
      pyenv = "py -m venv .venv && pysrc";
      nsh = "nix-shell --run zsh";
      ncf = "yazi ~/dotfiles/nix";
      wgu = "sudo systemctl start wg-quick-wg0.service";
      wgd = "sudo systemctl stop wg-quick-wg0.service";
      dl =
        "aria2c --console-log-level=error --max-connection-per-server=16 --max-concurrent-downloads=16 --split=16 --continue=true --dir=$HOME/Downloads";
    };
    dotDir = "${config.xdg.configHome}/zsh";
    initContent = builtins.readFile ./zshrc;
  };
}
