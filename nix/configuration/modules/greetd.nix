{ pkgs, ... }: {
  services.greetd = {
    enable = true;
    restart = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet -t -r --remember-session";
        user = "greeter";
      };
    };
  };
  systemd.services.greetd.after = [ "systemd-user-sessions.service" ];
  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "null"; # disable error logs flooding greetd
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
  };
}
