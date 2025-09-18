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
  services.nginx = lib.mkIf shouldEnable {
    enable = true;
    package = pkgs.nginx;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
    recommendedProxySettings = true;

    sslProtocols = "TLSv1.2 TLSv1.3";
    sslCiphers = "ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-RSA-AES128-GCM-SHA256";
    clientMaxBodySize = "2G";

    resolver = {
      addresses = [
        "1.1.1.1"
        "9.9.9.9"
      ];
      valid = "30s";
    };

    appendHttpConfig = ''
      sendfile_max_chunk 512k;

      map $scheme $hsts_header {
        https "max-age=63072000; includeSubDomains; preload";
      }
    '';
  };

  security.acme = lib.mkIf shouldEnable {
    acceptTerms = true;
    defaults = {
      email = "liberodark@gmail.com";
    };
  };

  networking.firewall.allowedTCPPorts = lib.mkIf shouldEnable [
    80
    443
  ];
}
