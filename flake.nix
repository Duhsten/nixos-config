{
  description = "duhsten's nixos config — multi-host, modular";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, zen-browser, ... }@inputs:
    let
      # mkHost builds a full nixos system config for a given host directory
      # to add a new machine: create hosts/<name>/ with default.nix + hardware-configuration.nix
      # then add it below like: new-pc = mkHost "new-pc";
      mkHost = name: nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/${name}         # host-specific stuff (hostname, gpu, hardware)
          ./modules/common.nix    # shared config across all machines
          ./modules/desktop.nix   # wayland, compositors, greeter
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.duhsten = import ./home/duhsten.nix;
          }
        ];
      };
    in
    {
      nixosConfigurations = {
        osborne-home = mkHost "osborne-home";
        osborne-work = mkHost "osborne-work";
      };
    };
}
