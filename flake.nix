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

  outputs =
    { self, nixpkgs, ... }@inputs:
    {
      nixosConfigurations = {
        blipa = nixpkgs.lib.nixosSystem {
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
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
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
          specialArgs = { inherit inputs; };
          modules = [
            { networking.hostName = "blipa-vm"; }
            inputs.disko.nixosModules.disko
            inputs.lanzaboote.nixosModules.lanzaboote
            ./hosts/blipa
            (
              { pkgs, ... }:
              {
                boot.lanzaboote.enable = nixpkgs.lib.mkForce false;
                boot.loader.systemd-boot.enable = nixpkgs.lib.mkForce true;
                disko.devices = nixpkgs.lib.mkForce { };
                users.users.arthur.hashedPassword = nixpkgs.lib.mkForce null;
                users.users.arthur.initialPassword = "arthur";
                virtualisation.vmVariant.virtualisation.memorySize = 4096;
                services.getty.autologinUser = "arthur";
                environment.systemPackages = with pkgs; [
                  xfce.xfce4-terminal
                ];
                services.gnome.core-apps.enable = false;
                services.gnome.core-developer-tools.enable = false;
                services.gnome.games.enable = false;
                services.gnome.gnome-browser-connector.enable = false;
                environment.gnome.excludePackages = with pkgs; [
                  gnome-tour
                  gnome-user-docs
                  baobab      # disk usage analyzer
                  cheese      # photo booth
                  eog         # image viewer
                  epiphany    # web browser
                  gedit       # text editor
                  simple-scan # document scanner
                  totem       # video player
                  yelp        # help viewer
                  evince      # document viewer
                  file-roller # archive manager
                  geary       # email client
                  seahorse    # password manager
                  gnome-calculator
                  gnome-maps
                  gnome-console
                  gnome-calendar
                  gnome-contacts
                ];
                services.gnome.evolution-data-server.enable = nixpkgs.lib.mkForce false;
                #services.xserver.displayManager.autoLogin.enable = true;
                #services.xserver.displayManager.autoLogin.user = "arthur";
                nixpkgs.overlays = [
                  (
                    final: prev:
                    let
                      pkgs' = import (prev.fetchzip {
                        url = "https://github.com/NixOS/nixpkgs/archive/16db70aea3e6af351e8ad4c217745ec67d46c8ca.tar.gz";
                        hash = "sha256-aUjQebbh+0SaZF0VMWtWF+DJAYx5IMbsor8F+VZQhDk=";
                      }) { inherit (prev) system; };
                    in
                    {
                      inherit (pkgs')
                        webkitgtk_4_1
                        webkitgtk_6_0
                        #libadwaita
                        #gjs
                        gnome-control-center
                        libsecret
                        ;
                      pipewire = prev.pipewire.overrideAttrs { doCheck = false; };
                      libdrm = prev.libdrm.override { withValgrind = false; };
                      mesa = prev.mesa.override { withValgrind = false; };
                    }
                  )
                ];
              }
            )
          ];
        };
      };
    };
}
