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

  # Remove after merge in 26.05 https://nixtracker.ynh.ovh/pr/523685
  nixpkgs.overlays = [
    (
      final: prev:
      let
        pythonOverride =
          py:
          py.override (old: {
            packageOverrides =
              pyfinal: pyprev:
              (old.packageOverrides or (_: _: { })) pyfinal pyprev
              // {
                numpy = pyprev.numpy.overridePythonAttrs (
                  oldAttrs:
                  lib.optionalAttrs final.stdenv.hostPlatform.isRiscV64 {
                    doCheck = false;
                    doInstallCheck = false;
                  }
                );
              };
          });
      in
      {
        python3 = pythonOverride prev.python3;
        python310 = pythonOverride prev.python310;
        python311 = pythonOverride prev.python311;
        python312 = pythonOverride prev.python312;
        python313 = pythonOverride prev.python313;
      }
    )
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
