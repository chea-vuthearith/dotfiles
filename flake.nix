{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland";
    split-monitor-workspaces = {
      url = "github:Duckonaut/split-monitor-workspaces";
      inputs.hyprland.follows = "hyprland";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    username = "kuro";
  in {
    nixosConfigurations = {
      desktop = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs username;};
        modules = [
          inputs.stylix.nixosModules.stylix
          ./hosts/desktop/configuration
          ./configuration
        ];
      };

      laptop = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs username;};
        modules = [
          inputs.stylix.nixosModules.stylix
          ./hosts/laptop/configuration
          ./configuration
        ];
      };
    };
  };
}
