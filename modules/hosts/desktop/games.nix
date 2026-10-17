{...}: {
  flake.modules.nixos.host-desktop = {...}: {
    security.pam.loginLimits = [
      {
        domain = "*";
        type = "soft";
        item = "memlock";
        value = "unlimited";
      }
      {
        domain = "*";
        type = "hard";
        item = "memlock";
        value = "unlimited";
      }
    ];
  };
  flake.modules.homeManager.host-desktop = {pkgs, ...}: {
    home.packages = with pkgs; [
      mono
      steam
      # rpcs3
      # SDL2
    ];
  };
}
