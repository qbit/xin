{
  writeShellApplication,
  diffutils,
  findutils,
  coreutils,
  ...
}:
let
  genPatches = writeShellApplication {
    name = "gen-patches";
    runtimeInputs = [
      diffutils
      findutils
      coreutils
    ];
    text = ''
      suffix=".orig"
      srcdir=$PWD
      output="$PWD/patches"

      usage() {
        echo "Usage: $0 [-s suffix (default .orig)] [-d source directory (default PWD)] [-o output directory (default PWD/patches)]" 1>&2;
        exit 1;
      }

      while getopts "d:ho:s:" arg; do
        case $arg in
          d)
            srcdir=$OPTARG
            ;;
          h)
            usage
            ;;
          s)
            suffix=$OPTARG
            ;;
          o)
            output=$OPTARG
            ;;
          *)
            usage
        esac
      done

      mkdir -p "$output"

      # hold my be er!
      # shellcheck disable=SC2044
      for patch in $(find "$srcdir" -name "*$suffix"); do
        fname=$(basename "$patch" "$suffix")
        dname=$(dirname "$patch")
        file="$dname/$fname"
        outfile="$(echo "$dname/$fname" | sed 's;/;_;g').diff"
        diff -u "$patch" "$file" > "$output/$outfile" || \
          echo "==> Created patch: $output/$outfile"
      done
    '';
  };
in
genPatches
