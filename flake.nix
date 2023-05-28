{
  description = "bold.daemon";

  inputs = {
    unstable.url = "github:NixOS/nixpkgs";
    unstableSmall.url = "github:NixOS/nixpkgs/nixos-unstable-small";

    #stable.url = "github:NixOS/nixpkgs/nixos-22.11-small";
    stable.url = "github:NixOS/nixpkgs/nixos-23.05-small";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs-stable.follows = "stable";
      inputs.nixpkgs.follows = "unstable";
    };

    xin-secrets = {
      url = "git+ssh://xin-secrets-ro/qbit/xin-secrets.git?ref=main";
      inputs.sops-nix.follows = "sops-nix";
    };

    nixos-hardware = { url = "github:NixOS/nixos-hardware/master"; };

    emacs-overlay = {
      url =
        "github:nix-community/emacs-overlay/d54a1521619daa37c9aa8c9e3362abb34e676007";
      inputs.nixpkgs.follows = "stable";
    };

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "unstableSmall";
    };

    microca = {
      url = "github:qbit/microca";
      inputs.nixpkgs.follows = "unstable";
    };
    gostart = {
      url = "github:qbit/gostart";
      inputs.nixpkgs.follows = "unstable";
    };
    pr-status = {
      url = "github:qbit/pr-status-pl";
      inputs.nixpkgs.follows = "stable";
    };
    taskobs = {
      url = "github:qbit/taskobs";
      inputs.nixpkgs.follows = "unstable";
    };
    xintray = {
      url = "github:qbit/xintray";
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

    gqrss = {
      url = "github:qbit/gqrss";
      flake = false;
    };

    peerix = {
      url = "github:cid-chan/peerix";
      inputs.nixpkgs.follows = "stable";
    };

    talon = {
      url = "github:qbit/talon-nix";
      inputs.nixpkgs.follows = "unstable";
    };
  };

  outputs = { self, darwin, gostart, nixos-hardware, peerix, po, pots, pr-status
    , stable, talon, tsRevProx, tsvnstat, unstable, unstableSmall, xin-secrets
    , xintray, ... }@inputs:
    let
      xinlib = import ./lib { inherit (unstable) lib; };
      supportedSystems = [ "x86_64-linux" ];
      #[ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = unstable.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import unstable { inherit system; });
      hostBase = {
        modules = [
          # Common config stuffs
          (import (./default.nix))

          xin-secrets.nixosModules.sops
          xin-secrets.nixosModules.xin-secrets

          peerix.nixosModules.peerix
        ];
      };

      overlays = [
        inputs.emacs-overlay.overlay
        inputs.gostart.overlay
        inputs.microca.overlay
        inputs.peerix.overlay
        inputs.pots.overlay
        inputs.pr-status.overlay
        inputs.talon.overlays.default
        inputs.taskobs.overlay
        inputs.tsRevProx.overlay
      ];

      buildSys = sys: sysBase: extraMods: name:
        sysBase.lib.nixosSystem {
          system = sys;
          specialArgs = {
            inherit inputs;
            inherit xinlib;
          };
          modules = hostBase.modules ++ extraMods ++ [{
            nix = {
              registry.nixpkgs.flake = sysBase;
              registry.stable.flake = stable;
              registry.unstable.flake = unstable;
              nixPath = [ "nixpkgs=${sysBase}" ];
            };
          }] ++ [ (xinlib.buildVer self) (./. + "/hosts/${name}") ]
            ++ [{ nixpkgs.overlays = overlays; }];
        };
      pkgs = unstable.legacyPackages.x86_64-linux;
      darwinPkgs = unstableSmall.legacyPackages.aarch64-darwin;
    in {
      darwinConfigurations = {
        plq = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = { inherit xinlib; };
          modules = [
            xin-secrets.nixosModules.sops
            ./overlays

            ./hosts/plq
          ];
        };
      };

      formatter.x86_64-linux = stable.legacyPackages.x86_64-linux.nixfmt;
      formatter.aarch64-darwin = stable.legacyPackages.aarch64-darwin.nixfmt;

      devShells.x86_64-linux.default = xinlib.buildShell pkgs;
      devShells.aarch64-darwin.default = xinlib.buildShell darwinPkgs;

      nixosConfigurations = {
        europa = buildSys "x86_64-linux" unstable [
          nixos-hardware.nixosModules.framework
          talon.nixosModules.talon
        ] "europa";
        pwntie = buildSys "x86_64-linux" unstable [ ] "pwntie";
        stan = buildSys "x86_64-linux" unstable [ ] "stan";
        #weather = buildSys "aarch64-linux" stable
        #  [ nixos-hardware.nixosModules.raspberry-pi-4 ] "weather";

        faf = buildSys "x86_64-linux" stable [ ./configs/hardened.nix ] "faf";
        box = buildSys "x86_64-linux" stable [ ./configs/hardened.nix ] "box";
        #luna = buildSys "x86_64-linux" stable
        #  [ "${nixos-hardware}/common/cpu/intel" ] "luna";
        h = buildSys "x86_64-linux" stable [
          ./configs/hardened.nix
          gostart.nixosModule
          pots.nixosModule
          pr-status.nixosModule
        ] "h";
        #router =
        #  buildSys "x86_64-linux" stable [ ./configs/hardened.nix ] "router";

        weatherInstall = stable.lib.nixosSystem {
          system = "aarch64-linux";

          modules = [
            (import (./installer.nix))
            xin-secrets.nixosModules.sops

            "${stable}/nixos/modules/installer/sd-card/sd-image-aarch64-installer.nix"
          ];
        };

        isoInstall = stable.lib.nixosSystem {
          system = "x86_64-linux";

          modules = [
            (xinlib.buildVer self)
            (import (./installer.nix))
            xin-secrets.nixosModules.sops

            "${stable}/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares-plasma5.nix"
          ];
        };
      };

      packages = forAllSystems (system:
        let pkgs = nixpkgsFor.${system};
        in {
          ada_language_server =
            pkgs.callPackage ./pkgs/ada_language_server.nix { inherit pkgs; };
          alire = pkgs.callPackage ./pkgs/alire.nix { inherit pkgs; };
          bearclaw = pkgs.callPackage ./pkgs/bearclaw.nix { inherit pkgs; };
          gqrss = pkgs.callPackage ./pkgs/gqrss.nix {
            inherit pkgs;
            isUnstable = true;
          };
          iamb = pkgs.callPackage ./pkgs/iamb.nix { };
          icbirc = pkgs.callPackage ./pkgs/icbirc.nix {
            inherit pkgs;
            isUnstable = true;
          };
          femtolisp = pkgs.callPackage ./pkgs/femtolisp.nix { };
          flake-warn = pkgs.callPackage ./pkgs/flake-warn.nix { inherit pkgs; };
          kurinto = pkgs.callPackage ./pkgs/kurinto.nix { };
          mcchunkie = pkgs.callPackage ./pkgs/mcchunkie.nix { inherit pkgs; };
          yaegi = pkgs.callPackage ./pkgs/yaegi.nix { inherit pkgs; };
          yarr = pkgs.callPackage ./pkgs/yarr.nix {
            inherit pkgs;
            isUnstable = true;
          };
          precursorupdater =
            pkgs.python3Packages.callPackage ./pkgs/precursorupdater.nix {
              inherit pkgs;
            };
          kobuddy = pkgs.python3Packages.callPackage ./pkgs/kobuddy.nix {
            inherit pkgs;
          };
          ghexport = pkgs.python3Packages.callPackage ./pkgs/ghexport.nix {
            inherit pkgs;
          };
          hpi =
            pkgs.python3Packages.callPackage ./pkgs/hpi.nix { inherit pkgs; };
          promnesia = pkgs.python3Packages.callPackage ./pkgs/promnesia.nix {
            inherit pkgs;
          };
          sliding-sync =
            pkgs.callPackage ./pkgs/sliding-sync.nix { inherit pkgs; };
          tailscaleSystray =
            pkgs.callPackage ./pkgs/tailscale-systray.nix { inherit pkgs; };
          golink = pkgs.callPackage ./pkgs/golink.nix { inherit pkgs; };
          gokrazy = pkgs.callPackage ./pkgs/gokrazy.nix { inherit pkgs; };
          gosignify = pkgs.callPackage ./pkgs/gosignify.nix { inherit pkgs; };
          gotosocial = pkgs.callPackage ./pkgs/gotosocial.nix { inherit pkgs; };
          govulncheck =
            pkgs.callPackage ./pkgs/govulncheck.nix { inherit pkgs; };
          zutty = pkgs.callPackage ./pkgs/zutty.nix {
            inherit pkgs;
            isUnstable = true;
          };
          inherit (xintray.packages.${system}) xintray;
          inherit (tsvnstat.packages.${system}) tsvnstat;
          inherit (pots.packages.${system}) pots;
          inherit (po.packages.${system}) po;
          inherit (tsRevProx.packages.${system}) ts-reverse-proxy;
        });

      templates."ada" = {
        path = ./templates/ada;
        description = "Ada template.";
      };
      templates."go" = {
        path = ./templates/go;
        description = "Go template.";
      };
      templates."perl" = {
        path = ./templates/perl;
        description = "Perl template.";
      };
      templates."mojo" = {
        path = ./templates/mojo;
        description = "Perl MojoLicious template.";
      };
      templates."ocaml" = {
        path = ./templates/ocaml;
        description = "OCaml template.";
      };

      checks = let buildList = [ "europa" "stan" "h" "box" "faf" ];
      in with unstable.lib;
      foldl' recursiveUpdate { } (mapAttrsToList (name: system: {
        "${system.pkgs.stdenv.hostPlatform.system}"."${name}" =
          system.config.system.build.toplevel;
      }) (filterAttrs (n: _: (builtins.elem n buildList))
        self.nixosConfigurations));
    };
}
