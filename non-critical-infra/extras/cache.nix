{ pkgs, ... }:

let
  keyDir = "/var/lib/secrets";
  secretKeyPath = "${keyDir}/harmonia.secret";
  publicKeyPath = "${keyDir}/harmonia.public";
  keyName = "nix-cache.ynh.ovh";
in
{
  systemd.services.harmonia-key-gen = {
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

  services.harmonia = {
    enable = true;
    signKeyPaths = [ "${secretKeyPath}" ];
  };
}
