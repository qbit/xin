{
  perl,
  perlPackages,
  ...
}: ''
  #!${perl}/bin/perl

  use strict;
  use warnings;
  use Data::Dumper;

  use lib "${perlPackages.JSON}/${perl.libPrefix}/${perl.version}/";
  use JSON qw{ decode_json encode_json };

  my $info = decode_json(`nixos-version --json`);
  $info->{needs_restart} = system('check-restart >/dev/null') == 0 ? JSON::false : JSON::true;
  print encode_json $info;
''
