{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      cheese
      bluez
      bluez-tools
      # cisco-packet-tracer_9
    ];
  };
}
