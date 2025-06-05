{ perl }:
''
  #!${perl}/bin/perl

  use strict;
  use warnings;

  use feature 'say';

  my @booted = split("/", `readlink -f /run/booted-system/kernel`);
  my @current = split("/", `readlink -f /run/current-system/kernel`);

  if ($booted[3] ne $current[3]) {
  	say "Restart required!";
  	say "old: $booted[3]";
  	say "new: $current[3]";
        exit 1;
  } else {
  	say "system is clean..";
  }
''
