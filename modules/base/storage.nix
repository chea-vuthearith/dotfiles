{...}: {
  flake.modules.nixos.base = {...}: {
    boot = {
      # clear tmp on reboot
      tmp = {
        useTmpfs = true;
        tmpfsSize = "50%";
      };
    };

    # compress contents in ram to fit more stuff. Sized to RAM: zstd averages ~3-4x,
    # so a full device costs roughly a quarter of RAM and keeps pages off the SSD.
    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = 100;
    };

    # zram tuning (as Fedora/Pop!_OS): swapping to compressed RAM is cheaper than
    # dropping page cache, and readahead is pointless on a RAM-backed device.
    boot.kernel.sysctl = {
      "vm.swappiness" = 180;
      "vm.page-cluster" = 0;
      "vm.watermark_boost_factor" = 0;
      "vm.watermark_scale_factor" = 125;
    };

    # ssd trimming
    services.fstrim = {
      enable = true;
      interval = "weekly";
    };

    # kill procs when mem low; earlyoom only, systemd-oomd would race it
    services.earlyoom = {
      enable = true;
      freeMemThreshold = 5;
      freeSwapThreshold = 10;
      enableNotifications = true;
    };
    systemd.oomd.enable = false;
  };
}
