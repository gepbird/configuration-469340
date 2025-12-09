{ inputs, ... }:

{
  imports = [
    # Import hardware configuration
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x1-6th-gen

    ./disko-configuration.nix
    ./hardware-configuration.nix
  ];

  boot.initrd.supportedFilesystems = [ "zfs" ];
  boot.initrd.kernelModules = [ "zfs" ];

  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportAll = false;
  # Enabled by default, but recommended to disable.
  # If it won't boot without, setting kernel parameters is required.
  boot.zfs.forceImportRoot = false;

  networking.hostId = "f1e73287";

  # LUKS encryption with automatic unlock
  boot.initrd.systemd.enable = true;

  # Use Lanzaboote for secure boot
  boot.loader.systemd-boot.enable = false;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };

  users.users.arthur = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    hashedPassword = "$6$IgjKfnXzaMlQv1u2$Pfp1fF3z1It.g9NYNwPyVI4Kx.DfHv.pH4o3hogdNTQUYpCE/w5LAoG8PD2JCaSh5DrmyMEHI5aVLv4272KQg.";
  };

  hardware.opentabletdriver.enable = true;

  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Amsterdam";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "nl_NL.UTF-8";
    LC_IDENTIFICATION = "nl_NL.UTF-8";
    LC_MEASUREMENT = "nl_NL.UTF-8";
    LC_MONETARY = "nl_NL.UTF-8";
    LC_NAME = "nl_NL.UTF-8";
    LC_NUMERIC = "nl_NL.UTF-8";
    LC_PAPER = "nl_NL.UTF-8";
    LC_TELEPHONE = "nl_NL.UTF-8";
    LC_TIME = "nl_NL.UTF-8";
  };

  # Request Chromium and Electron to run with Wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  services.xserver.videoDrivers = [ "modesetting" ];
  hardware.graphics.enable = true;

  console.useXkbConfig = true;

  # Enable sound.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable the fwupd daemon for firmware updates
  services.fwupd.enable = true;

  fonts.enableDefaultPackages = true;
  fonts.enableGhostscriptFonts = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

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
