{pkgs, ...}: let
  no-rgb = pkgs.writeScriptBin "no-rgb" ''
    #!/bin/sh
    echo "applying blackedout profile: ${./blackedout.orp}"
    ${pkgs.openrgb}/bin/openrgb --noautoconnect --profile ${./blackedout.orp}
    status=$?
    if [ $status -ne 0 ]; then
      echo "openrgb exited with status $status" >&2
    fi
    exit $status
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
        StandardOutput = "journal";
        StandardError = "journal";
        SyslogIdentifier = "no-rgb";
      };
      wantedBy = ["multi-user.target"];
    };
  };
}
