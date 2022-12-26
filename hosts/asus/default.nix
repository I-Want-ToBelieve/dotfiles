{
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./amdgpu.nix

    # Shared configuration across all machines
    ../shared
    ../shared/users/I-Want-ToBelieve.nix
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [];

    supportedFilesystems = ["btrfs"];

    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };

      systemd-boot.enable = false;

      grub = {
        enable = true;
        version = 2;
        device = "nodev";
        efiSupport = true;
        useOSProber = true;
        enableCryptodisk = true;
        configurationLimit = 5;
      };
    };
  };

  # OpenGL and accelerated video playback
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override {enableHybridCodec = true;};
  };

  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        intel-media-driver
        libvdpau-va-gl
        vaapiIntel
        vaapiVdpau
      ];
      extraPackages32 = with pkgs.pkgsi686Linux; [
        intel-media-driver
        libva
        libvdpau-va-gl
        vaapiIntel
        vaapiVdpau
      ];
    };

    bluetooth = {
      enable = true;
      package = pkgs.bluez;
    };

    enableRedistributableFirmware = true;
    pulseaudio.enable = false;
  };

  # compresses half the ram for use as swap
  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };

  services = {
    btrfs.autoScrub.enable = true;
    acpid.enable = true;
    thermald.enable = true;
    upower.enable = true;

    tlp = {
      enable = true;
      settings = {
        START_CHARGE_THRESH_BAT0 = 0;
        STOP_CHARGE_THRESH_BAT0 = 80;
      };
    };

    greetd = {
      enable = true;
      settings = rec {
        initial_session = {
          command = "Hyprland";
          user = "I-Want-ToBelieve";
        };
        default_session = initial_session;
      };
    };

    # add hyprland to display manager sessions
    xserver.displayManager.sessionPackages = [inputs.hyprland.packages.${pkgs.system}.default];
  };

  # selectable options
  environment.etc."greetd/environments".text = ''
    Hyprland
  '';

  xdg.portal = {
    enable = true;
    wlr.enable = false;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  security = {
    pam.services.swaylock = {
      text = ''
        auth include login
      '';
    };
  };

  environment = {
    systemPackages = with pkgs; [
      acpi
      brightnessctl
      docker-client
      docker-compose
      docker-credential-helpers
      libva-utils
      ocl-icd
      qt5.qtwayland
      qt5ct
      virt-manager
      vulkan-tools
    ];

    variables = {
      NIXOS_OZONE_WL = "1";
      WLR_BACKEND = "vulkan";
      GDK_BACKEND= "wayland";
    };
  };

  virtualisation = {
    spiceUSBRedirection.enable = true;

    docker = {
      enable = true;
    };

    podman = {
      enable = true;
      extraPackages = with pkgs; [
        skopeo
        conmon
        runc
      ];
    };

    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        ovmf = {
          enable = true;
          packages = with pkgs; [OVMFFull.fd];
        };
        swtpm.enable = true;
      };
    };
  };

  system.stateVersion = lib.mkForce "22.11"; # DONT TOUCH THIS
}
