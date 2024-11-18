{ pkgs
, config
, lib
, ...
}:
let
  tsAddr = "100.84.170.57";
  oLlamaPort = 11434;
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
      allowedTCPPorts = [ 22 ];
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
    (callPackage ../../pkgs/rtlamr.nix { })
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
    rtlamr2mqtt = {
      enable = true;
      configuration = {
        general = {
          device_ids_path = "${config.services.rtlamr2mqtt.package}/sdl_ids.txt";
          sleep_for = 0;
          verbosity = "debug";
          tickle_rtl_tcp = false;
          device_id = "0bda:2838";
        };
        mqtt = {
          host = "10.6.0.15";
          port = 1883;
          tls_enabled = false;
          ha_autodiscovery = true;
          base_topic = "rtlamr";
        };
        custom_parameters = {
          rtltcp = "-s 2048000";
          rtlamr = "-unique=true -symbollength=32";
        };
        meters = [
          {
            id = 48582066;
            protocol = "scm";
            name = "gas_meter";
            unit_of_measurement = "ft³";
            icon = "mdi:gas-burner";
            device_class = "gas";
            state_class = "total_increasing";
          }
        ];
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
