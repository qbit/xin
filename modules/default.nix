{ ... }:
{
  imports = [
    ./backup.nix
    ./golink.nix
    ./lock-action.nix
    ./signal-cli.nix
    ./ssh-fido-agent.nix
    ./tsvnstat.nix
    ./veilid-server.nix
    ./yarr.nix
  ];
}
