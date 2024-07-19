{ config
, lib
, options
, pkgs
, isUnstable
, ...
}:
let
  caPubKeys = builtins.concatStringsSep "\n" [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC5xMSYMwu6rjjLe2UYs1YGCIBVs35E9db2qAjNltCVPG5UoctxCDXxIz0PMOJrBbfqZzP/6qPU1WAhdGNTZ5eXq/ftnhI+2xFfMg1uzpXZ9vjy8lUCfXIObtoEdZ9h/7OUCN/BnL0ySqsamkcUo8SAj6wXoNCdwk6oncfyTmhPnoW5tCWCS9p7Q/LuWpYGsvW5nFDSxteP7re6SUe10eftIkFAPNhKA2lsrvzMgjxhnXqwIr1qJeY0otcuYA4V5V09FmElbnOWVuy4Pt8SqV4N9ykkAUXZN1Pi7Q4JnCUifRJVWpKHLoJe0mqwMDJbGtt2Akn3EwiGhyaVjq2FFgBKAb7w8UAE8gob8n4+DOx4TQAXlmWviYij2Xh6CvepbamxlJMvVdWgqk53+u4e+/oOQQ9QTmQvAuecg9dSO3m7+hNHEf+0TXjuTNlk9KHRg4s7ZAI+2Stfo1tBrvEeE2fAF//Mw7zaLPKmEbMiXdbDs816gvYtG6Y36fTGyzhowDQAMNm+zbg8YPz7xFukLdSCPt7RcpPnP1iJs/hGBnog5UaG/Cm4ftkm9zKvOaQKIoA/GQ3yQSyltczA+2h5fur6VQQGrQeVhAcXm9a6GaLPWxgvJX/og76CHps0rYzFM3QBlsiJ+Z0sstk5TtBex9nTjwRZ1U9+4DQes2TB4/uxnQ== SUAH CA"
  ];
  breakGlassKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA6CO4aa8ymIgPgHRMwVLPnkUXwFQRKJa66R3wGXrAS0 BreakGlass";
  managementKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDM2k2C6Ufx5RNf4qWA9BdQHJfAkskOaqEWf8yjpySwH Nix Manager";
  statusKey = ''
    command="/run/current-system/sw/bin/xin",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE9PIhQ+yWfBM2tEG+W8W8HXJXqISXif8BcPZHakKvLM xin-status
  '';
  gosignify = pkgs.callPackage ./pkgs/gosignify.nix { inherit isUnstable; };

  xin = pkgs.perlPackages.callPackage ./bins/xin { inherit pkgs; };
in
{
  imports = [
    ./configs
    ./dbuild
    ./gui
    ./modules
    ./overlays
    ./pkgs
    ./services
    ./users

    ./monitoring

    ./bins
  ];

  disabledModules = [
    "services/web-apps/gotosocial.nix"
  ];

  options.myconf = {
    managementPubKeys = lib.mkOption rec {
      type = lib.types.listOf lib.types.str;
      default = [ managementKey statusKey breakGlassKey ];
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
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBOyQpDBHjHb3tWnPO6QAjh6KzWYqpabzfjpuwfEUzmUiHpPiU+f4ejNgRFDf9p84SQDz3EXxUMsW/kJ1crAkwOg= surf"
      ];
      example = default;
      description = "List of hardware public keys to use";
    };
  };

  config = {
    sops = {
      age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

      secrets =
        if config.needsDeploy.enable then {
          xin_secrets_deploy_key = {
            sopsFile = config.xin-secrets.deploy;
            owner = "root";
            group = "wheel";
            mode = "400";
          };
        } else { };
    };


    security.pki.certificates = [
      ''
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
      ''
    ];

    i18n.defaultLocale = "en_US.utf8";

    users.motd = ''

                                            .-
                                     :      :=  .
                             ::      .=     --  +     -:    --
                              +.  =.  =-    -- :=    =:   .=:
                              :=  -=-: =.   -: =:  .=:   -=.   :-.
                     .:        -:  +.=--:   -.:-. :-:  :-:   :=:
                      :=: :.   .-: -- ==-.:-- ==-:::  ::.  :=-    .
                        =-.--   -+:----+=.-=::-==.---.:: :-:   .--.
           ..       :    :-:-=::-:*=-:=-=-.:--:-.:=--=++*+- .:-:.
            .--.    .=:  :.=:-+=-:-+=:-=-=-.:--=--==++=====++:...:::.
            .-===:.   --.-*++::----=+-:-=-:-----=+**++**++===+:::...
          .==-::=-:::. ==-=++-:-=-:::=--=-:===+##%*-...-***+==+:::..
        .==-:----++-:-::-=::=+--+=-:-==-:::::#@%@+       ***+-+#: ...
        ======----=**+::===:.-=-:==::::::::::*@%%        =%**+==+*-..
       :-:::--=---:=+===-:--..-=-.:::::::::::=@%%        =@#**+===
       :::--::----=-:::=+-::::=-::::::::::::::*@@+      :%%%%#***+..
       :::::------#=-:-=-===-::::::::::::::::::=*%*-..:+%%%%@%=.   :
       :-----------:::==----=----:::::::::::::::::------:---=+**+=+.
       .=+========+==--::::::::::::::::::::::::::-=-:::::::::::==#:
         :-:--====*=::----::::::::::::::::::::::-:.=-::::::::::::+.
          :+=----:.:::---:::::::::::::::::::::::-::-------------=+
      .::::......:-=+=--::::----::::::::::::::::--::::::::::::::-::.
              .::.  .+--===++=-::::::::::::::::::::::::::::::::. .-=.
                 .::-=+**++=-----:::::=-::::::::::::::::::::::::::.
            .::--::.  .---------=----=-:::::::::::::::::::::--.
            .          -:-------------:::::::::::::::::::::--
                       .=:::---------:::::::::::::::....:--.
                        :=-:::::---===::::...........::::
                          -========-:::::::::::::::::.
                            .....

    '';

    boot = {
      loader = { systemd-boot.configurationLimit = 15; };
      kernelPackages = lib.mkDefault pkgs.linuxPackages_hardened;
      kernel.sysctl = {
        "net.ipv4.tcp_keepalive_time" = 60;
        "net.ipv6.tcp_keepalive_time" = 60;
      };
      tmp.cleanOnBoot = true;
    };

    nix = {
      settings =
        if config.xinCI.enable
        then { }
        else {
          substituters = lib.mkForce [
            "https://cache.nixos.org"
            "https://nix-binary-cache.otter-alligator.ts.net/"
          ];
          trusted-public-keys = [
            "nix-binary-cache.otter-alligator.ts.net:XzgdqR79WNOzcvSHlgh4FDeFNUYR8U2m9dZGI7whuco="
            "nix-binary-cache.humpback-trout.ts.net:e9fJhcRtNVp6miW2pffFyK/gZ2et4y6IDigBNrEsAa0="
          ];
        };
    };

    environment = {
      etc = {
        "ssh/ca.pub" = { text = caPubKeys; };
        motd = { text = config.users.motd; };
      };

      systemPackages = with pkgs;
        [
          age
          apg
          bind
          btop
          direnv
          git-bug
          git-sync
          gosignify
          jq
          lz4
          minisign
          mosh
          nix-diff
          nix-index
          nix-output-monitor
          pass
          ripgrep
          sshfs
          tmux

          xin
        ]
        ++ (
          if isUnstable
          then [ nil ]
          else [ ]
        );

      interactiveShellInit = ''
        alias vi='emacsclient -ct'
      '';
    };

    time.timeZone = "US/Mountain";

    documentation.man.enable = true;

    networking.timeServers = options.networking.timeServers.default;

    programs = {
      zsh.enable = true;
      gnupg.agent.enable = true;
    };

    services = {
      smartd.enable = lib.mkDefault true;
    };
  };
}
