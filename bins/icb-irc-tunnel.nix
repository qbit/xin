{
  pkgs,
  icbirc,
}:
''
  #!${pkgs.yash}/bin/yash
  ${pkgs.procps}/bin/pkill icbirc

  # porters
  ${icbirc}/bin/icbirc -d -l 127.0.0.1 -s localhost -p 6644 >/tmp/icbirc-porters &

  # hackers
  ${icbirc}/bin/icbirc -d -l 127.0.0.1 -s localhost -p 6645 >/tmp/icbirc-hackers &

  ${pkgs.openssh}/bin/ssh -NTL 7326:localhost:7326 \
    -oServerAliveInterval=60 \
    -oExitOnForwardFailure=yes \
    anonicb@slackers.openbsd.org
''
