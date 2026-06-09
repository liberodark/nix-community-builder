{ lib, pkgs, ... }:

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

  systemd.services.spacemit-hmp-permissive = {
    description = "SpacemiT HMP permissive";
    wantedBy = [ "sysinit.target" ];
    before = [ "sysinit.target" ];
    after = [ "systemd-modules-load.service" ];
    unitConfig.DefaultDependencies = false;
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "hmp-permissive" ''
        echo permissive > /sys/kernel/spacemit_hmp/mode
        for pid in /proc/[0-9]*; do
          ${pkgs.util-linux}/bin/taskset -apc 0-15 "$(basename "$pid")" 2>/dev/null || true
        done
      '';
    };
  };

  nix.gc.options = lib.mkForce "--delete-older-than 180d";

  # Workaround for ffmpeg-headless
  # Remove after merge https://nixtracker.ynh.ovh/pr/525606
  nixpkgs.overlays = [
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
