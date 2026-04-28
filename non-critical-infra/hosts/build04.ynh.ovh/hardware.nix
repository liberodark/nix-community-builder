{ pkgs, ... }:

{
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_18;
}
