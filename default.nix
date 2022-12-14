{ config, lib, options, pkgs, isUnstable, ... }:

let
  managementKey =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDM2k2C6Ufx5RNf4qWA9BdQHJfAkskOaqEWf8yjpySwH Nix Manager";
  statusKey = ''
    command="/run/current-system/sw/bin/xin-status",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE9PIhQ+yWfBM2tEG+W8W8HXJXqISXif8BcPZHakKvLM xin-status
  '';
  gosignify = pkgs.callPackage ./pkgs/gosignify.nix { inherit isUnstable; };
in {
  imports = [
    ./configs/colemak.nix
    ./configs/develop.nix
    ./configs/dns.nix
    ./configs/doas.nix
    ./configs/gitmux.nix
    ./configs/git.nix
    ./configs/neovim.nix
    ./configs/peerix.nix
    ./configs/manager.nix
    ./configs/tmux.nix
    ./configs/net-overlay.nix
    ./configs/zsh.nix
    ./dbuild
    ./gui
    ./modules
    ./overlays
    ./pkgs
    ./services
    ./system/nix-config.nix
    ./system/nix-lockdown.nix
    ./system/update.nix
    ./users

    ./bins
  ];

  options.myconf = {
    managementPubKeys = lib.mkOption rec {
      type = lib.types.listOf lib.types.str;
      default = [ managementKey statusKey ];
      example = default;
      description = "List of management public keys to use";
    };
    hwPubKeys = lib.mkOption rec {
      type = lib.types.listOf lib.types.str;
      default = [
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIB1cBO17AFcS2NtIT+rIxR2Fhdu3HD4de4+IsFyKKuGQAAAACnNzaDpsZXNzZXI="
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIDEKElNAm/BhLnk4Tlo00eHN5bO131daqt2DIeikw0b2AAAABHNzaDo="
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBBB/V8N5fqlSGgRCtLJMLDJ8Hd3JcJcY8skI0l+byLNRgQLZfTQRxlZ1yymRs36rXj+ASTnyw5ZDv+q2aXP7Lj0="
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIHrYWbbgBkGcOntDqdMaWVZ9xn+dHM+Ap6s1HSAalL28AAAACHNzaDptYWlu"
      ];
      example = default;
      description = "List of hardware public keys to use";
    };
  };

  config = {
    sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    sops.secrets = {
      xin_secrets_deploy_key = {
        sopsFile = config.xin-secrets.deploy;
        owner = "root";
        group = "wheel";
        mode = "400";
      };
    };

    security.pki.caCertificateBlacklist =
      [ "TrustCor ECA-1" "TrustCor RootCert CA-1" "TrustCor RootCert CA-2" ];
    security.pki.certificates = [''
      -----BEGIN CERTIFICATE-----
      MIIBrjCCAVOgAwIBAgIIKUKZ6zcNut8wCgYIKoZIzj0EAwIwFzEVMBMGA1UEAxMM
      Qm9sZDo6RGFlbW9uMCAXDTIyMDEyOTAxMDMxOVoYDzIxMjIwMTI5MDEwMzE5WjAX
      MRUwEwYDVQQDEwxCb2xkOjpEYWVtb24wWTATBgcqhkjOPQIBBggqhkjOPQMBBwNC
      AARYgIn1RWf059Hb964JEaiU3G248k2ZpBHtrACMmLRRO9reKr/prEJ2ltKrjCaX
      +98ButRNIn78U8pL+H+aeE0Zo4GGMIGDMA4GA1UdDwEB/wQEAwIChDAdBgNVHSUE
      FjAUBggrBgEFBQcDAQYIKwYBBQUHAwIwEgYDVR0TAQH/BAgwBgEB/wIBADAdBgNV
      HQ4EFgQUiUdCcaNy3E2bFzO9I76TPlMJ4w4wHwYDVR0jBBgwFoAUiUdCcaNy3E2b
      FzO9I76TPlMJ4w4wCgYIKoZIzj0EAwIDSQAwRgIhAOd6ejqevrYAH5JtDdy2Mh9M
      OTIx9nDZd+AOAg0wzlzfAiEAvG5taCm14H+qdWbEZVn+vqj6ChtxjH7fqOHv3Xla
      HWw=
      -----END CERTIFICATE-----
    ''];

    i18n.defaultLocale = "en_US.utf8";

    # from https://github.com/dylanaraps/neofetch
    users.motd = ''

                ::::.    ':::::     ::::'
                ':::::    ':::::.  ::::'
                  :::::     '::::.:::::
            .......:::::..... ::::::::
           ::::::::::::::::::. ::::::    ::::.
          ::::::::::::::::::::: :::::.  ::::'
                 .....           ::::' :::::'
                :::::            '::' :::::'
       ........:::::               ' :::::::::::.
      :::::::::::::                 :::::::::::::
       ::::::::::: ..              :::::
           .::::: .:::            :::::
          .:::::  .....
          :::::   :::::.  ......:::::::::::::'
           :::     ::::::. ':::::::::::::::::'
                  .:::::::: '::::::::::
                 .::::'''::::.     '::::.
                .::::'   ::::.     '::::.
               .::::      ::::      '::::.

    '';

    boot = {
      cleanTmpDir = true;
      kernelPackages = lib.mkDefault pkgs.linuxPackages_hardened;
      kernel.sysctl = {
        "net.ipv4.tcp_keepalive_time" = 60;
        "net.ipv6.tcp_keepalive_time" = 60;
      };
    };

    environment.systemPackages = with pkgs;
      [
        age
        apg
        bind
        btop
        direnv
        git-sync
        gosignify
        got
        jq
        lz4
        minisign
        mosh
        nix-diff
        nixfmt
        nix-index
        nix-top
        pass
        rbw
        ripgrep
        taskwarrior
        tmux
      ] ++ (if isUnstable then [ nil ] else [ ]);

    environment.interactiveShellInit = ''
      alias vi=nvim
    '';

    time.timeZone = "US/Mountain";

    documentation.enable = true;
    documentation.man.enable = true;

    networking.timeServers = options.networking.timeServers.default;

    programs = {
      zsh.enable = true;
      gnupg.agent.enable = true;
      ssh = {
        knownHosts = {
          "[namish.humpback-trout.ts.net]:2222".publicKey =
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF9jlU5XATs8N90mXuCqrflwOJ+s3s7LefDmFZBx8cCk";
          "[git.tapenet.org]:2222".publicKey =
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOkbSJWeWJyJjak/boaMTqzPVq91wfJz1P+I4rnBUsPW";
        };
        startAgent = true;
        extraConfig = "";
      };
    };

    services = {
      openssh = {
        enable = true;
        permitRootLogin = "prohibit-password";
        passwordAuthentication = false;
        kexAlgorithms = [ "curve25519-sha256" "curve25519-sha256@libssh.org" ];
        macs = [
          "hmac-sha2-512-etm@openssh.com"
          "hmac-sha2-256-etm@openssh.com"
          "umac-128-etm@openssh.com"
        ];
      };
    };
  };
}
