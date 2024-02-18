{ pkgs }:
let
  oathPkg = pkgs.oath-toolkit or pkgs.oathToolkit;
  wlclip = if pkgs.system == "aarch64-darwin" then "" else "${pkgs.wl-clipboard}/bin/wl-copy";
  xclip = if pkgs.system == "aarch64-darwin" then "pbcopy" else "${pkgs.xclip}/bin/xclip";
in
''
  #!${pkgs.yash}/bin/yash

  set -e

  rage_dir=~/.rage

  . ''${rage_dir}/config

  cmd=$1

  list() {
      find $rage_dir -type f -name \*.age
  }

  if [ -z $cmd ]; then
      list
      exit
  fi

  case $cmd in
      ls)
              list
              ;;
      re)
              F=""
              if [ -f $2 ]; then
                      F=$2
              else
                      F=$(list | grep $2)
              fi

              echo "Re-encrypting: '$F'"
              pass="$(${pkgs.age}/bin/age -i $identity -d "$F")"
              echo "$pass" | ${pkgs.age}/bin/age -a -R "$recipients" > "$F"
              ;;
      en)
              printf 'Password: '
              stty -echo
              read pass
              stty echo
              echo ""
              printf 'Location: '
              read loc
              echo ""
              mkdir -p "$(dirname ~/.rage/$loc)"
              echo "$pass" | ${pkgs.age}/bin/age -a -R "$recipients" > ~/.rage/''${loc}.age
              ;;
      de)
              if [ -f $2 ]; then
                      ${pkgs.age}/bin/age -i $identity -d $2
              else
                      F=$(list | grep $2)
                      ${pkgs.age}/bin/age -i $identity -d "$F"
              fi
              ;;
      cp)
              CLIP=${xclip}
              if [ ! -z $WAYLAND_DISPLAY ]; then
                CLIP=${wlclip}
              fi

              if [ -f $2 ]; then
                      ${pkgs.age}/bin/age -i $identity -d $2 | $CLIP
              else
                      F=$(list | grep $2)
                      ${pkgs.age}/bin/age -i $identity -d "$F" | $CLIP
              fi
              ;;
      otp)
              if [ -f $2 ]; then
                      ${pkgs.age}/bin/age -i $identity -d $2 | ${oathPkg}/bin/oathtool -b --totp -
              else
                      F=$(list | grep $2)
                      ${pkgs.age}/bin/age -i $identity -d "$F" | ${oathPkg}/bin/oathtool -b --totp -
              fi
              ;;
      push)
              cd $rage_dir
              ${pkgs.git}/bin/git push
              ;;
      sync)
              cd $rage_dir
              ${pkgs.git-sync}/bin/git-sync
              ;;
      default)
              list
  esac
''
