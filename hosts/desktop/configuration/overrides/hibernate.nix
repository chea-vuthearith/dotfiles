{...}: {
  systemd.sleep.settings.Sleep = {
    HibernateDelaySec = "120min";
  };
  services.power-profiles-daemon.enable = true;
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 34 * 1024;
    }
  ];
  boot.kernelParams = ["resume_offset=89729024"];
  boot.resumeDevice = "/dev/nvme0n1p2";
}
