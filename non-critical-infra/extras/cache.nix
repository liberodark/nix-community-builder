{
  config,
  lib,
  pkgs,
  ...
}:
let
  # Enable
  enabledHosts = [ "build02" ];
  shouldEnable = lib.elem config.networking.hostName enabledHosts;
  # Config
  keyDir = "/var/lib/secrets";
  secretKeyPath = "${keyDir}/harmonia.secret";
  publicKeyPath = "${keyDir}/harmonia.public";
  keyName = "nix-cache.ynh.ovh";
in
{
  systemd.services.harmonia-key-gen = lib.mkIf shouldEnable {
    description = "Generate Harmonia signing keys if needed";
    wantedBy = [ "harmonia.service" ];
    before = [ "harmonia.service" ];
    path = [ pkgs.nix ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      mkdir -p ${keyDir}
      if [ ! -f ${secretKeyPath} ]; then
        echo "Generating new signing keys for Harmonia..."
        nix-store --generate-binary-cache-key ${keyName} ${secretKeyPath} ${publicKeyPath}
        chown harmonia:harmonia ${secretKeyPath}
        chown harmonia:harmonia ${publicKeyPath}
      fi
    '';
  };

  services.harmonia = lib.mkIf shouldEnable {
    enable = true;
    signKeyPaths = [ "${secretKeyPath}" ];
  };

  services.nginx.virtualHosts.${keyName} = lib.mkIf (shouldEnable && config.services.nginx.enable) {
    enableACME = true;
    forceSSL = true;

    locations."/" = {
      proxyPass = "http://127.0.0.1:5000";
    };
  };
}
