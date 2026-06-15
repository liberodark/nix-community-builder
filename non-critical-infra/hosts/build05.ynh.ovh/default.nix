{
  lib,
  pkgs,
  inputs,
  config,
  ...
}:

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

  boot.kernelPackages = lib.mkForce (
    pkgs.linuxPackagesFor (
      pkgs.callPackage "${inputs.nixos-hardware}/spacemit/k3-pico-itx/linux.nix" {
        inherit (config.boot) kernelPatches;
        stdenv = pkgs.overrideCC pkgs.stdenv
          inputs.nixpkgs-gcc153.legacyPackages.riscv64-linux.gcc15;
      }
    )
  );

  hardware.spacemit.hmp = {
    enable = true;
    mode = "permissive";
  };

  nix.gc.options = lib.mkForce "--delete-older-than 180d";

  nixpkgs.overlays = [
    # Workaround for ffmpeg-headless
    # Remove after merge https://nixtracker.ynh.ovh/pr/525606
    (final: prev: {
      ffmpeg-headless = prev.ffmpeg-headless.overrideAttrs (_: {
        doCheck = false;
      });
    })
  ];

  deployment.targetHost = "91.224.148.99";

  networking = {
    useNetworkd = true;
    useDHCP = false;
    hostName = "build05";
    domain = "ynh.ovh";
    hostId = "e60f2959"; # head -c4 /dev/urandom | od -A none -t x4 | sed 's/ //'
  };

  systemd.network.networks."10-uplink" = {
    enable = true;
    matchConfig.MACAddress = "50:0a:52:0b:e5:4a";
    address = [
      "91.224.148.99/32"
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
