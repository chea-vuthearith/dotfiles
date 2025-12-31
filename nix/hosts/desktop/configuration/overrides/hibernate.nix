{ ... }: {
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=120min
  '';
  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 34 * 1024;
  }];
  boot.kernelParams = [ "resume_offset=89729024" ];
  boot.resumeDevice = "/dev/nvme0n1p2";
}
