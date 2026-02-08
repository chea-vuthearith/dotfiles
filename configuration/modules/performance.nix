{pkgs, ...}: {
  # ===== PERFORMANCE OPTIMIZATIONS =====
  
  # Kernel parameters for better performance
  boot.kernel.sysctl = {
    # Network performance
    "net.core.netdev_max_backlog" = 16384;
    "net.ipv4.tcp_fastopen" = 3;
    "net.ipv4.tcp_congestion_control" = "bbr";
    
    # Memory management - reduce swap usage
    "vm.swappiness" = 10;
    "vm.vfs_cache_pressure" = 50;
    "vm.dirty_ratio" = 10;
    "vm.dirty_background_ratio" = 5;
    
    # File system - increase inotify limits for file watchers
    "fs.inotify.max_user_watches" = 524288;
    "fs.inotify.max_user_instances" = 512;
  };

  # Zram swap - compressed RAM swap for better performance
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50; # Use up to 50% of RAM for compressed swap
  };

  # Automatic SSD TRIM for better SSD performance and longevity
  services.fstrim = {
    enable = true;
    interval = "weekly";
  };

  # Early OOM killer to prevent system freezes
  services.earlyoom = {
    enable = true;
    freeMemThreshold = 5;  # Kill processes when free memory < 5%
    freeSwapThreshold = 10; # Kill processes when free swap < 10%
    enableNotifications = true;
  };

  # Use tmpfs for /tmp (faster, cleared on reboot)
  boot.tmp.useTmpfs = true;
  boot.tmp.tmpfsSize = "50%";

  # BBR congestion control module
  boot.kernelModules = ["tcp_bbr"];
}
