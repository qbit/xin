{ ... }: {
  imports = [
    ./golink.nix
    ./gotosocial.nix
    ./lock-action.nix
    ./rtlamr2mqtt.nix
    ./sliding-sync.nix
    ./ssh-fido-agent.nix
    ./ts-reverse-proxy.nix
    ./tsvnstat.nix
    ./veilid-server.nix
    ./wallabag.nix
    ./yarr.nix
  ];
}
