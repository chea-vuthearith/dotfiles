{pkgs, ...}: let
  no-rgb = pkgs.writeScriptBin "no-rgb" ''
    #!/bin/sh
    ${pkgs.openrgb}/bin/openrgb --noautoconnect --profile ${./blackedout.orp} 2>&1 || true
  '';
in {
  config = {
    services.udev.packages = [pkgs.openrgb];
    boot.kernelModules = ["i2c-dev"];
    hardware.i2c.enable = true;

    systemd.services.no-rgb = {
      description = "Apply blackedout RGB profile";
      after = ["multi-user.target"];
      serviceConfig = {
        ExecStart = "${no-rgb}/bin/no-rgb";
        Type = "idle";
        RemainAfterExit = true;
        StandardOutput = "null";
        StandardError = "journal";
      };
      wantedBy = ["multi-user.target"];
    };
  };
}
