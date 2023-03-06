{ config, lib, options, pkgs, isUnstable, xinlib, ... }:

let
  caPubKeys = builtins.concatStringsSep "\n" [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC5xMSYMwu6rjjLe2UYs1YGCIBVs35E9db2qAjNltCVPG5UoctxCDXxIz0PMOJrBbfqZzP/6qPU1WAhdGNTZ5eXq/ftnhI+2xFfMg1uzpXZ9vjy8lUCfXIObtoEdZ9h/7OUCN/BnL0ySqsamkcUo8SAj6wXoNCdwk6oncfyTmhPnoW5tCWCS9p7Q/LuWpYGsvW5nFDSxteP7re6SUe10eftIkFAPNhKA2lsrvzMgjxhnXqwIr1qJeY0otcuYA4V5V09FmElbnOWVuy4Pt8SqV4N9ykkAUXZN1Pi7Q4JnCUifRJVWpKHLoJe0mqwMDJbGtt2Akn3EwiGhyaVjq2FFgBKAb7w8UAE8gob8n4+DOx4TQAXlmWviYij2Xh6CvepbamxlJMvVdWgqk53+u4e+/oOQQ9QTmQvAuecg9dSO3m7+hNHEf+0TXjuTNlk9KHRg4s7ZAI+2Stfo1tBrvEeE2fAF//Mw7zaLPKmEbMiXdbDs816gvYtG6Y36fTGyzhowDQAMNm+zbg8YPz7xFukLdSCPt7RcpPnP1iJs/hGBnog5UaG/Cm4ftkm9zKvOaQKIoA/GQ3yQSyltczA+2h5fur6VQQGrQeVhAcXm9a6GaLPWxgvJX/og76CHps0rYzFM3QBlsiJ+Z0sstk5TtBex9nTjwRZ1U9+4DQes2TB4/uxnQ== SUAH CA"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCr/f87ARSgfYfjMpGHZuObStuh+8BPcQ/ByvJ/Lb+K04AaD2RzUfbTsXm3ZWqvt2uJARX8OSkV1DTWvOAQ/3gqDM981CBFqGMh2yMtptXUd1IL2h9qcfH2CIH1tka2QHdd2iK2xqHS3Z2jGE2klrMVKxr1bk2tJEzb6xK71lUjkGhwZ196Hb+8Fxs3RD0tmd78HF4p+nR2PD+lCba/TFPJyIu8MxmJsqZiv7uRKk4Nn+EZwbFahr2c6p/jmIPcFi3alm7YJ66I6hWHrXIVDR+PGgMlM1/eS/UfsI1m9fG7D/uOMezwCgqRt14aCYZYjziR6pTdIxIUr+JPRFXsuBN9H+2sfo2hzxpV7zOQ8JZYPVWNbCHxrRJvwRgdddjesyUM5my3zJAoNePNhFCfnUD9+t9mKev6aIgmjeIvMcKqHEwFRX/zn9k6fqXOUHZTEo4SMdTSUpeZOf7FWnIM3c0/LIuof+HitdMnjPC9bZ1SGkg9yN+OPO9HDVfxJUDTakhE1LSVaTUPxG0LZ1uaJt4ADz8cnW0EQsNEClYn07SqSp6K/yxKBg7BYgsc7n+sqTVAJDR0q/pmCl9I5JZHvylXsyHEBXyCn+EDtzvAVLulzDTJRIxpP3e1Zw6TPh1uKTgaPLpVqy4kI3D9GV6XCTa5pcoYN0E6iARCU5eQTE+0hQ== Bold::Daemon SSH CA"
  ];
  caPubKeyFile = pkgs.writeTextFile {
    name = "ssh-ca-pubkeys";
    text = caPubKeys;
  };
  managementKey =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDM2k2C6Ufx5RNf4qWA9BdQHJfAkskOaqEWf8yjpySwH Nix Manager";
  statusKey = ''
    command="/run/current-system/sw/bin/xin-status",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE9PIhQ+yWfBM2tEG+W8W8HXJXqISXif8BcPZHakKvLM xin-status
  '';
  gosignify = pkgs.callPackage ./pkgs/gosignify.nix { inherit isUnstable; };
  inFluxSSHOptions = if isUnstable then {
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
      KexAlgorithms = [ "curve25519-sha256" "curve25519-sha256@libssh.org" ];
      Macs = [
        "hmac-sha2-512-etm@openssh.com"
        "hmac-sha2-256-etm@openssh.com"
        "umac-128-etm@openssh.com"
      ];
    };
  } else {
    permitRootLogin = "prohibit-password";
    passwordAuthentication = false;
    kexAlgorithms = [ "curve25519-sha256" "curve25519-sha256@libssh.org" ];
    macs = [
      "hmac-sha2-512-etm@openssh.com"
      "hmac-sha2-256-etm@openssh.com"
      "umac-128-etm@openssh.com"
    ];
  };
in {
  imports = [
    ./configs
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

    nix = {
      settings = if config.networking.hostName != "pwntie" then {
        substituters = [ "https://nix-binary-cache.humpback-trout.ts.net/" ];
        trusted-public-keys = [
          "nix-binary-cache.humpback-trout.ts.net:e9fJhcRtNVp6miW2pffFyK/gZ2et4y6IDigBNrEsAa0="
        ];
      } else
        { };
    };

    environment.systemPackages = with pkgs;
      [
        age
        apg
        bind
        btop
        direnv
        git-bug
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
        agentTimeout = "100m";
        extraConfig = ''
          VerifyHostKeyDNS	yes
          AddKeysToAgent		confirm 90m
          CanonicalizeHostname	always

          Host *
            controlmaster         auto
            controlpath           /tmp/ssh-%r@%h:%p
        '';
      };
    };

    environment.etc."ssh/ca.pub" = { text = caPubKeys; };

    services = {
      openssh = {
        enable = true;
        knownHosts = {
          "*.bold.daemon,*.humpback-trout.ts.net,*.suah.dev" = {
            publicKeyFile = caPubKeyFile;
            certAuthority = true;
          };
        };
        extraConfig = ''
          #TrustedUserCAKeys = /etc/ssh/ca.pub
        '';
      } // inFluxSSHOptions;
    };
  };
}
