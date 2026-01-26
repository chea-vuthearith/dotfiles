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
    plugins = [{
      name = "zinit";
      src = pkgs.zinit;
      file = "share/zinit/zinit.zsh";
    }];
    shellAliases = {
      nsws = "nsw --option substitute true";
      wgu = "sudo systemctl start wg-quick-wg0.service";
      wgd = "sudo systemctl stop wg-quick-wg0.service";
      dl =
        "aria2c --console-log-level=error --max-connection-per-server=16 --max-concurrent-downloads=16 --split=16 --continue=true --dir=$HOME/Downloads";
    };
    dotDir = "${config.xdg.configHome}/zsh";
    initContent = ''
      ${builtins.readFile ./widgets.sh}
      ${builtins.readFile ./plugins.sh}
      ${builtins.readFile ./zshrc.sh}
    '';
  };
}
