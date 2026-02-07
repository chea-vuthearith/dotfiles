{...}: {
  boot.loader.limine.extraEntries = ''
    /Windows
      protocol: efi
      path: boot():/EFI/Microsoft/Boot/bootmgfw.efi
  '';
}
