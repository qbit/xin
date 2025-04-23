{
  description = "xin";

  inputs = {
    unstable.url = "github:NixOS/nixpkgs";
    unstableSmall.url = "github:NixOS/nixpkgs/nixos-unstable-small";

    stable.url = "github:NixOS/nixpkgs/nixos-24.11-small";

    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.92.0-3.tar.gz";
      inputs.nixpkgs.follows = "unstable";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs = {
        nixpkgs.follows = "unstable";
      };
    };

    xin-secrets = {
      url = "git+ssh://xin-secrets-ro/qbit/xin-secrets.git?ref=main";
      inputs = {
        sops-nix.follows = "sops-nix";
        stable.follows = "stable";
        unstable.follows = "unstable";
      };
    };

    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs = {
        nixpkgs.follows = "unstable";
        nixpkgs-stable.follows = "stable";
      };
    };

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "unstableSmall";
    };

    simple-nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-24.11";
      inputs = {
        nixpkgs.follows = "stable";
      };
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    mcchunkie = {
      url = "github:qbit/mcchunkie";
      inputs.nixpkgs.follows = "unstable";
    };
    microca = {
      url = "github:qbit/microca";
      inputs.nixpkgs.follows = "unstable";
    };
    gostart = {
      url = "github:qbit/gostart";
      inputs.nixpkgs.follows = "unstable";
    };
    kogs = {
      url = "github:qbit/kogs";
      inputs.nixpkgs.follows = "unstable";
    };
    pr-status = {
      url = "github:qbit/pr-status-pl";
      inputs.nixpkgs.follows = "stable";
    };
    xin-status = {
      url = "github:qbit/xin-status";
      inputs.nixpkgs.follows = "unstable";
    };
    beyt = {
      url = "github:qbit/beyt";
      inputs.nixpkgs.follows = "unstable";
    };
    tsvnstat = {
      url = "github:qbit/tsvnstat";
      inputs.nixpkgs.follows = "unstable";
    };
    pots = {
      url = "github:qbit/pots";
      inputs.nixpkgs.follows = "unstable";
    };
    po = {
      url = "github:qbit/po";
      inputs.nixpkgs.follows = "unstable";
    };
    tsns = {
      url = "github:qbit/tsns";
      inputs.nixpkgs.follows = "unstable";
    };
    ts-reverse-proxy = {
      url = "github:qbit/ts-reverse-proxy";
      inputs.nixpkgs.follows = "unstable";
    };
    traygent = {
      url = "github:qbit/traygent";
      inputs.nixpkgs.follows = "unstable";
    };
    fynado = {
      url = "github:qbit/fynado";
      inputs.nixpkgs.follows = "unstable";
    };
    calnow = {
      url = "github:qbit/calnow";
      inputs.nixpkgs.follows = "unstable";
    };
    gqrss = {
      url = "github:qbit/gqrss";
      flake = false;
    };
  };

  outputs =
    { self
    , beyt
    , calnow
    , darwin
    , emacs-overlay
    , gostart
    , kogs
    , lix-module
    , mcchunkie
    , microca
    , nixos-hardware
    , po
    , pots
    , pr-status
    , simple-nixos-mailserver
    , stable
    , traygent
    , fynado
    , ts-reverse-proxy
    , tsns
    , tsvnstat
    , unstable
    , unstableSmall
    , xin-secrets
    , xin-status
    , ...
    } @ inputs:
    let
      xinlib = import ./lib {
        inherit (unstable) lib;
        inherit inputs;
      };
      supportedSystems = [ "x86_64-linux" "aarch64-darwin" ];
      #[ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = unstable.lib.genAttrs supportedSystems;
      unstablePkgsFor = forAllSystems (system:
        import unstable {
          inherit system;
        });
      stablePkgsFor = forAllSystems (system:
        import stable {
          inherit system;
          #imports = [ ./overlays ];
        });
      hostBase = {
        modules = [
          # Common config stuffs
          (import ./default.nix)

          xin-status.nixosModules.default
          xin-secrets.nixosModules.sops
          xin-secrets.nixosModules.xin-secrets
          lix-module.nixosModules.default
          ts-reverse-proxy.nixosModule
          tsns.nixosModule
        ];
      };

      overlays = [
        emacs-overlay.overlay
        gostart.overlay
        kogs.overlay
        mcchunkie.overlay
        microca.overlay
        pots.overlay
        pr-status.overlay
        ts-reverse-proxy.overlay
        tsns.overlay
        xin-status.overlays.default
      ];

      buildSys = sys: sysBase: extraMods: name:
        sysBase.lib.nixosSystem {
          system = sys;
          specialArgs = {
            inherit inputs;
            inherit xinlib;
          };
          modules =
            hostBase.modules
            ++ extraMods
            ++ [
              {
                nix = {
                  registry = {
                    nixpkgs.flake = sysBase;
                    stable.flake = stable;
                    unstable.flake = unstable;
                  };
                  nixPath = [ "nixpkgs=${sysBase}" ];
                };
              }
            ]
            ++ [ (xinlib.buildVer self) (./. + "/hosts/${name}") ]
            ++ [{ nixpkgs.overlays = overlays; }];
        };
      lpkgs = unstable.legacyPackages.x86_64-linux;
      darwinPkgs = unstableSmall.legacyPackages.aarch64-darwin;
    in
    {
      darwinConfigurations = {
        plq = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = { inherit xinlib; };
          modules = [
            ./overlays
            lix-module.nixosModules.default

            ./hosts/plq
          ];
        };
      };

      # Expose all of the overlays to unstable so we can test build
      # everything before deploying
      legacyPackages.x86_64-linux = import unstable {
        system = "x86_64-linux";
        overlays =
          let
            overlayFn = import ./overlays;
            stableList = overlayFn {
              isUnstable = true;
              inherit xinlib;
            };
            unstableList = overlayFn {
              isUnstable = false;
              inherit xinlib;
            };
          in
          stableList.nixpkgs.overlays ++ unstableList.nixpkgs.overlays;
      };

      formatter.x86_64-linux = stable.legacyPackages.x86_64-linux.nixpkgs-fmt;
      formatter.aarch64-darwin = stable.legacyPackages.aarch64-darwin.nixpkgs-fmt;

      devShells.x86_64-linux.default = xinlib.buildShell lpkgs;
      devShells.aarch64-darwin.default = xinlib.buildShell darwinPkgs;

      nixosConfigurations = {
        europa = buildSys "x86_64-linux" unstable [
          nixos-hardware.nixosModules.framework-13-7040-amd
        ] "europa";
        clunk = buildSys "x86_64-linux" unstable [ ] "clunk";
        tv = buildSys "x86_64-linux" stable [
          nixos-hardware.nixosModules.framework-11th-gen-intel
        ] "tv";
        orcim = buildSys "x86_64-linux" unstable [ ] "orcim";
        pwntie = buildSys "x86_64-linux" stable [ ] "pwntie";
        stan = buildSys "x86_64-linux" unstable [
          nixos-hardware.nixosModules.framework-11th-gen-intel
        ] "stan";
        #weather = buildSys "aarch64-linux" stable [ ] "weather";
        #retic = buildSys "aarch64-linux" stable [ ] "retic";

        faf = buildSys "x86_64-linux" stable [ ./configs/hardened.nix ] "faf";
        box = buildSys "x86_64-linux" unstable [ ./configs/hardened.nix ] "box";
        h = buildSys "x86_64-linux" stable [
          ./configs/hardened.nix
          gostart.nixosModule
          mcchunkie.nixosModule
          kogs.nixosModule
          pots.nixosModule
          pr-status.nixosModule
          simple-nixos-mailserver.nixosModule
        ] "h";
        #router =
        #  buildSys "x86_64-linux" stable [ ./configs/hardened.nix ] "router";

        arm64Install = stable.lib.nixosSystem {
          system = "aarch64-linux";

          modules = [
            {
              _module.args.isUnstable = false;
            }

            (import ./installer.nix)
            xin-secrets.nixosModules.sops

            "${stable}/nixos/modules/installer/sd-card/sd-image-aarch64-installer.nix"
          ];
        };

        isoInstall = stable.lib.nixosSystem {
          system = "x86_64-linux";

          modules = [
            {
              _module.args.isUnstable = false;
            }
            (xinlib.buildVer self)
            (import ./installer.nix)
            xin-secrets.nixosModules.sops

            "${stable}/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares-plasma5.nix"
          ];
        };
      };

      packages = forAllSystems (system:
        let
          upkgs = unstablePkgsFor.${system};
          spkgs = stablePkgsFor.${system};
        in
        {
          rtlamr = spkgs.callPackage ./pkgs/rtlamr.nix { inherit spkgs; };
          gqrss = spkgs.callPackage ./pkgs/gqrss.nix {
            inherit spkgs;
            isUnstable = true;
          };
          icbirc = spkgs.callPackage ./pkgs/icbirc.nix {
            inherit spkgs;
            isUnstable = true;
          };
          irken = upkgs.tclPackages.callPackage ./pkgs/irken.nix { };
          krha = upkgs.callPackage ./pkgs/krunner-krha.nix { };
          ttfs = upkgs.callPackage ./pkgs/ttfs.nix { };
          intiface-engine = upkgs.callPackage ./pkgs/intiface-engine.nix { };
          flake-warn =
            spkgs.callPackage ./pkgs/flake-warn.nix { inherit spkgs; };
          gen-patches =
            spkgs.callPackage ./bins/gen-patches.nix { inherit spkgs; };
          yarr = spkgs.callPackage ./pkgs/yarr.nix {
            inherit spkgs;
            isUnstable = true;
          };
          precursorupdater = spkgs.python3Packages.callPackage ./pkgs/precursorupdater.nix {
            inherit spkgs;
          };
          watchmap = spkgs.python3Packages.callPackage ./pkgs/watchmap.nix {
            inherit spkgs;
          };
          rtlamr2mqtt = spkgs.python3Packages.callPackage ./pkgs/rtlamr2mqtt.nix {
            inherit spkgs;
          };
          kobuddy = upkgs.python3Packages.callPackage ./pkgs/kobuddy.nix {
            inherit upkgs;
          };
          ghexport = upkgs.python3Packages.callPackage ./pkgs/ghexport.nix {
            inherit upkgs;
          };
          hpi =
            upkgs.python3Packages.callPackage ./pkgs/hpi.nix { inherit upkgs; };
          openevse =
            upkgs.python3Packages.callPackage ./pkgs/openevse.nix { inherit upkgs; };
          ble-serial =
            upkgs.python3Packages.callPackage ./pkgs/ble-serial.nix { inherit upkgs; };
          promnesia = upkgs.python3Packages.callPackage ./pkgs/promnesia.nix {
            inherit upkgs;
          };
          pywebscrapbook = upkgs.python3Packages.callPackage ./pkgs/pywebscrapbook.nix {
            inherit upkgs;
          };
          lxst = upkgs.python3Packages.callPackage ./pkgs/lxst.nix {
            inherit upkgs;
          };
          rnsh = upkgs.python3Packages.callPackage ./pkgs/rnsh.nix {
            inherit upkgs;
          };
          gokrazy = upkgs.callPackage ./pkgs/gokrazy.nix { inherit upkgs; };
          gosignify = spkgs.callPackage ./pkgs/gosignify.nix { inherit spkgs; };
          zutty = upkgs.callPackage ./pkgs/zutty.nix {
            inherit upkgs;
          };
          mvoice = upkgs.callPackage ./pkgs/mvoice.nix {
            inherit upkgs;
          };
          inherit (beyt.packages.${system}) beyt;
          inherit (tsvnstat.packages.${system}) tsvnstat;
          inherit (pots.packages.${system}) pots;
          inherit (po.packages.${system}) po;
          inherit (ts-reverse-proxy.packages.${system}) ts-reverse-proxy;
          inherit (tsns.packages.${system}) tsns;
          inherit (traygent.packages.${system}) traygent;
          inherit (fynado.packages.${system}) fynado;
          inherit (calnow.packages.${system}) calnow;

          inherit (spkgs) matrix-synapse;

          openssh = upkgs.pkgsMusl.callPackage ./pkgs/openssh.nix { inherit upkgs; };
          matrix = self.nixosConfigurations.h.pkgs.matrix-synapse;
        });

      templates = {
        "shell" = {
          path = ./templates/shell;
          description = "A bare bones shell template.";
        };
        "ada" = {
          path = ./templates/ada;
          description = "Ada template.";
        };
        "go" = {
          path = ./templates/go;
          description = "Go template.";
        };
        "go-fyne" = {
          path = ./templates/go-fyne;
          description = "Go + fyne template.";
        };
        "go-fyne-shell" = {
          path = ./templates/go-fyne;
          description = "Go + fyne template for shell usage.";
        };
        "perl" = {
          path = ./templates/perl;
          description = "Perl template.";
        };
        "mojo" = {
          path = ./templates/mojo;
          description = "Perl MojoLicious template.";
        };
        "ocaml" = {
          path = ./templates/ocaml;
          description = "OCaml template.";
        };
      };

      checks =
        let
          buildList = [ "europa" "stan" "h" "box" "orcim" "tv" ];
        in
        with unstable.lib;
        foldl' recursiveUpdate { } (mapAttrsToList
          (name: system: {
            "${system.pkgs.stdenv.hostPlatform.system}"."${name}" =
              system.config.system.build.toplevel;
          })
          (filterAttrs (n: _: (builtins.elem n buildList))
            self.nixosConfigurations));
    };
}
