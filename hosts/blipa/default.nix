{ inputs, pkgs, ... }:

{
  imports = [
    ./disko-configuration.nix
    ./hardware-configuration.nix
  ];

  networking.hostId = "f1e73287";

  users.users.arthur = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    hashedPassword = "$6$IgjKfnXzaMlQv1u2$Pfp1fF3z1It.g9NYNwPyVI4Kx.DfHv.pH4o3hogdNTQUYpCE/w5LAoG8PD2JCaSh5DrmyMEHI5aVLv4272KQg.";
  };

  hardware.opentabletdriver.enable = true;

  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  networking.networkmanager.enable = true;

  # Ensure clean /tmp on boot
  #boot.tmp.cleanOnBoot = true;

  # Enable flakes and new CLI
  nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
  };

  services.xserver.videoDrivers = [ "modesetting" ];
  hardware.graphics.enable = true;

  console.useXkbConfig = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?
}
