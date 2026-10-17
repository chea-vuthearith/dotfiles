{config, ...}: {
  flake.modules.nixos.host-server = {pkgs, ...}: let
    # WD10SPZX 1 TB 5400 rpm. Formatted once by hand (wipes the disk):
    #   sudo mkfs.btrfs -f -L storage /dev/disk/by-id/ata-WDC_WD10SPZX-08Z10_WD-WXE2A518TLRS
    #   sudo mount -L storage /mnt && sudo btrfs subvolume create /mnt/@storage && sudo umount /mnt
    disk = "/dev/disk/by-id/ata-WDC_WD10SPZX-08Z10_WD-WXE2A518TLRS";
  in {
    fileSystems."/srv/storage" = {
      device = "/dev/disk/by-label/storage";
      fsType = "btrfs";
      # nofail: a dead or missing drive never blocks boot.
      options = ["subvol=@storage" "compress=zstd:1" "noatime" "nofail" "x-systemd.device-timeout=10s"];
    };

    systemd.tmpfiles.rules = ["d /srv/storage 0755 ${config.username} users -"];

    # Read every block monthly so a failing disk shows up before the data is needed.
    services.btrfs.autoScrub = {
      enable = true;
      fileSystems = ["/srv/storage"];
      interval = "monthly";
    };

    # Spin down after 20 min idle (-S 240 = 240 x 5 s).
    services.udev.extraRules = ''
      ACTION=="add|change", KERNEL=="sd[a-z]", ENV{ID_SERIAL_SHORT}=="WD-WXE2A518TLRS", RUN+="${pkgs.hdparm}/bin/hdparm -S 240 /dev/%k"
    '';

    environment.systemPackages = [pkgs.btrfs-progs pkgs.hdparm pkgs.smartmontools];
    # SMART health checks; failures go to the journal.
    services.smartd = {
      enable = true;
      devices = [{device = disk;}];
      # earlyoom already enables systembus-notify; match it.
      notifications.systembus-notify.enable = true;
    };
  };
}
