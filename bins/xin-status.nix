{ perl
, perlPackages
, ...
}: ''
  #!${perl}/bin/perl

  use strict;
  use warnings;
  use MIME::Base64;

  use lib "${perlPackages.JSON}/${perl.libPrefix}/${perl.version}/";
  use JSON qw{ decode_json encode_json };

  my $info = decode_json(`nixos-version --json`);
  $info->{needs_restart} = system('check-restart >/dev/null') == 0 ? JSON::false : JSON::true;
  my $sys_diff = `nix store diff-closures /run/booted-system /run/current-system`;
  $sys_diff =~ s/\e\[[0-9;]*m(?:\e\[K)?//g;

  $info->{system_diff} = encode_base64($sys_diff);
  $info->{uname_a} = `uname -a`;
  chomp $info->{uname_a};

  print encode_json $info;
''
