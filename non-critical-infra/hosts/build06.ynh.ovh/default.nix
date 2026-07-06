{ lib, ... }:

{
  imports = [
    ./hardware.nix
  ]
  ++ map (f: ../../modules + "/${f}") (
    builtins.filter (path: builtins.match ".*\\.nix" path != null) (
      builtins.attrNames (builtins.readDir ../../modules)
    )
  )
  ++ map (f: ../../extras + "/${f}") (
    builtins.filter (path: builtins.match ".*\\.nix" path != null) (
      builtins.attrNames (builtins.readDir ../../extras)
    )
  );

  # Bootloader.
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 3;
  };

  nix.gc.options = lib.mkForce "--delete-older-than 180d";

  deployment.targetHost = "91.224.148.87";

  networking = {
    useNetworkd = true;
    useDHCP = false;
    hostName = "build06";
    domain = "ynh.ovh";
    hostId = "c11a1d32"; # head -c4 /dev/urandom | od -A none -t x4 | sed 's/ //'
  };

  systemd.network.networks."10-uplink" = {
    enable = true;
    matchConfig.MACAddress = "50:0a:52:0b:e4:d6";
    address = [
      "91.224.148.87/32"
    ];
    routes = [
      {
        Gateway = "91.224.148.0";
        GatewayOnLink = true;
      }
    ];
    linkConfig.RequiredForOnline = "routable";
  };

  system.stateVersion = "26.05";
}
