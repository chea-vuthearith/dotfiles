{...}: {
  flake.modules.homeManager.base = {pkgs, ...}: {
    home.sessionVariables.PAGER = "less -X -F";
    programs = {
      atuin = {
        enable = true;
        settings = {
          filter_mode_shell_up_key_binding = "session";
          search_mode = "fuzzy";
          style = "full";
          show_preview = true;
        };
      };
      bat.enable = true;
      fzf = {
        enable = true;
        enableZshIntegration = true;
        historyWidget.command = ""; # atuin owns Ctrl-R
      };
      zoxide = {
        enable = true;
        enableZshIntegration = true;
      };
      zsh.shellAliases = {
        cat = "bat";
        ls = "eza --icons always";
        lt = "eza --tree --icons always";
      };
    };
    home.packages = with pkgs; [
      eza
      fd
      ripgrep
      lsof
      zip
      unzip
      unrar
      bottom
      jq
      xh
      magic-wormhole
    ];
  };
}
