{ pkgs, ... }:
let
  tmuxFormat = pkgs.formats.yaml { };
in
{
  config = {
    programs.zsh.promptInit = ''
      alias tstart='smug -f /etc/smug/main.yml start';
      alias cistart='smug -f /etc/smug/ci.yml start';
    '';
    environment = {
      systemPackages = with pkgs; [
        smug
      ];
      etc."smug/ci.yml".text = builtins.readFile (tmuxFormat.generate "ci.yml" {
        session = "CI";
        root = "~/";
        windows = [
          {
            name = "CI Status";
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
        ];
      });
      etc."smug/main.yml".text = builtins.readFile (tmuxFormat.generate "main.yml" {
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
                commands = [ "mosh pwntie 'smug -f /etc/smug/ci.yml start'" ];
              }
            ];
          }
          {
            name = "Barrier";
            commands = [
              "barriers -a 127.0.0.1 -f --disable-crypto"
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
      });
    };
  };
}
