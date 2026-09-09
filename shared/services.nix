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

  # Mask the stray, package-bundled onedrive.service (symlinks it to /dev/null).
  # The onedrive package ships share/systemd/user/onedrive.service (ExecStart
  # `onedrive --monitor`, no --confdir), which is loadable on every boot. It is
  # redundant with the `services.onedrive` module's real worker
  # (onedrive-launcher.service -> onedrive@<conf>.service, which uses --confdir).
  # If the stray unit ever starts, its process-table "already running" self-check
  # trips on the module instance and it crash-loops (Restart=on-failure), spawning
  # zombie onedrive procs and stopping sync. Masking it here is harmless on hosts
  # without onedrive and permanently prevents the conflict on hq + t15g.
  systemd.user.services.onedrive.enable = false;
}
