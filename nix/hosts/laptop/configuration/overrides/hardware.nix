{...}: {
  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = false;
    };
  };
  virtualisation = { libvirtd.enable = true; };

  systemd.sleep.extraConfig = ''
    HibernateDelaySec=30min
  '';

}
