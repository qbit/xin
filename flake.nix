{
  description = "xin";

  inputs = {
    unstable.url = "github:NixOS/nixpkgs";
    unstableSmall.url = "github:NixOS/nixpkgs/nixos-unstable-small";

    stable.url = "github:NixOS/nixpkgs/nixos-23.11-small";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs = {
        nixpkgs-stable.follows = "stable";
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
      url = "github:nix-community/emacs-overlay/64a633659fab447f12c898a32c451f88b5c3c048";
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
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-23.11";
      inputs = {
        nixpkgs.follows = "stable";
        nixpkgs-23_11.follows = "stable";
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
    xintray = {
      url = "github:qbit/xintray";
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
    tsRevProx = {
      url = "github:qbit/ts-reverse-proxy";
      inputs.nixpkgs.follows = "unstable";
    };
    traygent = {
      url = "github:qbit/traygent";
      inputs.nixpkgs.follows = "unstable";
    };

    gqrss = {
      url = "github:qbit/gqrss";
      flake = false;
    };

    peerix = {
      url = "github:cid-chan/peerix";
      inputs.nixpkgs.follows = "stable";
    };
  };

  outputs =
    { self
    , darwin
    , gostart
    , mcchunkie
    , kogs
    , peerix
    , po
    , pots
    , pr-status
    , stable
    , tsRevProx
    , traygent
    , tsvnstat
    , unstable
    , unstableSmall
    , xin-secrets
    , xintray
    , simple-nixos-mailserver
    , nixos-hardware
    , beyt
    , ...
    } @ inputs:
    let
      xinlib = import ./lib { inherit (unstable) lib; };
      supportedSystems = [ "x86_64-linux" ];
      #[ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = unstable.lib.genAttrs supportedSystems;
      unstablePkgsFor = forAllSystems (system:
        import unstable {
          inherit system;
          #imports = [ ./overlays ];
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

          xin-secrets.nixosModules.sops
          xin-secrets.nixosModules.xin-secrets

          peerix.nixosModules.peerix
        ];
      };

      overlays = [
        inputs.emacs-overlay.overlay
        inputs.gostart.overlay
        inputs.mcchunkie.overlay
        inputs.kogs.overlay
        inputs.microca.overlay
        inputs.peerix.overlay
        inputs.pots.overlay
        inputs.pr-status.overlay
        inputs.tsRevProx.overlay
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
          nixos-hardware.nixosModules.framework-11th-gen-intel
        ] "europa";
        clunk = buildSys "x86_64-linux" unstable [ ] "clunk";
        orcim = buildSys "x86_64-linux" unstable [ ] "orcim";
        pwntie = buildSys "x86_64-linux" stable [ ] "pwntie";
        stan = buildSys "x86_64-linux" unstable [
          nixos-hardware.nixosModules.framework-11th-gen-intel
        ] "stan";
        weather = buildSys "aarch64-linux" stable [ ] "weather";
        #octo = buildSys "aarch64-linux" stable [ ] "octo";

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

        #arm64Install = stable.lib.nixosSystem {
        #  system = "aarch64-linux";

        #  modules = [
        #    (import ./installer.nix)
        #    xin-secrets.nixosModules.sops

        #    "${stable}/nixos/modules/installer/sd-card/sd-image-aarch64-installer.nix"
        #  ];
        #};

        #weatherzero = buildSys "armv6l" stable [
        #  "${stable}/nixos/modules/installer/sd-card/sd-image-raspberrypi.nix"
        #  {
        #    nixpkgs = {
        #      buildPlatform = {
        #        system = "x86_64-linux";
        #        config = "x86_64-unknown-linux-gnu";
        #      };
        #      hostPlatform = {
        #        system = "armv6l-linux";
        #        config = "armv6l-unknown-linux-gnueabihf";
        #      };
        #    };
        #  }
        #] "weatherzero";

        #isoInstall = stable.lib.nixosSystem {
        #  system = "x86_64-linux";

        #  modules = [
        #    (xinlib.buildVer self)
        #    (import ./installer.nix)
        #    xin-secrets.nixosModules.sops

        #    "${stable}/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares-plasma5.nix"
        #  ];
        #};
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
          ttfs = upkgs.callPackage ./pkgs/ttfs.nix { };
          flake-warn =
            spkgs.callPackage ./pkgs/flake-warn.nix { inherit spkgs; };
          #kurinto = spkgs.callPackage ./pkgs/kurinto.nix {};
          gen-patches =
            spkgs.callPackage ./bins/gen-patches.nix { inherit spkgs; };
          yarr = spkgs.callPackage ./pkgs/yarr.nix {
            inherit spkgs;
            isUnstable = true;
          };
          precursorupdater = spkgs.python3Packages.callPackage ./pkgs/precursorupdater.nix {
            inherit spkgs;
          };
          rtlamr2mqtt = spkgs.python3Packages.callPackage ./pkgs/rtlamr2mqtt.nix {
            inherit spkgs;
          };
          openevse =
            upkgs.python312Packages.callPackage ./pkgs/openevse.nix { inherit upkgs; };
          sliding-sync =
            spkgs.callPackage ./pkgs/sliding-sync.nix { inherit spkgs; };
          gokrazy = upkgs.callPackage ./pkgs/gokrazy.nix { inherit upkgs; };
          gosignify = spkgs.callPackage ./pkgs/gosignify.nix { inherit spkgs; };
          gotosocial =
            spkgs.callPackage ./pkgs/gotosocial.nix { inherit spkgs; };
          zutty = upkgs.callPackage ./pkgs/zutty.nix {
            inherit upkgs;
          };
          inherit (xintray.packages.${system}) xintray;
          inherit (beyt.packages.${system}) beyt;
          inherit (tsvnstat.packages.${system}) tsvnstat;
          inherit (pots.packages.${system}) pots;
          inherit (po.packages.${system}) po;
          inherit (tsRevProx.packages.${system}) ts-reverse-proxy;
          inherit (traygent.packages.${system}) traygent;

          inherit (spkgs) matrix-synapse;
        });

      templates = {
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
          description = "Go template.";
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
          buildList = [ "europa" "stan" "h" "box" "faf" "weather" "clunk" "orcim" ];
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
