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
    memoryMax = 512 * 1024 * 1024 * 1024;
    memoryPercent = 505;
    priority = 5;
  };

  boot.kernel.sysctl = lib.mkIf shouldEnable {
    "vm.swappiness" = 180;
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
    "vm.page-cluster" = 0;
  };

}
