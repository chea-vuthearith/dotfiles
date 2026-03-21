{...}: {
  environment.defaultPackages = with pkgs; [
    vulkan-tools
    mesa
  ];
}
