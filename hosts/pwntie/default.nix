{ pkgs
, config
, lib
, inputs
, ...
}:
let
  tsAddr = "100.84.170.57";
  oLlamaPort = 11434;
  esphomePort = 6053;
  pubKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO7v+/xS8832iMqJHCWsxUZ8zYoMWoZhjj++e26g1fLT europa"
  ];
in
{
  _module.args.isUnstable = false;
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

    binfmt.emulatedSystems = [ "aarch64-linux" "riscv64-linux" ];
  };
  nixpkgs.config.allowUnsupportedSystem = true;

  networking = {
    hostName = "pwntie";
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 10300 10200 10400 ];
      checkReversePath = "loose";
    };
  };

  virtualisation.libvirtd.enable = true;

  environment.sessionVariables = {
    XDG_BIN_HOME = "\${HOME}/.local/bin";
    XDG_CACHE_HOME = "\${HOME}/.cache";
    XDG_CONFIG_HOME = "\${HOME}/.config";
    XDG_DATA_HOME = "\${HOME}/.local/share";

    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
    PATH = [ "\${XDG_BIN_HOME}" ];
  };

  environment.systemPackages = with pkgs; [
    rtl-sdr
    direwolf
  ];

  xinCI = {
    user = "qbit";
    enable = true;
  };

  systemd = {
    services = {
      esphome = {
        environment = {
          GIT_CONFIG_SYSTEM = "/dev/null";
        };
      };
      ollama = {
        environment = {
          OLLAMA_ORIGINS = "*";
          OLLAMA_HOST = lib.mkForce "0.0.0.0";
        };
      };
    };
  };

  services = {
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
    esphome = {
      enable = true;
      address = "127.0.0.1";
      package = inputs.unstable.legacyPackages.${pkgs.system}.esphome;
      port = esphomePort;
    };
    guix = {
      enable = true;
      gc = {
        enable = true;
      };
    };
    ts-reverse-proxy = {
      servers = {
        "ollama-reverse" = {
          enable = true;
          reverseName = "ollama";
          reversePort = oLlamaPort;
        };
        "esphome-reverse" = {
          enable = true;
          reverseName = "esphome";
          reversePort = esphomePort;
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
      root = { openssh.authorizedKeys.keys = pubKeys; };
      qbit = {
        openssh.authorizedKeys.keys = pubKeys;
        extraGroups = [ "dialout" "libvirtd" "docker" "plugdev" ];
      };
    };
  };

  system.stateVersion = "22.11";
}
