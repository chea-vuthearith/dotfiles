{
  flake.modules.nixos.desktop = {
    # BIOS/device firmware updates via LVFS: `fwupdmgr refresh && fwupdmgr update`
    services.fwupd.enable = true;
  };
}
