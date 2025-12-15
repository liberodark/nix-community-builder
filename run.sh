# Install
#nix-shell -p nixos-anywhere --run 'nixos-anywhere -f github:liberodark/nix-community-builder/394ad34#build02.ynh.ovh -L --copy-host-keys root@192.168.0.214 --debug'

#Update
nixos-rebuild switch \
  --no-reexec \
  --flake github:liberodark/nix-community-builder/45e7824#build02.ynh.ovh \
  --target-host root@build02.ynh.ovh \
  --build-host root@build02.ynh.ovh
