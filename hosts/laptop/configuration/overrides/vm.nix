{
  pkgs,
  username,
  ...
}: {
  virtualisation.libvirtd = {
    enable = true;
    qemu.package = pkgs.qemu_kvm;
  };

  programs.virt-manager.enable = true;

  users.users.${username}.extraGroups = ["libvirtd"];
}
