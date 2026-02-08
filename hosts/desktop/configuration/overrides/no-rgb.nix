{pkgs, ...}: let
  no-rgb = pkgs.writeScriptBin "no-rgb" ''
    #!/bin/sh
    NUM_DEVICES=$(${pkgs.openrgb}/bin/openrgb --noautoconnect --list-devices 2>/dev/null | grep -E '^[0-9]+: ' | wc -l)

    for i in $(seq 0 $(($NUM_DEVICES - 1))); do
      ${pkgs.openrgb}/bin/openrgb --noautoconnect --device $i --mode static --color 000000 2>/dev/null &
    done
    wait
  '';
in {
  config = {
    services.udev.packages = [pkgs.openrgb];
    boot.kernelModules = ["i2c-dev"];
    hardware.i2c.enable = true;

    systemd.services.no-rgb = {
      description = "Disable RGB lighting";
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
