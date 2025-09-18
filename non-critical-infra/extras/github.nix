{
  config,
  lib,
  pkgs,
  ...
}:
let
  enabledHosts = [ "build02" ];
  shouldEnable = lib.elem config.networking.hostName enabledHosts;
in
{
  # Enable Github Runner
  services.github-runners = lib.mkIf shouldEnable {
    # liberodark
    liberodark-npr-gha = {
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

    gaetan-npr-gha = {
      enable = true;
      url = "https://github.com/GaetanLepage/nixpkgs-review-gha";
      tokenFile = "/var/lib/github-runner-tokens/gaetan-npr-gha";
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

}
