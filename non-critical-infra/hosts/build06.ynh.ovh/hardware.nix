{
  lib,
  modulesPath,
  inputs,
  ...
}:

{

  imports = [
    "${inputs.nixos-hardware}/spacemit/k3-pico-itx"
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [ "nvme" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-partlabel/nixos-rootfs";
    fsType = "ext4";
  };

  fileSystems."/etc" = {
    device = "overlay";
    fsType = "overlay";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-partlabel/ESP";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "riscv64-linux";
}
