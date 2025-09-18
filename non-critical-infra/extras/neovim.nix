{
  config,
  lib,
  pkgs,
  ...
}:
let
  enabledHosts = [ "build02" ];
  shouldEnable = lib.elem config.networking.hostName enabledHosts;
  usersWithNeovim = [
    "gaetan"
  ];
in
{
  users.users = lib.mkIf shouldEnable (
    lib.genAttrs usersWithNeovim (_user: {
      packages = [ pkgs.neovim ];
    })
  );

  environment.shellAliases = lib.mkIf (shouldEnable && usersWithNeovim != [ ]) {
    vi = "nvim";
    vim = "nvim";
  };
}
