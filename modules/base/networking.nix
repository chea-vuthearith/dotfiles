{config, ...}: {
  flake.modules.nixos.base = {...}: {
    users.users.${config.username}.extraGroups = ["networkmanager"];
    networking = {
      networkmanager = {
        enable = true;
      };
      firewall = {
        enable = true;
      };
      wg-quick.interfaces = {
        wg0 = {
          configFile = "/etc/wireguard/wg0.conf";
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
