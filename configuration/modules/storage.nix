{...}: {
  boot = {
    # clear tmp on reboot
    tmp = {
      useTmpfs = true;
      tmpfsSize = "50%";
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
