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
      url = "github:nix-community/emacs-overlay";
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
    , sshKnownHosts, microca, mcchunkie, gqrss, darwin, xin-secrets, peerix, ...
    }@flakes:
    let
      hostBase = {
        overlays = [
          flakes.emacs-overlay.overlay
          flakes.peerix.overlay
          flakes.microca.overlay

        ];
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
      ];

      buildVer = { system.configurationRevision = self.rev or "DIRTY"; };
      buildShell = pkgs:
        pkgs.mkShell {
          shellHook = ''
            PS1='\u@\h:\w; '
            ( . ./common.sh; start )
          '';
          nativeBuildInputs = with pkgs; [
            git
            go
            jq
            nix-diff
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
        box = buildSys "x86_64-linux" stable [ ] "box";
        europa = buildSys "x86_64-linux" unstable [ ] "europa";
        faf = buildSys "x86_64-linux" stable [ ] "faf";
        hass = buildSys "x86_64-linux" stable
          [ "${nixos-hardware}/common/cpu/intel" ] "hass";
        luna = buildSys "x86_64-linux" stable
          [ "${nixos-hardware}/common/cpu/intel" ] "luna";
        h = buildSys "x86_64-linux" unstableSmall [ ] "h";
        stan = buildSys "x86_64-linux" unstable
          [ nixos-hardware.nixosModules.framework ] "stan";
        weather = buildSys "aarch64-linux" stable
          [ nixos-hardware.nixosModules.raspberry-pi-4 ] "weather";

        weatherInstall = stable.lib.nixosSystem {
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

      templates."go" = {
        path = ./templates/go;
        description = "Go template.";
      };
    };
}
