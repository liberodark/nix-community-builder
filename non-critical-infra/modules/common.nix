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
    };
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 1d";
    };
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Root Access
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGQ5hBVVKK72ZX+n+BVnPocx+AG5u6ht8bM++G1lhufp liberodark@gmail.com"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJfOUACs5oAn4Hyt6uMM5e/Xux0/5ODvSeg5zOy4MY1b gaetan@glepage.com"
  ];

  #users.users.nixos = {
  #  isNormalUser = true;
  #  description = "nixos";
  #  extraGroups = [ "networkmanager" ];
  #  hashedPassword = "$6$MPAnPgIh68A80v/X$fUZ.2GCTFIW1uA8jpj.0mHv0snEPopebHXL2NW6U1nxKEXwf9FTH6pmtgFN0ZQb5W08d35/BYi4e2.itDc/uG.";
  #};

  # Enable fstrim
  services.fstrim.enable = true;

  environment.systemPackages = with pkgs; [
    htop
    btop
    nvme-cli
    qemu
  ];

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
      AllowUsers = [ "root" ];
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
