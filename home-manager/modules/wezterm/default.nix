{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    nerd-fonts.victor-mono
  ];

  systemd.user.services.wezterm-server = {
    Unit = {
      Description = "WezTerm Server Multiplexer";
      After = ["graphical-session.target"];
    };
    Service = {
      Type = "forking";
      ExecStart = "${pkgs.wezterm}/bin/wezterm-mux-server --daemonize";
      Restart = "always";
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };
  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;
    extraConfig =
      builtins.readFile ./wezterm.lua
      + ''
        config.font_size = ${toString config.stylix.fonts.sizes.terminal}
        config.font = wezterm.font("${config.stylix.fonts.monospace.name}", { weight = "Medium" })
        config.font_rules = {
        	{
            intensity = "Bold",
        		font = wezterm.font("${config.stylix.fonts.monospace.name}", { weight = "Bold" }),
        	},
        	{
        		italic = true,
        		font = wezterm.font("VictorMono Nerd Font", { weight = "Regular", style = "Italic" }),
        	},
        	{
        		italic = true,
        		intensity = "Bold",
        		font = wezterm.font("VictorMono Nerd Font", { weight = "DemiBold", style = "Italic" }),
        	},
        }
        return config
      '';
  };
}
