{
  description = "Nixos config flake";

  inputs = {
    secrets.url = "git+ssh://git@github.com/chea-vuthearith/secrets.git";
    direnv-instant.url = "github:Mic92/direnv-instant";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    brave-origin-nixpkgs.url = "github:Dreaming-Codes/nixpkgs/brave-channels";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    apple-fonts.url = "github:Lyndeno/apple-fonts.nix";
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dms = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dms-plugin-registry = {
      url = "github:AvengeMedia/dms-plugin-registry";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # hypr-dynamic-cursors = {
    #   url = "github:VirtCode/hypr-dynamic-cursors";
    #   inputs.nixpkgs.follows = "nixpkgs";
    #   inputs.hyprland.follows = "hyprland";
    # };
    # hyprsplit = {
    #   url = "github:shezdy/hyprsplit";
    #   inputs.hyprland.follows = "hyprland";
    # };
    # hyprtasking = {
    #   url = "github:raybbian/hyprtasking";
    #   inputs.hyprland.follows = "hyprland";
    # };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    username = "kuro";

    # for symlinking configs for hot reload
    repoDir = "/home/${username}/dotfiles";

    lib = nixpkgs.lib.extend (
      final: prev: let
        utils = import ./lib/utils.nix {
          inherit self repoDir;
          lib = final;
        };
      in
        utils
    );

    sharedArgs = {inherit inputs username;};
    sharedModules = [./configuration];
  in {
    nixosConfigurations = {
      desktop = nixpkgs.lib.nixosSystem {
        inherit lib system;
        specialArgs = sharedArgs // {hostname = "desktop";};
        modules = sharedModules ++ [./hosts/desktop/configuration];
      };

      laptop = nixpkgs.lib.nixosSystem {
        inherit lib system;
        specialArgs = sharedArgs // {hostname = "laptop";};
        modules = sharedModules ++ [./hosts/laptop/configuration];
      };
    };
  };
}
