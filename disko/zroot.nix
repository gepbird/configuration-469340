{ refreservation }:
{
  type = "zpool";
  options = {
    # Enable automatic trimming to enable the SSD to perform wear levelling
    autotrim = "on";
  };
  rootFsOptions = {
    # Allow storing ACLs and use system-attributes for those extended attributes
    acltype = "posix";
    xattr = "sa";
    dnodesize = "auto";
    # Enable compression with the default algorithm
    compression = "on";
    # Don't write access times every single time (only if >24h ago)
    relatime = "on";
    # Don't allow mounting the pool itself
    canmount = "off";
    # Normalize Unicode file names
    # Don't do it! https://github.com/NixOS/nixpkgs/pull/86432
    # normalization = "formD";
  };
  mountpoint = "/";
  postCreateHook = "zfs snapshot zroot@blank";
  datasets = {
    root = {
      type = "zfs_fs";
      options.mountpoint = "legacy";
      mountpoint = "/";
    };
    home = {
      type = "zfs_fs";
      options.mountpoint = "legacy";
      mountpoint = "/home";
    };
    nix = {
      type = "zfs_fs";
      options.mountpoint = "legacy";
      mountpoint = "/nix";
    };
    var = {
      type = "zfs_fs";
      options.mountpoint = "none";
    };
    "var/lib" = {
      type = "zfs_fs";
      options.mountpoint = "legacy";
      mountpoint = "/var/lib";
    };
    "var/log" = {
      type = "zfs_fs";
      options.mountpoint = "legacy";
      mountpoint = "/var/log";
    };
    reserved = {
      type = "zfs_fs";
      options.mountpoint = "none";
      options.refreservation = refreservation;
    };
  };
}
