{
  inputs,
  username,
  hostname,
  ...
}: {
  imports = [inputs.home-manager.nixosModules.default];
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    extraSpecialArgs = {inherit inputs;};
    users.${username} = import ../../hosts/${hostname}/home-manager;
  };
}
