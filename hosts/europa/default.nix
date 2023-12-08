{ inputs
, config
, pkgs
, lib
, xinlib
, ...
}:
let
  inherit (inputs.stable.legacyPackages.${pkgs.system}) chirp;
  inherit (builtins) readFile;
  #myEmacs = pkgs.callPackage ../../configs/emacs.nix { };
  #doom-emacs = inputs.nix-doom-emacs.packages.${pkgs.system}.default.override {
  #  doomPrivateDir = ../../configs/doom.d;
  #};
  peerixUser =
    if builtins.hasAttr "peerix" config.users.users
    then config.users.users.peerix.name
    else "root";
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
      name = "taskobs";
      script = "taskobs";
      startAt = "*:0/30";
      path = [ pkgs.taskobs ] ++ pkgs.taskobs.buildInputs;
    }
  ];
in
{
  _module.args.isUnstable = true;

  imports = [ ./hardware-configuration.nix ../../pkgs ../../configs/neomutt.nix ];

  sops.secrets = {
    fastmail = {
      sopsFile = config.xin-secrets.europa.qbit;
      owner = "qbit";
      group = "wheel";
      mode = "400";
    };
    fastmail_user = {
      sopsFile = config.xin-secrets.europa.qbit;
      owner = "qbit";
      group = "wheel";
      mode = "400";
    };
    nix_review = {
      sopsFile = config.xin-secrets.europa.qbit;
      owner = "qbit";
      group = "wheel";
      mode = "400";
    };
    netrc = {
      sopsFile = config.xin-secrets.europa.qbit;
      owner = "qbit";
      group = "wheel";
      mode = "400";
    };
    peerix_private_key = {
      sopsFile = config.xin-secrets.europa.peerix;
      owner = "${peerixUser}";
      group = "wheel";
      mode = "400";
    };
    restic_password_file = {
      sopsFile = config.xin-secrets.europa.services;
      owner = "root";
      mode = "400";
    };
    restic_env_file = {
      sopsFile = config.xin-secrets.europa.services;
      owner = "root";
      mode = "400";
    };
    restic_remote_password_file = {
      sopsFile = config.xin-secrets.europa.services;
      owner = "root";
      mode = "400";
    };
    restic_remote_env_file = {
      sopsFile = config.xin-secrets.europa.services;
      owner = "root";
      mode = "400";
    };
    restic_remote_repo_file = {
      sopsFile = config.xin-secrets.europa.services;
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
    loader = {
      systemd-boot.enable = true;
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
    };
    kernelParams = [ "boot.shell_on_fail" "mem_sleep_default=deep" ];
    kernelPackages = pkgs.linuxPackages_latest;
  };

  sshFidoAgent.enable = lib.mkDefault true;

  nixManager = {
    enable = lib.mkDefault true;
    user = "qbit";
  };

  kde.enable = lib.mkDefault true;

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
    };
  };

  tsPeerix = {
    enable = false;
    privateKeyFile = "${config.sops.secrets.peerix_private_key.path}";
    interfaces = [ "wlp170s0" "ztksevmpn3" ];
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
        "clilol" = "env CLILOL_APIKEY=$(op item get omglol-cli --field credential) clilol";
        "godeps" = "go list -m -f '{{if not (or .Indirect .Main)}}{{.Path}}{{end}}' all";
        "mutt" = "neomutt -F /etc/neomuttrc";
        "neomutt" = "neomutt -F /etc/neomuttrc";
      };
    };
  };

  services.xinCA = { enable = false; };

  services = {
    rimgo = {
      enable = true;
      settings = {
        PORT = 3000;
        ADDRESS = "127.0.0.1";
      };
    };
    fprintd.enable = true;
    avahi = {
      enable = true;
      openFirewall = true;
    };
    printing.enable = true;
    restic = {
      backups = {
        remote = {
          initialize = true;
          #environmentFile = "${config.sops.secrets.restic_remote_env_file.path}";
          passwordFile = "${config.sops.secrets.restic_remote_password_file.path}";
          repositoryFile = "${config.sops.secrets.restic_remote_repo_file.path}";
          #repository = "https://europa@backup.bold.daemon:8484/";

          paths = [ "/home/qbit" "/var/lib/libvirt" ];

          pruneOpts = [ "--keep-daily 7" "--keep-weekly 5" "--keep-yearly 4" ];
        };
        local = {
          initialize = true;
          repository = "/run/media/qbit/backup/${config.networking.hostName}";
          environmentFile = "${config.sops.secrets.restic_env_file.path}";
          passwordFile = "${config.sops.secrets.restic_password_file.path}";

          paths = [ "/home/qbit" "/var/lib/libvirt" ];

          pruneOpts = [ "--keep-daily 7" "--keep-weekly 5" "--keep-yearly 5" ];
        };
      };
    };
    pcscd.enable = true;
    vnstat.enable = true;
    clamav.updater.enable = true;
    #emacs = {
    #  enable = true;
    #  package = myEmacs;
    #  install = true;
    #};
    tor = {
      enable = true;
      client.enable = true;
    };
    fwupd = {
      enable = true;
      enableTestRemote = true;
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
      lib.listToAttrs (builtins.map xinlib.jobToUserService jobs);
    services."whytailscalewhy" = {
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

  virtualisation.docker.enable = false;
  users.users.qbit.extraGroups = [
    "dialout"
    "libvirtd"
    "plugdev"
    #"docker"
  ];

  environment = {
    etc."barrier.conf" = { text = readFile ../../configs/barrier.conf; };
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
      barrier
      beets
      calibre
      chirp
      direwolf
      element-desktop
      elmPackages.elm
      elmPackages.elm-format
      elmPackages.elm-language-server
      elmPackages.elm-live
      elmPackages.elm-test
      entr
      gh
      gimp
      git-credential-1password
      gqrx
      hackrf
      klavaro
      minicom
      nheko
      nix-index
      nixpkgs-review
      nix-top
      nmap
      picocom
      proton-caller
      protonup-ng
      prusa-slicer
      python3Packages.meshtastic
      qdmr
      rex
      rofi
      rsibreak
      rtl-sdr
      sayonara
      sdrpp
      signal-desktop
      taskobs
      tcpdump
      tea
      thunderbird
      tigervnc
      unzip
      veilid
      virt-manager
      w3m
      yt-dlp
      zig

      (callPackage ../../pkgs/ttfs.nix { })
      (callPackage ../../pkgs/clilol.nix { })
      (callPackage ../../pkgs/iamb.nix { })
      (callPackage ../../pkgs/kobuddy.nix {
        inherit pkgs;
        inherit
          (pkgs.python39Packages)
          buildPythonPackage
          fetchPypi
          setuptools-scm
          pytz
          banal
          sqlalchemy
          alembic
          ;
      })
      (callPackage ../../pkgs/gokrazy.nix { })
      (callPackage ../../pkgs/mvoice.nix { })
      (callPackage ../../pkgs/zutty.nix { })

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
    autoUpgrade.enable = false;
    stateVersion = "21.11";
  };
}
