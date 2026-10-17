{...}: let
  mac = "04:7c:16:e1:5a:dc"; # desktop enp5s0 (r8169)
in {
  # NetworkManager owns enp5s0 and its profile defers to this default; 64 = magic packet.
  flake.modules.nixos.host-desktop = {...}: {
    networking.networkmanager.settings.connection."ethernet.wake-on-lan" = 64;
  };

  # Broadcast on the home LAN (wlo1); WoL needs only the MAC, not the desktop's IP.
  flake.modules.homeManager.host-server = {pkgs, ...}: {
    home.packages = [pkgs.wakeonlan];
    programs.zsh.shellAliases.wake-desktop = "wakeonlan -i 192.168.0.255 ${mac}";
  };
}
