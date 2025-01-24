# Install
#nix-shell -p nixos-anywhere --run 'nixos-anywhere -f github:liberodark/nix-community-builder/#build01.ynh.ovh -L --copy-host-keys root@192.168.0.56 --debug'

#Update
nixos-rebuild switch \
  --fast \
  --flake github:liberodark/nix-community-builder/7fca80c#build01.ynh.ovh \
  --target-host root@185.119.168.14 \
  --build-host root@185.119.168.14
