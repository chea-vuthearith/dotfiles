{...}: {
  powerManagement.enable = true;
  services = {
    upower.enable = true;
    thermald.enable = true;
    logind = {
      settings.Login = {
        HoldoffTimeoutSec = "0s";
        HandleLidSwitch = "suspend-then-hibernate";
      };
    };
    tlp = {
      enable = true;
      settings = {
        STOP_CHARGE_THRESH_BAT0 = 80;
      };
    };
  };

  systemd = {
    sleep.settings.Sleep = {
      HibernateDelaySec = "120min";
    };
    services.upower = {
      after = ["multi-user.target"];
    };
  };
}
