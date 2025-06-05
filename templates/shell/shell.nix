{
  pkgs ? import <nixpkgs> { },
}:
pkgs.mkShell {
  shellHook = ''
    PS1='\u@\h:\w; '
  '';
  buildInputs = with pkgs; [
  ];
}
