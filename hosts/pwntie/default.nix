{
  pkgs,
  config,
  lib,
  ...
}:
let
  tsAddr = "100.84.170.57";
  oLlamaPort = 11434;
  pubKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO7v+/xS8832iMqJHCWsxUZ8zYoMWoZhjj++e26g1fLT europa"
  ];
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  hardware.rtl-sdr.enable = true;

  # Bootloader.
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
    };
    kernelPackages = pkgs.linuxPackages_latest;

    binfmt.emulatedSystems = [
      "aarch64-linux"
      "riscv64-linux"
    ];
  };
  nixpkgs.config.allowUnsupportedSystem = true;

  networking = {
    hostName = "pwntie";
    networkmanager.enable = true;
    hosts = {
      "100.83.77.133" = [
        "bounce.bold.daemon"
      ];
    };
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22
        10300
        10200
        10400
      ];
      checkReversePath = "loose";
    };
  };

  virtualisation.libvirtd.enable = true;

  environment.sessionVariables = {
    XDG_BIN_HOME = "\${HOME}/.local/bin";
    XDG_CACHE_HOME = "\${HOME}/.cache";
    XDG_CONFIG_HOME = "\${HOME}/.config";
    XDG_DATA_HOME = "\${HOME}/.local/share";

    PATH = [ "\${XDG_BIN_HOME}" ];
  };

  environment.systemPackages = with pkgs; [
    rtl-sdr
    direwolf
    irssi
  ];

  xinCI = {
    user = "qbit";
    enable = true;
  };

  systemd = {
    services = {
      ollama = {
        environment = {
          OLLAMA_ORIGINS = "*";
          OLLAMA_HOST = lib.mkForce "0.0.0.0";
        };
      };
    };
  };

  services = {
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
          "calibre-library" = {
            path = "~/Calibre_Library";
            id = "calibre_library";
            devices = [
              "box"
              "europa"
            ];
            versioning = {
              type = "staggered";
              fsPath = "~/syncthing/calibre-backup";
              params = {
                cleanInterval = "3600";
                maxAge = "31536000";
              };
            };
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
    wyoming = {
      openwakeword = {
        enable = true;
        uri = "tcp://0.0.0.0:10400";
      };
      faster-whisper = {
        servers.ha = {
          enable = true;
          uri = "tcp://0.0.0.0:10300";
          language = "en";
        };
      };
      piper.servers.ha = {
        enable = true;
        uri = "tcp://0.0.0.0:10200";
        voice = "en-us-ryan-medium";
      };
    };
    ts-reverse-proxy = {
      servers = {
        "ollama-reverse" = {
          enable = true;
          reverseName = "ollama";
          reversePort = oLlamaPort;
        };
      };
    };
    ollama = {
      enable = true;
      acceleration = "rocm";
      host = "localhost";
      port = oLlamaPort;
    };
    prometheus = {
      enable = true;
      port = 9001;
      listenAddress = tsAddr;

      exporters = {
        node = {
          enable = true;
          enabledCollectors = [ "systemd" ];
          port = 9002;
        };
      };
    };
    fwupd = {
      enable = true;
    };
  };

  users = {
    users = {
      root = {
        openssh.authorizedKeys.keys = pubKeys;
      };
      qbit = {
        openssh.authorizedKeys.keys = pubKeys;
        extraGroups = [
          "dialout"
          "libvirtd"
          "docker"
          "plugdev"
        ];
      };
    };
  };

  system.stateVersion = "22.11";
}
