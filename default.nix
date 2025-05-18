{ config
, lib
, options
, pkgs
, isUnstable
, xinlib
, ...
}:
let
  inherit (builtins) readFile;
  inherit (xinlib) prIsOpen;
  caPubKeys = builtins.concatStringsSep "\n" [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC5xMSYMwu6rjjLe2UYs1YGCIBVs35E9db2qAjNltCVPG5UoctxCDXxIz0PMOJrBbfqZzP/6qPU1WAhdGNTZ5eXq/ftnhI+2xFfMg1uzpXZ9vjy8lUCfXIObtoEdZ9h/7OUCN/BnL0ySqsamkcUo8SAj6wXoNCdwk6oncfyTmhPnoW5tCWCS9p7Q/LuWpYGsvW5nFDSxteP7re6SUe10eftIkFAPNhKA2lsrvzMgjxhnXqwIr1qJeY0otcuYA4V5V09FmElbnOWVuy4Pt8SqV4N9ykkAUXZN1Pi7Q4JnCUifRJVWpKHLoJe0mqwMDJbGtt2Akn3EwiGhyaVjq2FFgBKAb7w8UAE8gob8n4+DOx4TQAXlmWviYij2Xh6CvepbamxlJMvVdWgqk53+u4e+/oOQQ9QTmQvAuecg9dSO3m7+hNHEf+0TXjuTNlk9KHRg4s7ZAI+2Stfo1tBrvEeE2fAF//Mw7zaLPKmEbMiXdbDs816gvYtG6Y36fTGyzhowDQAMNm+zbg8YPz7xFukLdSCPt7RcpPnP1iJs/hGBnog5UaG/Cm4ftkm9zKvOaQKIoA/GQ3yQSyltczA+2h5fur6VQQGrQeVhAcXm9a6GaLPWxgvJX/og76CHps0rYzFM3QBlsiJ+Z0sstk5TtBex9nTjwRZ1U9+4DQes2TB4/uxnQ== SUAH CA"
  ];
  breakGlassKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA6CO4aa8ymIgPgHRMwVLPnkUXwFQRKJa66R3wGXrAS0 BreakGlass";
  managementKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDM2k2C6Ufx5RNf4qWA9BdQHJfAkskOaqEWf8yjpySwH Nix Manager";
  gosignify = pkgs.callPackage ./pkgs/gosignify.nix { inherit isUnstable; };

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
    "services/misc/yarr.nix"
  ] ++ prIsOpen.list 399692 [
    "services/backup/restic-rest-server.nix"
  ];

  options = {
    syncthingDevices = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          id = lib.mkOption {
            type = lib.types.str;
            description = "Unique identifier for this item";
            example = "my-unique-id";
          };
        };
      });
      default = {
        box = {
          id = "P4PPRLS-3ZTXEKS-MWRM2J5-A6XI36L-TNVSZNE-RUIPMQE-TQJFVNK-2D4LRAB";
        };
        europa = {
          id = "X5COHAJ-6NGF6HB-YZZAKZ4-SJILL7F-4UYPC74-SIFTLFD-JKEG7DW-HEFHPQH";
        };
        graphy = {
          id = "AGSJRQ5-FYPP347-LM5RJK7-7SVCW24-SDXD33M-NEGMLMV-OGBMD4V-L5KP3Q7";
        };
        chunk = {
          id = "YNUY6S6-EEY4NUB-XIZA2MC-WXRNPQK-HZRTTPX-FSG2JLH-7WUA7P7-RDNQ7AV";
        };
        plq = {
          id = "RUTFVOM-IOER2YI-G5ZYORX-2VRWWPO-DGLT277-57MNPHD-OWS6LY5-TX4EKQ6";
        };
      };
    };
    myconf = {
      managementPubKeys = lib.mkOption rec {
        type = lib.types.listOf lib.types.str;
        default = [ managementKey breakGlassKey ];
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
  };

  config = {
    programs.xin = {
      enable = true;
      monitorKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE9PIhQ+yWfBM2tEG+W8W8HXJXqISXif8BcPZHakKvLM xin-status"
      ];
    };
    sops = {
      age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

      secrets =
        if config.needsDeploy.enable then {
          po_env = {
            sopsFile = config.xin-secrets.deploy;
            owner = "root";
            mode = "444";
          };
          xin_secrets_deploy_key = {
            sopsFile = config.xin-secrets.deploy;
            owner = "root";
            group = "wheel";
            mode = "400";
          };
        } else { };
    };


    security.pki.certificates = [
      (readFile ./bold.daemon.pem)
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
      settings = {
        trusted-public-keys = [
          "nix-binary-cache.otter-alligator.ts.net:XzgdqR79WNOzcvSHlgh4FDeFNUYR8U2m9dZGI7whuco="
          "store.bold.daemon:YE3+K/UOM49xzQoMMn+QdJYxsIDjRfT/114BP1ieLag="
        ];
      } //
      (if config.xinCI.enable
      then { }
      else {
        substituters = lib.mkOverride 2 [
          "https://cache.nixos.org"
          "https://nix-binary-cache.otter-alligator.ts.net/"
        ];
      });
    };

    system.nixos = {
      distroName = "XinOS";
    };

    nixpkgs.config = {
      allowUnfree = true;
      allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "rns"
      ];
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
          git-annex
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
          socat
          sshfs
          tcl
          tmux
          uxn
          rns
          python3Packages.nomadnet
          (python3Packages.callPackage ./pkgs/rnsh.nix { inherit pkgs; })
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
