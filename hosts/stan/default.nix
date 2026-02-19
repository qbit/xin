{
  config,
  pkgs,
  lib,
  ...
}:
let
  testingMode = false;
  syslogPort = 514;
  pubKeys = [
    "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBBB/V8N5fqlSGgRCtLJMLDJ8Hd3JcJcY8skI0l+byLNRgQLZfTQRxlZ1yymRs36rXj+ASTnyw5ZDv+q2aXP7Lj0= hosts@secretive.plq.local"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO7v+/xS8832iMqJHCWsxUZ8zYoMWoZhjj++e26g1fLT europa"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJrKLKzJQcecdPXUm5xCfinLKDStNP3MawaXy06krcK5 abieber@litr"
  ];

  userBase = {
    openssh.authorizedKeys.keys = pubKeys ++ config.myconf.managementPubKeys;
    shell = pkgs.zsh;
  };
in
{
  imports = [ ./hardware-configuration.nix ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/boot/efi";
    };

    initrd = {
      luks.devices."luks-23b20980-eb1e-4390-b706-f0f42a623ddf".device =
        "/dev/disk/by-uuid/23b20980-eb1e-4390-b706-f0f42a623ddf";
      luks.devices."luks-23b20980-eb1e-4390-b706-f0f42a623ddf".keyFile = "/crypto_keyfile.bin";
      secrets = {
        "/crypto_keyfile.bin" = null;
      };
    };
    kernelParams = [ "intel_idle.max_cstate=4" ];
    kernelPackages = pkgs.linuxPackages;
  };
  security = {
    pam.u2f = {
      enable = true;
      settings = {
        origin = "pam://xin";
      };
    };
    pki.certificates = [
      ''
        -----BEGIN CERTIFICATE-----
        MIIDPTCCAiWgAwIBAgIBATANBgkqhkiG9w0BAQsFADAiMSAwHgYDVQQDExdPYnNp
        ZGlhbiBMb2NhbCBSRVNUIEFQSTAeFw0yMzAyMTMxNzQ5MjVaFw0yNDAyMTMxNzQ5
        MjVaMCIxIDAeBgNVBAMTF09ic2lkaWFuIExvY2FsIFJFU1QgQVBJMIIBIjANBgkq
        hkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA0yijxG36TcCF7/NzZoBJFqxazwFhMB10
        D6p4PIx0JZvGaTREEZ+pIrkB4PrQ9WX8Te5trPxMXUYhoZGYPPhMPA60CARzkBFp
        WcsGmEeqxGrOYM+ixGYPQ26qDyxiBC8Au0EDRoEsH0iE2YnX+5gLpYKVKTBOzpZo
        w6BDT6zW+LyveVL8qNBWbsPxIVoWEL7uH1cQDr853XT5F85HIoh+oo9utjnUNM6e
        /h+rObzWqqOuPAkA4xG7peYPmDBWxDgTQnYA0NcnCNZavbfgLpBlcLVzkNjSZtHp
        He+7cGQTE1dFU+HD3dKCyZsFbkCiEZ2ilgnNDhMHH2v/9sXhfKrnUQIDAQABo34w
        fDAMBgNVHRMEBTADAQH/MAsGA1UdDwQEAwIC9DA7BgNVHSUENDAyBggrBgEFBQcD
        AQYIKwYBBQUHAwIGCCsGAQUFBwMDBggrBgEFBQcDBAYIKwYBBQUHAwgwEQYJYIZI
        AYb4QgEBBAQDAgD3MA8GA1UdEQQIMAaHBH8AAAEwDQYJKoZIhvcNAQELBQADggEB
        AGITD1ecJKfSlNWB7eRFHoyKkYCk7oObWX9Xmn+xlnagYCwNLwQkJbfIEx9h6B+7
        8D6fDKcmMAtV7cInJEVs31AwOCf6pPEAkEuV01gcliE0MCnMjLI9gXgvn6dUXCn2
        TfpgpBa/9r13qyT441QSXKUvdfKbG9jYDudRKCxUM3PWTMkisV04NTCXCv9wYoLb
        /zIX07be6psy7R4Lq7JMqAtkqyw+0ncPg6AP3/Mh4gNYiT6Ms6WowG+928GgXXKY
        igxg14FIjjtSmVVai9cL7rKiueDDGRsnfa/APz2jt+aCR40u9M1lWl3jJYqX8NHk
        iIsViCSrKSGrNAYxFdQEJ9M=
        -----END CERTIFICATE-----
      ''
      ''
        -----BEGIN CERTIFICATE-----
        MIIEVzCCAz+gAwIBAgIJALFQqjdrHsc+MA0GCSqGSIb3DQEBBQUAMHoxCzAJBgNV
        BAYTAlVTMRswGQYDVQQKExJDYWx5cHRpeCBTZWN1cml0eS4xCzAJBgNVBAsTAklU
        MSEwHwYDVQQDExhDYWx5cHRpeCBEZXYgSW50ZXJuYWwgQ0ExHjAcBgkqhkiG9w0B
        CQEWD2l0QGNhbHlwdGl4LmNvbTAeFw0xNTAzMjAwMDA1MDBaFw0yNTAzMTcwMDA1
        MDBaMHoxCzAJBgNVBAYTAlVTMRswGQYDVQQKExJDYWx5cHRpeCBTZWN1cml0eS4x
        CzAJBgNVBAsTAklUMSEwHwYDVQQDExhDYWx5cHRpeCBEZXYgSW50ZXJuYWwgQ0Ex
        HjAcBgkqhkiG9w0BCQEWD2l0QGNhbHlwdGl4LmNvbTCCASIwDQYJKoZIhvcNAQEB
        BQADggEPADCCAQoCggEBAMMvhgIrKr9/6szSqkj9KiZk/KCAJUG5r9X4yMa9TRMT
        S/wV3rKGgZv1s9d6S6YFePZlsXgNGoSAGgrlrxYBpgUrkPn+iG5hdP85UgbzpWJi
        1P5ESS5RRXaHe7PnFBDsy29zGEhR4YpPl6YNf8N870BRO7DVItlaaGwXD/U4uzSY
        R9YGENx85wD06qxk3TccRbglCSoqCIdjCkG343USy7oJftPycLWe3K6Xx8Zv89wT
        rtrjpSopXtY2iGxZJvs2OlxfHd7rEY+N9QNkwpOr5+gLYDnhJlOj0qP40FTytieX
        xGkFeb/o4FJHblfkQyEH87IK9QTckKip///4WSf8v20CAwEAAaOB3zCB3DAdBgNV
        HQ4EFgQUoc6flYe+Mlq4WTpWyvAMXk9f71swgawGA1UdIwSBpDCBoYAUoc6flYe+
        Mlq4WTpWyvAMXk9f71uhfqR8MHoxCzAJBgNVBAYTAlVTMRswGQYDVQQKExJDYWx5
        cHRpeCBTZWN1cml0eS4xCzAJBgNVBAsTAklUMSEwHwYDVQQDExhDYWx5cHRpeCBE
        ZXYgSW50ZXJuYWwgQ0ExHjAcBgkqhkiG9w0BCQEWD2l0QGNhbHlwdGl4LmNvbYIJ
        ALFQqjdrHsc+MAwGA1UdEwQFMAMBAf8wDQYJKoZIhvcNAQEFBQADggEBAErodbwo
        oCdB1x/GbE/Ap5pt0uuVymECgB9DGKmjFYzX9VB8i3Brjhp9UyqcpMKbA9hDhaOU
        S+BOPL4rI5NMFQpaiRLSBPlQrsdKlXIMln3C2c2oHvcuw0agfkmXRonm7En8T7vC
        kEWrZEZye9L8PRWRkHDwKb4lvOpnRcOvsV9ICRWEpFKVhP6I/HALfXonvMUNiOSo
        5+7yxanKMvXNmZ6qLnfHbyUi9bv1jchgNwSatF5RI1tzstJf8hqDIH47NTbRUX+h
        2hPSEdvfURSdHbvPsv8Ku87sgR+HY1P2j8Qdp63hALfkoMvaHn55MxRVUeVXExsn
        tRhywtPsIHEmllI=
        -----END CERTIFICATE-----
      ''
    ];
  };
  networking = {
    hostName = "stan";

    hosts = {
      "172.16.30.253" = [ "proxmox-02.vm.calyptix.local" ];
      "127.0.0.1" = [
        "borg.calyptix.dev"
        "localhost"
      ];
      "192.168.122.249" = [
        "arst.arst"
        "vm"
      ];
      "192.168.8.194" = [
        "router.arst"
        "router"
      ];
      "10.6.0.110" = [ "store.bold.daemon" ];
    };

    networkmanager.enable = true;
    firewall = {
      trustedInterfaces = [ "virbr0" ];
      allowedTCPPorts = [ 22 ] ++ (if testingMode then [ 8080 ] else [ ]);
      allowedUDPPorts = if testingMode then [ syslogPort ] else [ ];
      checkReversePath = "loose";
    };
    interfaces."enp133s0" = {
      wakeOnLan.enable = true;
    };
  };

  kde.enable = true;
  sway.enable = true;
  defaultUsers.enable = false;
  defaultUserName = "abieber";

  sops.secrets = {
    rkvm_cert = {
      sopsFile = config.xin-secrets.stan.secrets.main;
      owner = "root";
      group = "wheel";
      mode = "400";
    };
    vm_pass = {
      sopsFile = config.xin-secrets.stan.secrets.main;
      owner = "root";
      group = "wheel";
      mode = "400";
    };
    restic_password_file = {
      sopsFile = config.xin-secrets.stan.secrets.main;
      owner = "root";
      mode = "400";
    };
    restic_env_file = {
      sopsFile = config.xin-secrets.stan.secrets.main;
      owner = "root";
      mode = "400";
    };
    restic_repo_file = {
      sopsFile = config.xin-secrets.stan.secrets.main;
      owner = "root";
      mode = "400";
    };
    abieber_hash = {
      sopsFile = config.xin-secrets.stan.user_passwords.abieber;
      owner = "root";
      mode = "400";
      neededForUsers = true;
    };
    root_hash = {
      sopsFile = config.xin-secrets.stan.user_passwords.root;
      owner = "root";
      mode = "400";
      neededForUsers = true;
    };
    xin_store_pub = {
      sopsFile = config.xin-secrets.stan.secrets.main;
      owner = "root";
      group = "wheel";
      mode = "440";
    };
    xin_store_key = {
      sopsFile = config.xin-secrets.stan.secrets.main;
      owner = "root";
      group = "wheel";
      mode = "400";
    };
    xin_store_pub_user = {
      sopsFile = config.xin-secrets.stan.secrets.main;
      owner = "abieber";
      group = "wheel";
      mode = "440";
    };
    xin_store_key_user = {
      sopsFile = config.xin-secrets.stan.secrets.main;
      owner = "abieber";
      group = "wheel";
      mode = "400";
    };
    calyptix_ssh_config = {
      sopsFile = config.xin-secrets.stan.secrets.main;
      owner = "root";
      group = "wheel";
      mode = "440";
    };
    calyptix_tmp_ssh = {
      sopsFile = config.xin-secrets.stan.secrets.main;
      owner = "root";
      mode = "400";
    };
    "calyptix_tmp_ssh_pub" = {
      sopsFile = config.xin-secrets.stan.secrets.main;
      owner = "root";
      mode = "400";
    };
    netrc = {
      sopsFile = config.xin-secrets.stan.secrets.abieber;
      owner = "abieber";
      group = "wheel";
      mode = "400";
    };
  };

  users = {
    mutableUsers = false;
    users = {
      root = userBase // {
        hashedPasswordFile = config.sops.secrets.root_hash.path;
      };
      abieber = userBase // {
        isNormalUser = true;
        description = "Aaron Bieber";
        extraGroups = [
          "networkmanager"
          "wheel"
          "libvirtd"
          "podman"
        ];
        hashedPasswordFile = config.sops.secrets.abieber_hash.path;
      };
    };
  };

  nixpkgs.config.allowUnfree = true;

  nix = {
    settings = {
      substituters = lib.mkOverride 1 [
        "https://cache.nixos.org"
        "https://store.bold.daemon"
      ];
    };
  };

  environment = {
    systemPackages = with pkgs; [
      bitwarden-desktop
      distrobox
      firefox
      fzf
      glab
      google-chrome
      ispell
      libreoffice
      mattermost-desktop
      mosh
      mupdf
      nmap
      oath-toolkit
      obs-studio
      openvpn
      remmina
      snmpcheck
      sshfs
      tcpdump
      unzip
      virt-manager
      virt-viewer
      wireshark
    ];
  };

  virtualisation = {
    libvirtd.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
    };
  };

  programs = {
    git.config.safe.directory = "/home/abieber/aef100";
    dconf.enable = true;
    zsh.enable = true;
    ssh = {
      extraConfig = ''
        Include ${config.sops.secrets.calyptix_ssh_config.path}
      '';
      knownHosts = {
        "[192.168.122.249]:7022".publicKey =
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAOzf2Rv6FZYuH758TlNBcq4CXAHTPJxe5qoQTRM3nRc";
      };
    };
  };

  services = {
    unifi = {
      enable = false;
      unifiPackage = pkgs.unifi;
      mongodbPackage = pkgs.mongodb-7_0;
    };
    tailscale = {
      extraDaemonFlags = [ ];
    };
    avahi.enable = true;
    rkvm.client = {
      enable = true;
      settings = {
        certificate = "${config.sops.secrets.rkvm_cert.path}";
        password = "fake";
        server = "127.0.0.1:24800";
      };
    };
    backups = {
      remote = {
        enable = true;
        environmentFile = "${config.sops.secrets.restic_env_file.path}";
        passwordFile = "${config.sops.secrets.restic_password_file.path}";
        repositoryFile = "${config.sops.secrets.restic_repo_file.path}";

        paths = [ "/home/abieber" ];

        pruneOpts = [
          "--keep-daily 7"
          "--keep-weekly 2"
          "--keep-monthly 2"
        ];
      };
    };
    rsyslogd = {
      enable = testingMode;
      defaultConfig = ''
        module(load="imudp")
        input(type="imudp" port="${toString syslogPort}")

        daemon.*          -/var/log/daemon
        *.warning;*.warn  -/var/log/warning
      '';
    };
    printing.enable = true;
    fwupd.enable = true;
    openntpd.enable = true;
  };

  system = {
    autoUpgrade.allowReboot = false;
    stateVersion = "22.05"; # Did you read the comment?
  };
}
