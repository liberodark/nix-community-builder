{
  pkgs,
  ...
}:

{
  imports = [
    ./github_runners.nix
    ./nix.nix
    ./openssh.nix
    ./users.nix
  ];

  # Global options
  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
    "riscv64-linux"
  ];

  # Fish shell
  programs.fish.enable = true;
  environment.pathsToLink = [ "/share/fish" ];

  # Enable fstrim
  services.fstrim.enable = true;

  environment.systemPackages = with pkgs; [
    htop
    btop
    nvme-rs
    qemu
    (lib.hiPrio uutils-coreutils-noprefix)
    home-manager
  ];
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
  };

  # Enable sudo-rs
  security.sudo-rs = {
    enable = true;
    package = pkgs.sudo-rs;
    execWheelOnly = false;
    wheelNeedsPassword = false;
  };

  # Enable Firewall
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
  };

  deployment.tags = [ "builder" ];
}
