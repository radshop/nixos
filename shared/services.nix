{
  # flatpak
  services.flatpak.enable = true;

  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "client";

  services.syncthing = {
      enable = true;
      user = "miscguy";
      dataDir = "/home/miscguy/sync";    # Default folder for new synced folders
      configDir = "/home/miscguy/.config/syncthing";   # Folder for Syncthing's settings and keys
  };
}
