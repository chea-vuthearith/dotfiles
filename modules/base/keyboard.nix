{...}: {
  # Caps Lock <-> Escape at the evdev level: applies on TTY, every compositor and the server.
  flake.modules.nixos.base = {
    services.keyd = {
      enable = true;
      keyboards.default = {
        ids = ["*"];
        settings.main = {
          capslock = "esc";
          esc = "capslock";
        };
      };
    };
  };
}
