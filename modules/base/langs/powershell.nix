{...}: {
  # pwsh only; PSScriptAnalyzer is a PowerShell Gallery module, not in nixpkgs
  flake.modules.homeManager.base = {pkgs, ...}: {
    home.packages = [pkgs.powershell];
  };
}
