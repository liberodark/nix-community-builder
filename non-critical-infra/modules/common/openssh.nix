{
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
}
