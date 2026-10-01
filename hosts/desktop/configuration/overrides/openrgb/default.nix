{...}: {
  config = {
    services.hardware.openrgb = {
      enable = true;
      startupProfile = "blackedout";
    };

    # Pin OpenRGB's config dir to the module's StateDirectory (/var/lib/OpenRGB).
    systemd.services.openrgb.environment.XDG_CONFIG_HOME = "/var/lib";

    systemd.tmpfiles.rules = [
      "L+ /var/lib/OpenRGB/profiles/blackedout.json - - - - ${./blackedout.json}"
    ];
  };
}
