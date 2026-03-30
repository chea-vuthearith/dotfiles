{
  pkgs,
  username,
  ...
}: {
  users.${username}.extraGroups = [
    "libvirtd"
  ];
  libvirtd.enable = true;
  programs.virt-manager.enable = true;
  virtualisation.libvirtd = {
    spiceUSBRedirection.enable = true;
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
      ovmf = {
        enable = true;
        packages = [
          (pkgs.OVMF.override {
            secureBoot = true;
            tpmSupport = true;
          }).fd
        ];
      };
    };
  };
}
