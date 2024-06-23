{ inputs
, config
, pkgs
, lib
, xinlib
, ...
}:
let
  inherit (inputs.stable.legacyPackages.${pkgs.system}) chirp beets;
  inherit (inputs.unstableSmall.legacyPackages.${pkgs.system}) quodlibet-full;
  inherit (xinlib) jobToUserService prIsOpen;
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

  sshFidoAgent.enable = lib.mkDefault true;

  nixManager = {
    enable = lib.mkDefault true;
    user = "qbit";
  };

  kde.enable = lib.mkDefault true;
  kdeConnect.enable = true;

  virtualisation.libvirtd.enable = lib.mkDefault true;

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
      interfaces = {
        "tailscale0" =
          {
            allowedTCPPorts = [ 8384 ];
          };
      };
    };
  };

  programs = {
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
        "nixpkgs-review" = "env GITHUB_TOKEN=$(op item get nixpkgs-review --field token) nixpkgs-review";
        "godeps" = "go list -m -f '{{if not (or .Indirect .Main)}}{{.Path}}{{end}}' all";
        "sync-music" = "rsync -av --progress --delete ~/Music/ suah.dev:/var/lib/music/";
        "load-agent" = ''op item get signer --field 'private key' --reveal | sed '/"/d; s/\r//' | ssh-add -'';
      };
    };
  };

  services.xinCA = { enable = false; };

  services = {
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
    rimgo = {
      enable = true;
      settings = {
        PORT = 3001;
        ADDRESS = "127.0.0.1";
      };
    };
    fprintd = {
      enable = true;
    };
    avahi = {
      enable = true;
      openFirewall = true;
    };
    printing.enable = true;
    restic = {
      backups =
        let
          paths = [ "/home/qbit" "/var/lib/libvirt" "/etc" ];
        in
        {
          remote = {
            initialize = true;
            passwordFile = "${config.sops.secrets.restic_remote_password_file.path}";
            repositoryFile = "${config.sops.secrets.restic_remote_repo_file.path}";

            inherit paths;

            pruneOpts = [ "--keep-daily 7" "--keep-weekly 5" "--keep-yearly 4" ];
          };
          local = {
            initialize = true;
            repository = "/run/media/qbit/backup/${config.networking.hostName}";
            environmentFile = "${config.sops.secrets.restic_env_file.path}";
            passwordFile = "${config.sops.secrets.restic_password_file.path}";

            inherit paths;

            pruneOpts = [ "--keep-daily 7" "--keep-weekly 5" "--keep-yearly 5" ];
          };
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
    user.services =
      lib.listToAttrs (builtins.map jobToUserService jobs);
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
    "dialout"
    "libvirtd"
    "plugdev"
    "cdrom"
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
      chirp # stable
      #deltachat-desktop
      deluge
      direwolf
      element-desktop
      elmPackages.elm
      elmPackages.elm-format
      elmPackages.elm-language-server
      elmPackages.elm-live
      elmPackages.elm-test
      entr
      fossil
      gh
      gimp
      git-annex
      gqrx
      hackrf
      inkscape
      isync
      jan
      jujutsu
      klavaro
      koreader
      linphone
      minicom
      mu
      nheko
      nix-index
      nixpkgs-review
      nmap
      obsidian
      ollama
      openscad
      picocom
      proton-caller
      protonup-ng
      prusa-slicer
      python3Packages.meshtastic
      python3Packages.nomadnet
      python3Packages.rns
      qdmr
      quodlibet-full # unstableSmall
      deadbeef-with-plugins
      rex
      rofi
      rsibreak
      rtl-sdr
      sdrpp
      signal-desktop
      signal-desktop-beta
      tcpdump
      tea
      thunderbird
      tigervnc
      tncattach
      unzip
      veilid
      virt-manager
      w3m
      workrave
      yt-dlp
      zig

      (callPackage ../../pkgs/ttfs.nix { })
      (callPackage ../../pkgs/gokrazy.nix { })
      (callPackage ../../pkgs/zutty.nix { })
      (python3Packages.callPackage ../../pkgs/watchmap.nix { })

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
    stateVersion = "21.11";
  };
}
