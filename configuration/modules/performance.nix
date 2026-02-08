{...}: {
  boot = {
    # clear tmp on reboot
    tmp.useTmpfs = true;
    tmp.tmpfsSize = "50%";
    # faster wifi
    kernelModules = ["tcp_bbr"];
    kernel.sysctl = {
      # network performance
      "net.core.netdev_max_backlog" = 16384;
      "net.ipv4.tcp_fastopen" = 3;
      "net.ipv4.tcp_congestion_control" = "bbr";

      # memory management - reduce swap usage
      "vm.swappiness" = 10;
      "vm.vfs_cache_pressure" = 50;
      "vm.dirty_ratio" = 10;
      "vm.dirty_background_ratio" = 5;

      # file system - increase inotify limits for file watchers
      "fs.inotify.max_user_watches" = 524288;
      "fs.inotify.max_user_instances" = 512;
    };
  };

  # compress contents in ram to fit more stuff
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  # ssd trimming
  services.fstrim = {
    enable = true;
    interval = "weekly";
  };

  # kill procs when mem low
  services.earlyoom = {
    enable = true;
    freeMemThreshold = 5;
    freeSwapThreshold = 10;
    enableNotifications = true;
  };
}
