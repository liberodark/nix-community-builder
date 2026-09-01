# Install
#nix-shell -p nixos-anywhere --run 'nixos-anywhere -f github:liberodark/nix-community-builder/394ad34#build02.ynh.ovh -L --copy-host-keys root@192.168.0.214 --debug'

#Update
BUILDER=build02
COMMIT=c797078

nixos-rebuild switch \
  --no-reexec \
  --flake "github:liberodark/nix-community-builder/${COMMIT}#${BUILDER}.ynh.ovh" \
  --target-host "root@${BUILDER}.ynh.ovh" \
  --build-host "root@${BUILDER}.ynh.ovh"
