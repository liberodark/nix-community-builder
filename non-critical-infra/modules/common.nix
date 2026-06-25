{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  internalCaches = {
    build02 = {
      url = "https://build02.ynh.ovh";
      publicKey = "build02.ynh.ovh:0QeuH4uAfqbtMVDBDFlThOedamf3HBagsLp2G/WzsBg=";
      systems = [
        "x86_64-linux"
        "riscv64-linux"
      ];
    };
    build05 = {
      url = "https://build05.ynh.ovh";
      publicKey = "build05.ynh.ovh:bLxWKPjbKYOFxqrjOxv+cdwS3kFLuHEf1k6j8fAxbzM=";
      systems = [ "riscv64-linux" ];
    };
    build06 = {
      url = "https://build06.ynh.ovh";
      publicKey = "build06.ynh.ovh:bPg6x17ztNd3uMxdclDvdJpTl2pwLiTdHTt9ymTNoMU=";
      systems = [ "riscv64-linux" ];
    };
  };

  sharedSystem = "riscv64-linux";

  peerCaches = lib.filterAttrs (
    name: c: name != config.networking.hostName && lib.elem sharedSystem c.systems
  ) internalCaches;
in
{
  # Global Options
  boot.zfs.forceImportRoot = false;

  boot.binfmt.emulatedSystems = lib.optionals (!pkgs.stdenv.hostPlatform.isRiscV64) (
    lib.filter (s: s != pkgs.stdenv.hostPlatform.system) [
      "aarch64-linux"
      "riscv64-linux"
    ]
  );

  nix = {
    settings = {
      trusted-users = [
        "root"
        "@wheel"
        "nix"
      ];
      auto-optimise-store = true;
      builders-use-substitutes = true;
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://cache.flox.dev"
        "https://cache.nixos-cuda.org"
        "https://cache.ztier.in"
      ]
      ++ lib.mapAttrsToList (_: c: c.url) peerCaches;
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
        "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
        "cache.ztier.link-1:3P5j2ZB9dNgFFFVkCQWT3mh0E+S3rIWtZvoql64UaXM="
      ]
      ++ lib.mapAttrsToList (_: c: c.publicKey) peerCaches;
    };

    gc = {
      automatic = true;
      dates = "monthly";
      options = "--delete-older-than 30d";
    };

    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Fish shell
  programs.fish.enable = true;

  # Enable fstrim
  services.fstrim.enable = true;

  environment.systemPackages = with pkgs; [
    htop
    btop
    nvme-rs
    (lib.hiPrio uutils-coreutils-noprefix)
    home-manager
    #qemu
    inputs.nom-rs.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  # Enable sudo-rs
  security.sudo-rs = {
    enable = true;
    package = pkgs.sudo-rs;
    execWheelOnly = false;
    wheelNeedsPassword = false;
  };

  # Enable SSH
  services.openssh = {
    enable = true;
    settings = {
      Ciphers = [
        "aes256-gcm@openssh.com"
        "aes128-gcm@openssh.com"
        "aes256-ctr"
        "aes128-ctr"
      ];
      KexAlgorithms = [
        "mlkem768x25519-sha256"
        "sntrup761x25519-sha512"
        "ecdh-sha2-nistp384"
        "ecdh-sha2-nistp256"
        "diffie-hellman-group16-sha512"
        "diffie-hellman-group14-sha256"
      ];
      Macs = [
        "hmac-sha2-512-etm@openssh.com"
        "hmac-sha2-256-etm@openssh.com"
        "hmac-sha2-512"
        "hmac-sha2-256"
      ];

      PermitRootLogin = "yes";
      AllowUsers = [
        "root"
        "gaetan"
        "liberodark"
        "nix"
      ];
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      UsePAM = true;
      PermitEmptyPasswords = false;
      MaxAuthTries = 3;
      LogLevel = "VERBOSE";
      X11Forwarding = false;
      AllowTcpForwarding = false;
      AllowAgentForwarding = false;
      StrictModes = true;
      LoginGraceTime = 30;
      MaxSessions = 4;
      ClientAliveInterval = 300;
      ClientAliveCountMax = 2;
      RekeyLimit = "1G 1h";
    };

    hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };

  # Enable Firewall
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22
      4000
      4001
    ];
  };

  deployment.tags = [ "builder" ];
}
