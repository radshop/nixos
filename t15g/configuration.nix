# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ lib, config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../shared/locale.nix
      ../shared/services.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  # Use stable kernel to avoid modules-shrunk issue
  boot.kernelPackages = pkgs.linuxPackages_6_6;
  
  # DisplayLink kernel modules
  boot.kernelModules = [ "evdi" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ evdi ];

  networking.hostName = "nixt15g"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

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

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  
  # DisplayLink configuration
  nixpkgs.config.displaylink = {
    enable = true;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    virt-manager
    zoom-us
    pv
    calibre
    xournalpp
    wireplumber
    claude-code
    # DisplayLink reset script for recovery from black screens
    (writeShellScriptBin "displaylink-reset" ''
      #!/bin/bash
      echo "Restarting DisplayLink..."
      
      # Restart the DisplayLink service
      sudo systemctl restart dlm
      sleep 2
      
      # Reload the evdi module
      sudo modprobe -r evdi
      sleep 1
      sudo modprobe evdi
      sleep 2
      
      # Reconfigure displays
      export DISPLAY=:0
      ${xorg.xrandr}/bin/xrandr --setprovideroutputsource 1 0 || true
      ${xorg.xrandr}/bin/xrandr --setprovideroutputsource 2 0 || true
      
      echo "DisplayLink reset complete"
    '')
  ];

  virtualisation = {
    # libvirt/qemu/kvm enable
    libvirtd.enable = true;
    # docker
    docker = {
      enable = true;
    };
  };
  # dconf for kvm
  programs.dconf.enable = true;

  # ssh keyring
  programs.sway.extraSessionCommands = ''
      eval $(gnome-keyring-daemon --start --components=pkcs11,secrets,ssh);
      export SSH_AUTH_SOCK;
  '';
	services.openssh = {
		enable = true;
		# require public key authentication for better security
		settings.PasswordAuthentication = false;
		settings.KbdInteractiveAuthentication = false;
		#settings.PermitRootLogin = "yes";
	};

  # Enable CUPS to print documents.
  services.printing.enable = true;

  services.postgresql = {
    enable = true;
    authentication = pkgs.lib.mkForce ''
    # Generated file; do not edit!
    # TYPE  DATABASE        USER            ADDRESS                 METHOD
    local   all             all                                     trust
    host    all             all             127.0.0.1/32            trust
    host    all             all             ::1/128                 trust
    '';
  };
  services.onedrive.enable = true;
  # Enhanced DisplayLink service configuration with better boot timing
  systemd.services.dlm = {
    wantedBy = [ "multi-user.target" ];
    after = [ "multi-user.target" "systemd-logind.service" "systemd-modules-load.service" ];
    before = [ "display-manager.service" ];
    
    serviceConfig = {
      # Add retry and reload capability
      Restart = "always";
      RestartSec = lib.mkForce 3;
      # Ensure evdi module is loaded before service starts
      ExecStartPre = "${pkgs.kmod}/bin/modprobe evdi";
    };
  };
  services.xserver = {
    # Configure keymap in X11
    xkb.layout = "us";
    xkb.variant = "";
    # Enable the X11 windowing system.
    enable = true;
    # Enable DisplayLink
    videoDrivers = [ "displaylink" "modesetting" ];
    
    # Enhanced DisplayLink configuration with wait and retry logic
    displayManager.setupCommands = ''
      # Wait for DisplayLink to be ready
      for i in {1..10}; do
        if ${pkgs.util-linux}/bin/lsmod | grep -q evdi; then
          break
        fi
        sleep 1
      done
      
      # Configure DisplayLink outputs with fallbacks
      ${pkgs.xorg.xrandr}/bin/xrandr --setprovideroutputsource 1 0 || true
      ${pkgs.xorg.xrandr}/bin/xrandr --setprovideroutputsource 2 0 || true
      
      # Optional: Set a primary display to avoid black screen
      ${pkgs.xorg.xrandr}/bin/xrandr --output eDP-1 --primary || true
    '';
		# XFCE
    # desktopManager = {
    #   xterm.enable = false;
    #   xfce.enable = true;
    # };
    # displayManager.defaultSession = "xfce";
    # Enable the GNOME Desktop Environment.
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };
    services.displayManager.defaultSession = "gnome";


  networking.extraHosts =
    ''
      172.17.0.2 sql1
    '';

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  
  # Enhanced udev rules for DisplayLink devices with hot-plug support
  services.udev.extraRules = ''
    # DisplayLink USB devices
    SUBSYSTEM=="usb", ATTR{idVendor}=="17e9", MODE="0666"
    KERNEL=="card[0-9]*", SUBSYSTEM=="drm", ATTRS{vendor}=="0x17e9", TAG+="seat", TAG+="master-of-seat"
    
    # Restart DisplayLink service on USB events
    SUBSYSTEM=="usb", ATTR{idVendor}=="17e9", ACTION=="add", RUN+="${pkgs.systemd}/bin/systemctl restart dlm.service"
    SUBSYSTEM=="usb", ATTR{idVendor}=="17e9", ACTION=="remove", RUN+="${pkgs.systemd}/bin/systemctl restart dlm.service"
  '';
  
  # Hot-plug handler service
  systemd.services.displaylink-hotplug = {
    description = "DisplayLink Hot-plug Handler";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "displaylink-hotplug" ''
        sleep 2
        systemctl restart dlm.service
      '';
    };
  };

  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true;
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
