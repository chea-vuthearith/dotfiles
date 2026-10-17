{...}: {
  flake.modules.nixos.host-server = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      neovim
      wget
      git
      linux-firmware
    ];

    programs.zsh.enableGlobalCompInit = false;

    time.timeZone = "Asia/Phnom_Penh";
    system.stateVersion = "24.11";
  };
  flake.modules.homeManager.host-server = {...}: {
    home = {
      stateVersion = "24.11";
      preferXdgDirectories = true;
      sessionVariables = {
        NIXPKGS_ALLOW_UNFREE = 1;
      };
    };
  };
}
