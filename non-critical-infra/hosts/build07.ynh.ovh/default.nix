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

  disko.devices = import ./disko.nix;
  boot.supportedFilesystems = [ "zfs" ];

  boot.kernelPatches = [
    {
      name = "disable-btf-riscv";
      patch = null;
      structuredExtraConfig = with lib.kernel; {
        DEBUG_INFO_BTF = lib.mkForce no;
        DEBUG_INFO_BTF_MODULES = lib.mkForce no;
      };
    }
  ];

  hardware.spacemit.hmp = {
    enable = true;
    mode = "strict";
  };

  nixpkgs.overlays = [
    # Workaround for ffmpeg-headless
    # Remove after merge https://nixtracker.ynh.ovh/pr/525606
    (_final: prev: {
      ffmpeg-headless = prev.ffmpeg-headless.overrideAttrs (_: {
        doCheck = false;
      });
    })
  ];

  deployment.targetHost = "91.224.148.30";

  networking = {
    useNetworkd = true;
    useDHCP = false;
    hostName = "build07";
    domain = "ynh.ovh";
    hostId = "960c35b1"; # head -c4 /dev/urandom | od -A none -t x4 | sed 's/ //'
  };

  systemd.network.networks."10-uplink" = {
    enable = true;
    matchConfig.MACAddress = "fe:fe:fe:ba:7e:85";
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
