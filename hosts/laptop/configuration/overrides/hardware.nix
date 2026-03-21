{...}: {
  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = false;
    };
  };
  systemd = {
    services.bluetooth = {after = ["multi-user.target"];};
  };
}
