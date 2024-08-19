{ lib, pkgs, ... }:
let
  inherit (lib) mkMerge;
  tmuxFormat = pkgs.formats.yaml { };
  mkSmugEntry = name: cfg:
    {
      environment = {
        systemPackages = [
          (pkgs.writeScriptBin name ''
            ${pkgs.smug}/bin/smug -f /etc/smug/${name}.yml start
          '')
        ];
        etc."smug/${name}.yml".text = builtins.readFile
          (tmuxFormat.generate "${name}.yml" cfg);
      };
    };
in
{
  config = mkMerge [
    (mkSmugEntry "work"
      {
        session = "Work";
        root = "~/";
        before_start = [
          "ssh-add"
        ];
        windows = [
          {
            name = "VM";
            layout = "even-vertical";
            commands = [
              "ssh vm"
            ];
          }
          {
            name = "aef100";
            root = "~/aef100";
          }
        ];
      })
    (mkSmugEntry "cistart"
      {
        session = "CI";
        root = "~/";
        windows = [
          {
            name = "Status";
            layout = "even-vertical";
            commands = [
              "journalctl -xef -u xin-ci-update.service"
            ];
            panes = [
              {
                type = "even-vertical";
                commands = [ "journalctl -xef -u xin-ci.service" ];
              }
            ];
          }
          {
            name = "btop";
            commands = [
              "btop"
            ];
          }
          {
            name = "nix-binary-cache";
            commands = [
              "journalctl -xef -u nix-binary-cache.service"
            ];
          }
          {
            name = "admin";
          }
        ];
      })
    (mkSmugEntry "tstart"
      {
        session = "Main";
        root = "~/";
        before_start = [
          "ssh-add"
        ];
        windows = [
          {
            name = "Status";
            commands = [
              "while true; do ssh -4 anonicb@slackers.openbsd.org; sleep 300; done"
            ];
            panes = [
              {
                commands = [ "mosh pwntie cistart" ];
              }
            ];
          }
          {
            name = "KVM";
            commands = [
              "journalctl -xef -u rkvm-server"
            ];
            panes = [
              {
                commands = [ "ssh stan" ];
              }
            ];
          }
          {
            name = "Xin";
            root = "src/xin";
          }
          {
            name = "Lab";
            root = "src/biltong";
          }
          {
            name = "NixPkgs";
            root = "src/nixpkgs";
          }
          {
            name = "NomadNet";
            root = "reticulum";
          }
        ];
      })
  ];
}
