{...}: {
  services.logind.settings.Login.HandlePowerKey = "ignore";
  boot = {
    # Silent boot configuration
    kernelParams = [
      "quiet"
      "splash"
      "vga=current"
      "rd.systemd.show_status=auto"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
      "boot.shell_on_fail"
    ];
    consoleLogLevel = 3;
    initrd.verbose = false;

    loader = {
      limine = {
        enable = true;
        style.wallpapers = [];
        maxGenerations = 3;
      };
      efi.canTouchEfiVariables = true;
      timeout = 1;
    };
    plymouth = {
      enable = true;
    };
  };
}
