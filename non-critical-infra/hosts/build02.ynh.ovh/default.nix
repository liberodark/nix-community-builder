{ ... }:

{
  imports = [ ./hardware.nix ]
    ++ map (f: ../../modules + "/${f}")
      (builtins.filter
        (path: builtins.match ".*\\.nix" path != null)
        (builtins.attrNames (builtins.readDir ./modules))
      )
    ++ map (f: ../../extras + "/${f}")
      (builtins.filter
        (path: builtins.match ".*\\.nix" path != null)
        (builtins.attrNames (builtins.readDir ./extras))
      );

  # Bootloader.
  boot.loader.systemd-boot.enable = true;

  deployment.targetHost = "91.224.148.57";

  networking = {
    useNetworkd = true;
    useDHCP = false;
    hostName = "build02";
    domain = "ynh.ovh";
    hostId = "d28961ec"; # head -c4 /dev/urandom | od -A none -t x4 | sed 's/ //'
  };

  disko.devices = import ./disko.nix;

  systemd.network.networks."10-uplink" = {
    enable = true;
    matchConfig.MACAddress = "10:ff:e0:b9:59:d9";
    address = [
      "91.224.148.57/32"
      "2a03:7220:8080:3900::1/56"
    ];
    routes = [
      {
        Gateway = "91.224.148.0";
        GatewayOnLink = true;
      }
      {
        Gateway = "2a03:7220:8080::1";
        GatewayOnLink = true;
      }
    ];
    linkConfig.RequiredForOnline = "routable";
  };

  system.stateVersion = "24.11";
}
