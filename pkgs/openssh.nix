{ autoreconfHook
, etcDir ? "/etc/ssh"
, fetchFromGitHub
, hostname
, lib
, libedit
, libfido2
, libredirect
, libressl
, pkg-config
, stdenv
, zlib
, ...
}:
let
  inherit (builtins) readFile fromJSON;
  verStr = fromJSON (readFile ./openssh/version.json);
in
stdenv.mkDerivation {
  pname = "openssh";
  inherit (verStr) version;

  src = fetchFromGitHub {
    inherit (verStr) rev hash;
    owner = "openssh";
    repo = "openssh-portable";
  };

  patches =
    [
      ./openssh/locale_archive.patch
      ./openssh/ssh-keysign-8.5.patch

      # See discussion in https://github.com/NixOS/nixpkgs/pull/16966
      ./openssh/dont_create_privsep_path.patch
    ];

  postPatch =
    # On Hydra this makes installation fail (sometimes?),
    # and nix store doesn't allow such fancy permission bits anyway.
    ''
      substituteInPlace Makefile.in --replace '$(INSTALL) -m 4711' '$(INSTALL) -m 0711'
    '';

  strictDeps = true;
  nativeBuildInputs =
    [ autoreconfHook pkg-config ];
  buildInputs =
    [ zlib libedit libfido2 ];

  preConfigure = ''
    # Setting LD causes `configure' and `make' to disagree about which linker
    # to use: `configure' wants `gcc', but `make' wants `ld'.
    unset LD
  '';

  # I set --disable-strip because later we strip anyway. And it fails to strip
  # properly when cross building.
  configureFlags =
    [
      "--sbindir=\${out}/bin"
      "--localstatedir=/var"
      "--with-pid-dir=/run"
      "--with-mantype=man"
      "--with-libedit=yes"
      "--disable-strip"
      "--disable-dsa-keys"
      "--with-security-key-builtin=yes"
    ]
    ++ lib.optional (etcDir != null) "--sysconfdir=${etcDir}"
    ++ lib.optional stdenv.isDarwin "--disable-libutil";

  ${
  if stdenv.hostPlatform.isStatic then
    "NIX_LDFLAGS"
  else
    null
  } = [ "-laudit" ];

  buildFlags = [ "SSH_KEYSIGN=ssh-keysign" ];

  enableParallelBuilding = true;

  hardeningEnable = [ "pie" ];

  enableParallelChecking = false;
  nativeCheckInputs = [ libressl ] ++ lib.optional (!stdenv.isDarwin) hostname;
  preCheck = lib.optionalString (stdenv.hostPlatform == stdenv.buildPlatform) ''
    # construct a dummy HOME
    export HOME=$(realpath ../dummy-home)
    mkdir -p ~/.ssh

    # construct a dummy /etc/passwd file for the sshd under test
    # to use to look up the connecting user
    DUMMY_PASSWD=$(realpath ../dummy-passwd)
    cat > $DUMMY_PASSWD <<EOF
    $(whoami)::$(id -u):$(id -g)::$HOME:$SHELL
    EOF

    # we need to NIX_REDIRECTS /etc/passwd both for processes
    # invoked directly and those invoked by the "remote" session
    cat > ~/.ssh/environment.base <<EOF
    NIX_REDIRECTS=/etc/passwd=$DUMMY_PASSWD
    LD_PRELOAD=${libredirect}/lib/libredirect.so
    EOF

    # use an ssh environment file to ensure environment is set
    # up appropriately for build environment even when no shell
    # is invoked by the ssh session. otherwise the PATH will
    # only contain default unix paths like /bin which we don't
    # have in our build environment
    cat - regress/test-exec.sh > regress/test-exec.sh.new <<EOF
    cp $HOME/.ssh/environment.base $HOME/.ssh/environment
    echo "PATH=\$PATH" >> $HOME/.ssh/environment
    EOF
    mv regress/test-exec.sh.new regress/test-exec.sh

    # explicitly enable the PermitUserEnvironment feature
    substituteInPlace regress/test-exec.sh \
      --replace \
        'cat << EOF > $OBJ/sshd_config' \
        $'cat << EOF > $OBJ/sshd_config\n\tPermitUserEnvironment yes'

    # some tests want to use files under /bin as example files
    for f in regress/sftp-cmds.sh regress/forwarding.sh; do
      substituteInPlace $f --replace '/bin' "$(dirname $(type -p ls))"
    done

    # set up NIX_REDIRECTS for direct invocations
    set -a; source ~/.ssh/environment.base; set +a
  '';

  checkTarget = [ "t-exec" "unit" "file-tests" "interop-tests" ];

  installTargets = [ "install-nokeys" ];
  installFlags = [
    "sysconfdir=\${out}${etcDir}"
  ];

  meta = with lib; {
    description = "An implementation of the SSH protocol";
    homepage = "https://www.openssh.com/";
    changelog = "https://www.openssh.com/releasenotes.html";
    license = licenses.bsd2;
    platforms = platforms.unix ++ platforms.windows;
    maintainers = with maintainers; [ qbit ];
    mainProgram = "ssh";
  };
}
