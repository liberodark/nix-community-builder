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
  boot.loader.systemd-boot.enable = true;

  deployment.targetHost = "91.224.148.106";

  networking = {
    useNetworkd = true;
    useDHCP = false;
    hostName = "build04";
    domain = "ynh.ovh";
    hostId = "9debd924"; # head -c4 /dev/urandom | od -A none -t x4 | sed 's/ //'
  };

  disko.devices = import ./disko.nix;

  systemd.network.networks."10-uplink" = {
    enable = true;
    matchConfig.MACAddress = "38:05:25:33:e3:ab";
    address = [
      "91.224.148.106/32"
    ];
    routes = [
      {
        Gateway = "91.224.148.0";
        GatewayOnLink = true;
      }
    ];
    linkConfig.RequiredForOnline = "routable";
  };

  system.stateVersion = "24.11";
}
