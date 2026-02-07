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
    lib = nixpkgs.lib.extend (final: prev: 
      let utils = import ./lib/utils.nix {lib = final;};
      in utils
    );
    specialArgs = {inherit inputs username;};
    sharedModules = [
      inputs.stylix.nixosModules.stylix
      ./configuration
    ];
  in {
    nixosConfigurations = {
      desktop = nixpkgs.lib.nixosSystem {
        inherit lib;
        inherit specialArgs;
        modules =
          sharedModules
          ++ [./hosts/desktop/configuration];
      };

      laptop = nixpkgs.lib.nixosSystem {
        inherit lib;
        inherit specialArgs;
        modules =
          sharedModules
          ++ [./hosts/laptop/configuration];
      };
    };
  };
}
