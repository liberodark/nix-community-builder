{ ... }:

{
  launchd.daemons.apfs-cleanup = {
    script = ''
      date
      /System/Library/Filesystems/apfs.fs/Contents/Resources/apfs.util -P -minsize 0 /System/Volumes/Data
    '';
    serviceConfig = {
      StartCalendarInterval = [
        {
          Hour = 2;
          Minute = 30;
        }
      ];
      RunAtLoad = true;
      StandardErrorPath = "/var/log/apfs-cleanup.log";
      StandardOutPath = "/var/log/apfs-cleanup.log";
    };
  };

  environment.etc."newsyslog.d/apfs-cleanup.conf".text = ''
    /var/log/apfs-cleanup.log      root:wheel     644   5      1024      *
  '';
}
