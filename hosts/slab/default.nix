{
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  hardware = {
    rtl-sdr.enable = true;
    bluetooth.enable = true;
    sensor.iio.enable = true;
    enableAllFirmware = true;
  };

  nixpkgs.config = {
    allowUnsupportedSystem = true;
    allowUnfree = true;
  };

  console.font = "${pkgs.terminus_font}/share/consolefonts/ter-v32n.psf.gz";
  console.earlySetup = true;

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  networking = {
    hostName = "slab";
    networkmanager.enable = true;
    wireless.userControlled.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
      checkReversePath = "loose";
    };
  };

  programs.partition-manager.enable = true;

  environment.systemPackages = with pkgs; [
    isync
    mu
    rtl-sdr
    signal-desktop
  ];

  kdeMobile.enable = true;
  kdeconnect.enable = true;

  programs = {
    _1password.enable = true;
    _1password-gui = {
      enable = true;
      polkitPolicyOwners = [ "qbit" ];
    };
    zsh = {
      shellInit = ''
        export OP_PLUGIN_ALIASES_SOURCED=1
      '';
      shellAliases = {
        "gh" = "op plugin run -- gh";
        "nixpkgs-review" =
          "env GITHUB_TOKEN=$(op item get nixpkgs-review --field token --reveal) nixpkgs-review";
        "godeps" = "go list -m -f '{{if not (or .Indirect .Main)}}{{.Path}}{{end}}' all";
        "sync-music" = "rsync -av --progress --delete ~/Music/ suah.dev:/var/lib/music/";
        "load-agent" =
          ''op item get signer --field 'private key' --reveal | sed '/"/d; s/\r//' | ssh-add -'';
      };
    };
  };

  services = {
    libinput.enable = true;
    smartd.enable = false;
    fwupd = {
      enable = true;
    };
  };

  # pamu2fcfg -u qbit -opam://xin -ipam://orcim
  security.pam.u2f = {
    enable = true;
    settings = {
      origin = "pam://xin";
    };
  };

  system.stateVersion = "22.11";
}
