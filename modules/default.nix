{ ... }: {
  imports = [
    ./golink.nix
    ./gotosocial.nix
    ./nomadnet.nix
    ./rnsd.nix
    ./rtlamr2mqtt.nix
    ./sliding-sync.nix
    ./ssh-fido-agent.nix
    ./ts-rev-prox.nix
    ./tsvnstat.nix
    ./veilid-server.nix
    ./wallabag.nix
    ./yarr.nix
  ];
}
