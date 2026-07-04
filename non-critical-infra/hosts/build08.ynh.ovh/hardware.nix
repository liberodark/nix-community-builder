{
  lib,
  modulesPath,
  inputs,
  ...
}:

{

  imports = [
    "${inputs.nixos-hardware}/bananapi/bpi-sm10"
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [ "nvme" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "riscv64-linux";
}
