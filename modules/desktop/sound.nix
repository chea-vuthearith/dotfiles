{config, ...}: {
  flake.modules.nixos.desktop = {...}: {
    users.users.${config.username}.extraGroups = ["audio"];
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      wireplumber.enable = true;
    };
  };
}
