{...}: {
  boot.loader.limine.extraEntries = ''
    /Windows
      protocol: efi
      path: uuid(C6C67D2FC67D213B):/EFI/Microsoft/Boot/bootmgfw.efi
  '';
}
