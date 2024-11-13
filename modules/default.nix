{ ... }: {
  imports = [
    ./backup.nix
    ./golink.nix
    ./gotosocial.nix
    ./lock-action.nix
    ./rtlamr2mqtt.nix
    ./ssh-fido-agent.nix
    ./tsvnstat.nix
    ./veilid-server.nix
    ./yarr.nix
  ];
}
