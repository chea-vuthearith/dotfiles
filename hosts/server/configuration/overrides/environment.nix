{
  username,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    neovim
    wget
    git
    linux-firmware
  ];

  programs.zsh.enableGlobalCompInit = false;

  nix = {
    settings = {
      trusted-users = ["root" username];
      experimental-features = ["nix-command" "flakes"];
      max-jobs = "auto";
      cores = 0;
      auto-optimise-store = true;
      keep-outputs = true;
      keep-derivations = true;
      extra-substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://cache.numtide.com"
      ];
      extra-trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDSg+E="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      ];
      warn-dirty = false;
      build-use-substitutes = true;
    };
    gc = {
      automatic = true;
      dates = ["weekly"];
    };
    optimise = {
      automatic = true;
      dates = ["weekly"];
    };
  };

  time.timeZone = "Asia/Phnom_Penh";
  system.stateVersion = "24.11";
}
