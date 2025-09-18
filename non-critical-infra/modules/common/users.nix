{ config, ... }:
{
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
}
