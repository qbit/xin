{ ... }: {
  imports = [
    ./backup.nix
    ./golink.nix
    ./gotosocial.nix
    ./lock-action.nix
    ./rtlamr2mqtt.nix
    ./sliding-sync.nix
    ./ssh-fido-agent.nix
    ./tsvnstat.nix
    ./veilid-server.nix
    ./yarr.nix
  ];
}
