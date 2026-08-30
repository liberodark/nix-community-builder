{
  config,
  lib,
  pkgs,
  ...
}:
let
  enabledHosts = [ "build06" ];
  shouldEnable = lib.elem config.networking.hostName enabledHosts;
  riscvPkgs = import (builtins.fetchTarball {
    url = "https://github.com/liberodark/nixpkgs/archive/2f5c7bd5a67a113c86ed5ba1d846a18682a7a970.tar.gz";
    sha256 = "0mp63a35s3is2bng1j5nyll7yw9kz5ddf7y0xxkg8855w8m2alk6";
  }) { system = "riscv64-linux"; };
in
{
  services.github-runners = lib.mkIf shouldEnable {
    liberodark-npr-gha-riscv64 = {
      enable = true;
      url = "https://github.com/liberodark/nixpkgs-review-gha";
      tokenFile = "/var/lib/github-runner-tokens/liberodark-npr-gha-riscv64";
      replace = true;
      user = "liberodark";

      package = riscvPkgs.github-runner;
      extraLabels = [
        "riscv64"
        "k3"
      ];

      extraPackages = with pkgs; [
        git
        gh
        nushell
        nixpkgs-review
        jq
        gnused
        coreutils
      ];
    };
  };
}
