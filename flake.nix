{
  description = "bold.daemon";

  inputs = {
    xin-secrets = {
      url = "git+ssh://xin-secrets-ro/qbit/xin-secrets.git?ref=main";
    };

    unstable.url = "github:NixOS/nixpkgs";
    unstableSmall.url = "github:NixOS/nixpkgs/nixos-unstable-small";

    stable.url = "github:NixOS/nixpkgs/nixos-22.05-small";

    nixos-hardware = { url = "github:NixOS/nixos-hardware/master"; };

    emacs-overlay = {
      url =
        "github:nix-community/emacs-overlay/08445dd7824253ee8580f06127460a7d14e942cf";
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

    microca = { url = "github:qbit/microca"; };
    taskobs = { url = "github:qbit/taskobs"; };

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
  };

  outputs = { self, unstable, unstableSmall, stable, nixos-hardware
    , sshKnownHosts, microca, taskobs, mcchunkie, gqrss, darwin, xin-secrets
    , peerix, ... }@flakes:
    let
      supportedSystems =
        [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
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
        flakes.emacs-overlay.overlay
        flakes.peerix.overlay
        flakes.microca.overlay
        flakes.taskobs.overlay
      ];

      buildVer = { system.configurationRevision = self.rev or "DIRTY"; };
      buildShell = pkgs:
        pkgs.mkShell {
          shellHook = ''
            PS1='\u@\h:\w; '
            ( . ./common.sh; start ) || true;
          '';
          nativeBuildInputs = with pkgs; [
            deadnix
            git
            go
            jq
            nix-diff
            shfmt
            sops
            ssh-to-age
            ssh-to-pgp
            statix
            tree
          ];
        };
      buildSys = sys: sysBase: extraMods: name:
        sysBase.lib.nixosSystem {
          system = sys;
          modules = hostBase.modules ++ extraMods ++ [{
            nix = {
              registry.nixpkgs.flake = sysBase;
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
          nixos-hardware.nixosModules.framework ] "europa";
        stan = buildSys "x86_64-linux" unstable [ ] "stan";
        weather = buildSys "aarch64-linux" unstable
          [ nixos-hardware.nixosModules.raspberry-pi-4 ] "weather";

        faf = buildSys "x86_64-linux" stable [ ./configs/hardened.nix ] "faf";
        box = buildSys "x86_64-linux" stable [ ./configs/hardened.nix ] "box";
        luna = buildSys "x86_64-linux" stable
          [ "${nixos-hardware}/common/cpu/intel" ] "luna";
        h =
          buildSys "x86_64-linux" unstableSmall [ ./configs/hardened.nix ] "h";
        router =
          buildSys "x86_64-linux" stable [ ./configs/hardened.nix ] "router";

        weatherInstall = unstable.lib.nixosSystem {
          system = "aarch64-linux";

          modules = [
            (import (./installer.nix))
            xin-secrets.nixosModules.sops
            (import "${sshKnownHosts}")

            "${stable}/nixos/modules/installer/sd-card/sd-image-aarch64-installer.nix"
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
          mcchunkie = pkgs.callPackage ./pkgs/mcchunkie.nix {
            inherit pkgs;
            isUnstable = true;
          };
          yarr = pkgs.callPackage ./pkgs/yarr.nix {
            inherit pkgs;
            isUnstable = true;
          };
          gosignify = pkgs.callPackage ./pkgs/gosignify.nix { inherit pkgs; };
          zutty = pkgs.callPackage ./pkgs/zutty.nix {
            inherit pkgs;
            isUnstable = true;
          };
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
    };
}
