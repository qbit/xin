{
  description = "xin";

  inputs = {
    stable.url = "github:NixOS/nixpkgs/nixos-25.05-small";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable-small";

    lix = {
      url = "https://git.lix.systems/lix-project/lix/archive/main.tar.gz";
      flake = false;
    };

    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/main.tar.gz";
      inputs.nixpkgs.follows = "stable";
      inputs.lix.follows = "lix";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs = {
        nixpkgs.follows = "stable";
      };
    };

    xin-secrets = {
      url = "git+ssh://xin-secrets-ro/qbit/xin-secrets.git?ref=main";
      inputs = {
        sops-nix.follows = "sops-nix";
        stable.follows = "stable";
      };
    };

    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs = {
        nixpkgs-stable.follows = "stable";
      };
    };

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "stable";
    };

    simple-nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-25.05";
      inputs = {
        nixpkgs.follows = "stable";
      };
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
    };

    mcchunkie = {
      url = "git+https://codeberg.org/qbit/mcchunkie?ref=main";
      inputs.nixpkgs.follows = "stable";
    };
    microca = {
      url = "git+https://codeberg.org/qbit/microca";
      inputs.nixpkgs.follows = "stable";
    };
    gostart = {
      url = "git+https://codeberg.org/qbit/gostart";
      inputs.nixpkgs.follows = "unstable";
    };
    kogs = {
      url = "git+https://codeberg.org/qbit/kogs";
      inputs.nixpkgs.follows = "stable";
    };
    pr-status = {
      url = "git+https://codeberg.org/qbit/pr-status-pl";
      inputs.nixpkgs.follows = "stable";
    };
    xin-status = {
      url = "git+https://codeberg.org/qbit/xin-status";
      inputs.nixpkgs.follows = "stable";
    };
    beyt = {
      url = "git+https://codeberg.org/qbit/beyt";
      inputs.nixpkgs.follows = "stable";
    };
    tsvnstat = {
      url = "git+https://codeberg.org/qbit/tsvnstat";
      inputs.nixpkgs.follows = "unstable";
    };
    pots = {
      url = "git+https://codeberg.org/qbit/pots";
      inputs.nixpkgs.follows = "stable";
    };
    po = {
      url = "git+https://codeberg.org/qbit/po";
      inputs.nixpkgs.follows = "stable";
    };
    tsns = {
      url = "git+https://codeberg.org/qbit/tsns";
      inputs.nixpkgs.follows = "stable";
    };
    ts-reverse-proxy = {
      url = "git+https://codeberg.org/qbit/ts-reverse-proxy";
      inputs.nixpkgs.follows = "unstable";
    };
    traygent = {
      url = "git+https://codeberg.org/qbit/traygent";
      inputs.nixpkgs.follows = "stable";
    };
    fynado = {
      url = "git+https://codeberg.org/qbit/fynado";
      inputs.nixpkgs.follows = "stable";
    };
    calnow = {
      url = "git+https://codeberg.org/qbit/calnow";
      inputs.nixpkgs.follows = "stable";
    };
    gqrss = {
      url = "git+https://codeberg.org/qbit/gqrss";
      flake = false;
    };
  };

  outputs =
    {
      self,
      beyt,
      calnow,
      darwin,
      emacs-overlay,
      gostart,
      kogs,
      lix-module,
      mcchunkie,
      microca,
      nixos-hardware,
      po,
      pots,
      pr-status,
      simple-nixos-mailserver,
      traygent,
      fynado,
      ts-reverse-proxy,
      tsns,
      tsvnstat,
      stable,
      unstable,
      xin-secrets,
      xin-status,
      ...
    }@inputs:
    let
      xinlib = import ./lib {
        inherit (stable) lib;
        inherit inputs;
      };
      supportedSystems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];
      #[ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = stable.lib.genAttrs supportedSystems;
      stablePkgsFor = forAllSystems (
        system:
        import stable {
          inherit system;
        }
      );
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

      buildSys =
        sys: sysBase: extraMods: name:
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
            ++ [
              (xinlib.buildVer self)
              (./. + "/hosts/${name}")
            ]
            ++ [ { nixpkgs.overlays = overlays; } ];
        };
      lpkgs = unstable.legacyPackages.x86_64-linux;
      darwinPkgs = stable.legacyPackages.aarch64-darwin;
    in
    {
      darwinConfigurations = {
        plq = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = {
            inherit xinlib;
            inherit inputs;
          };
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
              inherit xinlib;
            };
            unstableList = overlayFn {
              inherit xinlib;
            };
          in
          stableList.nixpkgs.overlays ++ unstableList.nixpkgs.overlays;
      };

      formatter.x86_64-linux = stable.legacyPackages.x86_64-linux.nixfmt-rfc-style;
      formatter.aarch64-darwin = stable.legacyPackages.aarch64-darwin.nixfmt-rfc-style;

      devShells.x86_64-linux.default = xinlib.buildShell lpkgs;
      devShells.aarch64-darwin.default = xinlib.buildShell darwinPkgs;

      nixosConfigurations = {
        europa = buildSys "x86_64-linux" unstable [
          nixos-hardware.nixosModules.framework-13-7040-amd
        ] "europa";
        slab = buildSys "x86_64-linux" stable [
          nixos-hardware.nixosModules.microsoft-surface-pro-intel
        ] "slab";
        clunk = buildSys "x86_64-linux" unstable [ ] "clunk";
        orcim = buildSys "x86_64-linux" unstable [ ] "orcim";
        pwntie = buildSys "x86_64-linux" stable [ ] "pwntie";
        stan = buildSys "x86_64-linux" unstable [
          nixos-hardware.nixosModules.framework-11th-gen-intel
        ] "stan";
        #weather = buildSys "aarch64-linux" stable [ ] "weather";
        #retic = buildSys "aarch64-linux" stable [ ] "retic";

        faf = buildSys "x86_64-linux" stable [ ./configs/hardened.nix ] "faf";
        box = buildSys "x86_64-linux" stable [ ./configs/hardened.nix ] "box";
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
            (import ./installer.nix)
            xin-secrets.nixosModules.sops

            "${stable}/nixos/modules/installer/sd-card/sd-image-aarch64-installer.nix"
          ];
        };

        isoInstall = stable.lib.nixosSystem {
          system = "x86_64-linux";

          modules = [
            (xinlib.buildVer self)
            (import ./installer.nix)
            xin-secrets.nixosModules.sops

            "${stable}/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares-plasma6.nix"
          ];
        };
      };

      packages = forAllSystems (
        system:
        let
          pkgs = stablePkgsFor.${system};
        in
        {
          gqrss = pkgs.callPackage ./pkgs/gqrss.nix {
            inherit pkgs;
          };
          icbirc = pkgs.callPackage ./pkgs/icbirc.nix {
            inherit pkgs;
          };
          irken = pkgs.tclPackages.callPackage ./pkgs/irken.nix { };
          krha = pkgs.callPackage ./pkgs/krunner-krha.nix { };
          ttfs = pkgs.callPackage ./pkgs/ttfs.nix { };
          intiface-engine = pkgs.callPackage ./pkgs/intiface-engine.nix { };
          flake-warn = pkgs.callPackage ./pkgs/flake-warn.nix { inherit pkgs; };
          gen-patches = pkgs.callPackage ./bins/gen-patches.nix { inherit pkgs; };
          yarr = pkgs.callPackage ./pkgs/yarr.nix {
            inherit pkgs;
          };
          precursorupdater = pkgs.python3Packages.callPackage ./pkgs/precursorupdater.nix {
            inherit pkgs;
          };
          watchmap = pkgs.python3Packages.callPackage ./pkgs/watchmap.nix {
            inherit pkgs;
          };
          ble-serial = pkgs.python3Packages.callPackage ./pkgs/ble-serial.nix { inherit pkgs; };
          pywebscrapbook = pkgs.python3Packages.callPackage ./pkgs/pywebscrapbook.nix {
            inherit pkgs;
          };
          vcardtools = pkgs.python3Packages.callPackage ./pkgs/vcardtools.nix { inherit pkgs; };
          # lxst = pkgs.python3Packages.callPackage ./pkgs/lxst.nix {
          # inherit pkgs;
          # };
          # rnsh = pkgs.python3Packages.callPackage ./pkgs/rnsh.nix {
          # inherit pkgs;
          # };
          obsidian-to-org = pkgs.python3Packages.callPackage ./pkgs/obsidian-to-org.nix {
            inherit pkgs;
          };
          gokrazy = pkgs.callPackage ./pkgs/gokrazy.nix { inherit pkgs; };
          blurp = pkgs.callPackage ./pkgs/blurp.nix { inherit pkgs; };
          gosignify = pkgs.callPackage ./pkgs/gosignify.nix { inherit pkgs; };
          zutty = pkgs.callPackage ./pkgs/zutty.nix {
            inherit pkgs;
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
          openssh = pkgs.pkgsMusl.callPackage ./pkgs/openssh.nix { inherit pkgs; };
        }
      );

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
          buildList = [
            "pwntie"
            "box"
            "europa"
            "h"
            "stan"
          ];
        in
        with unstable.lib;
        foldl' recursiveUpdate { } (
          mapAttrsToList (name: system: {
            "${system.pkgs.stdenv.hostPlatform.system}"."${name}" = system.config.system.build.toplevel;
          }) (filterAttrs (n: _: (builtins.elem n buildList)) self.nixosConfigurations)
        );
    };
}
