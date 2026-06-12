{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.hardware.spacemit.hmp;
  isRiscv64 = pkgs.stdenv.hostPlatform.isRiscV64;
in
{
  options.hardware.spacemit.hmp = {
    enable = lib.mkEnableOption "SpacemiT K3 HMP mode control";

    mode = lib.mkOption {
      type = lib.types.enum [
        "strict"
        "permissive"
        "unsafe"
      ];
      default = "strict";
      description = ''
        SpacemiT K3 HMP scheduling mode.
      '';
    };
  };

  config = lib.mkIf (cfg.enable && isRiscv64) {
    environment.variables = lib.mkIf (cfg.mode == "unsafe") {
      OPENSSL_riscvcap = "RV64GC";
    };

    systemd.services.spacemit-hmp-mode = {
      description = "Set SpacemiT HMP mode (${cfg.mode})";
      wantedBy = [ "sysinit.target" ];
      before = [ "sysinit.target" ];
      after = [ "systemd-modules-load.service" ];
      unitConfig.DefaultDependencies = false;
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "hmp-set-mode" ''
          if [ -w /sys/kernel/spacemit_hmp/mode ]; then
            echo ${cfg.mode} > /sys/kernel/spacemit_hmp/mode
            ${lib.optionalString (cfg.mode == "unsafe") ''
              for pid in /proc/[0-9]*; do
                ${pkgs.util-linux}/bin/taskset -apc 0-15 "$(basename "$pid")" 2>/dev/null || true
              done
            ''}
          fi
        '';
      };
    };
  };
}
