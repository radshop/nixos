{ config, pkgs, ... }:

let
  pythonEnv = pkgs.python3.withPackages (ps: with ps; [
    flask
    gunicorn
  ]);
in
{
  # Greek Text Reader service
  systemd.services.greek-reader = {
    description = "Greek Text Reader Web Application";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    
    serviceConfig = {
      Type = "simple";
      User = "miscguy";
      Group = "users";
      WorkingDirectory = "/home/miscguy/coding/greek";
      # Bind to 0.0.0.0 for Tailscale access
      ExecStart = "${pythonEnv}/bin/gunicorn --workers 4 --bind 0.0.0.0:5000 --timeout 120 --access-logfile /home/miscguy/coding/greek/logs/access.log --error-logfile /home/miscguy/coding/greek/logs/error.log --log-level info --chdir /home/miscguy/coding/greek/src/api app:app";
      Restart = "always";
      RestartSec = 10;
      
      # Environment
      Environment = [
        "PATH=${pythonEnv}/bin"
        "PYTHONPATH=/home/miscguy/coding/greek/src/api"
      ];
    };
  };
  
  # Open firewall for Greek reader (port 5000)
  networking.firewall.allowedTCPPorts = [ 5000 ];
}