{
  users.groups.miscguy.members = [ "miscguy" ];
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.miscguy = {
    isNormalUser = true;
    description = "miscguy";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "docker" "miscguy"];
    # packages = with pkgs; [
    #   firefox librewolf brave chromium
    # ];
  };

  security.sudo.extraRules = [
    {
      users = [ "miscguy" ];
      commands = [
        {
          command = "ALL";
          options = [ "SETENV" "NOPASSWD" ];
        }
      ];
    }
  ];

}
