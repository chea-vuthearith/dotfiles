{...}: {
  flake.modules.nixos.desktop = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      neovim
      wget
      dconf
      dbus

      # libs
      glib
      libgtop
      linux-firmware
      libnotify
    ];
    programs.zsh.enableGlobalCompInit = false;
    fonts.packages = with pkgs; [
      noto-fonts
      noto-fonts-color-emoji
      noto-fonts-cjk-sans
    ];

    nix.settings = {
      extra-substituters = ["https://hyprland.cachix.org"];
      extra-trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
    };

    time.timeZone = "Asia/Phnom_Penh";
    system.stateVersion = "24.11";
  };
  flake.modules.homeManager.desktop = {...}: {
    home = {
      stateVersion = "24.11";
      preferXdgDirectories = true;
      sessionVariables = {
        NIXOS_OZONE_WL = "1";
        NIXPKGS_ALLOW_UNFREE = 1;
        XCURSOR_THEME = "Catppuccin-Mocha-Lavender-Cursors";
        XCURSOR_SIZE = "12";
      };
    };
  };
}
