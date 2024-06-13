{ lib
, buildPythonPackage
, fetchFromGitHub
, matplotlib
, folium
, datetime
, gpsbabel
, ...
}:
buildPythonPackage {
  pname = "watchmap";
  version = "2021-05-16";

  pyproject = false;
  doBuild = false;

  propagatedBuildInputs = [
    folium
    matplotlib
    datetime
    gpsbabel
  ];

  src = fetchFromGitHub {
    owner = "bunnie";
    repo = "watchmap";
    hash = "sha256-WSFUVn3SB7WS8hiJxlZSWXLnx2K7gJAufYGmvvC5PBQ=";
    rev = "5bab6e5107554bc76a51ccd6b5190764a0633097";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp plot.py $out/bin/watchmap
  '';

  meta = with lib; {
    description = "Tool to convert Garmin .fit files to a web map";
    homepage = "https://github.com/bunnie/watchmap/";
    license = licenses.gpl3;
    maintainers = [ maintainers.qbit ];
  };
}
