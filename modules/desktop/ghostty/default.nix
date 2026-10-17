{...}: {
  flake.modules.homeManager.desktop = {
    pkgs,
    lib,
    config,
    ...
  }: {
    home.packages = with pkgs; [
      nerd-fonts.victor-mono
    ];
    programs.ghostty = {
      enable = true;
      enableZshIntegration = true;
      systemd.enable = true;
      settings = {
        window-padding-x = "5";
        window-padding-y = "0";
        shell-integration-features = "ssh-env, title";
        font-family = config.stylix.fonts.monospace.name;
        font-family-italic = "VictorMono Nerd Font";
        font-family-bold-italic = "VictorMono Nerd Font";
        confirm-close-surface = false;
        mouse-hide-while-typing = true;
        resize-overlay = "never";
        # herdr owns tabs/splits: drop Ghostty's tab/split defaults, which take keys
        # (alt+1..9 = herdr tabs) before they reach herdr.
        keybind =
          [
            "ctrl+tab=unbind"
            "ctrl+shift+tab=unbind"
            "ctrl+page_up=unbind"
            "ctrl+page_down=unbind"
            "ctrl+shift+t=unbind"
            "ctrl+shift+arrow_left=unbind"
            "ctrl+shift+arrow_right=unbind"
            "ctrl+alt+arrow_up=unbind"
            "ctrl+alt+arrow_down=unbind"
            "ctrl+alt+arrow_left=unbind"
            "ctrl+alt+arrow_right=unbind"
          ]
          ++ lib.concatMap (n: ["alt+${n}=unbind" "alt+digit_${n}=unbind"]) (map toString (lib.range 1 9));
      };
    };
  };
}
