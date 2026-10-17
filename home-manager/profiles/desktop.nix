# Graphical workstation: picks modules from ../optional.
{inputs, ...}: {
  imports = [
    inputs.dms.homeModules.default
    inputs.dms-plugin-registry.homeModules.default
    ../optional/aria2.nix
    ../optional/cli.nix
    ../optional/environment.nix
    ../optional/ghostty
    ../optional/hyprland
    ../optional/kde-connect.nix
    ../optional/packages.nix
    ../optional/services.nix
    ../optional/shell.nix
    ../optional/theme.nix
    ../optional/vscode.nix
    ../optional/xdg.nix
    ../optional/yazi.nix
    ../optional/zed
  ];
}
