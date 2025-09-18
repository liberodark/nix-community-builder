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
          hashedPassword = "$y$j9T$gQHte4ikw3QE8BJp7tx6Z.$HT3Y8fNEMqnQmfWLZr5PH9vyneRHagC8krIYdBNMp47";
          openssh.authorizedKeys.keys = [
            sshLiberodark
          ];
        };
      };
  };

}
