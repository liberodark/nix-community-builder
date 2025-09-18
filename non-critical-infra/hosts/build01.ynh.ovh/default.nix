{ inputs, ... }:

{
  imports = [
    ../../modules/common
    ./hardware.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;

  deployment.targetHost = "185.119.168.14";

  networking = {
    useNetworkd = true;
    useDHCP = false;
    hostName = "build01";
    domain = "ynh.ovh";
    hostId = "007f0305";
  };

  disko.devices = import ./disko.nix;

  systemd.network.networks."10-uplink" = {
    enable = true;
    matchConfig.MACAddress = "22:17:4d:04:90:ca";
    address = [ "185.119.168.14/32" ];
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
