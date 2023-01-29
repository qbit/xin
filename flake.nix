{
  description = "bold.daemon";

  inputs = {
    unstable.url = "github:NixOS/nixpkgs";
    unstableSmall.url = "github:NixOS/nixpkgs/nixos-unstable-small";

    oldStable.url = "github:NixOS/nixpkgs/nixos-22.05-small";
    stable.url = "github:NixOS/nixpkgs/nixos-22.11-small";

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
    reform = { url = "github:nix-community/hardware-mnt-reform"; };

    emacs-overlay = {
      url =
        "github:nix-community/emacs-overlay/d54a1521619daa37c9aa8c9e3362abb34e676007";
      inputs.nixpkgs.follows = "stable";
    };

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "unstableSmall";
    };

    sshKnownHosts = {
      url = "github:qbit/ssh_known_hosts";
      flake = false;
    };

    microca = {
      url = "github:qbit/microca";
      inputs.nixpkgs.follows = "unstable";
    };
    gostart = {
      url = "github:qbit/gostart";
      inputs.nixpkgs.follows = "unstable";
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

    mcchunkie = {
      url = "github:qbit/mcchunkie";
      flake = false;
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

  outputs = { self, unstable, unstableSmall, stable, oldStable, nixos-hardware
    , reform, sshKnownHosts, microca, gostart, xintray, tsvnstat, pots, po
    , taskobs, mcchunkie, gqrss, darwin, xin-secrets, talon, peerix, ...
    }@inputs:
    let
      supportedSystems = [ "x86_64-linux" ];
      #[ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = unstable.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import unstable { inherit system; });
      hostBase = {
        modules = [
          # Common config stuffs
          (import (./default.nix))
          (import "${sshKnownHosts}")

          xin-secrets.nixosModules.sops
          xin-secrets.nixosModules.xin-secrets

          peerix.nixosModules.peerix
        ];
      };

      overlays = [
        inputs.emacs-overlay.overlay
        inputs.peerix.overlay
        inputs.microca.overlay
        inputs.taskobs.overlay
        inputs.reform.overlay
        inputs.gostart.overlay
        inputs.pots.overlay
        inputs.talon.overlays.default
      ];

      # Set our configurationRevison based on the status of our git repo.
      # If the repo is dirty, disable autoUpgrade as it means we are
      # testing something.
      buildVer = let state = self.rev or "DIRTY";
      in {
        system.configurationRevision = state;
        system.autoUpgrade.enable = state != "DIRTY";
      };

      buildShell = pkgs:
        pkgs.mkShell {
          shellHook = ''
            PS1='\u@\h:\w; '
            ( . ./common.sh; start ) || true;
          '';
          nativeBuildInputs = with pkgs; [
            deadnix
            git
            jq
            nil
            nix-diff
            nix-output-monitor
            shfmt
            sops
            ssh-to-age
            ssh-to-pgp
            statix
          ];
        };
      buildSys = sys: sysBase: extraMods: name:
        sysBase.lib.nixosSystem {
          system = sys;
          specialArgs = { inherit inputs; };
          modules = hostBase.modules ++ extraMods ++ [{
            nix = {
              registry.nixpkgs.flake = sysBase;
              registry.stable.flake = stable;
              registry.unstable.flake = unstable;
              nixPath = [ "nixpkgs=${sysBase}" ];
            };
          }] ++ [ buildVer (./. + "/hosts/${name}") ]
            ++ [{ nixpkgs.overlays = overlays; }];
        };
      pkgs = unstable.legacyPackages.x86_64-linux;
      darwinPkgs = unstableSmall.legacyPackages.aarch64-darwin;
    in {
      darwinConfigurations = {
        plq = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = [
            xin-secrets.nixosModules.sops
            (import "${sshKnownHosts}")
            ./overlays

            ./hosts/plq
          ];
        };
      };

      formatter.x86_64-linux = stable.legacyPackages.x86_64-linux.nixfmt;
      formatter.aarch64-darwin = stable.legacyPackages.aarch64-darwin.nixfmt;

      devShells.x86_64-linux.default = buildShell pkgs;
      devShells.aarch64-darwin.default = buildShell darwinPkgs;

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
        ] "h";
        #router =
        #  buildSys "x86_64-linux" stable [ ./configs/hardened.nix ] "router";

        weatherInstall = stable.lib.nixosSystem {
          system = "aarch64-linux";

          modules = [
            (import (./installer.nix))
            xin-secrets.nixosModules.sops
            (import "${sshKnownHosts}")

            "${stable}/nixos/modules/installer/sd-card/sd-image-aarch64-installer.nix"
          ];
        };
        reformInstall = oldStable.lib.nixosSystem {
          system = "aarch64-linux";

          modules = [
            reform.nixosModule
            (import (./installer.nix))
            xin-secrets.nixosModules.sops
            (import "${sshKnownHosts}")

            "${reform}/nixos/installer.nix"
          ];
        };

        isoInstall = stable.lib.nixosSystem {
          system = "x86_64-linux";

          modules = [
            buildVer
            (import (./installer.nix))
            xin-secrets.nixosModules.sops
            (import "${sshKnownHosts}")

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
          gqrss = pkgs.callPackage ./pkgs/gqrss.nix {
            inherit pkgs;
            isUnstable = true;
          };
          icbirc = pkgs.callPackage ./pkgs/icbirc.nix {
            inherit pkgs;
            isUnstable = true;
          };
          kurinto = pkgs.callPackage ./pkgs/kurinto.nix { };
          mcchunkie = pkgs.callPackage ./pkgs/mcchunkie.nix {
            inherit pkgs;
            isUnstable = true;
          };
          yarr = pkgs.callPackage ./pkgs/yarr.nix {
            inherit pkgs;
            isUnstable = true;
          };
          precursorupdater = pkgs.callPackage ./pkgs/precursorupdater.nix {
            inherit pkgs;
            inherit (pkgs.python39Packages) buildPythonPackage;
            inherit (pkgs.python39Packages) fetchPypi;
            inherit (pkgs.python39Packages) pyusb;
            inherit (pkgs.python39Packages) progressbar2;
            inherit (pkgs.python39Packages) requests;
          };
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
          rkvm = pkgs.callPackage ./pkgs/rkvm.nix { inherit pkgs; };
          inherit (xintray.packages.${system}) xintray;
          inherit (tsvnstat.packages.${system}) tsvnstat;
          inherit (pots.packages.${system}) pots;
          inherit (po.packages.${system}) po;
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

      # TODO: magicify this to be built of a list
      checks.x86_64-linux.europa =
        self.nixosConfigurations.europa.config.system.build.toplevel;
      checks.x86_64-linux.h =
        self.nixosConfigurations.h.config.system.build.toplevel;
      checks.x86_64-linux.box =
        self.nixosConfigurations.box.config.system.build.toplevel;
      checks.x86_64-linux.faf =
        self.nixosConfigurations.faf.config.system.build.toplevel;
    };
}
