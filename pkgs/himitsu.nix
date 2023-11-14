{ lib
, stdenv
, fetchgit
, fetchFromSourcehut
, binutils-unwrapped
, makeWrapper
  #, qbe # We use harec's override of qbe until 1.2 is released
, qbe
, scdoc
, ...
}:

let
  qbe' = qbe.overrideAttrs (_old: {
    version = "1.1-unstable-2023-08-18";
    src = fetchgit {
      url = "git://c9x.me/qbe.git";
      rev = "36946a5142c40b733d25ea5ca469f7949ee03439";
      hash = "sha256-bqxWFP3/aw7kRoD6ictbFcjzijktHvh4AgWAXBIODW8=";
    };
  });
  harec' = stdenv.mkDerivation (_: {
    pname = "harec";
    version = "unstable-2023-10-22";

    src = fetchFromSourcehut {
      owner = "~sircmpwn";
      repo = "harec";
      rev = "64dea196ce040fbf3417e1b4fb11331688672aca";
      hash = "sha256-2Aeb+OZ/hYUyyxx6aTw+Oxiac+p+SClxtg0h68ZBSHc=";
    };

    nativeBuildInputs = [
      qbe'
    ];

    buildInputs = [
      qbe'
    ];

    strictDeps = true;
    enableParallelBuilding = true;

    doCheck = true;

    passthru = {
      # We create this attribute so that the `hare` package can access the
      # overwritten `qbe`.
      qbeUnstable = qbe';
    };

    meta = {
      homepage = "http://harelang.org/";
      description = "Bootstrapping Hare compiler written in C for POSIX systems";
      license = lib.licenses.gpl3Only;
      maintainers = with lib.maintainers; [ onemoresuza ];
      # The upstream developers do not like proprietary operating systems; see
      # https://harelang.org/platforms/
      # UPDATE: https://github.com/hshq/harelang provides a MacOS port
      platforms = with lib.platforms;
        lib.intersectLists (freebsd ++ linux) (aarch64 ++ x86_64 ++ riscv64);
      badPlatforms = lib.platforms.darwin;
    };
  });

  hare' = stdenv.mkDerivation (_: {
    pname = "hare";
    version = "unstable-2023-10-23";

    src = fetchFromSourcehut {
      owner = "~sircmpwn";
      repo = "hare";
      rev = "1048620a7a25134db370bf24736efff1ffcb2483";
      hash = "sha256-slQPIhrcM+KAVAvjuRnqNdEAEr4Xa4iQNVEpI7Wl+Ks=";
    };

    nativeBuildInputs = [
      binutils-unwrapped
      harec'
      makeWrapper
      qbe'
      scdoc
    ];

    buildInputs = [
      binutils-unwrapped
      harec'
      qbe'
    ];

    strictDeps = true;
    enableParallelBuilding = true;

    # Append the distribution name to the version
    env.LOCALVER = "nix";

    configurePhase =
      let
        # https://harelang.org/platforms/
        arch =
          if stdenv.isx86_64 then "x86_64"
          else if stdenv.isAarch64 then "aarch64"
          else if stdenv.hostPlatform.isRiscV && stdenv.is64bit then "riscv64"
          else "unsupported";
        platform =
          if stdenv.isLinux then "linux"
          else if stdenv.isFreeBSD then "freebsd"
          else "unsupported";
      in
      ''
        runHook preConfigure

        cp config.example.mk config.mk
        makeFlagsArray+=(
          PREFIX="${builtins.placeholder "out"}"
          HARECACHE="$(mktemp -d --tmpdir harecache.XXXXXXXX)"
          BINOUT="$(mktemp -d --tmpdir bin.XXXXXXXX)"
          PLATFORM="${platform}"
          ARCH="${arch}"
        )

        runHook postConfigure
      '';

    doCheck = true;

    postFixup =
      let
        binPath = lib.makeBinPath [
          binutils-unwrapped
          harec'
          qbe'
        ];
      in
      ''
        wrapProgram $out/bin/hare --prefix PATH : ${binPath}
      '';

    setupHook = ./setup-hook.sh;

    meta = {
      homepage = "http://harelang.org/";
      description =
        "A systems programming language designed to be simple, stable, and robust";
      license = lib.licenses.gpl3Only;
      maintainers = with lib.maintainers; [ onemoresuza ];
      inherit (harec'.meta) platforms badPlatforms;
    };
  });
in
stdenv.mkDerivation rec {
  pname = "himitsu";
  version = "0.4";

  src = fetchFromSourcehut {
    name = pname + "-src";
    owner = "~sircmpwn";
    repo = pname;
    rev = version;
    hash = "sha256-Y2QSzYfG1F9Z8MjeVvQ3+Snff+nqSjeK6VNzRaRDLYo=";
  };

  nativeBuildInputs = [
    hare'
    scdoc
  ];

  preConfigure = ''
    export HARECACHE=$(mktemp -d)
  '';

  installFlags = [ "PREFIX=" "DESTDIR=$(out)" ];

  meta = with lib; {
    homepage = "https://himitsustore.org/";
    description = "A secret storage manager";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ auchter ];
    inherit (hare'.meta) platforms badPlatforms;
  };
}
