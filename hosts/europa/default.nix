{ inputs
, config
, pkgs
, lib
, xinlib
, ...
}:
let
  inherit (inputs.stable.legacyPackages.${pkgs.system}) chirp beets quodlibet-full;
  inherit (xinlib) jobToUserService prIsOpen;
  pywebscrapbook =
    pkgs.python3Packages.callPackage ../../pkgs/pywebscrapbook.nix { inherit pkgs; };
  jobs = [
    {
      name = "brain";
      script = "cd ~/Brain && git sync";
      startAt = "*:0/2";
      path = [ pkgs.git pkgs.git-sync ];
    }
    {
      name = "org";
      script = "(cd ~/org && git sync)";
      startAt = "*:0/5";
      path = [ pkgs.git pkgs.git-sync ];
    }
    {
      name = "org-roam";
      script = "(cd ~/org-roam && git sync)";
      startAt = "*:0/5";
      path = [ pkgs.git pkgs.git-sync ];
    }
  ];
in
{
  _module.args.isUnstable = true;

  imports = [ ./hardware-configuration.nix ../../pkgs ];

  sops.secrets = {
    rkvm_cert = {
      sopsFile = config.xin-secrets.europa.secrets.qbit;
      owner = "root";
      group = "wheel";
      mode = "400";
    };
    rkvm_key = {
      sopsFile = config.xin-secrets.europa.secrets.qbit;
      owner = "root";
      group = "wheel";
      mode = "400";
    };
    fastmail = {
      sopsFile = config.xin-secrets.europa.secrets.qbit;
      owner = "qbit";
      group = "wheel";
      mode = "400";
    };
    fastmail_user = {
      sopsFile = config.xin-secrets.europa.secrets.qbit;
      owner = "qbit";
      group = "wheel";
      mode = "400";
    };
    nix_review = {
      sopsFile = config.xin-secrets.europa.secrets.qbit;
      owner = "qbit";
      group = "wheel";
      mode = "400";
    };
    netrc = {
      sopsFile = config.xin-secrets.europa.secrets.qbit;
      owner = "qbit";
      group = "wheel";
      mode = "400";
    };
    restic_password_file = {
      sopsFile = config.xin-secrets.europa.secrets.services;
      owner = "root";
      mode = "400";
    };
    restic_env_file = {
      sopsFile = config.xin-secrets.europa.secrets.services;
      owner = "root";
      mode = "400";
    };
    restic_remote_password_file = {
      sopsFile = config.xin-secrets.europa.secrets.services;
      owner = "root";
      mode = "400";
    };
    restic_remote_env_file = {
      sopsFile = config.xin-secrets.europa.secrets.services;
      owner = "root";
      mode = "400";
    };
    restic_remote_repo_file = {
      sopsFile = config.xin-secrets.europa.secrets.services;
      owner = "root";
      mode = "400";
    };
    krha_env_file = {
      sopsFile = config.xin-secrets.europa.secrets.services;
      owner = "qbit";
      mode = "400";
    };
  };

  nixpkgs.config = {
    allowUnfree = true;
    allowUnsupportedSystem = true;
  };

  boot = {
    binfmt.emulatedSystems = [ "aarch64-linux" "riscv64-linux" ];
    initrd.systemd.enable = true;
    initrd.luks.devices."luks-4d7bf115-cdfd-486b-a2fd-ee620d81060c".device = "/dev/disk/by-uuid/4d7bf115-cdfd-486b-a2fd-ee620d81060c";
    loader = {
      systemd-boot = {
        enable = true;
        memtest86.enable = true;
      };
      efi = {
        canTouchEfiVariables = true;
      };
    };
    kernelParams = [
      "boot.shell_on_fail"
      # https://gitlab.freedesktop.org/upower/power-profiles-daemon#panel-power-savings
      "amdgpu.abmlevel=0"
    ];
    kernelPackages = pkgs.linuxPackages_latest;
  };

  nixManager = {
    enable = lib.mkDefault true;
    user = "qbit";
  };

  kde.enable = lib.mkDefault true;
  kdeConnect.enable = true;

  virtualisation = {
    libvirtd.enable = lib.mkDefault true;
    podman = {
      enable = true;
      dockerCompat = true;
    };
  };

  networking = {
    hostName = "europa";
    hostId = "87703c3e";
    hosts = {
      "192.168.122.6" = [ "chubs" ];
    };
    wireless.userControlled.enable = true;
    networkmanager.enable = true;

    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
    };
  };

  programs = {
    nix-ld.enable = lib.mkIf config.programs.ladybird.enable true;
    steam.enable = true;
    _1password.enable = true;
    _1password-gui = {
      enable = true;
      polkitPolicyOwners = [ "qbit" ];
    };
    dconf.enable = true;
    zsh = {
      shellInit = ''
        export OP_PLUGIN_ALIASES_SOURCED=1
      '';
      shellAliases = {
        "gh" = "op plugin run -- gh";
        "nixpkgs-review" = "env GITHUB_TOKEN=$(op item get nixpkgs-review --field token --reveal) nixpkgs-review";
        "godeps" = "go list -m -f '{{if not (or .Indirect .Main)}}{{.Path}}{{end}}' all";
        "sync-music" = "rsync -av --progress --delete ~/Music/ suah.dev:/var/lib/music/";
        "load-agent" = ''op item get signer --field 'private key' --reveal | sed '/"/d; s/\r//' | ssh-add -'';
      };
    };
  };

  services.xinCA = { enable = false; };

  services = {
    i2pd = {
      enable = true;
      address = "127.0.0.1";
      proto = {
        http = {
          enable = true;
          port = 7070;
        };
        socksProxy.enable = true;
        httpProxy.enable = true;
        sam.enable = true;
      };
    };
    syncthing = {
      enable = true;
      user = "qbit";
      dataDir = "/home/qbit";
      settings = {
        options = {
          urAccepted = -1;
        };
        devices = config.syncthingDevices;
        folders = {
          "android-camera" = {
            path = "~/camera";
            id = "pixel_8_5a6k-photos";
            devices = [ "graphy" ];
          };
          "calibre-library" = {
            path = "~/Calibre Library";
            id = "calibre_library";
            devices = [ "box" ];
          };
          "home/qbit/sync" = {
            path = "~/sync";
            id = "main_sync";
            devices = lib.attrNames config.syncthingDevices;
            versioning = {
              type = "staggered";
              fsPath = "~/syncthing/backup";
              params = {
                cleanInterval = "3600";
                maxAge = "31536000";
              };
            };
          };
        };
      };
    };
    ollama = {
      enable = false;
      acceleration = prIsOpen.str 306375 "rocm";
    };
    rkvm.server = {
      enable = true;
      settings = {
        listen = "127.0.0.1:24800";
        switch-keys = [
          "caps-lock"
          "left-alt"
        ];
        certificate = "${config.sops.secrets.rkvm_cert.path}";
        key = "${config.sops.secrets.rkvm_key.path}";
        password = "fake";
      };
    };
    logind = {
      lidSwitch = "suspend-then-hibernate";
      lidSwitchExternalPower = "lock";

      extraConfig = ''
        HandlePowerKey=suspend-then-hibernate
        HandlePowerKeyLongPress=poweroff
        IdleAction=suspend-then-hibernate
        IdleActionSec=300
      '';
    };
    fprintd = {
      enable = true;
    };
    avahi = {
      enable = true;
      openFirewall = true;
    };
    printing.enable = true;
    backups =
      let
        paths = [ "/home/qbit" "/etc" ];
        pruneOpts = [ "--keep-hourly 12" "--keep-daily 7" "--keep-weekly 5" "--keep-yearly 4" ];
        timerConfig = { OnCalendar = "*-*-* 00:30:00"; };
      in
      {
        remote = {
          enable = true;
          passwordFile = "${config.sops.secrets.restic_remote_password_file.path}";
          repositoryFile = "${config.sops.secrets.restic_remote_repo_file.path}";

          # Don't send libvirt over the air-wire
          inherit paths pruneOpts timerConfig;
        };
        local = {
          enable = true;
          repository = "/run/media/qbit/backup/${config.networking.hostName}";
          environmentFile = "${config.sops.secrets.restic_env_file.path}";
          passwordFile = "${config.sops.secrets.restic_password_file.path}";

          paths = paths ++ [ "/var/lib/libvirt" ];
          inherit pruneOpts;
          timerConfig = { OnCalendar = "hourly"; };
        };
      };
    pcscd.enable = true;
    vnstat.enable = true;
    clamav.updater.enable = true;
    tor = {
      enable = true;
      client.enable = true;
    };
    fwupd = {
      enable = true;
    };

    udev.extraRules = ''
      SUBSYSTEM=="usb", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="5bf0", GROUP="users", TAG+="uaccess"
      ACTION=="add", SUBSYSTEM=="thunderbolt", ATTRS{iommu_dma_protection}=="1", ATTR{authorized}=="0", ATTR{authorized}="1"
    '';
  };

  security.pki.certificates = [
    ''
      -----BEGIN CERTIFICATE-----
      MIIDPTCCAiWgAwIBAgIBATANBgkqhkiG9w0BAQsFADAiMSAwHgYDVQQDExdPYnNp
      ZGlhbiBMb2NhbCBSRVNUIEFQSTAeFw0yMzAyMDcwMTQ3NDVaFw0yNDAyMDcwMTQ3
      NDVaMCIxIDAeBgNVBAMTF09ic2lkaWFuIExvY2FsIFJFU1QgQVBJMIIBIjANBgkq
      hkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAiRr4708X1QMmQMG3+M7UoefV+9gq+jNR
      bM5HCOlBuB16LrhRiR/6ROaDnB3OJBP4NToCVY6+tJvWOqJe9FVyzviWzGaFkZGF
      eBF32QvYLZRbPTIVWADl+KabXm1TXtLos1GpPKnIjU9m+5Jt1ob8i4eTKjjarpSG
      u4kvKBQiQYxxYXA+miuqxPWD/mkIySvx50EVzrO5X8u/M4MQqPlpMvL6W6AxMXQ+
      WU5KWUkP3kU/CMB377GjqTfdwRMVqCFhKq0jzFueKrqY0qXnbLoTePFBV2HsPAhv
      Xup15Yx7G5pLROYkvmxvxzgP6mycB3SOiPDwj9UsFk41+KZV9cm6pQIDAQABo34w
      fDAMBgNVHRMEBTADAQH/MAsGA1UdDwQEAwIC9DA7BgNVHSUENDAyBggrBgEFBQcD
      AQYIKwYBBQUHAwIGCCsGAQUFBwMDBggrBgEFBQcDBAYIKwYBBQUHAwgwEQYJYIZI
      AYb4QgEBBAQDAgD3MA8GA1UdEQQIMAaHBH8AAAEwDQYJKoZIhvcNAQELBQADggEB
      AHfjsIJpQlQcSP1Gy0gcrnBt9PhcA5TAqKlafKXVs0z60gVFDd/8d9PU3QxuTa4m
      uQGLtFiMSudaoZoGhyEZ4kk5upqjfANppJj4R5UgPmfhp24AUvPjf2bVXczdIbvY
      MNrXMtOq4+zD8QdZ25aPXT17LDIGx3TSM4HQzpu9YQdVt6fGgqPKFo3U9HGsBCja
      lXsQ+lw4Hfi50HqLFRmLA50AP5m+EGdgIkVktAm7v8x0H8wHjd2Ysy8oRRAYtf2i
      tynaHjsc6x3jDd5HiGuShRNHV9r3Q+IG1+SikALFk0nhKfB4DpYTz/fSQsw9hEj5
      5wYD1VN/zBzPsHUUwCujYOs=
      -----END CERTIFICATE-----
    ''
  ];

  systemd = {
    user.services = lib.listToAttrs (builtins.map jobToUserService jobs) //
      {
        wsb = {
          description = "web scrap book";
          wantedBy = [ "graphical-session.target" ];
          partOf = [ "graphical-session.target" ];
          after = [ "graphical-session.target" ];
          serviceConfig = {
            WorkingDirectory = "/home/qbit/web-scrap";
            ExecStart = "${pywebscrapbook}/bin/wsb serve";
          };
        };
      };
    services = {
      ollama = {
        environment = {
          OLLAMA_ORIGINS = "*";
        };
      };
      "whytailscalewhy" = {
        description = "Tailscale restart on resume";
        wantedBy = [ "post-resume.target" ];
        after = [ "post-resume.target" ];
        script = ''
          . /etc/profile;
          ${pkgs.systemd}/bin/systemctl restart tailscaled.service
        '';
        serviceConfig.Type = "oneshot";
      };
    };
  };

  users.users.qbit.extraGroups = [
    "cdrom"
    "davfs2"
    "dialout"
    "input"
    "libvirtd"
    "plugdev"
    "podmap"
  ];

  environment = {
    sessionVariables = {
      XDG_BIN_HOME = "\${HOME}/.local/bin";
      XDG_CACHE_HOME = "\${HOME}/.cache";
      XDG_CONFIG_HOME = "\${HOME}/.config";
      XDG_DATA_HOME = "\${HOME}/.local/share";

      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
      PATH = [ "\${XDG_BIN_HOME}" ];
      MUHOME = "\${HOME}/.config/mu";
    };

    systemPackages = with pkgs; [
      arduino
      beets # stable
      calibre
      cinny-desktop
      chirp # stable
      davfs2
      deltachat-desktop
      deluge
      dino
      direwolf
      distrobox
      element-desktop
      elmPackages.elm
      elmPackages.elm-format
      elmPackages.elm-language-server
      elmPackages.elm-live
      entr
      ferdium
      fossil
      freetube
      gajim
      gforth
      gh
      gimp
      git-credential-keepassxc
      gqrx
      hackrf
      inkscape
      intiface-central
      isync
      jan
      joplin-desktop
      jujutsu
      klavaro
      koreader
      linphone
      ltunify
      minicom
      mu
      nix-index
      nixpkgs-review
      nmap
      obsidian
      signal-cli
      ollama
      openscad
      picard
      picocom
      proton-caller
      protonup-ng
      prusa-slicer
      python3Packages.nomadnet
      python3Packages.rns
      qdmr
      # Don't do it, don't switch to another music player. They all suck!
      # this one works the least sucky!
      quodlibet-full #stable
      # Don't do it! ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
      #
      rtl-sdr
      sdrpp
      signal-desktop
      tangara-cli
      tangara-companion
      tcpdump
      tea
      tigervnc
      tncattach
      unzip
      veilid
      virt-manager
      yt-dlp

      (callPackage ../../pkgs/ttfs.nix { })
      (python3Packages.callPackage ../../pkgs/kobuddy.nix { })
      (callPackage ../../pkgs/gokrazy.nix { })
      (callPackage ../../pkgs/mvoice.nix { })
      (callPackage ../../pkgs/zutty.nix { })
      # (python3Packages.callPackage ../../pkgs/watchmap.nix { })
      (python3Packages.callPackage ../../pkgs/ble-serial.nix { })
      (tclPackages.callPackage ../../pkgs/irken.nix { })

      restic
    ];
  };

  # for Pharo
  security.pam.loginLimits = [
    {
      domain = "qbit";
      type = "hard";
      item = "rtprio";
      value = "2";
    }
    {
      domain = "qbit";
      type = "soft";
      item = "rtprio";
      value = "2";
    }
  ];

  system = {
    autoUpgrade.allowReboot = false;
    # 21.11
    stateVersion = "23.11";
  };
}
