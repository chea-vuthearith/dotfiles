{
  description = "Nixos config flake";

  inputs = {
    prismlauncher.url = "github:Diegiwg/PrismLauncher-Cracked";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprpanel = {
      url = "github:jas-singhfsu/hyprpanel";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland";
    split-monitor-workspaces = {
      url = "github:Duckonaut/split-monitor-workspaces";
      inputs.hyprland.follows = "hyprland";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let username = "kuro";
    in {
      nixosConfigurations = {
        desktop = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs username; };
          modules = [
            ./hosts/desktop/configuration/configuration.nix
            ./configuration/configuration.nix
          ];
        };

        laptop = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs username; };
          modules = [
            ./hosts/laptop/configuration/configuration.nix
            ./configuration/configuration.nix
          ];
        };
      };
    };
}
