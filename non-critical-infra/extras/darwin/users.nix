{ config, ... }:

let
  sshGaetan = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJfOUACs5oAn4Hyt6uMM5e/Xux0/5ODvSeg5zOy4MY1b gaetan@glepage.com";
  sshLiberodark = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGQ5hBVVKK72ZX+n+BVnPocx+AG5u6ht8bM++G1lhufp liberodark@gmail.com";

  myUsers = {
    gaetan = {
      uid = 502;
      shell = config.programs.fish.package;
      openssh.authorizedKeys.keys = [ sshGaetan ];
    };

    liberodark = {
      uid = 503;
      shell = config.programs.fish.package;
      openssh.authorizedKeys.keys = [ sshLiberodark ];
    };
  };

  userNames = builtins.attrNames myUsers;
  systemGroups = [
    "admin"
    "com.apple.access_ssh"
  ];
in
{
  users = {
    knownUsers = userNames;
    users = builtins.mapAttrs (
      name: cfg:
      cfg
      // {
        gid = 20;
        home = "/Users/${name}";
        createHome = true;
      }
    ) myUsers;
  };

  system.activationScripts.postActivation.text = ''
    for user in ${builtins.concatStringsSep " " userNames}; do
      for group in ${builtins.concatStringsSep " " systemGroups}; do
        dseditgroup -o edit -a "$user" -t user "$group"
      done
    done
  '';
}
