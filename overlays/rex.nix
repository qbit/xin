let
  rex = _: super: {
    rex = super.rex.overrideAttrs (_: {
      postPatch = ''
        patchShebangs bin
      '';
    });
  };
in
  rex
