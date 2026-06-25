{
  disk = {
    main = {
      type = "disk";
      #device = "/dev/nvme0n1";
      device = "/dev/sda";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };
          root = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "zroot";
            };
          };
        };
      };
    };
  };

  zpool = {
    zroot = {
      type = "zpool";
      options = {
        # smartctl --all /dev/nvme0n1 to confirm; 512 logical -> ashift 12 is safe
        ashift = "12";
      };
      rootFsOptions = {
        acltype = "posixacl";
        compression = "zstd";
        mountpoint = "none";
        xattr = "sa";
      };
      datasets = {
        "root" = {
          type = "zfs_fs";
          mountpoint = "/";
        };
        "nix" = {
          type = "zfs_fs";
          mountpoint = "/nix";
          options = {
            atime = "off";
          };
        };
        "reserved" = {
          type = "zfs_fs";
          options = {
            canmount = "off";
            refreservation = "1G";
          };
        };
      };
    };
  };
}
