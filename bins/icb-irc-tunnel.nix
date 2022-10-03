{ pkgs, icbirc }:

''
  #!${pkgs.yash}/bin/yash
  ${pkgs.procps}/bin/pkill icbirc

  ${icbirc}/bin/icbirc -l 127.0.0.1 -s localhost -p 6644
  ${icbirc}/bin/icbirc -l 127.0.0.1 -s localhost -p 6645

  tname="IRC"
  if !tmux ls | grep -q "^''${tname}:"; then
    tmux -2 new-session -d -s "''${tname}" 'weechat'
    tmux -s "''${tname}" splitw -dv -b -h -l 30% 'ssh anonicb@slackers.openbsd.org'
  fi

  ${pkgs.openssh}/bin/ssh -NTL 7326:localhost:7326 \
    -oServerAliveInterval=60 \
    -oExitOnForwardFailure=yes \
    anonicb@slackers.openbsd.org
''
