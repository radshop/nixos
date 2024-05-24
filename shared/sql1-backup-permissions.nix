with import <nixpkgs> {};
{
  systemd.services.sql1-backup-permissions= {
    serviceConfig.Type = "oneshot";
    path = with pkgs; [ docker ];
    script = ''
      docker exec -u 0 sql1 bash -c 'chmod -R 777 /mnt/sql1/nixhq'
    '';
  };

  systemd.timers.sql1-backup-permissions= {
    wantedBy = [ "timers.target" ];
    partOf = [ "sql1-backup-permissions.service" ];
    timerConfig = {
      OnCalendar = "*-*-* *:00:00";
      Unit = "sql1-backup-permissions.service";
    };
  };
}
