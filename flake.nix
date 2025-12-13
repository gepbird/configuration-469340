{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    # Disko for declarative partion management
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Lanzaboote for secure boot
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.3";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Community hardware configurations
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
    };
  };

  nixConfig = {
    extra-substituters = [
      # Numtide cache for unfree packages
      "https://numtide.cachix.org"
      # For NVIDIA Cuda packages
      "https://cuda-maintainers.cachix.org"
    ];
    extra-trusted-public-keys = [
      "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
    ];
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations = {
      blipa = nixpkgs.lib.nixosSystem {
        pkgs = import nixpkgs { system = "x86_64-linux"; config.allowUnfree = true; };
        specialArgs = { inherit inputs; };
        modules = [
          { networking.hostName = "blipa"; }
          inputs.disko.nixosModules.disko
          inputs.lanzaboote.nixosModules.lanzaboote
          ./hosts/blipa
        ];
      };
      # `nix run .#nixosConfigurations.blipa-vm.config.system.build.vm`
      blipa-vm = nixpkgs.lib.nixosSystem {
        pkgs = import nixpkgs { system = "x86_64-linux"; config.allowUnfree = true; };
        specialArgs = { inherit inputs; };
        modules = [
          { networking.hostName = "blipa-vm"; }
          inputs.disko.nixosModules.disko
          inputs.lanzaboote.nixosModules.lanzaboote
          ./hosts/blipa
          {
            boot.lanzaboote.enable = nixpkgs.lib.mkForce false;
            boot.loader.systemd-boot.enable = nixpkgs.lib.mkForce true;
            disko.devices = nixpkgs.lib.mkForce {};
            users.users.arthur.hashedPassword = nixpkgs.lib.mkForce null;
            users.users.arthur.initialPassword = "arthur";
          }
        ];
      };
    };
  };
}
