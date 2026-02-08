{pkgs, ...}: {
  environment.systemPackages = with pkgs; [neovim wget dconf dbus zinit];
  programs.zsh.enableGlobalCompInit = false;
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-color-emoji
    noto-fonts-cjk-sans
  ];

  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
      max-jobs = "auto";
      cores = 0;
      auto-optimise-store = true;
      keep-outputs = true;
      keep-derivations = true;
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://hyprland.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDSg+E="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
      warn-dirty = false;
      build-use-substitutes = true;
    };

    optimise = {
      automatic = true;
      dates = ["weekly"];
    };
  };

  time.timeZone = "Asia/Phnom_Penh";
  system.stateVersion = "24.11";
}
