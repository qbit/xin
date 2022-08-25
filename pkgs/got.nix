{ lib, stdenv, fetchpatch, fetchgit, bison, pkg-config, libressl, libbsd
, libuuid, libmd, zlib, ncurses, isUnstable, openssh, autoreconfHook
, sshKeyGenPath ? "/run/current-system/sw/bin/ssh-keygen" }:

stdenv.mkDerivation rec {
  pname = "got";
  rev = "a8fa2ba8469e013475c403304989843b7fc17ae8";
  version = "0.74";

  src = fetchgit {
    inherit rev;

    url = "git://git.gameoftrees.org/got-portable.git";
    sha256 = "sha256-oQofGknpCyRFyNuUZYpLcZ57JCl04wuaxM1RpIXp1LE=";
  };

  patches = [
    (fetchpatch {
      url = "http://sprunge.us/sEDCV2";
      sha256 = "sha256-oondY/IMU6YMnx5+lIGpN43/tQ/tkCarmveMykQc24c=";
    })
  ];

  nativeBuildInputs = [ pkg-config libressl libbsd libmd zlib autoreconfHook ];

  buildInputs = [ bison libressl libbsd libuuid libmd zlib ncurses ];

  CFLAGS = ''-DGOT_TAG_PATH_SSH_KEYGEN=\"${sshKeyGenPath}\"'';

  doInstallCheck = true;

  installCheckPhase = ''
    runHook preInstallCheck
    test "$($out/bin/got --version)" = '${pname} ${version}'
    runHook postInstallCheck
  '';

  meta = with lib; {
    description =
      "A version control system which prioritizes ease of use and simplicity over flexibility";
    longDescription = ''
      Game of Trees (Got) is a version control system which prioritizes
      ease of use and simplicity over flexibility.

      Got uses Git repositories to store versioned data. Git can be used
      for any functionality which has not yet been implemented in
      Got. It will always remain possible to work with both Got and Git
      on the same repository.
    '';
    homepage = "https://gameoftrees.org";
    license = licenses.isc;
    platforms = platforms.linux;
    maintainers = with maintainers; [ qbit ];
  };
}

