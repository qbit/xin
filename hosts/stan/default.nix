{ config, pkgs, ... }:
let
  pubKeys = [
    "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBBB/V8N5fqlSGgRCtLJMLDJ8Hd3JcJcY8skI0l+byLNRgQLZfTQRxlZ1yymRs36rXj+ASTnyw5ZDv+q2aXP7Lj0= hosts@secretive.plq.local"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO7v+/xS8832iMqJHCWsxUZ8zYoMWoZhjj++e26g1fLT europa"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJrKLKzJQcecdPXUm5xCfinLKDStNP3MawaXy06krcK5 abieber@litr"
  ];

  userBase = {
    openssh.authorizedKeys.keys = pubKeys ++ config.myconf.managementPubKeys;
  };
  myEmacs = pkgs.callPackage ../../configs/emacs.nix { };
  peerixUser = if builtins.hasAttr "peerix" config.users.users then
    config.users.users.peerix.name
  else
    "root";
in {
  _module.args.isUnstable = true;
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
      luks.devices."luks-23b20980-eb1e-4390-b706-f0f42a623ddf".keyFile =
        "/crypto_keyfile.bin";
      secrets = { "/crypto_keyfile.bin" = null; };
    };
    kernelParams = [ "intel_idle.max_cstate=4" ];
    kernelPackages = pkgs.linuxPackages;
  };
  security.pki.certificates = [
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

  preDNS.enable = false;
  networking = {
    hostName = "stan";

    hosts = {
      "172.16.30.253" = [ "proxmox-02.vm.calyptix.local" ];
      "127.0.0.1" = [ "borg.calyptix.dev" "localhost" ];
      "192.168.122.249" = [ "arst.arst" "vm" ];
      "192.168.54.1" = [ "router.arst" "router" ];
    };

    networkmanager.enable = true;
    firewall = {
      allowedTCPPorts = [ 22 ];
      checkReversePath = "loose";
    };
  };

  i18n.defaultLocale = "en_US.utf8";

  kde.enable = true;
  defaultUsers.enable = false;
  jetbrains.enable = true;
  sshFidoAgent.enable = true;

  sops.secrets = {
    tskey = {
      sopsFile = config.xin-secrets.stan.secrets;
      owner = "root";
      mode = "400";
    };
    vm_pass = {
      sopsFile = config.xin-secrets.stan.main;
      owner = "root";
      group = "wheel";
      mode = "400";
    };
    peerix_private_key = {
      sopsFile = config.xin-secrets.stan.peerix;
      owner = "${peerixUser}";
      group = "wheel";
      mode = "400";
    };
  };

  systemd.services = {
    "tailscale-init" = {
      wantedBy = [ "tailscaled.service" ];
      after = [ "tailscaled.service" ];
      serviceConfig = {
        ExecStart =
          "${pkgs.tailscale}/bin/tailscale up --auth-key file://${config.sops.secrets.tskey.path}";
      };
    };
  };

  users.users.root = userBase;
  users.users.abieber = {
    isNormalUser = true;
    description = "Aaron Bieber";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "libvirtd" ];
  } // userBase;

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    barrier
    bitwarden
    brave
    firefox
    fzf
    google-chrome-dev
    ispell
    keychain
    libreoffice
    mattermost-desktop
    mosh
    mupdf
    nmap
    oathToolkit
    obsidian
    obs-studio
    openvpn
    remmina
    rex
    sshfs
    tcpdump
    virt-manager
    wireshark
    zig

    (callPackage ../../pkgs/zutty.nix { })
  ];

  virtualisation.libvirtd.enable = true;

  programs = {
    dconf.enable = true;
    zsh.enable = true;
  };

  tsPeerix = {
    enable = false;
    privateKeyFile = "${config.sops.secrets.peerix_private_key.path}";
    interfaces = [ "wlp170s0" "ztksevmpn3" ];
  };

  services = {
    emacs = {
      enable = true;
      package = myEmacs;
      install = true;
    };
    printing.enable = true;
    fwupd.enable = true;
    unifi.enable = false;
    openntpd.enable = true;
    resolved = {
      enable = true;
      dnssec = "allow-downgrade";
    };
  };

  system.autoUpgrade.allowReboot = false;
  system.stateVersion = "22.05"; # Did you read the comment?

}
