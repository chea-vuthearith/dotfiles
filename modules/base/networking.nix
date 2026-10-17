{config, ...}: let
  inherit (config) username;
in {
  flake.modules.nixos.base = {config, ...}: {
    sops.secrets."wg0.conf" = {};
    users.users.${username}.extraGroups = ["networkmanager"];
    networking = {
      networkmanager = {
        enable = true;
      };
      firewall = {
        enable = true;
      };
      wg-quick.interfaces = {
        wg0 = {
          configFile = config.sops.secrets."wg0.conf".path;
          autostart = false;
        };
      };
    };

    systemd.network.wait-online.enable = false; # network dont block boot
  };
  flake.modules.homeManager.base = {...}: {
    programs.zsh.shellAliases = {
      wgu = "sudo systemctl start wg-quick-wg0.service";
      wgd = "sudo systemctl stop wg-quick-wg0.service";
    };
  };
}
