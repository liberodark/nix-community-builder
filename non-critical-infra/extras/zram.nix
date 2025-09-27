{
  config,
  lib,
  pkgs,
  ...
}:
let
  enabledHosts = [ "build02" ];
  shouldEnable = lib.elem config.networking.hostName enabledHosts;
in
{
  zramSwap = lib.mkIf shouldEnable {
    enable = true;
    algorithm = "zstd";
    memoryMax = 128 * 1024 * 1024 * 1024;
    memoryPercent = 100;
    priority = 5;
  };

  boot.kernel.sysctl = lib.mkIf shouldEnable {
    "vm.swappiness" = 180;
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
    "vm.page-cluster" = 0;
  };

}
