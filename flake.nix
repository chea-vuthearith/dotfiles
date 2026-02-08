{
  description = "Nixos config flake";

  inputs = {
    apple-fonts.url = "github:Lyndeno/apple-fonts.nix";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    caelestia-cli = {
      url = "github:chea-vuthearith/cli?ref=feat/record-to-clip";
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
  };

  outputs = {nixpkgs, ...} @ inputs: let
    system = "x86_64-linux";
    username = "kuro";
    lib = nixpkgs.lib.extend (
      final: prev: let
        utils = import ./lib/utils.nix {lib = final;};
      in
        utils
    );
    specialArgs = {inherit inputs username;};
    sharedModules = [
      inputs.stylix.nixosModules.stylix
      ./configuration
    ];
  in {
    nixosConfigurations = {
      desktop = nixpkgs.lib.nixosSystem {
        inherit lib specialArgs system;
        modules =
          sharedModules
          ++ [./hosts/desktop/configuration];
      };

      laptop = nixpkgs.lib.nixosSystem {
        inherit lib specialArgs system;
        modules =
          sharedModules
          ++ [./hosts/laptop/configuration];
      };
    };
  };
}
