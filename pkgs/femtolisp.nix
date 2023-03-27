{
  stdenv
  , lib
  , fetchgit
  , gnumake
}:

stdenv.mkDerivation {
  pname = "femtolisp";
  version = "2023-03-27";

  src = fetchgit {
    url = "https://git.sr.ht/~ft/femtolisp";
    rev = "52b98fac634a4bdd7cbc0154dcfad639013ed198";
    hash = "sha256-mh7upbCmWXLhudtaaebBf1XTIv4nYPSh0OAJDOqaQnk=";
  };

  buildInputs = [
    gnumake
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp flisp $out/bin
  '';

  meta = {
    description = "A compact interpreter for a minimal lisp/scheme dialect.";
    homepage = "https://git.sr.ht/~ft/femtolisp";
    license = lib.licenses.bsd3;
    maintainer = with lib.maintainers; [ qbit ];
  };
}
