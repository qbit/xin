{ lib
, fetchFromGitHub
, buildPythonPackage
#, fetchPypi
#, setuptools-scm
, mistune
#, alembic
#, banal
#, sqlalchemy
, ...
}:
buildPythonPackage rec {
  pname = "md2mu";
  version = "unstable-2023-05-16";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "randogoth";
    repo = pname;
    rev = "baf662b97fde0b2456fb3da725f1caf14882d60e";
    hash = "sha256-93fr1EV4UfRPq1MQSffoHtLvTYFQeaqHQ+BtsTlH8Ec=";
  };

  doCheck = true;

  #nativeBuildInputs = [ setuptools-scm ];

  propagatedBuildInputs = [ mistune ];

  meta = with lib; {
    homepage = "https://github.com/randogoth/md2mu";
    description = "Markdown to micron converter";
    license = licenses.mit;
    maintainers = with maintainers; [ qbit ];
  };
}
