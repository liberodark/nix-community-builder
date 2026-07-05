{ ... }:

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

  deployment.targetHost = "91.224.148.30";

  networking = {
    useNetworkd = true;
    useDHCP = false;
    hostName = "build07";
    domain = "ynh.ovh";
    hostId = "007cf0c5"; # head -c4 /dev/urandom | od -A none -t x4 | sed 's/ //'
  };

  systemd.network.networks."10-uplink" = {
    enable = true;
    matchConfig.MACAddress = "50:0a:52:0b:e6:8b";
    address = [
      "91.224.148.30/32"
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
