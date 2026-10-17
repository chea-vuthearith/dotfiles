{config, ...}: let
  inherit (config) username;
in {
  flake.modules.nixos.host-laptop = {pkgs, ...}: {
    virtualisation.libvirtd = {
      enable = true;
      qemu.package = pkgs.qemu_kvm;
    };

    programs.virt-manager.enable = true;

    users.users.${username}.extraGroups = ["libvirtd"];
  };
}
