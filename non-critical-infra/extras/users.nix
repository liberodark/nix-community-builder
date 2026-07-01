{
  config,
  lib,
  pkgs,
  ...
}:

let
  isRiscv64 = pkgs.stdenv.hostPlatform.isRiscV64;
  sshJamie = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIGAcZNQTgVUK/JRWww3WS+utcsuwHpTcOVSBvqWC/rQZAAAABHNzaDo= jamie.magee@gmail.com";
in
{
  users = {
    mutableUsers = false;

    groups = {
      gaetan = { };
      liberodark = { };
      nix = { };
    }
    // lib.optionalAttrs isRiscv64 {
      jamie = { };
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
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKzs9dyvO7JspwAUSQFirPrAASMwx7AysVy/2eBTDxgD hydra-queue-runner@node-a"
          ];
        };
      }
      // lib.optionalAttrs isRiscv64 {
        jamie = {
          isNormalUser = true;
          group = "jamie";
          shell = config.programs.fish.package;
          hashedPassword = "$y$j9T$QF7FIOV/CjU68G02pZvH0.$lk67kBcsLULlZ14bkiU2Cyz9tK2cxEal5eaW7kFa4U2";
          openssh.authorizedKeys.keys = [
            sshJamie
          ];
        };
      };
  };

}
