{ ... }:

{
  imports = [
    ./hardware.nix
  ]
  ++ map (f: ../../modules/darwin + "/${f}") (
    builtins.filter (path: builtins.match ".*\\.nix" path != null) (
      builtins.attrNames (builtins.readDir ../../modules/darwin)
    )
  )
  ++ map (f: ../../extras/darwin + "/${f}") (
    builtins.filter (path: builtins.match ".*\\.nix" path != null) (
      builtins.attrNames (builtins.readDir ../../extras/darwin)
    )
  );

  networking = {
    hostName = "build03";
    domain = "ynh.ovh";
  };

  nix.settings = {
    cores = 4;
    max-jobs = 6;
  };

  darwin.network.networks."10-uplink" = {
    enable = true;
    matchConfig.MACAddress = "d0:11:e5:04:5a:e3";
    address = [
      "91.224.148.58/32"
      "2a03:7220:8080:3a00::1/56"
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
    dns = [ "1.1.1.1" ];
  };

  system.stateVersion = 5;
}
