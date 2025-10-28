{ config, ... }:

{
  users = {
    mutableUsers = false;

    groups = {
      gaetan = { };
      liberodark = { };
      nix = { };
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

        nix = {
          isNormalUser = true;
          group = "nix";
          hashedPassword = "$y$j9T$qSCWsp8ENdqyQRtWMUh1b0$Pqa4Er3BFIJpgdqXq7V2QnQNZEFErgb0uytctBkz6h4";
          openssh.authorizedKeys.keys = [
          ];
        };
      };
  };

}
