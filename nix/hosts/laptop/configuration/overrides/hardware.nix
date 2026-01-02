{...}: {
  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = false;
    };
  };
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=30min
  '';

}
