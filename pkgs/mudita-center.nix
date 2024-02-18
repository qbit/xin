{
  fetchurl,
  appimageTools,
  desktop-file-utils,
  ...
}:
let
  name = "mudita-center";
  version = "1.3.0";

  src = fetchurl {
    name = "mudita-center.AppImage";
    url = "https://github.com/mudita/mudita-center/releases/download/${version}/Mudita-Center.AppImage";
    sha256 = "1cqrrs5ycl5lrla8mprx443dpiz99a63f4i3da43vxh1xxl0ki4n";
  };

  appimageContents = appimageTools.extract { inherit name src; };
in
appimageTools.wrapType1 rec {
  inherit name src;

  extraInstallCommands = ''
    cp -r ${appimageContents}/* $out
    cd $out
    chmod -R +w $out

    mv "Mudita Center" $out/${name}

    # TODO:
    #${desktop-file-utils}/bin/desktop-file-install --dir $out/share/applications \
    #  --set-key Exec --set-value ${name} "Mudita Center.desktop"

    mv usr/share/icons share

    rm usr/lib/* AppRun *.desktop
  '';

  #extraPkgs = pkgs: with pkgs; [ ];
}
