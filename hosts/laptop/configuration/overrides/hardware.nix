{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    mesa
    vulkan-tools
  ];

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        intel-media-driver
        intel-vaapi-driver
      ];
    };
    bluetooth = {
      enable = true;
      powerOnBoot = false;
    };
  };
  systemd = {
    sleep.extraConfig = ''
      HibernateDelaySec=30min
    '';
    services.bluetooth = {after = ["multi-user.target"];};
  };
}
