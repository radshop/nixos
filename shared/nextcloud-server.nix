{ config, pkgs, ... }:

{
  # Environment setup for Nextcloud admin and database passwords
  environment.etc."nextcloud-admin-pass".text = "Bloomington@1993";
  environment.etc."nextcloud-db-pass".text = "Bloomington@1993";

  # PostgreSQL service configuration
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_14;  # Adjust the PostgreSQL version as needed
    initialScript = pkgs.writeText "nextcloud-db-init.sql" ''
      CREATE ROLE nextcloud WITH LOGIN PASSWORD 'SECURE_PASSWORD_HERE';
      CREATE DATABASE nextcloud WITH OWNER nextcloud;
    '';
  };

  # PHP-FPM service configuration for Nextcloud
  services.phpfpm.pools.nextcloud = {
    user = "nextcloud";
    group = "nextcloud";
    phpOptions = ''
      upload_max_filesize = 1G
      post_max_size = 1G
      memory_limit = 512M
      max_execution_time = 300
      date.timezone = "America/LosAngeles"
    '';
  };

  # Nextcloud service configuration
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud28; # Adjust the Nextcloud version as needed
    hostName = "nixhq";
    config = {
      dbtype = "pgsql";
      dbname = "nextcloud";
      dbuser = "nextcloud";
      dbpassFile = "/etc/nextcloud-db-pass"; # Reference to the DB password file
      adminpassFile = "/etc/nextcloud-admin-pass";
      # Additional Nextcloud configuration...
    };
    maxUploadSize = "2G"; # Adjust for max upload size
  };

  # Other services and configuration...
}

