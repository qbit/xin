{ config, pkgs, lib, modulesPath, inputs, ... }:
let
  myEmacs = pkgs.callPackage ../../configs/emacs.nix { };
  peerixUser = if builtins.hasAttr "peerix" config.users.users then
    config.users.users.peerix.name
  else
    "root";
  mkCronScript = name: src: ''
    . /etc/profile;
    set -x
    # autogenreated ${name}
    ${src}
  '';
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
  jobToService = job: {
    name = "${job.name}";
    value = {
      script = mkCronScript "${job.name}_script" job.script;
      inherit (job) startAt;
      inherit (job) path;
    };
  };
in {
  _module.args.isUnstable = true;

  imports =
    [ ./hardware-configuration.nix ../../pkgs ../../configs/neomutt.nix ];

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
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  nixpkgs.config.allowUnsupportedSystem = true;

  boot = {
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

  sshFidoAgent.enable = true;

  nixManager = {
    enable = true;
    user = "qbit";
  };

  kde.enable = true;
  jetbrains.enable = true;

  virtualisation.libvirtd.enable = true;

  networking = {
    hostName = "europa";
    hostId = "87703c3e";
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
        "godeps" =
          "go list -m -f '{{if not (or .Indirect .Main)}}{{.Path}}{{end}}' all";
        "mutt" = "neomutt -F /etc/neomuttrc";
        "neomutt" = "neomutt -F /etc/neomuttrc";
      };
    };
  };

  services = {
    restic = {
      backups = {
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
    emacs = {
      enable = true;
      package = myEmacs;
      install = true;
    };
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

  systemd.user.services = lib.listToAttrs (builtins.map jobToService jobs);
  systemd.services."whytailscalewhy" = {
    description = "Tailscale restart on resume";
    wantedBy = [ "post-resume.target" ];
    after = [ "post-resume.target" ];
    script = ''
      . /etc/profile;
      ${pkgs.systemd}/bin/systemctl restart tailscaled.service
    '';
    serviceConfig.Type = "oneshot";
  };

  virtualisation.docker.enable = true;
  users.users.qbit.extraGroups = [ "dialout" "libvirtd" "docker" ];

  nixpkgs.config.allowUnfree = true;

  environment.sessionVariables = {
    XDG_BIN_HOME = "\${HOME}/.local/bin";
    XDG_CACHE_HOME = "\${HOME}/.cache";
    XDG_CONFIG_HOME = "\${HOME}/.config";
    XDG_DATA_HOME = "\${HOME}/.local/share";

    STEAM_EXTRA_COMPAT_TOOLS_PATHS =
      "\${HOME}/.steam/root/compatibilitytools.d";
    PATH = [ "\${XDG_BIN_HOME}" ];
    MUHOME = "\${HOME}/.config/mu";
  };

  environment.systemPackages = with pkgs; [
    aerc
    git-credential-1password
    arcanPackages.all-wrapped
    barrier
    rex
    calibre
    cider
    cinny-desktop
    clementine
    drawterm
    element-desktop
    exercism
    fido2luks
    gh
    isync
    klavaro
    linphone
    logseq
    minicom
    mu
    nheko
    nix-index
    nixpkgs-review
    nix-top
    nmap
    obsidian
    pharo
    pharo-launcher
    proton-caller
    protonup-ng
    rofi
    signal-desktop
    taskobs
    tcpdump
    tea
    thunderbird
    tidal-hifi
    tigervnc
    unzip
    virt-manager
    yt-dlp
    yubioath-flutter
    zig

    talon

    (callPackage ../../pkgs/gokrazy.nix { })
    (callPackage ../../pkgs/zutty.nix { })
  ];

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

  system.autoUpgrade.allowReboot = false;
  system.stateVersion = "21.11";
}
