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
      ../shared/misc_configuration.nix
      ../shared/miscguy.nix
      ../common/nix/flakes.nix
    ];

  home-manager = {
    users.miscguy = import ./home.nix;
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  # Use stable kernel to avoid modules-shrunk issue
  # boot.kernelPackages = pkgs.linuxPackages_6_6;

  networking.hostName = "nixt15g"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

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

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

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
    python3
    python3Packages.pip
    python3Packages.inotify
    python3Packages.requests
    python3Packages.flask
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
  
  services.xserver = {
    # Configure keymap in X11
    xkb.layout = "us";
    xkb.variant = "";
    # Enable the X11 windowing system.
    enable = true;
    # Enable DisplayLink
    videoDrivers = [ "displaylink" "modesetting" ];
    
    # DisplayLink configuration
    displayManager.setupCommands = ''
      ${pkgs.xorg.xrandr}/bin/xrandr --setprovideroutputsource 1 0
      ${pkgs.xorg.xrandr}/bin/xrandr --setprovideroutputsource 2 0
    '';
    # Enable the GNOME Desktop Environment.
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };
  services.displayManager.defaultSession = "gnome";

  # DisplayLink configuration
  systemd.services.dlm.wantedBy = [ "multi-user.target" ];
  nixpkgs.config.displaylink = {
    enable = true;
  };


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
