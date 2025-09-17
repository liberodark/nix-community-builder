{
  config,
  pkgs,
  inputs,
  ...
}:

{
  # Globale Options
  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
    "riscv64-linux"
  ];

  nix = {
    settings = {
      trusted-users = [
        "root"
        "@wheel"
      ];
      auto-optimise-store = true;
      builders-use-substitutes = true;
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://cache.flox.dev"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
      ];
    };
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 30d";
    };
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Fish shell
  programs.fish.enable = true;
  environment.pathsToLink = [ "/share/fish" ];

  # Root Access
  users = {
    mutableUsers = false;

    groups = {
      gaetan = { };
      liberodark = { };
    };

    users =
      let
        sshGaetan = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJfOUACs5oAn4Hyt6uMM5e/Xux0/5ODvSeg5zOy4MY1b gaetan@glepage.com";
        sshLiberodark = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGQ5hBVVKK72ZX+n+BVnPocx+AG5u6ht8bM++G1lhufp liberodark@gmail.com";
      in
      {
        root.openssh.authorizedKeys.keys = [
          sshLiberodark
        ];

        gaetan = {
          isNormalUser = true;
          group = "gaetan";
          extraGroups = [
            "wheel"
          ];
          shell = config.programs.fish.package;
          hashedPassword = "$y$j9T$DcNh44UsDFjthtH7vjQE9/$Nk4ey9oblVpiFwT0zWVgkZdh/WAmR1Kuqz58HwnbBj2";
          openssh.authorizedKeys.keys = [
            sshGaetan
          ];
        };

        liberodark = {
          isNormalUser = true;
          group = "liberodark";
          extraGroups = [
            "wheel"
          ];
          shell = config.programs.fish.package;
          hashedPassword = "$6$gqUcksN1scoXJMuY$FbgTwt8KBU9/WPWr0jRB32b/XLFCWYxHGwW7qdqmwg9DKn4gWGQtewwZMIjHSSt8H/OAA6bO.cT3wl2QiqD6f0";
          openssh.authorizedKeys.keys = [
            sshLiberodark
          ];
        };
      };

    #users.nixos = {
    #  isNormalUser = true;
    #  description = "nixos";
    #  extraGroups = [ "networkmanager" ];
    #  hashedPassword = "$6$MPAnPgIh68A80v/X$fUZ.2GCTFIW1uA8jpj.0mHv0snEPopebHXL2NW6U1nxKEXwf9FTH6pmtgFN0ZQb5W08d35/BYi4e2.itDc/uG.";
    #};
  };

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

  # Enable Github Runner
  services.github-runners = {
    build02 = {
      enable = true;
      url = "https://github.com/liberodark/nixpkgs-review-gha";
      tokenFile = "/var/lib/github-runner-tokens/liberodark-npr-gha";
      replace = true;
      user = "liberodark";

      extraPackages = with pkgs; [
        git
        nixpkgs-review
        jq
        gnused
        coreutils
      ];

      extraEnvironment = {
        NIX_CONFIG = "experimental-features = nix-command flakes";
      };
    };

    # Gaetan
    gaetan-config = {
      enable = true;
      url = "https://github.com/GaetanLepage/nix-config";
      tokenFile = "/var/lib/github-runner-tokens/gaetan-config";
      replace = true;
      user = "gaetan";
    };

    gaetan-lk = {
      enable = true;
      url = "https://github.com/LepageKnives";
      tokenFile = "/var/lib/github-runner-tokens/gaetan-lk";
      replace = true;
      user = "gaetan";
    };
  };

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
    allowedTCPPorts = [ 22 ];
  };

  deployment.tags = [ "builder" ];
}
